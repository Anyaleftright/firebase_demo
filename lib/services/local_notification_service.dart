import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    const InitializationSettings initializationSettings = InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'));

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? route) async {
        if(route!=null){
          Navigator.of(context).pushNamed(route);
        }
      },
    );
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/1000;
      const NotificationDetails notificationDetails = NotificationDetails(android: AndroidNotificationDetails(
        'vjppro',
        'vjppro channel',
        channelDescription: 'vjppro description',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ));

      await _flutterLocalNotificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['route'],
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}