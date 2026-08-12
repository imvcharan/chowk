import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherClient {
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();

  Future<void> init({
    required String apiKey,
    required String cluster,
    bool forceTLS = true,
    bool logToConsole = false,
  }) async {
    await _pusher.init(
      apiKey: apiKey,
      cluster: cluster,
      useTLS: forceTLS,
      logToConsole: logToConsole,
      onError: (message, code, error) {
        if (logToConsole) {
          print('PusherClient error: $message ($code) $error');
        }
      },
    );
  }

  Future<void> connect() async {
    await _pusher.connect();
  }

  Future<void> disconnect() async {
    await _pusher.disconnect();
  }

  Future<PusherChannel> subscribe({
    required String channelName,
    required Function(PusherEvent event) onEvent,
  }) async {
    return _pusher.subscribe(
      channelName: channelName,
      onEvent: onEvent,
    );
  }
}
