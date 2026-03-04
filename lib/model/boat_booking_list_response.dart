import 'package:boat_booking/model/user_full_response.dart';

class BoatBookingListResponse {
  final bool success;
  final String? status;
  final String? message;
  final List<BoatBookingDetail> data;

  BoatBookingListResponse({
    required this.success,
    this.status,
    this.message,
    required this.data,
  });

  factory BoatBookingListResponse.fromJson(Map<String, dynamic> json) {
    return BoatBookingListResponse(
      success: json['success'] ?? false,
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => BoatBookingDetail.fromJson(e))
          .toList(),
    );
  }
}
