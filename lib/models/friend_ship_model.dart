class FriendShipModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final bool isBlocked;
  final String? blockedBy;


  FriendShipModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    this.isBlocked = false,
    this.blockedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isBlocked': isBlocked,
      'blockedBy': blockedBy,
    };
  }

  static FriendShipModel fromMap(Map<String, dynamic> map) {
    return FriendShipModel(
      id: map['id'] ?? '',
      user1Id: map['user1Id'] ?? '',
      user2Id: map['user2Id'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isBlocked: map['isBlocked'] ?? false,
      blockedBy: map['blockedBy'],
    );
  }

  FriendShipModel copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    DateTime? createdAt,
    bool? isBlocked,
    String? blockedBy,
  }) {
    return FriendShipModel(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      createdAt: createdAt ?? this.createdAt,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedBy: blockedBy ?? this.blockedBy,
    );
  }

  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }

  bool isBlockedBy (String userId) {
    return isBlocked && blockedBy == userId;
  }

  
}