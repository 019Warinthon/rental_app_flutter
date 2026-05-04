class UserModel {
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;

  const UserModel({
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
