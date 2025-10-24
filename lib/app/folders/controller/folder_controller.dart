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
  }

  void createFolder(String name, {String? parentId}) {
    final id = const Uuid().v4();
    final folder = FolderModel(id: id, name: name, parentId: parentId);
    final box = Hive.box<FolderModel>('Folders');
    box.put(id, folder);

    if (parentId != null) {
      final parentFolder = box.get(parentId);
      if (parentFolder != null) {
        parentFolder.childFolderIds.add(id);
        parentFolder.save();
      }
    }
    loadFolders();
  }

  // --- NEW METHODS ---

  /// **1. Updates the name of a specific folder.**
  void updateFolderName(String folderId, String newName) {
    final box = Hive.box<FolderModel>('Folders');
    final folder = box.get(folderId);
    if (folder != null) {
      folder.name = newName;
      folder.save(); // Save the changes to the database
      loadFolders(); // Refresh the UI
      Get.snackbar("Success", "Folder renamed to '$newName'");
    }
  }

  /// **2. Removes a media item's reference from a folder.**
  /// This does NOT delete the actual file from the device's storage.
  void removeMediaFromFolder(String folderId, String mediaId) {
    final box = Hive.box<FolderModel>('Folders');
    final folder = box.get(folderId);
    if (folder != null) {
      folder.mediaItems.removeWhere((item) => item.id == mediaId);
      folder.save();
      loadFolders(); // Refresh to update thumbnails and content
    }
  }

  /// **3. Deletes a folder and recursively deletes all of its subfolders.**
  void deleteFolder(String folderId) {
    final box = Hive.box<FolderModel>('Folders');
    final folderToDelete = box.get(folderId);
    if (folderToDelete == null) return;

    // Step 1: Recursively delete all children first. This is important.
    // We create a copy of the list to avoid errors while modifying it during iteration.
    final childIds = List<String>.from(folderToDelete.childFolderIds);
    for (String childId in childIds) {
      deleteFolder(childId); // The recursive call
    }

    // Step 2: Remove this folder's ID from its parent's list of children.
    if (folderToDelete.parentId != null) {
      final parentFolder = box.get(folderToDelete.parentId!);
      if (parentFolder != null) {
        parentFolder.childFolderIds.remove(folderId);
        parentFolder.save();
      }
    }

    // Step 3: Finally, delete the folder itself.
    box.delete(folderId);
    
    // Refresh the UI once at the end after all operations are complete.
    loadFolders();
  }

  // --- Existing Methods ---
  
  List<FolderModel> getSubfolders(String parentId) {
    return folders.where((f) => f.parentId == parentId).toList();
  }

  List<FolderModel> getRootFolders() {
    return folders.where((f) => f.parentId == null).toList();
  }

  void addMedia(String folderId, MediaItem media) {
    final box = Hive.box<FolderModel>('Folders');
    final folder = box.get(folderId);
    if (folder != null) {
      folder.mediaItems.add(media);
      folder.save();
      loadFolders();
    }
  }

  FolderModel? getFolderById(String folderId) {
    try {
      return folders.firstWhere((f) => f.id == folderId);
    } catch (e) {
      return null; // Return null if not found
    }
  }
}