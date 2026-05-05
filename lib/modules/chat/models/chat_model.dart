class ChatModel {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatar;
  final String? lastMessage;
  final String? lastMessageTime;
  final String updatedAt;

  ChatModel({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.ownerId,
    required this.ownerName,
    this.ownerAvatar,
    this.lastMessage,
    this.lastMessageTime,
    required this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      propertyId: json['propertyId'],
      propertyTitle: json['propertyTitle'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      ownerAvatar: json['ownerAvatar'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
      updatedAt: json['updatedAt'],
    );
  }
}
