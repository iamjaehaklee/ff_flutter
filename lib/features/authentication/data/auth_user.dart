class LoggedInUser {
  final String id;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final bool isLawyer;

  LoggedInUser({
    required this.id,
    required this.username,
    required this.email,
    this.profilePictureUrl,
    required this.isLawyer,
  });

  factory LoggedInUser.fromJson(Map<String, dynamic> json) {
    return LoggedInUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profilePictureUrl: json['profile_picture_url'],
      isLawyer: json['is_lawyer'] ?? false,
    );
  }
}