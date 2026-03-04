class LoginResponse {
  final bool? success;
  final String? accessToken;
  final String? tokenType;
  final LoginData? data;
  final int? expiresInSecond;
  final String? error;

  LoginResponse({
    this.success,
    this.accessToken,
    this.tokenType,
    this.data,
    this.expiresInSecond,
    this.error,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      expiresInSecond: json['expires_in_second'],
      error: json['error'],
    );
  }
}
class LoginData {
  final User? user;

  LoginData({this.user});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
class User {
  final int? id;
  final String? name;
  final String? email;
  final String? emailVerifiedAt;
  final String? role;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      role: json['role'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
