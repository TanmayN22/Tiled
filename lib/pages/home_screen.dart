import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'package:tiled/controllers/nav_controller.dart';
import 'package:tiled/pages/root_folder_tab.dart';
import 'package:tiled/pages/search_screen.dart';
import 'package:tiled/widgets/build_gallery_view.dart';
import 'package:tiled/widgets/nav_bar.dart';
import 'package:tiled/widgets/root_folder_creation_dailog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> imageFiles = [];
  final NavController navController = Get.find();
  bool isLoading = false;
  bool hasMoreImages = true;
  int currentPage = 0;
  final int pageSize = 50;

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  Future<void> _loadGalleryImages({bool loadMore = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      Get.snackbar("Permission Denied", "Gallery access is required");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    final recentAlbum = albums.first;

    // Get total count first
    final totalCount = await recentAlbum.assetCountAsync;
    print("Total images available: $totalCount");

    final assets = await recentAlbum.getAssetListPaged(
      page: currentPage,
      size: pageSize,
    );

    if (assets.isEmpty) {
      setState(() {
        hasMoreImages = false;
        isLoading = false;
      });
      return;
    }

    final files = await Future.wait(assets.map((a) => a.file));
    final newFiles = files.whereType<File>().toList();
    setState(() {
      if (loadMore) {
        imageFiles.addAll(newFiles);
      } else {
        imageFiles = newFiles;
      }
      currentPage++;
      isLoading = false;
      hasMoreImages = assets.length == pageSize;
    });
  }

  Future<void> _loadMoreImages() async {
    if (hasMoreImages && !isLoading) {
      await _loadGalleryImages(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      BuildGalleryView(
        imageFiles: imageFiles,
        onLoadMore: _loadMoreImages,
        isLoading: isLoading,
        hasMoreImages: hasMoreImages,
      ), // Index 0: Gallery images
      RootFolderTab(), // Index 1: Folder management
      SearchPage(), // Index 2: Search functionality
    ];

    final List<String> titles = ["Photos", "Tiled", "Search"];

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
              pages[currentIndex],
              Align(alignment: Alignment.bottomCenter, child: NavBar()),
            ],
          ),
        ),
      );
    });
  }
}
