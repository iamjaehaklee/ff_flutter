import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class Profile {
  final User user;
  final LawyerProfile? lawyerProfile;
  final List<LawyerLicense>? lawyerLicenses;

  Profile({
    required this.user,
    this.lawyerProfile,
    this.lawyerLicenses,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class User {
  final String id;
  final String username;
  final String email;
  final bool isLawyer;
  final String profilePictureUrl;
  final String bio;
  final String country;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isLawyer,
    required this.profilePictureUrl,
    required this.bio,
    required this.country,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class LawyerProfile {
  final String lawyerProfileId;
  final String? practiceAreas;
  final String? education;
  final String lawFirm;
  final String biography;
  final String? certifications;
  final String? languages;
  final bool isVerified;

  LawyerProfile({
    required this.lawyerProfileId,
    this.practiceAreas,
    this.education,
    required this.lawFirm,
    required this.biography,
    this.certifications,
    this.languages,
    required this.isVerified,
  });

  factory LawyerProfile.fromJson(Map<String, dynamic> json) => _$LawyerProfileFromJson(json);
  Map<String, dynamic> toJson() => _$LawyerProfileToJson(this);
}

@JsonSerializable()
class LawyerLicense {
  final String licenseId;
  final String licenseCountry;
  final String licenseState;
  final int licenseYear;
  final String licenseTitle;
  final DateTime createdAt;
  final DateTime updatedAt;

  LawyerLicense({
    required this.licenseId,
    required this.licenseCountry,
    required this.licenseState,
    required this.licenseYear,
    required this.licenseTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LawyerLicense.fromJson(Map<String, dynamic> json) => _$LawyerLicenseFromJson(json);
  Map<String, dynamic> toJson() => _$LawyerLicenseToJson(this);
}
//flutter pub run build_runner build