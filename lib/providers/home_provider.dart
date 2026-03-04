import 'package:boat_booking/core/utils/session_timeout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:boat_booking/api/api.dart';
import 'package:boat_booking/core/utils/constants.dart';
import 'package:boat_booking/core/utils/shared_pref_manager.dart';
import 'package:boat_booking/model/user_full_response.dart';

class HomeProvider extends ChangeNotifier {
  bool isLoading = true;

  List<BoatContact> boats = [];
  BoatContact? selectedBoat;

  final Map<DateTime, BoatAvailability> availabilityMap = {};
  Future<void> loadBoatData(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await SharedPrefManager.getString(Constants.USER_TOKEN);
      final userId = await SharedPrefManager.getString(Constants.USER_ID);

      if (token == null || userId == null) {
        showSessionTimeoutDialog(context);
        return;
      }

      final response = await Api().getUserById(
        token: token,
        userId: int.parse(userId),
      );

      final newBoats = response.data?.boatContacts ?? [];

      boats = List<BoatContact>.from(newBoats);

      if (boats.isNotEmpty) {
        if (selectedBoat == null) {
          selectedBoat = boats.first;
        } else {
          selectedBoat = boats.firstWhere(
            (b) => b.id == selectedBoat!.id,
            orElse: () => boats.first,
          );
        }
      } else {
        selectedBoat = null;
      }

      _buildAvailability();
    } on UnauthenticatedException {
      showSessionTimeoutDialog(context);
    } catch (e) {
      debugPrint("HomeProvider error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Change selected boat safely
  void selectBoat(BoatContact boat) {
    selectedBoat = boats.firstWhere((b) => b.id == boat.id, orElse: () => boat);
    _buildAvailability();
    notifyListeners();
  }

  /// 🔹 Build availability map (date → availability)
  void _buildAvailability() {
    availabilityMap.clear();

    final list = selectedBoat?.availabilities ?? [];
    for (final a in list) {
      if (a.date == null) continue;

      final d = DateTime.parse(a.date!);
      availabilityMap[DateTime.utc(d.year, d.month, d.day)] = a;
    }
  }

  /// 🔹 Helpers
  bool isDateBooked(DateTime day) {
    return availabilityMap[DateTime.utc(day.year, day.month, day.day)]
            ?.status ==
        "Booked";
  }

  Color getDayColor(DateTime day) {
    final availability =
        availabilityMap[DateTime.utc(day.year, day.month, day.day)];

    if (availability == null) return Colors.transparent;

    switch (availability.status) {
      case 'Available':
        return const Color(0xFF10B981);
      case 'Booked':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }
}
