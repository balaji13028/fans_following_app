class SocialLinkModel {
  final String id;
  final String platform; // Instagram, Twitter, Facebook, YouTube, etc.
  final String url;
  final String icon; // Icon name or URL

  SocialLinkModel({
    required this.id,
    required this.platform,
    required this.url,
    required this.icon,
  });

  factory SocialLinkModel.fromJson(Map<String, dynamic> json) {
    return SocialLinkModel(
      id: json['id'] as String,
      platform: json['platform'] as String,
      url: json['url'] as String,
      icon: json['icon'] as String? ?? json['platform'].toString().toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'url': url,
      'icon': icon,
    };
  }

  SocialLinkModel copyWith({
    String? id,
    String? platform,
    String? url,
    String? icon,
  }) {
    return SocialLinkModel(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      url: url ?? this.url,
      icon: icon ?? this.icon,
    );
  }
}

