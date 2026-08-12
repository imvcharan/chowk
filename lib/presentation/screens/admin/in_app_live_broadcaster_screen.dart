import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

import '../../../services/api_service.dart';
import '../../../core/theme/app_theme.dart';

class InAppLiveBroadcasterScreen extends StatefulWidget {
  const InAppLiveBroadcasterScreen({super.key, required this.stream});

  final Map<String, dynamic> stream;

  @override
  State<InAppLiveBroadcasterScreen> createState() => _InAppLiveBroadcasterScreenState();
}

class _InAppLiveBroadcasterScreenState extends State<InAppLiveBroadcasterScreen> {
  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  String? _whipResource;
  String? _error;
  bool _starting = false;
  bool _broadcasting = false;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _renderer.initialize();
  }

  @override
  void dispose() {
    _stopBroadcast(updateServer: false);
    _renderer.dispose();
    super.dispose();
  }

  Future<void> _startBroadcast() async {
    if (_starting || _broadcasting) return;
    setState(() {
      _starting = true;
      _error = null;
    });

    try {
      final whipUrl = ApiService.normalizeMediaUrl(widget.stream['whipUrl']?.toString() ?? '');
      if (whipUrl.isEmpty) throw Exception('The broadcast endpoint is missing.');

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
          'frameRate': {'ideal': 30},
        },
      });
      _renderer.srcObject = _localStream;
      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      });

      for (final track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }

      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': false,
        'offerToReceiveVideo': false,
      });
      await _peerConnection!.setLocalDescription(offer);
      await _waitForIceGathering();

      final localDescription = await _peerConnection!.getLocalDescription();
      final response = await http.post(
        Uri.parse(whipUrl),
        headers: const {'Content-Type': 'application/sdp', 'Accept': 'application/sdp'},
        body: localDescription?.sdp ?? offer.sdp ?? '',
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Media server rejected the broadcast (${response.statusCode}).');
      }

      final answer = RTCSessionDescription(response.body, 'answer');
      await _peerConnection!.setRemoteDescription(answer);
      _whipResource = response.headers['location'];
      await ApiService.updateLiveStream(id: widget.stream['id'].toString(), status: 'LIVE');
      if (!mounted) return;
      setState(() {
        _starting = false;
        _broadcasting = true;
      });
    } catch (error) {
      await _cleanupPeerConnection();
      if (!mounted) return;
      setState(() {
        _starting = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _waitForIceGathering() async {
    if (_peerConnection?.iceGatheringState == RTCIceGatheringState.RTCIceGatheringStateComplete) return;
    final completer = Completer<void>();
    _peerConnection?.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete && !completer.isCompleted) {
        completer.complete();
      }
    };
    await completer.future.timeout(const Duration(seconds: 8), onTimeout: () {});
  }

  Future<void> _stopBroadcast({bool updateServer = true}) async {
    if (updateServer && _broadcasting) {
      try {
        await ApiService.updateLiveStream(id: widget.stream['id'].toString(), status: 'ENDED');
      } catch (_) {}
    }
    final resource = _whipResource;
    if (resource != null) {
      try {
        await http.delete(Uri.parse(ApiService.normalizeMediaUrl(resource)));
      } catch (_) {}
    }
    await _cleanupPeerConnection();
    if (mounted) setState(() => _broadcasting = false);
  }

  Future<void> _cleanupPeerConnection() async {
    for (final track in _localStream?.getTracks() ?? <MediaStreamTrack>[]) {
      await track.stop();
    }
    await _localStream?.dispose();
    await _peerConnection?.close();
    _localStream = null;
    _peerConnection = null;
    _whipResource = null;
    _renderer.srcObject = null;
  }

  void _toggleMute() {
    final audioTracks = _localStream?.getAudioTracks() ?? <MediaStreamTrack>[];
    for (final track in audioTracks) {
      track.enabled = _muted;
    }
    setState(() => _muted = !_muted);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.stream['title']?.toString() ?? 'Live broadcast';
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: AppTheme.chowkBlack),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _localStream == null
                  ? const Center(child: Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 72))
                  : RTCVideoView(_renderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _broadcasting ? _toggleMute : null,
                    icon: Icon(_muted ? Icons.mic_off : Icons.mic, color: Colors.white),
                    tooltip: 'Mute microphone',
                  ),
                  FilledButton.icon(
                    onPressed: _starting ? null : () => _broadcasting ? _stopBroadcast() : _startBroadcast(),
                    icon: Icon(_broadcasting ? Icons.stop : Icons.videocam),
                    label: Text(_starting ? 'Starting...' : _broadcasting ? 'End live' : 'Go live'),
                    style: FilledButton.styleFrom(backgroundColor: _broadcasting ? Colors.redAccent : AppTheme.chowkOrange),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}