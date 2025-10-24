import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiled/app/folders/view/sub_folder_screen.dart';
import 'package:tiled/models/folder_model.dart';

class SubfolderCard extends StatelessWidget {
  final FolderModel subfolder;

  const SubfolderCard({super.key, required this.subfolder});

  ///This private helper method contains the full logic for building the dynamic thumbnail.
  Widget _buildThumbnailGrid(List<String> imagePaths) {
    if (imagePaths.isEmpty) {
      return const Center(
        child: Icon(Icons.folder_outlined, size: 48, color: Colors.white30),
      );
    }

    // Layout for a single image (fills the whole space)
    if (imagePaths.length == 1) {
      return Image.file(
        File(imagePaths[0]),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // Layout for two images (side-by-side)
    if (imagePaths.length == 2) {
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
    }

    // Layout for three images (one large, two small)
    if (imagePaths.length == 3) {
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
    }

    // Default layout for four or more images (2x2 grid)
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 4, // Only show the first 4 images
      itemBuilder: (context, index) {
        return Image.file(File(imagePaths[index]), fit: BoxFit.cover);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This logic correctly filters for images only.
    final imagePaths =
        subfolder.mediaItems
            .where((item) => item.type == 'image')
            .take(4)
            .map((e) => e.path)
            .toList();

    return GestureDetector(
      onTap: () {
        Get.to(
          () => SubFolderPage(),
          arguments: subfolder,
          preventDuplicates: false,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  // The UI is now built using the new, more intelligent helper method.
                  child: _buildThumbnailGrid(imagePaths),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                subfolder.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
