import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:video_player/video_player.dart';

class MediaViewerPage extends StatefulWidget {
  final AssetEntity asset;

  const MediaViewerPage({super.key, required this.asset});

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasError = false;

  // 1. State for controlling the visibility of the overlay
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    if (widget.asset.type == AssetType.video) {
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      final file = await widget.asset.file;
      if (file == null) throw Exception("Video file not found");

      _videoController = VideoPlayerController.file(file);
      await _videoController?.initialize();

      // Add a listener to rebuild the UI when the player's state changes (e.g., position, playing status)
      _videoController?.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        // Start the timer to hide controls after a few seconds
        _startHideControlsTimer();
      }
    } catch (e) {
      print("Error initializing video player: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  // 2. Function to toggle the visibility of the controls
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      // If we are showing the controls, start the timer to hide them again.
      // If we are hiding them, cancel any existing timer.
      if (_showControls) {
        _startHideControlsTimer();
      } else {
        _hideControlsTimer?.cancel();
      }
    });
  }

  // 3. Timer to automatically hide the controls after a delay
  void _startHideControlsTimer() {
    // Cancel any existing timer
    _hideControlsTimer?.cancel();
    // Start a new timer
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _videoController!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  // 4. Helper function to format duration into MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asset.type == AssetType.video) {
      if (_hasError) {
        return const Center();
      }
      return GestureDetector(
        onTap: _toggleControls, // Toggle controls on any tap on the screen
        child: Center(
          child:
              _isVideoInitialized && _videoController != null
                  ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_videoController!),
                        // ✨ 5. Animated container for the controls overlay
                        AnimatedOpacity(
                          opacity: _showControls ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            color: Colors.black.withOpacity(0.4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Spacer(), // Pushes the middle controls down
                                // Middle Row: Rewind, Play/Pause, Forward
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.replay_10,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                      onPressed: () {
                                        final newPosition =
                                            _videoController!.value.position -
                                            const Duration(seconds: 10);
                                        _videoController!.seekTo(newPosition);
                                        _startHideControlsTimer();
                                      },
                                    ),
                                    const SizedBox(width: 20),
                                    IconButton(
                                      icon: Icon(
                                        _videoController!.value.isPlaying
                                            ? Icons.pause_circle_outline
                                            : Icons.play_circle_outline,
                                        color: Colors.white,
                                        size: 64,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _videoController!.value.isPlaying
                                              ? _videoController!.pause()
                                              : _videoController!.play();
                                          _startHideControlsTimer();
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 20),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.forward_10,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                      onPressed: () {
                                        final newPosition =
                                            _videoController!.value.position +
                                            const Duration(seconds: 10);
                                        _videoController!.seekTo(newPosition);
                                        _startHideControlsTimer();
                                      },
                                    ),
                                  ],
                                ),
                                const Spacer(), // Pushes the bottom controls to the bottom
                                // Bottom Row: Progress bar and time
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _formatDuration(
                                          _videoController!.value.position,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Expanded(
                                        child: VideoProgressIndicator(
                                          _videoController!,
                                          allowScrubbing: true,
                                          colors: const VideoProgressColors(
                                            playedColor: Colors.white,
                                            bufferedColor: Colors.grey,
                                            backgroundColor: Colors.white24,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(
                                          _videoController!.value.duration,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : const CircularProgressIndicator(color: Colors.white),
        ),
      );
    } else {
      // Image viewer remains the same
      return InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: AssetEntityImage(
          widget.asset,
          isOriginal: true,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.error, color: Colors.red));
          },
        ),
      );
    }
  }
}
