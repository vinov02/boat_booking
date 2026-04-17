import 'package:boat_booking/providers/booking_providers/bookings_provider.dart';
import 'package:boat_booking/providers/dashboard_provider.dart';
import 'package:boat_booking/providers/home_provider.dart';
import 'package:boat_booking/providers/vendors_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/splash/splash_screen.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => VendorsProvider()),
        ChangeNotifierProvider(create: (_) => BookingsProvider()),
        // ProfileProvider()
      ],
      child: const BoatBookingApp(),
    ),
  );
}

class BoatBookingApp extends StatelessWidget {
  const BoatBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Alleppey Boat Booking',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
