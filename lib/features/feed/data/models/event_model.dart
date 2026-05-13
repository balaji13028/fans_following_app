class EventModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String date;
  final String time;
  final String? location;
  final int likesCount;
  final bool isLiked;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.date,
    required this.time,
    this.location,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: (json['publicId'] ?? json['id'] ?? '') as String,
      name: (json['name'] ?? json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      imageUrl: (json['eventBanner'] ?? json['imageUrl']) as String?,
      date: (json['date'] ?? '') as String,
      time: (json['time'] ?? '') as String,
      location: json['location'] as String?,
      likesCount: (json['likesCount'] ?? 0) as int,
      isLiked: (json['isLiked'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publicId': id,
      'name': name,
      'description': description,
      'eventBanner': imageUrl,
      'date': date,
      'time': time,
      'location': location,
      'likesCount': likesCount,
      'isLiked': isLiked,
    };
  }

  EventModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? date,
    String? time,
    String? location,
    int? likesCount,
    bool? isLiked,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
