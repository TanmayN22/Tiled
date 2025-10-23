import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'image_viewer.dart';
import 'video_viewer.dart';

/// A widget that intelligently displays either an image or a video player
/// based on the provided [AssetEntity].
class MediaViewerPage extends StatelessWidget {
  final AssetEntity asset;

  const MediaViewerPage({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    // Check the asset type and return the appropriate viewer.
    if (asset.type == AssetType.video) {
      return VideoViewer(asset: asset);
    } else {
      return ImageViewer(asset: asset);
    }
  }
}