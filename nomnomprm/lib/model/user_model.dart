class UserModel {
  final String id;
  final String username;
  final String email;
  final String RoleId;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.RoleId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'],
      username: json['userName'],
      email: json['email'],
      RoleId: json['role'],
    );
  }
}
