import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiled/app/folders/controller/folder_controller.dart';

void showCreateSubFolderDialog(BuildContext context, String parentId) {
  final TextEditingController name = TextEditingController();
  final FolderController controller = Get.find();

  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text('Create Subfolder'),
          content: TextField(
            controller: name,
            decoration: const InputDecoration(hintText: 'Subfolder name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (name.text.trim().isNotEmpty) {
                  controller.createFolder(name.text.trim(), parentId: parentId);
                }
              },
              child: const Text('Create'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
  );
}
