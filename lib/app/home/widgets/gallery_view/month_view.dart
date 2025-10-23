import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:tiled/app/home/view/full_media_screen.dart';

class MonthView extends StatelessWidget {
  final Map<DateTime, List<AssetEntity>> groupedAssets;
  final List<AssetEntity> allAssets;
  final ScrollController scrollController;
  final Map<DateTime, GlobalKey> dateKeys;

  const MonthView({
    super.key,
    required this.groupedAssets,
    required this.allAssets,
    required this.scrollController,
    required this.dateKeys,
  });

  @override
  Widget build(BuildContext context) {
    final sortedMonths = groupedAssets.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      controller: scrollController,
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final month = sortedMonths[index];
        final assetsForMonth = groupedAssets[month]!;
        return Column(
          key: dateKeys[month],
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(DateFormat('MMMM y').format(month),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
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
                      Get.to(() => FullMediaScreen(
                          assets: allAssets, initalIndex: initialIndex));
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AssetEntityImage(asset,
                          isOriginal: false,
                          thumbnailSize: const ThumbnailSize(150, 150),
                          fit: BoxFit.cover),
                      if (asset.type == AssetType.video)
                        const Positioned(
                          bottom: 2,
                          right: 2,
                          child: Icon(Icons.videocam,
                              color: Colors.white, size: 14),
                        ),
                    ],
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