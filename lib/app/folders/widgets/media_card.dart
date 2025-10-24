import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:tiled/app/home/view/full_media_screen.dart';
import 'package:tiled/models/media_item.dart';

class MediaCard extends StatelessWidget {
  final MediaItem mediaItem;
  final List<MediaItem> allMediaInFolder;

  const MediaCard({
    super.key,
    required this.mediaItem,
    required this.allMediaInFolder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // ✨ 1. Show a loading dialog while we prepare the data.
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        try {
          // ✨ 2. Asynchronously convert the list of MediaItems to a list of AssetEntities.
          // Future.wait runs all the lookups in parallel, which is very fast.
          final List<AssetEntity> assetList = await Future.wait(
            allMediaInFolder.map((item) async {
              // AssetEntity.fromId returns a Future<AssetEntity?>, so we await it.
              final asset = await AssetEntity.fromId(item.id);
              // We throw an error if an asset is not found (e.g., deleted from device).
              if (asset == null) throw Exception("Asset not found");
              return asset;
            }).toList(),
          );

          // ✨ 3. Find the index of the tapped item in the new list.
          final initialIndex = assetList.indexWhere(
            (asset) => asset.id == mediaItem.id,
          );

          // Close the loading dialog.
          Get.back();

          // ✨ 4. Navigate to the full-screen viewer with the correct data.
          if (initialIndex != -1) {
            Get.to(
              () =>
                  FullMediaScreen(assets: assetList, initalIndex: initialIndex),
            );
          }
        } catch (e) {
          // If any asset fails to load, close the dialog and show an error.
          Get.back();
          Get.snackbar(
            "Error",
            "Could not load media. It may have been deleted.",
            snackPosition: SnackPosition.BOTTOM,
          );
          print("Error preparing assets for viewer: $e");
        }
      },
      // The FutureBuilder for displaying the thumbnail remains the same.
      child: FutureBuilder<AssetEntity?>(
        future: AssetEntity.fromId(mediaItem.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.0),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Icon(Icons.error_outline, color: Colors.red),
            );
          }

          final asset = snapshot.data!;

          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AssetEntityImage(
                  asset,
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize(250, 250),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) {
                    return const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
                if (asset.type == AssetType.video)
                  const Positioned(
                    bottom: 4,
                    right: 4,
                    child: Icon(Icons.videocam, color: Colors.white, size: 18),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
