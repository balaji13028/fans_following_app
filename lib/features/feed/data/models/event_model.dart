class EventModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime date;
  final String? location;
  final bool isUpcoming;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.date,
    this.location,
    required this.isUpcoming,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String?,
      isUpcoming: json['isUpcoming'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': date.toIso8601String(),
      'location': location,
      'isUpcoming': isUpcoming,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? date,
    String? location,
    bool? isUpcoming,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      location: location ?? this.location,
      isUpcoming: isUpcoming ?? this.isUpcoming,
    );
  }
}

