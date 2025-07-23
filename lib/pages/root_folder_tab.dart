import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiled/controllers/folder_controller.dart';
import 'package:tiled/models/folder_model.dart';
import 'package:tiled/pages/sub_folder_screen.dart';

class RootFolderTab extends StatelessWidget {
  final FolderController controller = Get.find();

  RootFolderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rootFolders = controller.getRootFolders();

      if (rootFolders.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No folders created yet.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85, // Slightly taller for better proportions
          ),
          itemCount: rootFolders.length,
          itemBuilder: (context, index) {
            final folder = rootFolders[index];
            return _buildFolderCard(folder, context);
          },
        ),
      );
    });
  }

  Widget _buildFolderCard(FolderModel folder, BuildContext context) {
    // Collect all available images from this folder and its subfolders
    final List<String> allImagePaths = [];

    // Add images from the root folder itself
    for (var media in folder.mediaItems) {
      allImagePaths.add(media.path);
      if (allImagePaths.length >= 4) break;
    }

    // Add images from subfolders if we need more
    if (allImagePaths.length < 4) {
      final subfolders = controller.getSubfolders(folder.id);
      for (var subfolder in subfolders) {
        for (var media in subfolder.mediaItems) {
          allImagePaths.add(media.path);
          if (allImagePaths.length >= 4) break;
        }
        if (allImagePaths.length >= 4) break;
      }
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => SubFolderPage(), arguments: folder);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[700]!, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail preview area
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[800],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildThumbnailGrid(allImagePaths),
                ),
              ),
            ),
            // Folder info section
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      folder.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailGrid(List<String> imagePaths) {
    if (imagePaths.isEmpty) {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.folder_outlined, size: 48, color: Colors.white30),
        ),
      );
    }

    if (imagePaths.length == 1) {
      // Single image - full coverage
      return Image.file(
        File(imagePaths[0]),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (imagePaths.length == 2) {
      // Two images - side by side
      return Row(
        children: [
          Expanded(
            child: Image.file(
              File(imagePaths[0]),
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Image.file(
              File(imagePaths[1]),
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
        ],
      );
    } else if (imagePaths.length == 3) {
      // Three images - one large on left, two stacked on right
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: Image.file(
              File(imagePaths[0]),
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Image.file(
                    File(imagePaths[1]),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Image.file(
                    File(imagePaths[2]),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Four or more images - 2x2 grid
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Image.file(File(imagePaths[index]), fit: BoxFit.cover);
        },
      );
    }
  }
}
