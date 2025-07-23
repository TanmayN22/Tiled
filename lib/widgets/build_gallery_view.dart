import 'dart:io';
import 'package:flutter/material.dart';

class BuildGalleryView extends StatelessWidget {
  final List<File> imageFiles;
  final VoidCallback? onLoadMore;
  final bool isLoading;
  final bool hasMoreImages;

  const BuildGalleryView({
    super.key,
    required this.imageFiles,
    this.onLoadMore,
    this.isLoading = false,
    this.hasMoreImages = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFiles.isEmpty && isLoading) {
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

    if (imageFiles.isEmpty) {
      return const Center(child: Text("No photos found in gallery"));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            hasMoreImages &&
            !isLoading &&
            onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: imageFiles.length + (hasMoreImages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == imageFiles.length) {
            // Loading indicator at the end
            return const Center(child: CircularProgressIndicator());
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(imageFiles[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}
