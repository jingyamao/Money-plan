import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // 处理通知点击
  }

  Future<void> requestPermission() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _notifications
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // 超支提醒
  Future<void> showOverBudgetNotification({
    required double budget,
    required double spent,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_channel',
      '预算提醒',
      channelDescription: '预算超支提醒',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _notifications.show(
      0,
      '预算超支提醒',
      '您本月已消费 ¥${spent.toStringAsFixed(2)}，超出预算 ¥${(spent - budget).toStringAsFixed(2)}',
      details,
    );
  }

  // 每日消费提醒
  Future<void> showDailySummaryNotification({
    required double todaySpent,
    required double dailyBudget,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_channel',
      '每日消费',
      channelDescription: '每日消费总结',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    final isOver = todaySpent > dailyBudget;
    final message = isOver
        ? '今日已消费 ¥${todaySpent.toStringAsFixed(2)}，超出日预算 ¥${(todaySpent - dailyBudget).toStringAsFixed(2)}'
        : '今日已消费 ¥${todaySpent.toStringAsFixed(2)}，日预算剩余 ¥${(dailyBudget - todaySpent).toStringAsFixed(2)}';

    await _notifications.show(
      1,
      '今日消费总结',
      message,
      details,
    );
  }

  // 预算进度提醒
  Future<void> showBudgetProgressNotification({
    required double budget,
    required double spent,
    required double percent,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'progress_channel',
      '预算进度',
      channelDescription: '预算使用进度提醒',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _notifications.show(
      2,
      '预算进度提醒',
      '本月预算已使用 ${(percent * 100).toStringAsFixed(0)}%',
      details,
    );
  }
}
