// import 'package:firebase_core/firebase_core.dart';
// import "package:firebase_messaging/firebase_messaging.dart";
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:sueltito/firebase_options.dart';

// class PushNotificationService {
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   static final FirebaseMessaging _firebaseMessaging =
//       FirebaseMessaging.instance;

//   @pragma('vm:entry-point')
//   static Future<void> firebaseMessagingBackgroundHandler(
//     RemoteMessage message,
//   ) async {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     await _initializeLocalNotifications();
//     await _showFlutterNotification(message);
//   }

//   static Future<void> _showFlutterNotification(RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//     Map<String, dynamic>? data = message.data;

//     String title =
//         notification?.title ?? data?['title'] ?? 'Título por defecto';
//     String body = notification?.body ?? data?['body'] ?? 'Cuerpo por defecto';

//     AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'CHANNEL_ID',
//       'CHANNEL_NAME',
//       channelDescription: 'This is the default notification channel',
//       importance: Importance.max,
//       priority: Priority.high,
//       icon: '@mipmap/ic_launcher',
//     );

//     DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await flutterLocalNotificationsPlugin.show(
//       // notification.hashCode,
//       0,
//       title,
//       body,
//       notificationDetails,
//     );
//   }

//   static Future<void> _initializeLocalNotifications() async {
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings();

//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await flutterLocalNotificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         print('Notification clicked with payload: ${response.payload}');
//       },
//     );
//   }

//   static Future<void> _getInitialNotification() async {
//     RemoteMessage? message = await FirebaseMessaging.instance
//         .getInitialMessage();

//     if (message != null) {
//       print(
//         'App opened from terminated state via notification ${message.data}',
//       );
//       // await _showFlutterNotification(message);
//     }
//   }

//   static Future<void> initializeNotification() async {
//     await _firebaseMessaging.requestPermission();
//     // Called when message is recevied while app is in opened state
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       await _showFlutterNotification(message);
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print(
//         'Notification caused app to open from background state: '
//         '${message.messageId}',
//       );
//     });

//     await _getFmcToken();
//     await _initializeLocalNotifications();
//     await _getInitialNotification();
//   }

//   static Future<void> _getFmcToken() async {
//     String? token = await _firebaseMessaging.getToken();
//     print('Firebase Messaging Token: $token');
//   }
// }
