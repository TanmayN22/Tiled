import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiled/app/folders/controller/folder_controller.dart';
import 'package:tiled/app/folders/widgets/root_folder_card.dart';

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
            childAspectRatio: 0.85,
          ),
          itemCount: rootFolders.length,
          itemBuilder: (context, index) {
            final folder = rootFolders[index];
            return RootFolderCard(key: ValueKey(folder.id), folder: folder);
          },
        ),
      );
    });
  }
}
