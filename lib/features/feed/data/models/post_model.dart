class PostModel {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;
  final AuthorModel author;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
    required this.author,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      likesCount: json['likesCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      author: AuthorModel.fromJson(json['author'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'likesCount': likesCount,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'author': author.toJson(),
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? content,
    String? imageUrl,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
    AuthorModel? author,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
    );
  }
}

class AuthorModel {
  final String id;
  final String name;
  final String? profileImageUrl;

  AuthorModel({
    required this.id,
    required this.name,
    this.profileImageUrl,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImageUrl': profileImageUrl,
    };
  }
}

