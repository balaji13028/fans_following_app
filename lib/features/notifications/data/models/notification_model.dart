class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final bool isSeen;
  final DateTime createdAt;
  final String type; // e.g., 'post_like', 'new_event', 'comment', etc.

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.isSeen,
    required this.createdAt,
    required this.type,
  });

  // Convert from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      isSeen: json['isSeen'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: json['type'] as String? ?? 'general',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'isSeen': isSeen,
      'createdAt': createdAt.toIso8601String(),
      'type': type,
    };
  }

  // Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    bool? isSeen,
    DateTime? createdAt,
    String? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isSeen: isSeen ?? this.isSeen,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
    );
  }
}

