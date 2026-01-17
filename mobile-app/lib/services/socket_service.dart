import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/app_config.dart';

class SocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;
  
  // Callbacks for order events
  static Function(Map<String, dynamic>)? onNewOrder;
  static Function(Map<String, dynamic>)? onOrderUpdate;
  
  /// Initialize Socket.IO connection
  static Future<void> connect() async {
    if (_socket != null && _isConnected) {
      print('🔌 Socket already connected');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) {
        print('❌ No access token found, cannot connect to Socket.IO');
        return;
      }

      // Get base URL without /api prefix
      final baseUrl = AppConfig.baseUrl.replaceAll('/api', '');
      
      print('🔌 Connecting to Socket.IO: $baseUrl');
      
      _socket = IO.io(baseUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {
          'token': token,
        },
        // ULTRA-ECO MODE: Minimal heartbeat to save data
        'pingInterval': 120000, // 2 minutes (default is 25 seconds)
        'pingTimeout': 60000,   // 1 minute timeout
        'reconnection': true,
        'reconnectionDelay': 5000,
      });

      // Connection events
      _socket!.onConnect((_) {
        _isConnected = true;
        print('✅ Socket.IO connected');
        _registerUser();
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        print('❌ Socket.IO disconnected');
      });

      _socket!.onConnectError((error) {
        print('❌ Socket.IO connection error: $error');
      });

      _socket!.onError((error) {
        print('❌ Socket.IO error: $error');
      });

      // Order events
      _socket!.on('order:new', (data) {
        print('📲 New order received: $data');
        if (onNewOrder != null) {
          onNewOrder!(data as Map<String, dynamic>);
        }
      });

      _socket!.on('order:update', (data) {
        print('📲 Order update received: $data');
        if (onOrderUpdate != null) {
          onOrderUpdate!(data as Map<String, dynamic>);
        }
      });

      // Driver registration confirmation
      _socket!.on('driver:registered', (data) {
        print('✅ Driver registered on Socket.IO: $data');
      });

      // Customer registration confirmation
      _socket!.on('customer:registered', (data) {
        print('✅ Customer registered on Socket.IO: $data');
      });

      // Connect
      _socket!.connect();
    } catch (e) {
      print('❌ Error connecting to Socket.IO: $e');
    }
  }

  /// Register user (driver or customer) with Socket.IO
  static Future<void> _registerUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('user_type');
    
    if (userType == 'driver') {
      final driverId = prefs.getString('driver_id');
      if (driverId != null) {
        emit('driver:register', {'driverId': driverId});
        print('🚗 Registering driver: $driverId');
      }
    } else if (userType == 'customer') {
      final customerId = prefs.getString('customer_id');
      if (customerId != null) {
        emit('customer:register', {'customerId': customerId});
        print('👤 Registering customer: $customerId');
      }
    }
  }

  /// Emit event to server
  static void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
    } else {
      print('⚠️ Socket not connected, cannot emit event: $event');
    }
  }

  /// Update driver location
  static void updateDriverLocation(double latitude, double longitude) {
    emit('driver:location', {
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  /// Update driver status (available/unavailable)
  static void updateDriverStatus(bool isAvailable) {
    emit('driver:status', {
      'isAvailable': isAvailable,
    });
  }

  /// Disconnect from Socket.IO
  static void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
      print('🔌 Socket.IO disconnected');
    }
  }

  /// Check if connected
  static bool get isConnected => _isConnected;

  /// Get socket instance
  static IO.Socket? get socket => _socket;
}
