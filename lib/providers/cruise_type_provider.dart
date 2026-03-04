import 'package:boat_booking/api/api.dart';
import 'package:boat_booking/core/utils/constants.dart';
import 'package:boat_booking/core/utils/shared_pref_manager.dart';
import 'package:boat_booking/model/cruise_type.dart';
import 'package:flutter/material.dart';

class CruiseTypeProvider extends ChangeNotifier {
  bool isLoading = false;
  List<CruiseType> cruiseTypes = [];

  Future<void> loadCruiseTypes() async {
    if (cruiseTypes.isNotEmpty) return;

    try {
      isLoading = true;
      notifyListeners();

      final token =
          await SharedPrefManager.getString(Constants.USER_TOKEN);
      if (token == null) return;

      cruiseTypes = await Api().getCruiseTypes(token: token);
    } catch (e) {
      debugPrint("CRUISE TYPE LOAD ERROR: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
