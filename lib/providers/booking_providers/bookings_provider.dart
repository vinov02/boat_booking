import 'dart:async';

import 'package:boat_booking/api/api.dart';
import 'package:boat_booking/core/utils/constants.dart';
import 'package:boat_booking/core/utils/shared_pref_manager.dart';
import 'package:boat_booking/model/user_full_response.dart';
import 'package:flutter/material.dart';

class BookingsProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSearching = false;

  List<BoatBookingDetail> bookings = [];
  List<BoatBookingDetail> filteredBookings = [];

  Timer? _debounce;

  // ---------------- LOAD ----------------
  Future<void> loadBookings() async {
    try {
      isLoading = true;
      notifyListeners();

      final token =
          await SharedPrefManager.getString(Constants.USER_TOKEN);
      if (token == null) return;

      bookings = await Api().getAllBookings(token: token);
      filteredBookings = bookings;
    } catch (e) {
      debugPrint("Bookings load error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- SEARCH ----------------
  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.isEmpty) {
        filteredBookings = bookings;
        notifyListeners();
      } else {
        _searchBookings(query);
      }
    });
  }

  Future<void> _searchBookings(String query) async {
    try {
      isSearching = true;
      notifyListeners();

      final token =
          await SharedPrefManager.getString(Constants.USER_TOKEN);
      if (token == null) return;

      filteredBookings = await Api().searchBoatBookings(
        token: token,
        search: query,
      );
    } catch (e) {
      debugPrint("Booking search error: $e");
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
