import 'package:boat_booking/model/user_full_response.dart';
import 'package:boat_booking/providers/booking_providers/booking_details_provider.dart';
import 'package:boat_booking/providers/cruise_type_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'edit_booking_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BoatBookingDetail booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingDetailsProvider(widget.booking),
      child: const _BookingDetailsView(),
    );
  }
}

class _BookingDetailsView extends StatelessWidget {
  const _BookingDetailsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingDetailsProvider>();
    final booking = provider.booking;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FloatingActionButton(
            heroTag: "whatsapp_fab",
            backgroundColor: const Color(0xFF25D366),
            onPressed: () => _sendWhatsAppMessage(context, booking),
            child: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(height: 12),

          // ☎️ Call FAB
          FloatingActionButton(
            heroTag: "call_fab",
            backgroundColor: Colors.blue,
            onPressed: () => _callCustomer(context, booking),
            child: const Icon(Icons.add_ic_call, color: Colors.white),
          ),
        ],
      ),

      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- CUSTOMER ----------------
            _section(
              title: "Customer Details",
              children: [
                _row("Name", booking.name),
                _row("Phone", booking.phone),
              ],
            ),

            // ---------------- BOOKING INFO ----------------
            _section(
              title: "Booking Info",
              children: [
                _row("Booking Date", provider.formatDate(booking.bookingDate)),
                _row("Check-in", provider.formatDateTime(booking.checkin)),
                _row("Check-out", provider.formatDateTime(booking.checkout)),
              ],
            ),

            // ---------------- CRUISE & VENDOR ----------------
            _section(
              title: "Cruise & Vendor",
              children: [
                _row("Cruise Type", booking.cruiseType?.name),
                _row("Vendor Company", booking.vendor?.id.toString()),
                _row("Vendor Name", booking.vendor?.name),
                _row("Vendor Phone", booking.vendor?.phone1),
              ],
            ),

            // ---------------- Ac time and Category ----------------

            _section(
              title: "Ac time & Category",
              children: [
                _row("Ac time start", formatTimeOnly(booking.acStartTime)),
                _row("Ac time end", formatTimeOnly(booking.acEndTime)),
                _row("Category", booking.category?.name),
              ],
            ),

            // ---------------- PASSENGERS ----------------
            _section(
              title: "Passengers",
              children: [
                _row("Adults", booking.passangers?.toString()),
                _row("Kids", booking.kids?.toString()),
              ],
            ),

            // ---------------- FOOD ----------------
            _section(
              title: "Food Details",
              children: [
                _row("Veg", booking.vegCount.toString()),
                _row("Non-Veg", booking.nonVegCount?.toString()),
                _row("Jain Food", booking.jainFood?.toString()),
              ],
            ),

            // ---------------- PAYMENT ----------------
            _section(
              title: "Payment",
              children: [
                _row("Rate", "₹ ${booking.rate}"),
                _row("Collected", "₹ ${booking.collectionAmount}"),
              ],
            ),

            // ---------------- NOTES ----------------
            if (booking.note != null && booking.note!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF0F766E).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          booking.note!,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ---------------- ACTIONS ----------------
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiProvider(
                            providers: [
                              ChangeNotifierProvider(
                                create: (_) => CruiseTypeProvider(),
                              ),
                            ],
                            child: EditBookingScreen(booking: booking),
                          ),
                        ),
                      );

                      if (result != null && result is Map<String, dynamic>) {
                        final success = await context
                            .read<BookingDetailsProvider>()
                            .updateBooking(result);

                        if (success && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    child: const Text("Edit"),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: provider.isDeleting
                        ? null
                        : () async {
                            final confirm = await showDeleteConfirmationSheet(
                              context,
                            );

                            if (confirm == true) {
                              final success = await provider.deleteBooking();

                              if (success && context.mounted) {
                                Navigator.pop(context, true);
                              }
                            }
                          },
                    child: provider.isDeleting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget _section({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F766E),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
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

String formatTimeOnly(String? isoString) {
  if (isoString == null || isoString.isEmpty) return "-";

  try {
    final dt = DateTime.parse(isoString).toLocal();
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  } catch (_) {
    return "-";
  }
}

// ---------------- DELETE CONFIRMATION ----------------

Future<bool?> showDeleteConfirmationSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            const Text(
              "Delete Booking?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Are you sure you want to delete this booking?",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("No"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      "Yes",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _sendWhatsAppMessage(
  BuildContext context,
  BoatBookingDetail booking,
) async {
  final phone = booking.phone;

  if (phone == null || phone.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Customer phone number not available"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final message = _buildWhatsAppMessage(booking);
  final encodedMessage = Uri.encodeComponent(message);

  final uri = Uri.parse("https://wa.me/91$phone?text=$encodedMessage");

  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unable to open WhatsApp"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

String _buildWhatsAppMessage(BoatBookingDetail b) {
  String formatDate(String? iso) {
    if (iso == null) return "-";
    final d = DateTime.parse(iso);
    return "${d.day.toString().padLeft(2, '0')} "
        "${_month(d.month)} ${d.year}";
  }

  String formatDateTime(String? iso) {
    if (iso == null) return "-";
    final d = DateTime.parse(iso);
    return "${d.day.toString().padLeft(2, '0')} "
        "${_month(d.month)} ${d.year} "
        "${_formatTime(d)}";
  }

  return '''
Hi ${b.name ?? "Customer"} 👋

Thank you for choosing *Alleppey Boating!* 🌊

*Your Alleppey Boating Booking is Confirmed!*

*Booking Summary:*
• *Status:* Confirmed
• *Phone Number:* ${b.phone ?? "-"}
• *Cruise Type:* ${b.cruiseType?.name ?? "-"}
• *Booking Date:* ${formatDate(b.bookingDate)}
• *Check-in:* ${formatDateTime(b.checkin)}
• *Check-out:* ${formatDateTime(b.checkout)}
• *Passengers:* ${b.passangers ?? 0}
• *Kids:* ${b.kids ?? 0}

💳 *Payment Details:*
• *Advance Paid:* ₹ ${_calculateBalance(b.rate, b.collectionAmount)}
• *Total Amount:* ₹ ${b.rate ?? 0}
• *Balance Due:* ₹ ${b.collectionAmount ?? 0}

📌 Balance should be paid at check-in.

''';
}

String _month(int m) {
  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  return months[m - 1];
}

String _formatTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final period = d.hour >= 12 ? "PM" : "AM";
  return "${hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $period";
}

num _toNum(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value;
  return num.tryParse(value.toString()) ?? 0;
}

String _calculateBalance(dynamic total, dynamic paid) {
  final totalAmount = _toNum(total);
  final paidAmount = _toNum(paid);

  final balance = totalAmount - paidAmount;

  // Prevent negative balance
  final safeBalance = balance < 0 ? 0 : balance;

  return safeBalance.toStringAsFixed(2);
}

Future<void> _callCustomer(
  BuildContext context,
  BoatBookingDetail booking,
) async {
  final phone = booking.phone;

  if (phone == null || phone.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Customer phone number not available"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final uri = Uri.parse("tel:$phone");

  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unable to make a call"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
