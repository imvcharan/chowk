class NotificationService {
  static Future<void> initialize() async {
    // Notifications are currently not initialized on this platform.
    return;
  }

  static Future<void> showBreakingNewsNotification({
    required String title,
    required String body,
  }) async {
    // This is a no-op implementation until a compatible notifications plugin is added.
    return;
  }
}
