import 'dart:convert';
import 'dart:io';
import 'package:boat_booking/core/utils/constants.dart';
import 'package:boat_booking/model/boat_booking_list_response.dart';
import 'package:boat_booking/model/category_type.dart';
import 'package:boat_booking/model/create_booking_request.dart';
import 'package:boat_booking/model/cruise_type.dart';
import 'package:boat_booking/model/login_response.dart';
import 'package:boat_booking/model/logout_response.dart';
import 'package:boat_booking/model/user_full_response.dart' hide CruiseType;
import 'package:boat_booking/model/vendor.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Api {
  String baseUrl = Constants.MAIN_URL;

  Future<LoginResponse> login(body) async {
    Uri url = Uri.parse("$baseUrl/api/user/login");
    print("URL:$url");
    debugPrint("PAYLOAD:$body", wrapWidth: 1024);
    var response = await http.post(
      url,
      body: body,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
    );
    debugPrint("RESPONSE:${response.body}", wrapWidth: 1024);
    return LoginResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
  }

  Future<LogoutResponse> logout(String token) async {
    Uri url = Uri.parse("$baseUrl/api/user/auth/v1/logout");

    print("URL: $url");

    var response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.acceptHeader: "application/json",
      },
    );

    print("RESPONSE: ${response.body}");

    return LogoutResponse.fromJson(
      json.decode(utf8.decode(response.bodyBytes)),
    );
  }

  Future<UserFullResponse> getUserById({
    required String token,
    required int userId,
  }) async {
    debugPrint("User Id : $userId");
    Uri url = Uri.parse("$baseUrl/api/user/v1/users/$userId");

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
      },
    );
    debugPrint("URL : $url");
    debugPrint("RESPONSE: ${response.body}");
    final body = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 401 ||
      body is Map && body["message"] == "Unauthenticated.") {
    throw const UnauthenticatedException();
  }

    return UserFullResponse.fromJson(
      json.decode(utf8.decode(response.bodyBytes)),
    );
  }

  Future<CreateBookingResponse> createBoatBooking({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    Uri url = Uri.parse("$baseUrl/api/user/v1/boat-booking-details");

    print("URL: $url");
    print("PAYLOAD: $body");

    final response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.acceptHeader: "application/json",
      },
      body: jsonEncode(body),
    );

    print("RESPONSE: ${response.body}");

    return CreateBookingResponse.fromJson(
      json.decode(utf8.decode(response.bodyBytes)),
    );
  }

  Future<List<CruiseType>> getCruiseTypes({required String token}) async {
    final url = Uri.parse("$baseUrl/api/user/v1/cruise-types");

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
      },
    );

    final decoded = json.decode(response.body);

    print("URL: ${url}");
    print("PAYLOAD: ${response.body}");

    if (decoded['success'] == true) {
      return (decoded['data'] as List)
          .map((e) => CruiseType.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load cruise types");
    }
  }

  Future<List<CategoryType>> getCategoryTypes({required String token}) async {
    final url = Uri.parse("$baseUrl/api/user/v1/categories");

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
      },
    );
    print("URL: ${url}");
    print("PAYLOAD : ${response.body}");

    final decoded = json.decode(response.body);

    if (decoded['success'] == true) {
      return (decoded['data'] as List)
          .map((e) => CategoryType.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }

  Future<CreateVendorResponse> createVendor({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse("$baseUrl/api/user/v1/vendors");

    final response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.acceptHeader: "application/json",
      },
      body: jsonEncode(body),
    );

    return CreateVendorResponse.fromJson(
      json.decode(utf8.decode(response.bodyBytes)),
    );
  }

  Future<List<Vendor>> getVendors({required String token}) async {
    final url = Uri.parse("$baseUrl/api/user/v1/vendors");

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
      },
    );

    debugPrint("STATUS: ${response.statusCode}");
    debugPrint("URL: $url");
    debugPrint("Response : ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load vendors");
    }

    final decoded = json.decode(response.body);

    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? "Unknown error");
    }

    return (decoded['data'] as List).map((e) => Vendor.fromJson(e)).toList();
  }

  Future<List<BoatBookingDetail>> getAllBookings({
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/api/user/v1/boat-booking-details");

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
      },
    );

    final decoded = json.decode(response.body);

    final bookingResponse = BoatBookingListResponse.fromJson(decoded);

    print(url);
    print(response.body);

    return bookingResponse.data;
  }

  // UPDATE VENDOR
  Future<CreateVendorResponse> updateVendor({
    required String token,
    required int vendorId,
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse("$baseUrl/api/user/v1/vendors/$vendorId");

    final response = await http.put(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.contentTypeHeader: "application/json",
      },
      body: jsonEncode(body),
    );
    print(url);
    print(response.body);

    return CreateVendorResponse.fromJson(jsonDecode(response.body));
  }

  // DELETE VENDOR
  Future<CreateVendorResponse> deleteVendor({
    required String token,
    required int vendorId,
  }) async {
    final url = Uri.parse("$baseUrl/api/user/v1/vendors/$vendorId");

    final response = await http.delete(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
      },
    );
    print(url);
    print(response.body);

    return CreateVendorResponse.fromJson(jsonDecode(response.body));
  }

  Future<Vendor> getVendorById({
    required String token,
    required int vendorId,
  }) async {
    final url = Uri.parse("$baseUrl/api/user/v1/vendors/$vendorId");

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
      },
    );

    final decoded = json.decode(response.body);

    if (decoded["success"] == true) {
      return Vendor.fromJson(decoded["data"]);
    } else {
      throw Exception(decoded["message"] ?? "Failed to fetch vendor");
    }
  }

  Future<List<Vendor>> searchVendors({
    required String token,
    required String search,
  }) async {
    final url = Uri.parse(
      "$baseUrl/api/user/v1/search/vendors",
    ).replace(queryParameters: {"search": search});

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print(url);

    final decoded = jsonDecode(response.body);

    if (decoded["success"] == true) {
      return (decoded["data"] as List).map((e) => Vendor.fromJson(e)).toList();
    } else {
      throw Exception(decoded["message"] ?? "Search failed");
    }
  }

  Future<List<BoatBookingDetail>> searchBoatBookings({
    required String token,
    required String search,
  }) async {
    final url = Uri.parse(
      "$baseUrl/api/user/v1/search/boat-bookings",
    ).replace(queryParameters: {"search": search});

    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
      },
    );

    final decoded = jsonDecode(response.body);

    print(url);
    print(response.body);

    if (decoded["success"] == true) {
      final bookingResponse = BoatBookingListResponse.fromJson(decoded);

      return bookingResponse.data;
    } else {
      throw Exception(decoded["message"] ?? "Search failed");
    }
  }

  Future<bool> deleteBoatBooking({
    required String token,
    required int bookingId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/api/user/v1/boat-booking-details/$bookingId",
    );

    final response = await http.delete(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
      },
    );

    final json = jsonDecode(response.body);
    print(url);
    print(response.body);

    return json['success'] == true;
  }

  Future<bool> updateBoatBooking({
    required String token,
    required int bookingId,
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse(
      "$baseUrl/api/user/v1/boat-booking-details/$bookingId",
    );

    final response = await http.put(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.contentTypeHeader: "application/json",
      },
      body: jsonEncode(body),
    );

    final json = jsonDecode(response.body);

    return json['success'] == true;
  }
  
}
class UnauthenticatedException implements Exception {
  const UnauthenticatedException();
}

