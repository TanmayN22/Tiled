// lib/app/search/controller/search_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiled/app/folders/controller/folder_controller.dart';
import 'package:tiled/models/folder_model.dart';

class SearchController extends GetxController {
  // Find the FolderController to get access to the list of all folders.
  final FolderController _folderController = Get.find();

  // Controller for the text field in the search bar.
  final TextEditingController textController = TextEditingController();

  // An observable list to hold the search results. The UI will automatically
  // update whenever this list changes.
  var searchResults = <FolderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Add a listener to the text field. Whenever the user types,
    // the _searchFolders method will be called.
    textController.addListener(_searchFolders);
  }

  @override
  void onClose() {
    // Clean up the controller to prevent memory leaks.
    textController.dispose();
    super.onClose();
  }

  /// The core search logic.
  void _searchFolders() {
    // Get the current search query from the text field, in lowercase.
    final query = textController.text.toLowerCase().trim();

    // If the query is empty, clear the results and do nothing.
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    // Filter the full list of folders from the FolderController.
    // A folder is included in the results if its name (in lowercase)
    // contains the search query.
    final results =
        _folderController.folders.where((folder) {
          return folder.name.toLowerCase().contains(query);
        }).toList();

    // Update the observable list with the new results.
    searchResults.value = results;
  }

  /// Clears the search text and results.
  void clearSearch() {
    textController.clear();
    searchResults.clear();
  }
}
