import 'package:boat_booking/model/user_full_response.dart';
import 'package:boat_booking/providers/cruise_type_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditBookingScreen extends StatefulWidget {
  final BoatBookingDetail booking;

  const EditBookingScreen({super.key, required this.booking});

  @override
  State<EditBookingScreen> createState() => EditBookingScreenState();
}

class EditBookingScreenState extends State<EditBookingScreen> {
  // ---------------- TEXT CONTROLLERS ----------------
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController adultsCtrl;
  late TextEditingController kidsCtrl;
  late TextEditingController vegCtrl;
  late TextEditingController nonVegCtrl;
  late TextEditingController jainCtrl;
  late TextEditingController rateCtrl;
  late TextEditingController collectedCtrl;
  late TextEditingController noteCtrl;

  // ---------------- DATE & TIME ----------------
  DateTime? checkIn;
  DateTime? checkOut;

  // ---------------- DROPDOWNS ----------------
  int? selectedCruiseTypeId;
  // int? selectedVendorId;

  @override
  void initState() {
    super.initState();

    final b = widget.booking;

    nameCtrl = TextEditingController(text: b.name);
    phoneCtrl = TextEditingController(text: b.phone);
    adultsCtrl = TextEditingController(text: b.passangers?.toString() ?? "0");
    kidsCtrl = TextEditingController(text: b.kids?.toString() ?? "0");
    vegCtrl = TextEditingController(text: b.vegCount?.toString() ?? "0");
    nonVegCtrl = TextEditingController(text: b.nonVegCount?.toString() ?? "0");
    jainCtrl = TextEditingController(text: b.jainFood?.toString() ?? "0");
    rateCtrl = TextEditingController(text: b.rate?.toString() ?? "0");
    collectedCtrl = TextEditingController(
      text: b.collectionAmount?.toString() ?? "0",
    );
    noteCtrl = TextEditingController(text: b.note ?? "");

    checkIn = b.checkin != null ? DateTime.parse(b.checkin!) : null;
    checkOut = b.checkout != null ? DateTime.parse(b.checkout!) : null;

    selectedCruiseTypeId = b.cruiseType?.id;
    // selectedVendorId = b.vendor?.id;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    adultsCtrl.dispose();
    kidsCtrl.dispose();
    vegCtrl.dispose();
    nonVegCtrl.dispose();
    jainCtrl.dispose();
    rateCtrl.dispose();
    collectedCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  // ---------------- DATE PICKER ----------------
  Future<void> pickDateTime(bool isCheckIn) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isCheckIn) {
        checkIn = combined;
      } else {
        checkOut = combined;
      }
    });
  }

  // ---------------- FORMAT ----------------
  String formatDateTime(DateTime? d) {
    if (d == null) return "-";
    return "${d.day.toString().padLeft(2, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.year} "
        "${d.hour.toString().padLeft(2, '0')}:"
        "${d.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Edit Booking"),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ---------------- CUSTOMER ----------------
              section("Customer Details", [
                field("Name", nameCtrl),
                field("Phone", phoneCtrl, keyboard: TextInputType.phone),
              ]),
        
              // ---------------- DATE & TIME ----------------
              section("Booking Time", [
                dateTile("Check-in", checkIn, () => pickDateTime(true)),
                dateTile("Check-out", checkOut, () => pickDateTime(false)),
              ]),
        
              // ---------------- CRUISE ----------------
              Consumer<CruiseTypeProvider>(
                builder: (context, cruiseProvider, _) {
                  return SizedBox(
                    width: 300,
                    child: GestureDetector(
                      onTap: () {
                        cruiseProvider.loadCruiseTypes();
                      },
                      child: AbsorbPointer(
                        child: DropdownButtonFormField<int>(
                          value: selectedCruiseTypeId,
                          decoration: InputDecoration(
                            labelText: "Cruise Type",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: cruiseProvider.isLoading
                              ? []
                              : cruiseProvider.cruiseTypes.map((type) {
                                  return DropdownMenuItem<int>(
                                    value: type.id,
                                    child: Text(type.name!),
                                  );
                                }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCruiseTypeId = value;
                            });
                          },
                          hint: cruiseProvider.isLoading
                              ? const Text("Loading...")
                              : const Text("Select cruise type"),
                        ),
                      ),
                    ),
                  );
                },
              ),
        
              // ---------------- VENDOR ----------------
              // _section("Vendor", [
              //   DropdownButtonFormField<int>(
              //     value: selectedVendorId,
              //     decoration:
              //         const InputDecoration(labelText: "Vendor"),
              //     items: widget.booking.ve
              //         ?.map(
              //           (v) => DropdownMenuItem(
              //             value: v.id,
              //             child: Text(v.companyName ?? v.name ?? "-"),
              //           ),
              //         )
              //         .toList(),
              //     onChanged: (v) => setState(() => selectedVendorId = v),
              //   ),
              // ]),
        
              // ---------------- PASSENGERS ----------------
              section("Passengers", [
                field("Adults", adultsCtrl, keyboard: TextInputType.number),
                field("Kids", kidsCtrl, keyboard: TextInputType.number),
              ]),
        
              // ---------------- FOOD ----------------
              section("Food Details", [
                field("Veg", vegCtrl, keyboard: TextInputType.number),
                field("Non-Veg", nonVegCtrl, keyboard: TextInputType.number),
                field("Jain Food", jainCtrl, keyboard: TextInputType.number),
              ]),
        
              // ---------------- PAYMENT ----------------
              section("Payment", [
                field("Rate", rateCtrl, keyboard: TextInputType.number),
                field(
                  "Collected",
                  collectedCtrl,
                  keyboard: TextInputType.number,
                ),
              ]),
        
              // ---------------- NOTES ----------------
              section("Notes", [
                TextField(
                  controller: noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ]),
        
              const SizedBox(height: 20),
        
              // ---------------- SAVE ----------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0F766E),
                  ),
                  onPressed: onSave,
                  child: const Text("Save Changes",style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- SAVE PAYLOAD ----------------
  void onSave() {
    Navigator.pop(context, {
      "name": nameCtrl.text,
      "phone": phoneCtrl.text,
      "passangers": int.tryParse(adultsCtrl.text) ?? 0,
      "kids": int.tryParse(kidsCtrl.text) ?? 0,
      "veg_count": int.tryParse(vegCtrl.text) ?? 0,
      "non_veg_count": int.tryParse(nonVegCtrl.text) ?? 0,
      "jain_food": int.tryParse(jainCtrl.text) ?? 0,
      "rate": double.tryParse(rateCtrl.text) ?? 0,
      "collection_amount": double.tryParse(collectedCtrl.text) ?? 0,
      "note": noteCtrl.text,
      "checkin": checkIn?.toIso8601String(),
      "checkout": checkOut?.toIso8601String(),
      "cruise_type_id": selectedCruiseTypeId,
      // "vendor_id": selectedVendorId ?? "",
    });
  }

  // ---------------- UI HELPERS ----------------

  Widget section(String title, List<Widget> children) {
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget field(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget dateTile(String label, DateTime? value, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(formatDateTime(value)),
      trailing: const Icon(Icons.calendar_today),
      onTap: onTap,
    );
  }
}
