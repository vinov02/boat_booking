class DeleteResponse {
  final bool success;
  final String message;

  DeleteResponse({
    required this.success,
    required this.message,
  });

  factory DeleteResponse.fromJson(Map<String, dynamic> json) {
    return DeleteResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
    );
  }
}
