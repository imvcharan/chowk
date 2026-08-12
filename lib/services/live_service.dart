import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'api_service.dart';

class LiveService {
  LiveService._privateConstructor();
  static final LiveService instance = LiveService._privateConstructor();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final StreamController<Map<String, dynamic>> _controller = StreamController.broadcast();
  bool _isInitialized = false;
  bool _isDisposed = false;
  PusherChannel? _channel;

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  Map<String, dynamic> parseIncomingUpdate(dynamic data) {
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw FormatException('Unsupported live update payload: $data');
  }

  Future<Map<String, String>> _loadConfig() async {
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return {
          'appKey': decoded['pusherAppKey']?.toString() ?? '',
          'cluster': decoded['pusherCluster']?.toString() ?? 'mt1',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('LiveService config load error: $e');
      }
    }

    return {'appKey': '', 'cluster': 'mt1'};
  }

  Future<void> init({
    String? appKey,
    String? cluster,
    String? channelName = 'live',
    String? eventName = 'live:update',
  }) async {
    if (_isDisposed) {
      _isDisposed = false;
      _isInitialized = false;
    }

    if (_isInitialized) return;
    _isInitialized = true;

    final config = await _loadConfig();
    final resolvedAppKey = appKey ?? config['appKey'] ?? '';
    final resolvedCluster = cluster ?? config['cluster'] ?? 'mt1';

    if (resolvedAppKey.isEmpty) {
      if (kDebugMode) {
        print('LiveService: Pusher app key is not configured. Listening for live updates is disabled.');
      }
      return;
    }

    try {
      await _pusher.init(
        apiKey: resolvedAppKey,
        cluster: resolvedCluster,
        useTLS: true,
        logToConsole: kDebugMode && !kIsWeb,
        onError: (message, code, error) {
          if (kDebugMode) {
            print('LiveService Pusher error: $message ($code) $error');
          }
        },
      );
      await _pusher.connect();
      _channel = await _pusher.subscribe(
        channelName: channelName!,
        onEvent: (event) {
          if (event.eventName != eventName) return;
          try {
            final parsed = parseIncomingUpdate(event.data);
            _controller.add(parsed);
          } catch (e) {
            if (kDebugMode) {
              print('LiveService parse error: $e');
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('LiveService init error: $e');
      }
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    try {
      await _channel?.unsubscribe();
      await _pusher.disconnect();
    } catch (_) {}
    await _controller.close();
  }

  Future<List<dynamic>> fetchInitial({int limit = 20}) => ApiService.getLiveUpdates(limit: limit);
}
