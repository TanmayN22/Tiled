// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiled/app/folders/view/root_folder_tab.dart';
import 'package:tiled/app/folders/widgets/root_folder_creation_dailog.dart';
import 'package:tiled/app/home/controllers/gallery_controller.dart';
import 'package:tiled/app/home/widgets/gallery_view/build_gallery_view.dart';
import 'package:tiled/app/search/view/search_screen.dart';
import 'package:tiled/controllers/nav_controller.dart';
import 'package:tiled/widgets/nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers by finding them with GetX.
    final NavController navController = Get.find();
    // The GalleryController now provides all the data and logic.
    final GalleryController galleryController = Get.find();

    final List<Widget> pages = [
      // We now pass data directly from the galleryController.
      // The Obx wrapper will handle rebuilding this widget when the data changes.
      Obx(() => BuildGalleryView(
            groupedByDay: galleryController.groupedByDay.value,
            groupedByMonth: galleryController.groupedByMonth.value,
            allAssets: galleryController.allAssets.value,
            onLoadMore: galleryController.loadMoreImages,
            isLoading: galleryController.isLoading.value,
            hasMoreImages: galleryController.hasMoreImages.value,
          )),
      RootFolderTab(),
      SearchPage(),
    ];

    final List<String> titles = ["Photos", "Tiled", "Search"];

    // The main Obx wrapper for handling tab changes.
    return Obx(() {
      final currentIndex = navController.selectedIndex.value;
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(titles[currentIndex]),
          actions: [
            if (currentIndex == 1)
              IconButton(
                onPressed: () => showCreateRootFolderDialog(context),
                icon: const Icon(Icons.add),
              ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // This IndexedStack keeps the state of each page alive when switching tabs.
              IndexedStack(
                index: currentIndex,
                children: pages,
              ),
              Align(alignment: Alignment.bottomCenter, child: NavBar()),
            ],
          ),
        ),
      );
    });
  }
}