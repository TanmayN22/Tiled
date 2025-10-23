import 'package:flutter/material.dart';
import 'package:tiled/app/home/widgets/media_viewer/media_viewer_page.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class FullMediaScreen extends StatelessWidget {
  final List<AssetEntity> assets;
  final int initalIndex;

  const FullMediaScreen({
    super.key,
    required this.assets,
    required this.initalIndex,
  });

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: initalIndex);
    return Scaffold(
      // This allows the body to draw behind the AppBar.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: pageController,
        itemCount: assets.length,
        itemBuilder: (context, index) {
          return MediaViewerPage(asset: assets[index]);
        },
      ),
    );
  }
}
