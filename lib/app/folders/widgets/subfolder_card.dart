import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiled/app/folders/controller/folder_controller.dart';
import 'package:tiled/app/folders/view/sub_folder_screen.dart';
import 'package:tiled/models/folder_model.dart';

class SubfolderCard extends StatelessWidget {
  final FolderModel subfolder;
  final FolderController controller = Get.find();

  SubfolderCard({super.key, required this.subfolder});

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
                  Navigator.pop(context); // Close the bottom sheet first.
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
                  Navigator.pop(context); // Close the bottom sheet.
                  _showDeleteConfirmationDialog(context);
                },
              ),
            ],
          ),
    );
  }

  // ✨ 2. Helper function to show the rename dialog.
  void _showRenameDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: subfolder.name,
    );
    Get.dialog(
      AlertDialog(
        title: const Text("Rename Folder"),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "New folder name"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              Get.back(); // Close the dialog.
              if (newName.isNotEmpty) {
                // Call the controller method to update the name.
                controller.updateFolderName(subfolder.id, newName);
              }
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }

  // ✨ 3. Helper function for the delete confirmation dialog.
  void _showDeleteConfirmationDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Folder?"),
        content: Text(
          "Are you sure you want to delete '${subfolder.name}' and all of its contents? This cannot be undone.",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              // Call the recursive delete method from the controller.
              controller.deleteFolder(subfolder.id);
              Get.back(); // Close the dialog.
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
      onLongPress: () => _showFolderOptions(context),
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
