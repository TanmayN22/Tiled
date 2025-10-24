import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiled/app/folders/controller/folder_controller.dart';
import 'package:tiled/models/folder_model.dart';
import 'package:tiled/app/folders/view/sub_folder_screen.dart';

class RootFolderCard extends StatelessWidget {
  final FolderModel folder;
  final FolderController controller = Get.find();

  RootFolderCard({super.key, required this.folder});

  // ✨ NEW: Helper function to show the options menu.
  void _showFolderOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(context); 
                  _showRenameDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _showDeleteConfirmationDialog(context);
                },
              ),
            ],
          ),
    );
  }

  // ✨ NEW: Helper function for the rename dialog.
  void _showRenameDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: folder.name,
    );
    Get.dialog(
      AlertDialog(
        title: const Text("Rename Folder"),
        content: TextField(controller: nameController, autofocus: true),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                controller.updateFolderName(
                  folder.id,
                  nameController.text.trim(),
                );
              }
              Get.back();
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }

  // ✨ NEW: Helper function for the delete confirmation dialog.
  void _showDeleteConfirmationDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Folder?"),
        content: Text(
          "Are you sure you want to delete '${folder.name}' and all of its contents? This cannot be undone.",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              controller.deleteFolder(folder.id);
              Get.back();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> allImagePaths = [];

    // Filter for images only to prevent decoding errors with videos.
    for (var media in folder.mediaItems.where((m) => m.type == 'image')) {
      allImagePaths.add(media.path);
      if (allImagePaths.length >= 4) break;
    }

    if (allImagePaths.length < 4) {
      final subfolders = controller.getSubfolders(folder.id);
      for (var subfolder in subfolders) {
        for (var media in subfolder.mediaItems.where(
          (m) => m.type == 'image',
        )) {
          allImagePaths.add(media.path);
          if (allImagePaths.length >= 4) break;
        }
        if (allImagePaths.length >= 4) break;
      }
    }

    return GestureDetector(
      onTap: () {
        Get.to(
          () => SubFolderPage(),
          arguments: folder,
          preventDuplicates: false,
        );
      },
      onLongPress: () => _showFolderOptions(context),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 60, 59, 59),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(255, 60, 59, 59),
            width: 0.5,
          ),
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
                  color: const Color.fromARGB(255, 60, 59, 59),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildThumbnailGrid(allImagePaths),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                folder.name,
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

  /// ✨ This is the corrected thumbnail logic.
  Widget _buildThumbnailGrid(List<String> imagePaths) {
    if (imagePaths.isEmpty) {
      return Container(
        color: Colors.black45, // Use a consistent background color
        child: const Center(
          child: Icon(
            Icons.folder_outlined,
            size: 48,
            color: Colors.white60,
          ), // Use a more visible icon color
        ),
      );
    }

    // Layout for a single image
    if (imagePaths.length == 1) {
      return Image.file(
        File(imagePaths[0]),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // Layout for two images
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
          const SizedBox(width: 4),
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

    // Layout for three images
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

    // Default layout for four or more image
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      // Only build up to 4 items for the preview
      itemCount: 4,
      itemBuilder: (context, index) {
        return Image.file(File(imagePaths[index]), fit: BoxFit.cover);
      },
    );
  }
}
