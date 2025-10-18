import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:tiled/app/home/view/full_media_screen.dart';

// Enum to manage the current zoom level of the gallery
enum GalleryViewLevel { day, month }

class BuildGalleryView extends StatefulWidget {
  final Map<DateTime, List<AssetEntity>> groupedByDay;
  final Map<DateTime, List<AssetEntity>> groupedByMonth;
  final List<AssetEntity> allAssets;
  final VoidCallback? onLoadMore;
  final bool isLoading;
  final bool hasMoreImages;

  const BuildGalleryView({
    super.key,
    required this.groupedByDay,
    required this.groupedByMonth,
    required this.allAssets,
    this.onLoadMore,
    this.isLoading = false,
    this.hasMoreImages = true,
  });

  @override
  State<BuildGalleryView> createState() => _BuildGalleryViewState();
}

class _BuildGalleryViewState extends State<BuildGalleryView> {
  GalleryViewLevel _currentView = GalleryViewLevel.day;
  double _startScale = 1.0;

  // Handles the start of a pinch gesture
  void _onScaleStart(ScaleStartDetails details) {
    _startScale = 1.0; // Reset scale
  }

  // Handles the update of a pinch gesture to switch views
  void _onScaleUpdate(ScaleUpdateDetails details) {
    // Zoom out (pinch in) to switch to Month View
    if (details.scale < _startScale && details.scale < 0.8) {
      if (_currentView == GalleryViewLevel.day) {
        setState(() {
          _currentView = GalleryViewLevel.month;
        });
      }
    }
    // Zoom in (pinch out) to switch to Day View
    else if (details.scale > _startScale && details.scale > 1.2) {
      if (_currentView == GalleryViewLevel.month) {
        setState(() {
          _currentView = GalleryViewLevel.day;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allAssets.isEmpty && widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.allAssets.isEmpty) {
      return const Center(child: Text("No photos or videos found"));
    }

    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child:
            _currentView == GalleryViewLevel.day
                ? _DayView(
                  key: const ValueKey('day_view'),
                  groupedAssets: widget.groupedByDay,
                  allAssets: widget.allAssets,
                  hasMoreImages: widget.hasMoreImages,
                  onLoadMore: widget.onLoadMore,
                  isLoading: widget.isLoading,
                )
                // ✨ CHANGE: The _MonthView is now a different widget
                : _MonthView(
                  key: const ValueKey('month_view'),
                  groupedAssets: widget.groupedByMonth,
                  allAssets: widget.allAssets,
                ),
      ),
    );
  }
}

// WIDGET FOR DAY VIEW (Spaced out grid)
class _DayView extends StatelessWidget {
  // ... (This widget remains exactly the same as the previous version)
  final Map<DateTime, List<AssetEntity>> groupedAssets;
  final List<AssetEntity> allAssets;
  final bool hasMoreImages;
  final bool isLoading;
  final VoidCallback? onLoadMore;

  const _DayView({
    super.key,
    required this.groupedAssets,
    required this.allAssets,
    required this.hasMoreImages,
    required this.isLoading,
    this.onLoadMore,
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
    final sortedDates =
        groupedAssets.keys.toList()..sort((a, b) => b.compareTo(a));
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200 &&
            hasMoreImages &&
            !isLoading &&
            onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: sortedDates.length + (hasMoreImages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == sortedDates.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final date = sortedDates[index];
          final assetsForDate = groupedAssets[date]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  _formatDate(date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: assetsForDate.length,
                itemBuilder: (context, gridIndex) {
                  final asset = assetsForDate[gridIndex];
                  return GestureDetector(
                    onTap: () {
                      final initialIndex = allAssets.indexOf(asset);
                      if (initialIndex != -1) {
                        Get.to(
                          () => FullMediaScreen(
                            assets: allAssets,
                            initalIndex: initialIndex,
                          ),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AssetEntityImage(
                        asset,
                        isOriginal: false,
                        thumbnailSize: const ThumbnailSize(250, 250),
                        fit: BoxFit.cover,
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

// ✨ NEW WIDGET FOR MONTH VIEW (Compact grid, like Google Photos)
class _MonthView extends StatelessWidget {
  final Map<DateTime, List<AssetEntity>> groupedAssets;
  final List<AssetEntity> allAssets;

  const _MonthView({
    super.key,
    required this.groupedAssets,
    required this.allAssets,
  });

  @override
  Widget build(BuildContext context) {
    final sortedMonths =
        groupedAssets.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final month = sortedMonths[index];
        final assetsForMonth = groupedAssets[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                DateFormat('MMMM y').format(month),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // A much denser grid for the month view
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              // Using more columns to make the thumbnails smaller
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // More items per row
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: assetsForMonth.length,
              itemBuilder: (context, gridIndex) {
                final asset = assetsForMonth[gridIndex];
                return GestureDetector(
                  onTap: () {
                    final initialIndex = allAssets.indexOf(asset);
                    if (initialIndex != -1) {
                      Get.to(
                        () => FullMediaScreen(
                          assets: allAssets,
                          initalIndex: initialIndex,
                        ),
                      );
                    }
                  },
                  // No border radius for a tighter, seamless look
                  child: AssetEntityImage(
                    asset,
                    isOriginal: false,
                    // Smaller thumbnail size for performance
                    thumbnailSize: const ThumbnailSize(150, 150),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
