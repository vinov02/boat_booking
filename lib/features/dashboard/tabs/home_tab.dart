import 'package:flutter/material.dart';
import 'package:boat_booking/features/booking/add_booking_screen.dart';
import 'package:boat_booking/model/user_full_response.dart';
import 'package:boat_booking/providers/home_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool isPastDate(DateTime day) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final checkDate = DateTime(day.year, day.month, day.day);

    return checkDate.isBefore(todayDate);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HomeProvider>().loadBoatData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

    if (home.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0F766E)),
      );
    }

    if (home.boats.isEmpty) {
      return const Center(child: Text("No boats found"));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          await home.loadBoatData(context);
        },
        color: const Color(0xFF0F766E),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Boat",
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              _buildBoatDropdown(home),
              const SizedBox(height: 16),
              Text(
                "Availability Calendar",
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              _buildCalendar(home),
              const SizedBox(height: 10),
              if (_selectedDay == null)
                const Text(
                  "Select a date to view availability",
                  style: TextStyle(color: Colors.grey),
                )
              else
                _buildAvailabilityInfo(home),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // BOAT DROPDOWN (SAFE)
  // ------------------------------------------------
  Widget _buildBoatDropdown(HomeProvider home) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: home.selectedBoat?.id,
          isExpanded: true,
          items: home.boats.map((boat) {
            return DropdownMenuItem<int>(
              value: boat.id,
              child: Row(
                children: [
                  const Icon(Icons.directions_boat, color: Color(0xFF0F766E)),
                  const SizedBox(width: 12),
                  Text(
                    boat.name ?? "Boat",
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (boatId) {
            if (boatId == null) return;
            final boat = home.boats.firstWhere((b) => b.id == boatId);
            home.selectBoat(boat);
            setState(() => _selectedDay = null);
          },
        ),
      ),
    );
  }

  // ------------------------------------------------
  // CALENDAR (ALL INTERACTIONS RESTORED)
  // ------------------------------------------------
  Widget _buildCalendar(HomeProvider home) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),

        focusedDay: _focusedDay,

        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

        /// SINGLE TAP → select & show availability
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },

        /// MONTH SWIPE / ARROWS
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },

        /// HEADER TAP → PICK YEAR & MONTH
        onHeaderTapped: (focusedDay) {
          _showMonthYearPicker();
        },

        /// LONG PRESS → booking or warning
        onDayLongPressed: (day, _) {
          if (isPastDate(day)) {
            _showPastDateMessage();
          } else {
            _showBookingBottomSheet(home, day);
          }
        },

        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left),
          rightChevronIcon: Icon(Icons.chevron_right),
        ),

        calendarStyle: const CalendarStyle(outsideDaysVisible: false),

        calendarBuilders: CalendarBuilders(
          /// PAST DATES (optional visual cue)
          disabledBuilder: (context, day, _) {
            if (isPastDate(day)) {
              return Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              );
            }
            return null;
          },

          /// AVAILABLE / BOOKED COLORS
          defaultBuilder: (context, day, _) {
            final color = home.getDayColor(day);
            if (color == Colors.transparent) return null;

            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                border: Border.all(color: color, width: 1.5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showMonthYearPicker() {
    showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _focusedDay = DateTime(pickedDate.year, pickedDate.month);
        });
      }
    });
  }

  void _showPastDateMessage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_busy, size: 42, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                "Booking Not Allowed",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "You cannot create a booking for past dates.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK",style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------
  // LONG PRESS → BOTTOM SHEET
  // ------------------------------------------------
  void _showBookingBottomSheet(HomeProvider home, DateTime day) {
    final availability =
        home.availabilityMap[DateTime.utc(day.year, day.month, day.day)];

    final isBooked = availability?.status == "Booked";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ───── Drag Handle ─────
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              /// ───── Header ─────
              Row(
                children: [
                  Icon(
                    isBooked ? Icons.event_busy : Icons.event_available,
                    color: isBooked ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBooked ? "Date Booked" : "Date Available",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              /// ───── Warning Card (Booked) ─────
              if (isBooked)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "This date already has bookings. You can still add another cruise booking.",
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              /// ───── Section Title ─────
              Text(
                "Create New Booking",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F766E),
                ),
              ),

              const SizedBox(height: 14),

              /// ───── CTA Button ─────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.directions_boat, color: Colors.white),
                  label: const Text(
                    "Add Booking",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddBookingScreen(
                          selectedBoat: home.selectedBoat!.name!,
                          boatContactId: home.selectedBoat!.id!,
                          bookingDate: day,
                        ),
                      ),
                    ).then((v) {
                      if (v == true) home.loadBoatData(context);
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------
  // AVAILABILITY INFO CARD
  // ------------------------------------------------
  Widget _buildAvailabilityInfo(HomeProvider home) {
  final selected = _selectedDay!;
  final isPast = isPastDate(selected);

  final availability = home.availabilityMap[
    DateTime.utc(
      selected.year,
      selected.month,
      selected.day,
    )
  ];

  /// ---------------- PAST DATE + NO BOOKING ----------------
  if (isPast && availability == null) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.4)),
      ),
      child: Row(
        children: const [
          Icon(Icons.block, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Booking not available for past dates",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- NO BOOKING (TODAY / FUTURE) ----------------
  if (availability == null) {
    return _availableCard(home);
  }

  final isBooked = availability.status == "Booked";
  final color = isBooked ? Colors.red : Colors.green;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// STATUS ROW
        Row(
          children: [
            Icon(
              isBooked ? Icons.event_busy : Icons.event_available,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              availability.status ?? "",
              style: GoogleFonts.lato(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// BOOKED → VIEW DETAILS (PAST + FUTURE)
        if (isBooked && availability.bookingDetail != null)
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.visibility),
              label: const Text(
                "View Booking Details",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _showBookingDetailsDialog(
                  context,
                  availability.bookingDetail!,
                );
              },
            ),
          ),

        /// AVAILABLE → ADD BOOKING (ONLY TODAY / FUTURE)
        if (!isBooked && !isPast)
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text(
                "Available – Add Booking",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
              ),
              onPressed: () {
                _showBookingBottomSheet(home, selected);
              },
            ),
          ),
      ],
    ),
  );
}
Widget _availableCard(HomeProvider home) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.green.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.green.withOpacity(0.3)),
    ),
    child: Row(
      children: const [
        Icon(Icons.event_available, color: Colors.green),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            "Available for Booking",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}


  // ------------------------------------------------
  // BOOKING DETAILS DIALOG
  // ------------------------------------------------
  void _showBookingDetailsDialog(
    BuildContext context,
    BoatBookingDetail booking,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Booking Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow("Customer", booking.name),
              _detailRow("Phone", booking.phone),
              _detailRow("Passengers", booking.passangers?.toString()),
              _detailRow("Kids", booking.kids?.toString()),
              _detailRow("Rate", "₹ ${booking.rate}"),
              _detailRow("Collected", "₹ ${booking.collectionAmount}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? "-")),
        ],
      ),
    );
  }
}