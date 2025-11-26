import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'driver_app.dart';
import 'services/notification_service.dart';

/// Entry point for Driver App
/// Run with: flutter run -t lib/driver_main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService().initialize();
  
  // Set orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  
  runApp(const DriverApp());
}

