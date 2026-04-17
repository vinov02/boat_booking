import 'package:boat_booking/features/dashboard/tabs/vendors_tab.dart';
import 'package:boat_booking/features/dashboard/tabs/bookings_tab.dart';
import 'package:boat_booking/features/dashboard/tabs/home_tab.dart';
import 'package:boat_booking/features/dashboard/tabs/profile_tab.dart';
import 'package:boat_booking/providers/dashboard_provider.dart';
import 'package:boat_booking/providers/home_provider.dart';
import 'package:boat_booking/shared/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {
  
  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();

    final pages = const [
      HomeTab(),
      VendorsTab(),
      BookingsTab(),
      ProfileTab(),
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F766E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "HB Manager",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(child: pages[dashboard.currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: dashboard.currentIndex,
        onTap: (index) async{
          dashboard.changeTab(index);

          if (index == 0) {
            await context.read<HomeProvider>().loadBoatData(context);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            backgroundColor: Color(0xFF0F766E)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Vendors",
            backgroundColor: Color(0xFF0F766E)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Bookings",
            backgroundColor: Color(0xFF0F766E)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
            backgroundColor: Color(0xFF0F766E)
          ),
        ],
      ),
    );
  }
}
