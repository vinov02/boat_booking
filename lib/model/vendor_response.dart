import 'vendor.dart';

class VendorResponse {
  final bool success;
  final String message;
  final Vendor data;

  VendorResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory VendorResponse.fromJson(Map<String, dynamic> json) {
    return VendorResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      data: Vendor.fromJson(json['data']),
    );
  }
}
