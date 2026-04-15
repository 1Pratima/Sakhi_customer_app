class NotificationModel {
  final int id;
  final String objectType;
  final int objectId;
  final String action;
  final int actorId;
  final String content;
  final bool isRead;
  final bool isSystemGenerated;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.objectType,
    required this.objectId,
    required this.action,
    required this.actorId,
    required this.content,
    required this.isRead,
    required this.isSystemGenerated,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      objectType: json['objectType']?.toString() ?? 'other',
      objectId: json['objectId'] as int? ?? 0,
      action: json['action']?.toString() ?? 'info',
      actorId: json['actorId'] as int? ?? 0,
      content: json['content']?.toString() ?? '',
      isRead: json['isRead'] as bool? ?? false,
      isSystemGenerated: json['isSystemGenerated'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Helper for UI
  String get title {
    switch (action) {
      case 'created':
        return 'New ${objectType[0].toUpperCase()}${objectType.substring(1)}';
      case 'repaymentMade':
        return 'Payment Received';
      case 'approved':
        return 'Loan Approved';
      default:
        return 'Notification';
    }
  }

  String get type {
    if (objectType == 'loan') return 'loan';
    if (content.toLowerCase().contains('saving')) return 'savings';
    if (content.toLowerCase().contains('meeting')) return 'meeting';
    return 'other';
  }
}
