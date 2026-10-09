import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// سرویس اعلان‌ها — یادآور سال خمسی
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// زمان‌بندی یادآورهای ۳۰ و ۷ روز قبل از سال خمسی
  Future<void> scheduleKhumsYearReminders(DateTime yearStart) async {
    await init();
    await _requestPermissions();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'khums_year_channel',
        'یادآور سال خمسی',
        channelDescription: 'اعلان نزدیک شدن سال خمسی',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final now = DateTime.now();
    var nextYear = DateTime(now.year, yearStart.month, yearStart.day);
    if (nextYear.isBefore(now)) {
      nextYear = DateTime(now.year + 1, yearStart.month, yearStart.day);
    }

    final remind30 = nextYear.subtract(const Duration(days: 30));
    final remind7 = nextYear.subtract(const Duration(days: 7));

    if (remind30.isAfter(now)) {
      await _plugin.zonedSchedule(
        1001,
        'سال خمسی نزدیک است',
        '۳۰ روز تا پایان سال خمسی شما باقی مانده است.',
        tz.TZDateTime.from(remind30, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
    if (remind7.isAfter(now)) {
      await _plugin.zonedSchedule(
        1002,
        'سال خمسی نزدیک است',
        '۷ روز تا پایان سال خمسی شما باقی مانده است.',
        tz.TZDateTime.from(remind7, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
