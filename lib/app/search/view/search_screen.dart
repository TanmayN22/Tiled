// lib/app/search/view/search_screen.dart

import 'package:flutter/material.dart'
    hide SearchController; // ✨ FIX: Add this hide statement
import 'package:get/get.dart';
import 'package:tiled/app/folders/view/sub_folder_screen.dart';
import 'package:tiled/app/search/controller/search_controller.dart';
import 'package:tiled/models/folder_model.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // This will now correctly refer to YOUR SearchController
    final SearchController searchController = Get.put(SearchController());

    return Column(
      children: [
        // --- Search Bar UI ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController.textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Search folders...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => searchController.clearSearch(),
              ),
              filled: true,
              fillColor: Colors.grey.shade800,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // --- Search Results UI ---
        Expanded(
          child: Obx(() {
            if (searchController.textController.text.isEmpty &&
                searchController.searchResults.isEmpty) {
              return const Center(
                child: Text(
                  "Search for any of your folders.",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            if (searchController.searchResults.isEmpty) {
              return Center(
                child: Text(
                  "No folders found for '${searchController.textController.text}'",
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: searchController.searchResults.length,
              itemBuilder: (context, index) {
                final FolderModel folder =
                    searchController.searchResults[index];
                return ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(folder.name),
                  subtitle:
                      folder.parentId != null
                          ? const Text("Subfolder")
                          : const Text("Root Folder"),
                  onTap: () {
                    Get.to(
                      () => SubFolderPage(),
                      arguments: folder,
                      preventDuplicates: false,
                    );
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
