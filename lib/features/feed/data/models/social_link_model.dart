class SocialLinkModel {
  final String id;
  final String name;
  final String url;
  final String? image;

  SocialLinkModel({
    required this.id,
    required this.name,
    required this.url,
    this.image,
  });

  factory SocialLinkModel.fromJson(Map<String, dynamic> json) {
    return SocialLinkModel(
      id: (json['publicId'] ?? json['id'] ?? '') as String,
      name: (json['name'] ?? json['platform'] ?? '') as String,
      url: (json['url'] ?? '') as String,
      image: (json['image'] ?? json['icon']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publicId': id,
      'name': name,
      'url': url,
      'image': image,
    };
  }
}
