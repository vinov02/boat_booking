import 'package:boat_booking/api/api.dart';
import 'package:boat_booking/core/utils/constants.dart';
import 'package:boat_booking/core/utils/shared_pref_manager.dart';
import 'package:boat_booking/features/dashboard/dashboard_screen.dart';
import 'package:boat_booking/model/category_type.dart';
import 'package:boat_booking/model/cruise_type.dart';
import 'package:boat_booking/model/vendor.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddBookingScreen extends StatefulWidget {
  final String selectedBoat;
  final DateTime bookingDate;

  final boatContactId;

  const AddBookingScreen({
    super.key,
    required this.selectedBoat,
    required this.bookingDate,
    required this.boatContactId,
  });

  @override
  State<AddBookingScreen> createState() => AddBookingScreenState();
}

class AddBookingScreenState extends State<AddBookingScreen> {
  final formKey = GlobalKey<FormState>();
  Vendor? selectedVendor;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController collectionController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController vegController = TextEditingController();
  final TextEditingController nonVegController = TextEditingController();
  final TextEditingController jainController = TextEditingController();
  final TextEditingController passengerController = TextEditingController();
  final TextEditingController kidsController = TextEditingController();
  final FocusNode cruiseFocusNode = FocusNode();
  final FocusNode categoryFocusNode = FocusNode();
  List<Vendor> vendors = [];

  bool isVendorLoading = false;
  int? selectedVendorId;

  List<CruiseType> cruiseTypes = [];
  List<CategoryType> CategoryTypes = [];

  int? selectedCategoryTypeId;
  bool isCategoryLoading = false;
  bool CategoryLoadedOnce = false;

  int? selectedCruiseTypeId;
  bool isCruiseLoading = false;
  bool cruiseLoadedOnce = false;

  int passengers = 1;
  int kids = 0;

  TimeOfDay? acStartTime;
  TimeOfDay? acEndTime;
  // int? vegCount = 0;
  // int? nonVegCount = 0;
  // int? jain_food = 0;

  DateTime? checkInDate;
  DateTime? checkOutDate;
  TimeOfDay? checkInTime;
  TimeOfDay? checkOutTime;

  @override
  void initState() {
    super.initState();
    loadCruiseTypes();
    loadCategory();
    loadVendors();
    checkInDate = widget.bookingDate;
    checkOutDate = widget.bookingDate;
  }

  @override
  void dispose() {
    kidsController.dispose();
    passengerController.dispose();
    super.dispose();
  }

  Future<void> loadVendors() async {
    try {
      final token = await SharedPrefManager.getString(Constants.USER_TOKEN);
      if (token == null) return;

      vendors = await Api().getVendors(token: token);
    } catch (e) {
      debugPrint("Vendor load error: $e");
    } finally {
      if (!mounted) return;
      setState(() => isVendorLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Add Booking", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0F766E),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                card(
                  title: "Booking Info",
                  child: Column(
                    children: [
                      infoRow("Boat", widget.selectedBoat),
                      infoRow(
                        "Booking Date",
                        "${widget.bookingDate.day}-${widget.bookingDate.month}-${widget.bookingDate.year}",
                      ),
                    ],
                  ),
                ),
        
                DropdownSearch<Vendor>(
                  items: vendors,
                  selectedItem: selectedVendor,
        
                  itemAsString: (Vendor v) =>
                      "${v.companyName ?? 'Unknown Company'}"
                      " [${v.name ?? 'Unknown'}]",
        
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
        
                    /// 🔥 This hides the visible search bar
                    searchFieldProps: TextFieldProps(
                      autofocus: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: "Type to search...",
                      ),
                    ),
        
                    itemBuilder: (context, vendor, isSelected) {
                      return ListTile(
                        title: Text(
                          vendor.companyName ?? "Unknown Company",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(vendor.name ?? "Unknown"),
                      );
                    },
                  ),
        
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Vendor",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
        
                  onChanged: (vendor) {
                    setState(() {
                      selectedVendor = vendor;
                      selectedVendorId = vendor?.id;
                    });
                  },
        
                  validator: (vendor) =>
                      vendor == null ? "Please select vendor" : null,
                ),
        
                SizedBox(height: 20),
        
                card(
                  title: "Trip Details",
                  child: Column(
                    children: [
                      datePickerTile(
                        label: "Check-in Date",
                        date: checkInDate,
                        onPick: (d) => setState(() => checkInDate = d),
                      ),
                      timePickerTile(
                        label: "Check-in Time",
                        time: checkInTime,
                        onPick: (t) => setState(() => checkInTime = t),
                      ),
        
                      datePickerTile(
                        label: "Check-out Date",
                        date: checkOutDate,
                        onPick: (d) => setState(() => checkOutDate = d),
                      ),
                      timePickerTile(
                        label: "Check-out Time",
                        time: checkOutTime,
                        onPick: (t) => setState(() => checkOutTime = t),
                      ),
        
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select Category",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      DropdownButtonFormField<int>(
                        value: selectedCruiseTypeId,
                        decoration: InputDecoration(
                          labelText: "Cruise Type",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: isCruiseLoading
                            ? []
                            : cruiseTypes.map((type) {
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
                        validator: (value) =>
                            value == null ? "Please select cruise type" : null,
                        hint: isCruiseLoading
                            ? const Text("Loading...")
                            : const Text("Select cruise type"),
                      ),
        
                      SizedBox(height: 20),
                      DropdownButtonFormField<int>(
                        value: selectedCategoryTypeId,
                        decoration: InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: isCategoryLoading
                            ? []
                            : CategoryTypes.map((type) {
                                return DropdownMenuItem<int>(
                                  value: type.id,
                                  child: Text(type.name),
                                );
                              }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategoryTypeId = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? "Please select category" : null,
                        hint: isCategoryLoading
                            ? const Text("Loading...")
                            : const Text("Select Category"),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: passengerController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: "Enter number of Passengers",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter number of passengers";
                          }
                          final n = int.tryParse(value);
                          if (n == null || n <= 0) {
                            return "Enter a valid number";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          passengers = int.tryParse(value) ?? 0; // ✅ INT
                        },
                      ),
        
                      SizedBox(height: 20),
        
                      TextFormField(
                        controller: kidsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: "Enter number of Kids",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter number of kids";
                          }
                          final n = int.tryParse(value);
                          if (n == null || n < 0) {
                            return "Enter a valid number";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          kids = int.tryParse(value) ?? 0;
                        },
                      ),
        
                      SizedBox(height: 20),
        
                      materialField(
                        "Enter Rate (₹)",
                        rateController,
                        keyboard: TextInputType.number,
                      ),
                      materialField(
                        "Enter Collection Amount (₹)",
                        collectionController,
                        keyboard: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: timePickerField(
                              label: "AC Start Time",
                              time: acStartTime?.format(context),
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: acStartTime ?? TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() => acStartTime = picked);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: timePickerField(
                              label: "AC End Time",
                              time: acEndTime?.format(context),
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: acEndTime ?? TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() => acEndTime = picked);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
        
                      const SizedBox(height: 16),
        
                      // ---------------- FOOD COUNTS ----------------
                    ],
                  ),
                ),
                card(
                  title: "Food Count",
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: numberInputField(
                              label: "Veg Count",
                              controller: vegController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: numberInputField(
                              label: "Non-Veg Count",
                              controller: nonVegController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      numberInputField(
                        label: "Jain Food Count",
                        controller: jainController,
                      ),
                    ],
                  ),
                ),
                card(
                  title: "Customer Details",
                  child: Column(
                    children: [
                      materialField("Enter Customer Name", nameController),
                      materialField(
                        "Enter Phone Number",
                        phoneController,
                        keyboard: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
        
                card(
                  title: "Additional Notes",
                  child: materialField(
                    "Special requests",
                    noteController,
                    maxLines: 3,
                  ),
                ),
        
                const SizedBox(height: 20),
        
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: submitBooking,
                    child: const Text(
                      "Confirm Booking",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loadCruiseTypes() async {
    if (cruiseLoadedOnce) return;

    try {
      setState(() => isCruiseLoading = true);

      final token = await SharedPrefManager.getString(Constants.USER_TOKEN);
      if (token == null) return;

      cruiseTypes = await Api().getCruiseTypes(token: token);
      cruiseLoadedOnce = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        cruiseFocusNode.requestFocus();
      });
    } catch (e) {
      snack("Failed to load cruise types");
    } finally {
      setState(() => isCruiseLoading = false);
    }
  }

  Future<void> loadCategory() async {
    if (CategoryLoadedOnce) return;

    try {
      setState(() => isCategoryLoading = true);

      final token = await SharedPrefManager.getString(Constants.USER_TOKEN);
      if (token == null) return;

      CategoryTypes = await Api().getCategoryTypes(token: token);
      CategoryLoadedOnce = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        categoryFocusNode.requestFocus();
      });
    } catch (e) {
      snack("Failed to load cruise types");
    } finally {
      setState(() => isCategoryLoading = false);
    }
  }

  // =========================
  // SUBMIT
  // =========================
  Future<void> submitBooking() async {
    if (!formKey.currentState!.validate()) return;

    if (checkInDate == null ||
        checkOutDate == null ||
        checkInTime == null ||
        checkOutTime == null) {
      snack("Please select date & time");
      return;
    }

    final checkIn = combine(checkInDate!, checkInTime!);
    final checkOut = combine(checkOutDate!, checkOutTime!);

    if (!checkOut.isAfter(checkIn)) {
      snack("Checkout must be after check-in");
      return;
    }
    if (selectedCruiseTypeId == null) {
      snack("Please select cruise type");
      return;
    }

    if (selectedCategoryTypeId == null) {
      snack("Please select category");
      return;
    }

    try {
      final token = await SharedPrefManager.getString(Constants.USER_TOKEN);

      if (token == null) {
        snack("Session expired. Please login again.");
        return;
      }

      // final payload = {
      //   "boat_contact_id": widget.boatContactId,
      //   "booking_date": checkInDate!.toIso8601String().split('T')[0],
      //   "checkin_date_time": checkIn.toIso8601String(),
      //   "checkout_date_time": checkOut.toIso8601String(),
      //   "passangers": passengers,
      //   "kids": kids,
      //   "rate": double.tryParse(rateController.text) ?? 0,
      //   "collection_amount": double.tryParse(collectionController.text) ?? 0,
      //   "veg_food": vegCount,
      //   "non_veg_food": nonVegCount,
      //   "ac_time_start": acStartTime,
      //   "ac_time_out": acEndTime,
      //   "name": nameController.text,
      //   "phone": phoneController.text,
      //   "note": noteController.text,
      //   "cruise_type_id": selectedCruiseTypeId,
      // };
      //
      final payload = {
        "boat_contact_id": widget.boatContactId,
        "vendor_id": selectedVendorId,
        "booking_date": checkInDate!.toIso8601String().split('T')[0],
        "checkin_date_time": checkIn.toIso8601String(),
        "checkout_date_time": checkOut.toIso8601String(),
        "passangers": passengers,
        "kids": kids,
        "rate": double.tryParse(rateController.text) ?? 0,
        "collection_amount": double.tryParse(collectionController.text) ?? 0,
        "ac_time_start": acStartTime != null
            ? combineDateAndTime(checkInDate!, acStartTime!).toIso8601String()
            : null,
        "ac_time_out": acEndTime != null
            ? combineDateAndTime(checkInDate!, acEndTime!).toIso8601String()
            : null,
        "veg_food": vegController.text,
        "non_veg_food": nonVegController.text,
        "jain_food": jainController.text,
        "name": nameController.text,
        "phone": phoneController.text,
        "note": noteController.text,
        "cruise_type_id": selectedCruiseTypeId,
        "category_id": selectedCategoryTypeId,
      };

      debugPrint("BOOKING PAYLOAD => $payload");
      final response = await Api()
          .createBoatBooking(token: token, body: payload)
          .timeout(const Duration(seconds: 20));

      if (response.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Booking created successfully"),
            backgroundColor: Colors.green,
          ),
        );
        // _snack("Booking created successfully");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        snack(response.message ?? "Booking failed");
      }
    } catch (e) {
      debugPrint("BOOKING ERROR: $e");
      snack("Something went wrong. Try again.");
    }
  }

  DateTime combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // =========================
  // UI HELPERS
  // =========================
  Widget card({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget materialField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontSize: 12),
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  

  Widget timePickerTile({
    required String label,
    required TimeOfDay? time,
    required Function(TimeOfDay) onPick,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(
        time == null ? "Select" : time.format(context),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) onPick(picked);
      },
    );
  }

  Widget datePickerTile({
    required String label,
    required DateTime? date,
    required Function(DateTime) onPick,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(
        date == null ? "Select" : "${date.day}-${date.month}-${date.year}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPick(picked);
      },
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

Widget timePickerField({
  required String label,
  required String? time,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(time ?? "Select Time", style: const TextStyle(fontSize: 14)),
    ),
  );
}

Widget numberInputField({
  required String label,
  required TextEditingController controller,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return "Required";
      if (int.tryParse(value) == null) return "Enter valid number";
      return null;
    },
  );
}

DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
