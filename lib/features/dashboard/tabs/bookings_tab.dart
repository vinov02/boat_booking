import 'package:boat_booking/features/booking/booking_details_screen.dart';
import 'package:boat_booking/model/user_full_response.dart';
import 'package:boat_booking/providers/booking_providers/bookings_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => BookingsTabState();
}

class BookingsTabState extends State<BookingsTab> {
  @override
  void initState() {
    super.initState();

    /// SAFE provider call after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingsProvider>().loadBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingsProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0F766E)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            searchBar(context),
            if (provider.isSearching)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.loadBookings,
                child: provider.filteredBookings.isEmpty
                    ? const Center(child: Text("No bookings found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.filteredBookings.length,
                        itemBuilder: (_, i) =>
                            bookingCard(context, provider.filteredBookings[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: context.read<BookingsProvider>().onSearchChanged,
        decoration: InputDecoration(
          hintText: "Search bookings",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
Widget bookingCard(BuildContext context, BoatBookingDetail booking) {
  String formatDate(String? iso) {
    if (iso == null) return "-";
    final d = DateTime.parse(iso);
    return "${d.day.toString().padLeft(2, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.year.toString().substring(2)}";
  }

  return InkWell(
    onTap: () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailsScreen(booking: booking),
        ),
      );

      if (result == true) {
        context.read<BookingsProvider>().loadBookings();
        // context.read<HomeProvider>().loadBoatData(context);
      }
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.name ?? "-",
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                formatDate(booking.bookingDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.phone ?? "-",
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              chip(
                booking.cruiseType?.name ?? "Cruise",
                Icons.directions_boat,
              ),
              const SizedBox(width: 8),
              chip(
                "₹ ${booking.rate}",
                Icons.currency_rupee,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
Widget chip(String text, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF0F766E).withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF0F766E)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF0F766E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
