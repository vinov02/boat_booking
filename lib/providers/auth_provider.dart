import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/api.dart';
import '../core/utils/constants.dart';
import '../core/utils/shared_pref_manager.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isLoggedIn = false;

  String? token;
  String? userName;
  String? userEmail;
  String? errorMessage;

  Future<void> init() async {
    isLoggedIn =
        await SharedPrefManager.getBool(Constants.IS_LOGEDIN) ?? false;

    if (isLoggedIn) {
      token = await SharedPrefManager.getString(Constants.USER_TOKEN);
      userName = await SharedPrefManager.getString(Constants.USER_NAME);
      userEmail = await SharedPrefManager.getString(Constants.USER_EMAIL);
      if (token == null || token!.isEmpty) {
        await forceLogout();
      }
    }

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage = "Email and password required";
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final body = jsonEncode({
        "email": email,
        "password": password,
      });

      final response = await Api().login(body);

      if (response.success == true) {
        await SharedPrefManager.setString(Constants.USER_TOKEN, response.accessToken!);
        await SharedPrefManager.setString(Constants.USER_ID, response.data!.user!.id!.toString());
        await SharedPrefManager.setString(Constants.USER_NAME, response.data!.user!.name!);
        await SharedPrefManager.setString(Constants.USER_EMAIL, response.data!.user!.email!);
        await SharedPrefManager.setBool(Constants.IS_LOGEDIN, true);

        token = response.accessToken;
        userName = response.data!.user!.name;
        userEmail = response.data!.user!.email;
        isLoggedIn = true;

        return true;
      } else {
        errorMessage = response.error ?? "Invalid credentials";
        return false;
      }
    } catch (_) {
      errorMessage = "Something went wrong. Please try again.";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      final token = await SharedPrefManager.getString(Constants.USER_TOKEN);

      if (token != null && token.isNotEmpty) {
        await Api().logout(token).timeout(
          const Duration(seconds: 10),
        );
      }
    } catch (_) {

    } finally {
      await forceLogout();
    }
  }

  Future<void> forceLogout() async {
    await SharedPrefManager.clear();

    token = null;
    userName = null;
    userEmail = null;
    isLoggedIn = false;

    notifyListeners();
  }
}
