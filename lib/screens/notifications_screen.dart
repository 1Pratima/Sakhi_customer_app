import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shg_customer_app/widgets/account_widgets.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock notification data
    final notifications = [
      {
        'title': 'SHG Monthly Meeting',
        'message':
            'Your group meeting is scheduled for Apr 24, 2024 at 11:00 AM',
        'type': 'meeting',
      },
      {
        'title': 'Savings Reminder',
        'message': 'Don\'t forget to make your monthly savings deposit',
        'type': 'savings',
      },
      {
        'title': 'EMI Payment Due',
        'message': 'Your next EMI payment of ₹2,150 is due on May 10, 2024',
        'type': 'loan',
      },
      {
        'title': 'Important Update',
        'message': 'New features added to your SHG mobile app',
        'type': 'other',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark All Read'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text('No notifications'),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationCard(
                  title: notification['title'] as String,
                  message: notification['message'] as String,
                  type: notification['type'] as String,
                );
              },
            ),
    );
  }
}
