import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageCompressionService {
  /// Compress image to reduce file size while maintaining quality
  /// 
  /// Industry standard compression:
  /// - Max resolution: 1024x1024
  /// - Quality: 85%
  /// - Format: JPEG
  /// - Expected size: 200-500KB
  static Future<File?> compressImage(File imageFile) async {
    try {
      // Get file extension
      final String ext = path.extension(imageFile.path).toLowerCase();
      
      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.webp',
      );

      // Compress image
      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 80, // High quality but small size
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.webp, // Convert to WebP as requested
      );

      if (compressedFile == null) {
        print('❌ Image compression failed');
        return null;
      }

      final File compressed = File(compressedFile.path);
      
      // Log compression results
      final int originalSize = await imageFile.length();
      final int compressedSize = await compressed.length();
      final double compressionRatio = (1 - (compressedSize / originalSize)) * 100;
      
      print('✅ Image compressed successfully');
      print('📊 Original size: ${(originalSize / 1024).toStringAsFixed(2)} KB');
      print('📊 Compressed size: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
      print('📊 Compression ratio: ${compressionRatio.toStringAsFixed(1)}%');

      return compressed;
    } catch (e) {
      print('❌ Error compressing image: $e');
      return null;
    }
  }

  /// Compress multiple images
  static Future<List<File>> compressMultipleImages(List<File> images) async {
    final List<File> compressedImages = [];
    
    for (final image in images) {
      final compressed = await compressImage(image);
      if (compressed != null) {
        compressedImages.add(compressed);
      }
    }
    
    return compressedImages;
  }

  /// Check if image needs compression
  static Future<bool> needsCompression(File imageFile) async {
    final int fileSize = await imageFile.length();
    // If file is larger than 500KB, compress it
    return fileSize > 500 * 1024;
  }
}
