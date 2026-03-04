import 'package:boat_booking/api/api.dart';
import 'package:boat_booking/core/utils/constants.dart';
import 'package:boat_booking/core/utils/shared_pref_manager.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String userName = "User";
  bool isLoggingOut = false;
  String? errorMessage;

  Future<void> loadUser() async {
    final name =
        await SharedPrefManager.getString(Constants.USER_NAME);
    userName = name ?? "User";
    notifyListeners();
  }

  Future<bool> logout() async {
  try {
    isLoggingOut = true;
    errorMessage = null;
    notifyListeners();

    final token =
        await SharedPrefManager.getString(Constants.USER_TOKEN);

    // 🔥 If token missing → logout locally
    if (token == null) {
      await _forceLocalLogout();
      return true;
    }

    try {
      final response = await Api()
          .logout(token)
          .timeout(const Duration(seconds: 20));

      // ✅ Logout success
      if (response.success == true) {
        await _forceLocalLogout();
        return true;
      }

      // ❌ API failed but still logout locally
      await _forceLocalLogout();
      return true;
    } catch (e) {
      // 🔥 Token expired / network / timeout
      await _forceLocalLogout();
      return true;
    }
  } finally {
    isLoggingOut = false;
    notifyListeners();
  }
}

  void clearError() {
  errorMessage = null;
  notifyListeners();
}
}
Future<void> _forceLocalLogout() async {
  await SharedPrefManager.clear();
}