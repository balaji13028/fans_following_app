class PostModel {
  final String id;
  final String title;
  final List<String> tags;
  final String description;
  final String? imageUrl;
  final int likesCount;
  final bool isLiked;
  final DateTime postedOn;
  final String status;
  final String? creatorId;

  PostModel({
    required this.id,
    required this.title,
    this.tags = const [],
    required this.description,
    this.imageUrl,
    required this.likesCount,
    required this.isLiked,
    required this.postedOn,
    this.status = 'approved',
    this.creatorId,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: (json['publicId'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      tags: List<String>.from(json['tags'] ?? []),
      description: (json['description'] ?? json['content'] ?? '') as String,
      imageUrl: (json['image'] ?? json['imageUrl']) as String?,
      likesCount: (json['likesCount'] ?? 0) as int,
      isLiked: (json['isLiked'] ?? false) as bool,
      postedOn: DateTime.parse(json['postedOn'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      status: (json['status'] ?? 'approved') as String,
      creatorId: json['creatorId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publicId': id,
      'title': title,
      'tags': tags,
      'description': description,
      'image': imageUrl,
      'likesCount': likesCount,
      'isLiked': isLiked,
      'postedOn': postedOn.toIso8601String(),
      'status': status,
      'creatorId': creatorId,
    };
  }

  PostModel copyWith({
    String? id,
    String? title,
    List<String>? tags,
    String? description,
    String? imageUrl,
    int? likesCount,
    bool? isLiked,
    DateTime? postedOn,
    String? status,
    String? creatorId,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      postedOn: postedOn ?? this.postedOn,
      status: status ?? this.status,
      creatorId: creatorId ?? this.creatorId,
    );
  }
}
