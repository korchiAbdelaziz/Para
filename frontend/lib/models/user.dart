class User {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? address;
  final String? token;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.address,
    this.token,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? address,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      token: token ?? this.token,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['name'] ?? json['username'], // Backend uses 'name' as username in UserResponse
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      token: json['token'],
    );
  }
}
