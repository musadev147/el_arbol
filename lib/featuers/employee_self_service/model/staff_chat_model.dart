class StaffChatMessage {
  final int? id;
  final int? staff;
  final int? adminUser;
  final String? sender;
  final String? message;
  final bool? isRead;
  final String? createdAt;
  final String? staffName;

  StaffChatMessage({
    this.id,
    this.staff,
    this.adminUser,
    this.sender,
    this.message,
    this.isRead,
    this.createdAt,
    this.staffName,
  });

  factory StaffChatMessage.fromJson(Map<String, dynamic> json) {
    return StaffChatMessage(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      staff: json['staff'] is int ? json['staff'] : (json['staff'] != null ? int.tryParse(json['staff'].toString()) : null),
      adminUser: json['admin_user'] is int ? json['admin_user'] : (json['admin_user'] != null ? int.tryParse(json['admin_user'].toString()) : null),
      sender: json['sender']?.toString(),
      message: json['message']?.toString(),
      isRead: json['is_read'] is bool ? json['is_read'] : (json['is_read']?.toString() == 'true'),
      createdAt: json['created_at']?.toString(),
      staffName: json['staff_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff': staff,
      'admin_user': adminUser,
      'sender': sender,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt,
      'staff_name': staffName,
    };
  }
}
