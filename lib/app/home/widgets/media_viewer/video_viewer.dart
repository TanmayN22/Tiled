import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'video_controls_overlay.dart';

class VideoViewer extends StatefulWidget {
  final AssetEntity asset;

  const VideoViewer({super.key, required this.asset});

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      final file = await widget.asset.file;
      if (file == null) throw Exception("Video file not found");

      _controller = VideoPlayerController.file(file);
      await _controller?.initialize();

      _controller?.addListener(() {
        if (mounted) setState(() {});
      });

      if (mounted) {
        setState(() => _isInitialized = true);
        _startHideControlsTimer();
      }
    } catch (e) {
      print("Error initializing video player: $e");
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startHideControlsTimer();
      } else {
        _hideControlsTimer?.cancel();
      }
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controller!.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 8),
            Text("Could not play video", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller!),
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: VideoControlsOverlay(
                  controller: _controller!,
                  onPlayPause: () {
                    setState(() {
                      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                      _startHideControlsTimer();
                    });
                  },
                  onSeekForward: () {
                    final newPosition = _controller!.value.position + const Duration(seconds: 10);
                    _controller!.seekTo(newPosition);
                    _startHideControlsTimer();
                  },
                  onSeekBackward: () {
                    final newPosition = _controller!.value.position - const Duration(seconds: 10);
                    _controller!.seekTo(newPosition);
                    _startHideControlsTimer();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}