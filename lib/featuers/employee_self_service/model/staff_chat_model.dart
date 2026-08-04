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
      id: json['id'],
      staff: json['staff'],
      adminUser: json['admin_user'],
      sender: json['sender'],
      message: json['message'],
      isRead: json['is_read'],
      createdAt: json['created_at'],
      staffName: json['staff_name'],
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
