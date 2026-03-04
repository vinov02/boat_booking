import 'package:boat_booking/api/api.dart';
import 'package:boat_booking/features/auth/login_screen.dart';
import 'package:boat_booking/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:boat_booking/core/utils/constants.dart';
import 'package:boat_booking/core/utils/shared_pref_manager.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userName = "User";
  String userEmail = "user@email.com";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name =
        await SharedPrefManager.getString(Constants.USER_NAME);
    final email =
        await SharedPrefManager.getString(Constants.USER_EMAIL);

    if (!mounted) return;

    setState(() {
      userName = name ?? "User";
      userEmail = email ?? "user@email.com";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF0F766E),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: Color(0xFF0F766E),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= MENU =================
          _drawerItem(
            icon: Icons.dashboard_outlined,
            title: "Dashboard",
            onTap: () => Navigator.pop(context),
          ),
          _drawerItem(
            icon: Icons.directions_boat_outlined,
            title: "My Boats",
            onTap: () => Navigator.pop(context),
          ),
          _drawerItem(
            icon: Icons.calendar_today_outlined,
            title: "Bookings",
            onTap: () => Navigator.pop(context),
          ),
          _drawerItem(
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () => Navigator.pop(context),
          ),

          const Spacer(),
          const Divider(),

          _drawerItem(
            icon: Icons.logout,
            title: "Logout",
            isLogout: true,
            onTap: () {
              _logout();
              // ToDo : clear token & navigate to login
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
Future<void> _logout() async {
    try {
      final token =
          await SharedPrefManager.getString(Constants.USER_TOKEN);

      if (token == null) {
        _showError(context, "Session expired. Please login again.");
        return;
      }

      final value = await Api()
          .logout(token)
          .timeout(const Duration(seconds: 20));

      if (value.success == true) {
        await SharedPrefManager.clear();
        context.read<DashboardProvider>().reset();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        _showError(
          context,
          value.message ?? "Logout failed",
        );
      }
    } catch (_) {
      _showError(
        context,
        "Something went wrong. Please try again.",
      );
    }
  }

   void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  // ================= DRAWER ITEM =================
  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.red : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}
