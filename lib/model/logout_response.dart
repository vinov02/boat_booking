class LogoutResponse {
  bool? success;
  String? status;
  String? message;
  dynamic data;

  LogoutResponse({this.success, this.status, this.message, this.data});

  LogoutResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    status = json['status'];
    message = json['message'];
    data = json['data'];
  }
}
