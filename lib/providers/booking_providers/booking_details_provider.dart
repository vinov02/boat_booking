import 'package:boat_booking/api/api.dart';
import 'package:boat_booking/core/utils/constants.dart';
import 'package:boat_booking/core/utils/shared_pref_manager.dart';
import 'package:boat_booking/model/user_full_response.dart';
import 'package:flutter/material.dart';

class BookingDetailsProvider extends ChangeNotifier {
  BoatBookingDetail booking;

  bool isDeleting = false;
  bool isUpdating = false;

  BookingDetailsProvider(this.booking);

  // ---------- FORMATTERS ----------
  String formatDate(String? iso) {
    if (iso == null) return "-";
    final d = DateTime.parse(iso);
    return "${d.day.toString().padLeft(2, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.year.toString().substring(2)}";
  }

  String formatDateTime(String? iso) {
    if (iso == null) return "-";
    final d = DateTime.parse(iso);
    return "${d.day.toString().padLeft(2, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.year.toString().substring(2)} "
        "${d.hour.toString().padLeft(2, '0')}:"
        "${d.minute.toString().padLeft(2, '0')}";
  }

  // ---------- UPDATE ----------
  Future<bool> updateBooking(Map<String, dynamic> payload) async {
  try {
    isUpdating = true;
    notifyListeners();

    final token =
        await SharedPrefManager.getString(Constants.USER_TOKEN);
    if (token == null) return false;

    final success = await Api().updateBoatBooking(
      token: token,
      bookingId: booking.id!,
      body: payload,
    );
    return success;
  } catch (e) {
    debugPrint("UPDATE BOOKING ERROR: $e");
    return false;
  } finally {
    isUpdating = false;
    notifyListeners();
  }
}


  // ---------- DELETE ----------
  Future<bool> deleteBooking() async {
    try {
      isDeleting = true;
      notifyListeners();

      final token =
          await SharedPrefManager.getString(Constants.USER_TOKEN);
      if (token == null) return false;

      return await Api().deleteBoatBooking(
        token: token,
        bookingId: booking.id!,
      );
    } catch (e) {
      debugPrint("DELETE BOOKING ERROR: $e");
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}
