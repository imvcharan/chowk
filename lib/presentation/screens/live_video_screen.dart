import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/safe_network_image.dart';

class LiveVideoScreen extends StatefulWidget {
  const LiveVideoScreen({super.key, required this.story});

  final Map<String, dynamic> story;

  @override
  State<LiveVideoScreen> createState() => _LiveVideoScreenState();
}

class _LiveVideoScreenState extends State<LiveVideoScreen> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;
  Timer? _retryTimer;
  String? _playbackError;
  String? _playbackErrorDetail;
  int _retryAttempt = 0;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializePlayback();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayback() async {
    final rawVideoUrl = widget.story['video_url'] ?? widget.story['videoUrl'] ?? '';
    final videoUrl = rawVideoUrl.toString().trim();
    if (videoUrl.isEmpty) return;

    _retryTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();

    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _controller = controller;
    _playbackError = null;
    _initializeFuture = controller.initialize();

    try {
      await _initializeFuture;
      if (!mounted || _controller != controller) return;
      controller
        ..setLooping(true)
        ..setVolume(_isMuted ? 0 : 1)
        ..addListener(_onControllerUpdate);
      await controller.play();
      setState(() {});
    } catch (_) {
      if (!mounted || _controller != controller) return;
      setState(() => _playbackError = 'The live feed is starting. Retrying...');
      _scheduleRetry();
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    if (_retryAttempt >= 12) {
      setState(() => _playbackError = 'The live feed is unavailable right now.');
      return;
    }
    _retryAttempt += 1;
    _retryTimer = Timer(const Duration(seconds: 3), _initializePlayback);
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {});
  }

  void _toggleMute() {
    _isMuted = !_isMuted;
    _controller?.setVolume(_isMuted ? 0 : 1);
    setState(() {});
  }

  void _retryPlayback() {
    _retryAttempt = 0;
    _initializePlayback();
  }

  void _restartPlayback() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    _controller!.seekTo(Duration.zero);
    _controller!.play();
    setState(() {});
  }

  Future<void> _copyStreamLink() async {
    final rawVideoUrl = widget.story['video_url'] ?? widget.story['videoUrl'] ?? '';
    final videoUrl = rawVideoUrl.toString().trim();
    if (videoUrl.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: videoUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Live stream link copied to clipboard')),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours > 0 ? '${duration.inHours.toString().padLeft(2, '0')}:' : ''}$minutes:$seconds';
  }

  Widget _buildLiveStatusRow() {
    final label = widget.story['label']?.toString().toUpperCase() ?? 'LIVE';
    final viewers = widget.story['viewers'];
    final channel = widget.story['channel'] ?? widget.story['source'];
    final liveStatus = widget.story['liveStatus']?.toString() ?? 'Live now';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.chowkOrange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          liveStatus,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.chowkBlack,
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        if (viewers != null)
          Row(
            children: [
              const Icon(Icons.remove_red_eye, size: 16, color: AppTheme.mutedText),
              const SizedBox(width: 4),
              Text(
                viewers.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedText),
              ),
            ],
          ),
        if (channel != null) ...[
          const SizedBox(width: 12),
          Text(
            channel.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedText),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaybackControls() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final duration = _controller!.value.duration;
    final position = _controller!.value.position;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VideoProgressIndicator(
          _controller!,
          allowScrubbing: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          colors: VideoProgressColors(
            playedColor: AppTheme.chowkOrange,
            bufferedColor: AppTheme.mediumGray,
            backgroundColor: AppTheme.lightGray,
          ),
        ),
        Row(
          children: [
            Text(
              _formatDuration(position),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedText),
            ),
            const Spacer(),
            Text(
              _formatDuration(duration),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedText),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _togglePlayPause,
                icon: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(_controller!.value.isPlaying ? 'Pause' : 'Play'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.chowkBlack,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _toggleMute,
                icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                color: AppTheme.chowkBlack,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _restartPlayback,
                icon: const Icon(Icons.replay),
                color: AppTheme.chowkBlack,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    final rawVideoUrl = widget.story['video_url'] ?? widget.story['videoUrl'] ?? '';
    final rawImageUrl = widget.story['image_url'] ?? widget.story['imageUrl'] ?? '';
    final videoUrl = rawVideoUrl.toString().trim();
    final imageUrl = rawImageUrl?.toString().trim() ?? '';

    if (videoUrl.isNotEmpty) {
      return AspectRatio(
        aspectRatio: _controller?.value.isInitialized == true ? _controller!.value.aspectRatio : 16 / 9,
        child: Stack(
          children: [
            if (_controller != null)
              FutureBuilder<void>(
                future: _initializeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && _controller?.value.isInitialized == true) {
                    return VideoPlayer(_controller!);
                  }

                  return Container(
                    color: AppTheme.mediumGray.withOpacity(0.12),
                    child: Center(
                      child: _playbackError == null
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(AppTheme.chowkOrange),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _playbackError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppTheme.mutedText),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _retryPlayback,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.chowkBlack,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Retry stream'),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              )
            else if (imageUrl.isNotEmpty)
              SafeNetworkImage(imageUrl: imageUrl, width: double.infinity, fit: BoxFit.cover)
            else
              Container(
                color: AppTheme.mediumGray.withOpacity(0.12),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppTheme.mutedText,
                    size: 56,
                  ),
                ),
              ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.chowkBlack.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.fiber_manual_record, size: 10, color: Colors.red),
                    SizedBox(width: 6),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.chowkBlack.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _copyStreamLink,
                  icon: const Icon(Icons.share, color: Colors.white),
                  tooltip: 'Copy stream link',
                ),
              ),
            ),
            if (_controller?.value.isInitialized == true)
              Positioned(
                bottom: 18,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.chowkBlack.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _controller!.value.isPlaying ? 'Live now' : 'Paused',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (imageUrl.isNotEmpty) {
      return SafeNetworkImage(imageUrl: imageUrl, width: double.infinity, fit: BoxFit.cover);
    }

    return Container(
      height: 220,
      color: AppTheme.mediumGray.withOpacity(0.12),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppTheme.mutedText,
          size: 56,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.story['title'] ?? 'Live Report';
    final timeAgo = widget.story['timeAgo'] ?? widget.story['updated_at'] ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppTheme.chowkBlack,
        actions: [
          IconButton(
            onPressed: _copyStreamLink,
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Copy stream link',
          ),
        ],
      ),
      backgroundColor: AppTheme.kagazWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildVideoSection(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLiveStatusRow(),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeAgo.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedText),
                  ),
                  const SizedBox(height: 14),
                  if (widget.story['body'] != null && widget.story['body'].toString().trim().isNotEmpty)
                    Text(
                      widget.story['body'].toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.chowkBlack,
                            height: 1.5,
                          ),
                    ),
                  const SizedBox(height: 20),
                  _buildPlaybackControls(),
                  if (_playbackError != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retryPlayback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.chowkBlack,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry Live Stream'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
