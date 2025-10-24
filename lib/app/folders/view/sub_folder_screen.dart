import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiled/app/folders/controller/folder_controller.dart';
import 'package:tiled/app/folders/widgets/media_card.dart';
import 'package:tiled/app/folders/widgets/subfolder_card.dart';
import 'package:tiled/models/folder_model.dart';
import 'package:tiled/models/media_item.dart';
import 'package:tiled/widgets/subFolder_dialogBox.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class SubFolderPage extends StatelessWidget {
  final FolderController controller = Get.find();

  SubFolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FolderModel folderArg = Get.arguments as FolderModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(folderArg.name),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.add),
            onSelected: (value) {
              if (value == 'subfolder') {
                showCreateSubFolderDialog(context, folderArg.id);
              } else if (value == 'media') {
                _pickAndAddMedia(context, folderArg.id);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'media',
                    child: ListTile(
                      leading: Icon(Icons.photo),
                      title: Text('Add Media'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'subfolder',
                    child: ListTile(
                      leading: Icon(Icons.create_new_folder),
                      title: Text('Create Subfolder'),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Obx(() {
        final currentFolder = controller.getFolderById(folderArg.id);

        if (currentFolder == null) {
          // This can happen if the folder is deleted while being viewed.
          return const Center(child: Text("Folder not found."));
        }

        final subfolders = controller.getSubfolders(currentFolder.id);
        final mediaItems = currentFolder.mediaItems;

        // Combine subfolders and media items, ensuring subfolders appear first.
        final allItems = <dynamic>[...subfolders, ...mediaItems];

        if (allItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "This folder is empty",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85, // Optimal for the card layout
          ),
          itemCount: allItems.length,
          itemBuilder: (context, index) {
            final item = allItems[index];

            if (item is FolderModel) {
              // Use the dedicated SubfolderCard widget with a unique key for performance.
              return SubfolderCard(key: ValueKey(item.id), subfolder: item);
            } else if (item is MediaItem) {
              return MediaCard(
                key: ValueKey(item.id),
                mediaItem: item,
                folderId: currentFolder.id,
                allMediaInFolder: mediaItems,
              );
            }
            return const SizedBox.shrink(); // Fallback for safety
          },
        );
      }),
    );
  }

  /// Handles picking media from the gallery and adding it to the current folder.
  void _pickAndAddMedia(BuildContext context, String folderId) async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      Get.snackbar("Permission Denied", "Media access is required");
      return;
    }

    final List<AssetEntity>? media = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(maxAssets: 100),
    );

    if (media != null && media.isNotEmpty) {
      for (var asset in media) {
        final file = await asset.file;
        if (file != null) {
          final mediaItem = MediaItem(
            id: asset.id,
            path: file.path,
            // Use asset.type.name for a reliable string representation (e.g., 'video', 'image')
            type: asset.type.name,
            createdAt: asset.createDateTime,
          );
          controller.addMedia(folderId, mediaItem);
        }
      }
      Get.snackbar(
        "Success",
        "Added ${media.length} ${media.length == 1 ? 'item' : 'items'} to folder",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
