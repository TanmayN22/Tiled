import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class ImageViewer extends StatelessWidget {
  final AssetEntity asset;

  const ImageViewer({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    // InteractiveViewer allows the user to pinch-to-zoom and pan the image.
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0, // Allow zooming up to 4x
      child: AssetEntityImage(
        asset,
        isOriginal: true, // Load the full, high-quality image
        fit: BoxFit.contain, // Ensure the entire image is visible
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error, color: Colors.red));
        },
      ),
    );
  }
}