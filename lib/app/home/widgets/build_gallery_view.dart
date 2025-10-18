import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class BuildGalleryView extends StatelessWidget {
  final List<AssetEntity> imageAssets;
  final VoidCallback? onLoadMore;
  final bool isLoading;
  final bool hasMoreImages;

  const BuildGalleryView({
    super.key,
    required this.imageAssets,
    this.onLoadMore,
    this.isLoading = false,
    this.hasMoreImages = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageAssets.isEmpty && isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading photos..."),
          ],
        ),
      );
    }

    if (imageAssets.isEmpty) {
      return const Center(child: Text("No photos found in gallery"));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent -
                    200 && // Load a bit before the end
            hasMoreImages &&
            !isLoading &&
            onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: GridView.builder(
        // ✨ OPTIMIZATION: This tells the GridView to build and cache items that are
        // outside of the visible screen. A value of 1000.0 means it will
        // cache images up to 1000 pixels below the visible area, making
        // scrolling feel much smoother.
        cacheExtent: 1000.0,
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: imageAssets.length + (hasMoreImages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == imageAssets.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final asset = imageAssets[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AssetEntityImage(
              asset,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize(
                250,
                250,
              ), // Slightly bigger for better quality
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
