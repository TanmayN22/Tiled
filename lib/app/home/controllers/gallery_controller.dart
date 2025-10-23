import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryController extends GetxController {
  // --- STATE VARIABLES ---
  // These are observable, so the UI will automatically update when they change.

  var allAssets = <AssetEntity>[].obs;
  var groupedByDay = <DateTime, List<AssetEntity>>{}.obs;
  var groupedByMonth = <DateTime, List<AssetEntity>>{}.obs;

  var isLoading = false.obs;
  var hasMoreImages = true.obs;
  var currentPage = 0;
  final int pageSize = 150;

  // --- LIFECYCLE METHOD ---

  @override
  void onInit() {
    super.onInit();
    loadGalleryImages(); // Load images when the controller is first created.
  }

  // --- LOGIC METHODS ---

  /// Groups the flat list of allAssets into two maps: one for days, one for months.
  void _groupAssets() {
    final dayMap = <DateTime, List<AssetEntity>>{};
    final monthMap = <DateTime, List<AssetEntity>>{};

    for (final asset in allAssets) {
      final dayDate = DateTime(asset.createDateTime.year, asset.createDateTime.month, asset.createDateTime.day);
      if (dayMap[dayDate] == null) dayMap[dayDate] = [];
      dayMap[dayDate]!.add(asset);

      final monthDate = DateTime(asset.createDateTime.year, asset.createDateTime.month, 1);
      if (monthMap[monthDate] == null) monthMap[monthDate] = [];
      monthMap[monthDate]!.add(asset);
    }
    groupedByDay.value = dayMap;
    groupedByMonth.value = monthMap;
  }

  /// Fetches a paginated list of media from the device's gallery.
  Future<void> loadGalleryImages({bool loadMore = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;

    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      Get.snackbar("Permission Denied", "Gallery access is required");
      isLoading.value = false;
      return;
    }

    final albums = await PhotoManager.getAssetPathList(type: RequestType.all, onlyAll: true);
    if (albums.isEmpty) {
      isLoading.value = false;
      hasMoreImages.value = false;
      return;
    }

    final recentAlbum = albums.first;
    final assets = await recentAlbum.getAssetListPaged(page: currentPage, size: pageSize);
    if (assets.isEmpty) {
      hasMoreImages.value = false;
      isLoading.value = false;
      return;
    }

    if (loadMore) {
      allAssets.addAll(assets);
    } else {
      allAssets.value = assets;
    }
    
    currentPage++;
    isLoading.value = false;
    hasMoreImages.value = assets.length == pageSize;

    _groupAssets();
  }

  /// A public method to be called from the UI to load the next page.
  Future<void> loadMoreImages() async {
    if (hasMoreImages.value && !isLoading.value) {
      await loadGalleryImages(loadMore: true);
    }
  }
}