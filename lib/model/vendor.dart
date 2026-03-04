class CreateVendorResponse {
  final bool success;
  final String status;
  final String message;
  final Vendor? data;

  CreateVendorResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory CreateVendorResponse.fromJson(Map<String, dynamic> json) {
    return CreateVendorResponse(
      success: json['success'] == true,
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] is Map<String, dynamic>
          ? Vendor.fromJson(json['data'])
          : null,
    );
  }
}
class Vendor {
  final int? id;
  final int? userId;
  final String? companyName;
  final String? name;
  final String? phone1;
  final String? phone2;
  final String? address;
  final VendorUser? user; // 🔴 nullable

  Vendor({
    this.id,
    this.userId,
    this.companyName,
    this.name,
    this.phone1,
    this.phone2,
    this.address,
    this.user,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      userId: json['user_id'],
      companyName: json['company_name'],
      name: json['name'],
      phone1: json['phone1'],
      phone2: json['phone2'],
      address: json['address'],
      user: json['user'] is Map<String, dynamic>
          ? VendorUser.fromJson(json['user'])
          : null,
    );
  }
}
class VendorUser {
  final int? id;
  final String? name;
  final String? email;
  final String? role;
  final String? status;

  VendorUser({
    this.id,
    this.name,
    this.email,
    this.role,
    this.status,
  });

  factory VendorUser.fromJson(Map<String, dynamic> json) {
    return VendorUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
    );
  }
}
