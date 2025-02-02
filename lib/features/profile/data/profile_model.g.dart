// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      lawyerProfile: json['lawyerProfile'] == null
          ? null
          : LawyerProfile.fromJson(
              json['lawyerProfile'] as Map<String, dynamic>),
      lawyerLicenses: (json['lawyerLicenses'] as List<dynamic>?)
          ?.map((e) => LawyerLicense.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'user': instance.user,
      'lawyerProfile': instance.lawyerProfile,
      'lawyerLicenses': instance.lawyerLicenses,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      isLawyer: json['isLawyer'] as bool,
      profilePictureUrl: json['profilePictureUrl'] as String,
      bio: json['bio'] as String,
      country: json['country'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'isLawyer': instance.isLawyer,
      'profilePictureUrl': instance.profilePictureUrl,
      'bio': instance.bio,
      'country': instance.country,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

LawyerProfile _$LawyerProfileFromJson(Map<String, dynamic> json) =>
    LawyerProfile(
      lawyerProfileId: json['lawyerProfileId'] as String,
      practiceAreas: json['practiceAreas'] as String?,
      education: json['education'] as String?,
      lawFirm: json['lawFirm'] as String,
      biography: json['biography'] as String,
      certifications: json['certifications'] as String?,
      languages: json['languages'] as String?,
      isVerified: json['isVerified'] as bool,
    );

Map<String, dynamic> _$LawyerProfileToJson(LawyerProfile instance) =>
    <String, dynamic>{
      'lawyerProfileId': instance.lawyerProfileId,
      'practiceAreas': instance.practiceAreas,
      'education': instance.education,
      'lawFirm': instance.lawFirm,
      'biography': instance.biography,
      'certifications': instance.certifications,
      'languages': instance.languages,
      'isVerified': instance.isVerified,
    };

LawyerLicense _$LawyerLicenseFromJson(Map<String, dynamic> json) =>
    LawyerLicense(
      licenseId: json['licenseId'] as String,
      licenseCountry: json['licenseCountry'] as String,
      licenseState: json['licenseState'] as String,
      licenseYear: (json['licenseYear'] as num).toInt(),
      licenseTitle: json['licenseTitle'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LawyerLicenseToJson(LawyerLicense instance) =>
    <String, dynamic>{
      'licenseId': instance.licenseId,
      'licenseCountry': instance.licenseCountry,
      'licenseState': instance.licenseState,
      'licenseYear': instance.licenseYear,
      'licenseTitle': instance.licenseTitle,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
