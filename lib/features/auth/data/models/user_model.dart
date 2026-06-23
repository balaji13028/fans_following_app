import '../../../../core/constants/app_constants.dart';

class UserModel {
  final String id;
  final String? email;
  final String? name;
  final String? profileImageUrl;
  final String? dob;
  final String? mobile;
  final String? facebookId;
  final String? instagramId;
  final String? country;
  final String? state;
  final String? district;
  final bool isPostCreator;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    this.email,
    this.name,
    this.profileImageUrl,
    this.dob,
    this.mobile,
    this.facebookId,
    this.instagramId,
    this.country,
    this.state,
    this.district,
    this.isPostCreator = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['publicId'] ?? json['id'] ?? '') as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      profileImageUrl: _getFullImageUrl(
          (json['profileImage'] ?? json['profileImageUrl']) as String?),
      dob: json['dob'] as String?,
      mobile: (json['mobile'] ?? json['mobileNumber']) as String?,
      facebookId: json['facebookId'] as String?,
      instagramId: json['instagramId'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      district: json['district'] as String?,
      isPostCreator: (json['isPostCreator'] ?? false) as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publicId': id,
      'email': email,
      'name': name,
      'profileImage': profileImageUrl,
      'dob': dob,
      'mobile': mobile,
      'facebookId': facebookId,
      'instagramId': instagramId,
      'country': country,
      'state': state,
      'district': district,
      'isPostCreator': isPostCreator,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static String? _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final baseUrl = AppConstants.baseUrl.endsWith('/')
        ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)
        : AppConstants.baseUrl;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }
}
