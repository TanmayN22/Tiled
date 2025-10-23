import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:tiled/app/home/view/full_media_screen.dart';

class DayView extends StatelessWidget {
  final Map<DateTime, List<AssetEntity>> groupedAssets;
  final List<AssetEntity> allAssets;
  final bool hasMoreImages;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final ScrollController scrollController;
  final Map<DateTime, GlobalKey> dateKeys;

  const DayView({
    super.key,
    required this.groupedAssets,
    required this.allAssets,
    required this.hasMoreImages,
    required this.isLoading,
    this.onLoadMore,
    required this.scrollController,
    required this.dateKeys,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return "Today";
    if (date == yesterday) return "Yesterday";
    return DateFormat('MMMM d, y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = groupedAssets.keys.toList()..sort((a, b) => b.compareTo(a));

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200 &&
            hasMoreImages && !isLoading && onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: ListView.builder(
        controller: scrollController,
        itemCount: sortedDates.length + (hasMoreImages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == sortedDates.length) {
            return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()));
          }
          final date = sortedDates[index];
          final assetsForDate = groupedAssets[date]!;
          return Column(
            key: dateKeys[date],
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(_formatDate(date),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
                itemCount: assetsForDate.length,
                itemBuilder: (context, gridIndex) {
                  final asset = assetsForDate[gridIndex];
                  return GestureDetector(
                    onTap: () {
                      final initialIndex = allAssets.indexOf(asset);
                      if (initialIndex != -1) {
                        Get.to(() => FullMediaScreen(
                            assets: allAssets, initalIndex: initialIndex));
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AssetEntityImage(asset,
                              isOriginal: false,
                              thumbnailSize: const ThumbnailSize(250, 250),
                              fit: BoxFit.cover),
                          if (asset.type == AssetType.video)
                            const Positioned(
                              bottom: 4,
                              right: 4,
                              child: Icon(Icons.videocam,
                                  color: Colors.white, size: 18),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}