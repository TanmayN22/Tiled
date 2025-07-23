import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiled/controllers/folder_controller.dart';

void showCreateRootFolderDialog(BuildContext context) {
  final FolderController controller = Get.find();
  final TextEditingController nameController = TextEditingController();
  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text("Create Root Folder"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Folder name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  controller.createFolder(name);
                }
              },
              child: const Text("Create"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        ),
  );
}
