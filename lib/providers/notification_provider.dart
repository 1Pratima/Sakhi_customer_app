import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:com.navajyoti.app/models/notification.dart';
import 'package:com.navajyoti.app/providers/service_providers.dart';

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final response = await apiService.getNotifications();
  
  final List<dynamic> data = response.data['pageItems'] as List? ?? [];
  return data.map((json) => NotificationModel.fromJson(json)).toList();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
});
