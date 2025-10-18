import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tiled/controllers/nav_controller.dart';
import 'package:tiled/app/folders/view/root_folder_tab.dart';
import 'package:tiled/app/search/view/search_screen.dart';
import 'package:tiled/app/home/widgets/build_gallery_view.dart';
import 'package:tiled/widgets/nav_bar.dart';
import 'package:tiled/app/folders/widgets/root_folder_creation_dailog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // A list to hold the gallery images. Using AssetEntity is much more memory-efficient
  // than using File, as it holds metadata and allows for loading thumbnails.
  List<AssetEntity> imageAssets = [];
  final NavController navController = Get.find();
  // A boolean flag to prevent multiple simultaneous loading operations.
  bool isLoading = false;
  // A flag to know if there are more images to load from the gallery.
  bool hasMoreImages = true;
  // Keeps track of the current page of images to load for pagination.
  int currentPage = 0;
  // Defines how many images to load in each batch (or "page").
  // This value is a trade-off between smooth scrolling and initial load time.
  final int pageSize = 150;

  @override
  void initState() {
    super.initState();
    // When the widget is first created, initiate the process of loading images.
    _loadGalleryImages();
  }

  /// Fetches a paginated list of images from the device's gallery.
  /// The [loadMore] parameter determines whether to append the new images
  /// to the existing list (for infinite scrolling) or to replace the list.
  Future<void> _loadGalleryImages({bool loadMore = false}) async {
    // If a loading operation is already in progress, do nothing.
    if (isLoading) return;

    // Set the state to 'loading' to show a progress indicator in the UI.
    setState(() {
      isLoading = true;
    });

    // Request permission to access the photo gallery.
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      Get.snackbar("Permission Denied", "Gallery access is required");
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Get a list of all photo albums on the device.
    // `onlyAll: true` gets the "All Photos" or "Recents" album.
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    // If there are no albums (e.g., no photos on the device), stop loading.
    if (albums.isEmpty) {
        setState(() {
        isLoading = false;
        hasMoreImages = false;
      });
      return;
    }

    // The first album is typically the "Recents" or "All Photos" album.
    final recentAlbum = albums.first;

    // Fetch a "page" of assets (images) from the album.
    final assets = await recentAlbum.getAssetListPaged(
      page: currentPage, // The page number to fetch.
      size: pageSize,   // The number of items to fetch in this batch.
    );

    // If the returned list of assets is empty, it means there are no more images to load.
    if (assets.isEmpty) {
      setState(() {
        hasMoreImages = false;
        isLoading = false;
      });
      return;
    }

    // Update the UI with the newly loaded images.
    setState(() {
      if (loadMore) {
        // If loading more, add the new assets to the existing list.
        imageAssets.addAll(assets);
      } else {
        // Otherwise, this is the first load, so replace the list.
        imageAssets = assets;
      }
      // Increment the page number for the next fetch.
      currentPage++;
      // Set loading to false as the operation is complete.
      isLoading = false;
      // If the number of assets fetched is less than the page size, we've reached the end.
      hasMoreImages = assets.length == pageSize;
    });
  }

  /// A helper function to trigger loading the next page of images.
  /// This is called by the `onLoadMore` callback in `BuildGalleryView`.
  Future<void> _loadMoreImages() async {
    if (hasMoreImages && !isLoading) {
      await _loadGalleryImages(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // A list of the main pages/widgets to display based on the selected nav bar index.
    final List<Widget> pages = [
      BuildGalleryView(
        imageAssets: imageAssets,
        onLoadMore: _loadMoreImages,
        isLoading: isLoading,
        hasMoreImages: hasMoreImages,
      ), // Index 0: The main gallery grid.
      RootFolderTab(), // Index 1: The screen showing user-created folders.
      SearchPage(),    // Index 2: The search screen.
    ];

    // A list of titles for the AppBar, corresponding to the pages.
    final List<String> titles = ["Photos", "Tiled", "Search"];

    // The Obx widget from GetX automatically rebuilds its child when the
    // value of an observable variable (like selectedIndex) changes.
    return Obx(() {
      final currentIndex = navController.selectedIndex.value;
      return Scaffold(
        resizeToAvoidBottomInset: false, // Prevents the UI from resizing when the keyboard appears.
        appBar: AppBar(
          title: Text(titles[currentIndex]),
          // Conditionally show an "Add" button only on the "Tiled" (folders) screen.
          actions: [
            if (currentIndex == 1)
              IconButton(
                onPressed: () => showCreateRootFolderDialog(context),
                icon: const Icon(Icons.add),
              ),
          ],
        ),
        body: SafeArea(
          // Use a Stack to overlay the navigation bar on top of the page content.
          child: Stack(
            children: [
              // Display the currently selected page.
              pages[currentIndex],
              // Align the NavBar to the bottom center of the screen.
              Align(alignment: Alignment.bottomCenter, child: NavBar()),
            ],
          ),
        ),
      );
    });
  }
}