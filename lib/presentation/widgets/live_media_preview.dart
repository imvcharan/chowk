import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/safe_network_image.dart';

class LiveMediaPreview extends StatefulWidget {
  const LiveMediaPreview({super.key, required this.story, this.height = 140});

  final Map<String, dynamic> story;
  final double height;

  @override
  State<LiveMediaPreview> createState() => _LiveMediaPreviewState();
}

class _LiveMediaPreviewState extends State<LiveMediaPreview> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;

  @override
  void initState() {
    super.initState();
    final rawVideo = widget.story['video_url'] ?? widget.story['videoUrl'] ?? '';
    final videoUrl = rawVideo?.toString().trim() ?? '';

    if (videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _initializeFuture = _controller!.initialize().then((_) {
        if (mounted) {
          _controller!..setLooping(true);
          setState(() {});
        }
      }).catchError((_) {
        // ignore initialization errors and fall back to image
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawImage = widget.story['image_url'] ?? widget.story['imageUrl'] ?? '';
    final imageUrl = rawImage?.toString().trim() ?? '';

    if (_controller != null && _initializeFuture != null) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: FutureBuilder<void>(
          future: _initializeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && _controller?.value.isInitialized == true) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.chowkOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_controller == null) return;
                      setState(() {
                        _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.chowkBlack.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            }

            if (imageUrl.isNotEmpty) {
              return SizedBox(
                height: widget.height,
                width: double.infinity,
                child: SafeNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
              );
            }

            return Container(
              height: widget.height,
              color: AppTheme.lightGray,
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported_outlined, color: AppTheme.mutedText, size: 36),
            );
          },
        ),
      );
    }

    if (imageUrl.isNotEmpty) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: SafeNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
      );
    }

    return Container(
      height: widget.height,
      color: AppTheme.lightGray,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, color: AppTheme.mutedText, size: 36),
    );
  }
}
