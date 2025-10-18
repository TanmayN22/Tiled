import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiled/app/folders/controller/folder_controller.dart';
import 'package:tiled/app/folders/widgets/subFolder_dialogBox.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:tiled/models/folder_model.dart';
import 'package:tiled/models/media_item.dart';

class SubFolderPage extends StatelessWidget {
  final FolderController controller = Get.find();

  SubFolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FolderModel folder = Get.arguments as FolderModel;
    debugPrint('Opened folder: ${folder.name}, id: ${folder.id}');

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.name),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.add),
            onSelected: (value) {
              if (value == 'subfolder') {
                showCreateSubFolderDialog(context, folder.id);
              } else if (value == 'media') {
                _pickAndAddMedia(context, folder.id);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'media',
                    child: ListTile(
                      leading: Icon(Icons.photo),
                      title: Text('Add Image'),
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
        final subfolders = controller.getSubfolders(folder.id);
        final mediaItems = folder.mediaItems;

        // Combine subfolders and media items for unified grid
        final allItems = <dynamic>[];
        allItems.addAll(subfolders);
        allItems.addAll(mediaItems);

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

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              final item = allItems[index];

              if (item is FolderModel) {
                // Subfolder card
                return _buildSubfolderCard(item, context);
              } else {
                // Media item card
                return _buildMediaCard(item, context);
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildSubfolderCard(FolderModel subfolder, BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('=== NAVIGATION DEBUG ===');
        debugPrint('Clicking on subfolder: ${subfolder.name}');
        debugPrint('Subfolder ID: ${subfolder.id}');
        debugPrint('Subfolder parentId: ${subfolder.parentId}');
        debugPrint('Subfolder has ${subfolder.mediaItems.length} media items');

        // Check if this folder actually exists in the controller
        final foundFolder = controller.getFolderById(subfolder.id);
        if (foundFolder != null) {
          debugPrint('Folder found in controller, navigating...');
          Get.to(
            () => SubFolderPage(key: UniqueKey()),
            arguments: subfolder,
            transition: Transition.rightToLeft,
          );
        } else {
          debugPrint('ERROR: Folder not found in controller!');
          Get.snackbar('Error', 'Folder not found');
        }
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
                  child:
                      subfolder.mediaItems.isNotEmpty
                          ? _buildSubfolderThumbnailGrid(
                            subfolder.mediaItems
                                .take(4)
                                .map((e) => e.path)
                                .toList(),
                          )
                          : Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(
                                Icons.folder_outlined,
                                size: 48,
                                color: Colors.white30,
                              ),
                            ),
                          ),
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
                      subfolder.name,
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

  Widget _buildSubfolderThumbnailGrid(List<String> imagePaths) {
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

  Widget _buildMediaCard(dynamic mediaItem, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle media item tap (e.g., open full screen viewer)
        _showFullScreenImage(context, mediaItem.path);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[700]!, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(File(mediaItem.path), fit: BoxFit.cover),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InteractiveViewer(
                    child: Image.file(File(imagePath), fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
    );
  }

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
