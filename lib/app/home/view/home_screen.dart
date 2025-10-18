import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tiled/app/folders/view/root_folder_tab.dart';
import 'package:tiled/app/folders/widgets/root_folder_creation_dailog.dart';
import 'package:tiled/app/home/widgets/build_gallery_view.dart';
import 'package:tiled/app/search/view/search_screen.dart';
import 'package:tiled/controllers/nav_controller.dart';
import 'package:tiled/widgets/nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Flat list of all loaded assets
  List<AssetEntity> allAssets = [];
  // ✨ NEW: Maps to hold assets grouped by day and month.
  Map<DateTime, List<AssetEntity>> groupedByDay = {};
  Map<DateTime, List<AssetEntity>> groupedByMonth = {};

  final NavController navController = Get.find();
  bool isLoading = false;
  bool hasMoreImages = true;
  int currentPage = 0;
  final int pageSize = 150;

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  /// ✨ NEW: Groups assets into two separate maps: one for days, one for months.
  void _groupAssets() {
    final dayMap = <DateTime, List<AssetEntity>>{};
    final monthMap = <DateTime, List<AssetEntity>>{};

    for (final asset in allAssets) {
      // Group by day (normalized to midnight)
      final dayDate = DateTime(
        asset.createDateTime.year,
        asset.createDateTime.month,
        asset.createDateTime.day,
      );
      if (dayMap[dayDate] == null) dayMap[dayDate] = [];
      dayMap[dayDate]!.add(asset);

      // Group by month (normalized to the 1st of the month)
      final monthDate = DateTime(
        asset.createDateTime.year,
        asset.createDateTime.month,
        1,
      );
      if (monthMap[monthDate] == null) monthMap[monthDate] = [];
      monthMap[monthDate]!.add(asset);
    }
    setState(() {
      groupedByDay = dayMap;
      groupedByMonth = monthMap;
    });
  }

  Future<void> _loadGalleryImages({bool loadMore = false}) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    // ... (Permission checks and album fetching remain the same)
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      Get.snackbar("Permission Denied", "Gallery access is required");
      setState(() {
        isLoading = false;
      });
      return;
    }
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.all,
      onlyAll: true,
    );
    if (albums.isEmpty) {
      setState(() {
        isLoading = false;
        hasMoreImages = false;
      });
      return;
    }
    final recentAlbum = albums.first;
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

    setState(() {
      if (loadMore) {
        allAssets.addAll(assets);
      } else {
        allAssets = assets;
      }
      currentPage++;
      isLoading = false;
      hasMoreImages = assets.length == pageSize;
    });

    // ✨ After loading/updating assets, re-group them.
    _groupAssets();
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
        // Pass both grouped maps and the flat list to the view
        groupedByDay: groupedByDay,
        groupedByMonth: groupedByMonth,
        allAssets: allAssets,
        onLoadMore: _loadMoreImages,
        isLoading: isLoading,
        hasMoreImages: hasMoreImages,
      ),
      RootFolderTab(),
      SearchPage(),
    ];

    final List<String> titles = ["Photos", "Tiled", "Search"];

    return Obx(() {
      final currentIndex = navController.selectedIndex.value;
      return Scaffold(
        // ... (rest of Scaffold is the same)
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
