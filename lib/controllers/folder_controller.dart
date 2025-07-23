import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:tiled/models/folder_model.dart';
import 'package:tiled/models/media_item.dart';
import 'package:uuid/uuid.dart';

class FolderController extends GetxController {
  var folders = <FolderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFolders();
  }

  void loadFolders() {
    final box = Hive.box<FolderModel>('Folders');
    folders.value = box.values.toList();
    debugPrint("Loaded folders count: ${folders.length}");

    // Debug: Print all folders with their parentIds
    for (var folder in folders) {
      debugPrint(
        "Folder: ${folder.name}, ID: ${folder.id}, ParentID: ${folder.parentId}",
      );
    }
  }

  void createFolder(String name, {String? parentId}) {
    final id = const Uuid().v4();
    final folder = FolderModel(
      id: id,
      name: name,
      parentId: parentId,
      childFolderIds: [],
      mediaItems: [],
    );

    final box = Hive.box<FolderModel>('Folders');
    box.put(id, folder);

    // Update parent folder's childFolderIds if this is a subfolder
    if (parentId != null) {
      final parentFolder = box.get(parentId);
      if (parentFolder != null) {
        parentFolder.childFolderIds.add(id);
        parentFolder.save();
        debugPrint("Added child folder ID $id to parent ${parentFolder.name}");
      }
    }

    loadFolders(); // Reload folders list to refresh reactive state
    debugPrint("Created folder: $name with parentId: $parentId");
  }

  List<FolderModel> getSubfolders(String parentId) {
    final subfolders =
        folders
            .where((f) => f.parentId != null && f.parentId == parentId)
            .toList();

    debugPrint("=== GETSUBFOLDERS DEBUG ===");
    debugPrint("Looking for subfolders of parentId: $parentId");
    debugPrint("Total folders available: ${folders.length}");
    debugPrint("Found subfolders: ${subfolders.length}");

    for (var subfolder in subfolders) {
      debugPrint("  - Subfolder: ${subfolder.name} (ID: ${subfolder.id})");
    }

    return subfolders;
  }

  List<FolderModel> getRootFolders() {
    final rootFolders =
        folders.where((f) => f.parentId == null || f.parentId == '').toList();

    debugPrint("=== ROOT FOLDERS DEBUG ===");
    debugPrint("Root folders found: ${rootFolders.length}");
    for (var folder in rootFolders) {
      debugPrint("  - Root folder: ${folder.name} (ID: ${folder.id})");
    }

    return rootFolders;
  }

  void addMedia(String folderId, MediaItem media) {
    final box = Hive.box<FolderModel>('Folders');
    final folder = box.get(folderId);
    if (folder != null) {
      folder.mediaItems.add(media);
      folder.save();
      loadFolders();
      debugPrint("Added media to folder: ${folder.name}");
    } else {
      debugPrint("ERROR: Folder with ID $folderId not found when adding media");
    }
  }

  // Helper method to get a specific folder by ID
  FolderModel? getFolderById(String folderId) {
    try {
      return folders.firstWhere((f) => f.id == folderId);
    } catch (e) {
      debugPrint("Folder with ID $folderId not found: $e");
      return null;
    }
  }

  // Helper method to delete a folder
  void deleteFolder(String folderId) {
    final box = Hive.box<FolderModel>('Folders');
    final folder = box.get(folderId);

    if (folder != null) {
      // Remove from parent's childFolderIds if it has a parent
      if (folder.parentId != null) {
        final parentFolder = box.get(folder.parentId!);
        if (parentFolder != null) {
          parentFolder.childFolderIds.remove(folderId);
          parentFolder.save();
        }
      }

      // Delete the folder
      box.delete(folderId);
      loadFolders();
      debugPrint("Deleted folder: ${folder.name}");
    }
  }
}
