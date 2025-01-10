class User {
  final String username;
  final String password;
  final String estado;

  User({required this.username, required this.password, required this.estado});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      password: json['password'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'estado': estado,
    };
  }
}
