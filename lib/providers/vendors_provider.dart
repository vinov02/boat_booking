import 'dart:async';

import 'package:boat_booking/api/api.dart';
import 'package:boat_booking/core/utils/constants.dart';
import 'package:boat_booking/core/utils/shared_pref_manager.dart';
import 'package:boat_booking/model/vendor.dart';
import 'package:flutter/material.dart';

class VendorsProvider extends ChangeNotifier {
  bool isLoading = true;
  bool isSearching = false;

  List<Vendor> vendors = [];
  List<Vendor> filteredVendors = [];

  Timer? _debounce;

  // ------------------------------------------------------
  // INIT
  // ------------------------------------------------------
  Future<void> loadVendors() async {
    try {
      isLoading = true;
      notifyListeners();

      final token =
          await SharedPrefManager.getString(Constants.USER_TOKEN);
      if (token == null) return;

      vendors = await Api().getVendors(token: token);
      filteredVendors = vendors;
    } catch (e) {
      debugPrint("Vendor load error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------------------------------
  // SEARCH WITH DEBOUNCE
  // ------------------------------------------------------
  void onSearchChanged(String query) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        filteredVendors = vendors;
        notifyListeners();
      } else {
        searchVendors(query.trim());
      }
    });
  }

  // ------------------------------------------------------
  // BACKEND SEARCH
  // ------------------------------------------------------
  Future<void> searchVendors(String query) async {
    try {
      isSearching = true;
      notifyListeners();

      final token =
          await SharedPrefManager.getString(Constants.USER_TOKEN);
      if (token == null) return;

      filteredVendors = await Api().searchVendors(
        token: token,
        search: query,
      );
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  // ------------------------------------------------------
  // CLEANUP
  // ------------------------------------------------------
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
