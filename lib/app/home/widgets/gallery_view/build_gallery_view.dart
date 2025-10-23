import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tiled/app/home/widgets/gallery_view/day_view.dart';
import 'package:tiled/app/home/widgets/gallery_view/month_view.dart';

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

  final ScrollController _dayScrollController = ScrollController();
  final ScrollController _monthScrollController = ScrollController();
  DateTime? _topmostDate;

  final Map<DateTime, GlobalKey> _dateKeys = {};

  @override
  void initState() {
    super.initState();
    _dayScrollController.addListener(_updateTopmostDate);
  }

  @override
  void dispose() {
    _dayScrollController.removeListener(_updateTopmostDate);
    _dayScrollController.dispose();
    _monthScrollController.dispose();
    super.dispose();
  }

  void _updateTopmostDate() {
    if (!_dayScrollController.hasClients) return;
    final sortedDates = widget.groupedByDay.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final date in sortedDates) {
      final key = _dateKeys[date];
      if (key != null && key.currentContext != null) {
        final box = key.currentContext!.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        if (position.dy >= 0) {
          _topmostDate = date;
          return;
        }
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _startScale = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale < _startScale && details.scale < 0.8 && _currentView == GalleryViewLevel.day) {
      setState(() => _currentView = GalleryViewLevel.month);
      _scrollToCorrespondingMonth();
    } else if (details.scale > _startScale && details.scale > 1.2 && _currentView == GalleryViewLevel.month) {
      setState(() => _currentView = GalleryViewLevel.day);
      _scrollToCorrespondingDay();
    }
  }

  void _scrollToCorrespondingMonth() {
    if (_topmostDate == null) return;
    final targetMonth = DateTime(_topmostDate!.year, _topmostDate!.month, 1);
    final key = _dateKeys[targetMonth];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 100), alignment: 0.05);
    }
  }

  void _scrollToCorrespondingDay() {
    if (_topmostDate == null) return;
    final key = _dateKeys[_topmostDate!];
     if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 100), alignment: 0.05);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate keys for all date groups
    (widget.groupedByDay.keys.toList() + widget.groupedByMonth.keys.toList()).toSet().forEach((date) {
      _dateKeys.putIfAbsent(date, () => GlobalKey());
    });

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
        child: _currentView == GalleryViewLevel.day
            ? DayView(
                key: const ValueKey('day_view'),
                groupedAssets: widget.groupedByDay,
                allAssets: widget.allAssets,
                hasMoreImages: widget.hasMoreImages,
                onLoadMore: widget.onLoadMore,
                isLoading: widget.isLoading,
                scrollController: _dayScrollController,
                dateKeys: _dateKeys,
              )
            : MonthView(
                key: const ValueKey('month_view'),
                groupedAssets: widget.groupedByMonth,
                allAssets: widget.allAssets,
                scrollController: _monthScrollController,
                dateKeys: _dateKeys,
              ),
      ),
    );
  }
}