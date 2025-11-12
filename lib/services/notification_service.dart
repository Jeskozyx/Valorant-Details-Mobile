import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Map<String, String> _getConvertedTimes() {
    final now = DateTime.now().toUtc();
    final wib = now.add(const Duration(hours: 7));
    final wita = now.add(const Duration(hours: 8));
    final wit = now.add(const Duration(hours: 9));
    final london = now.add(const Duration(hours: 0));
    final format = DateFormat('HH:mm');
    return {
      'WIB': format.format(wib),
      'WITA': format.format(wita),
      'WIT': format.format(wit),
      'London': format.format(london),
    };
  }

  Future<void> showTopupSuccessNotification(int vp) async {
    final times = _getConvertedTimes();
    final String notificationBody = '''
WIB: ${times['WIB']} • WITA: ${times['WITA']} • WIT: ${times['WIT']} • London: ${times['London']}''';

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'topup_channel',
          'Top Up Notifications',
          channelDescription: 'Channel for top up success notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(''),
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Selamat, anda berhasil membeli $vp VP!',
      notificationBody,
      platformChannelSpecifics,
    );
  }
}
