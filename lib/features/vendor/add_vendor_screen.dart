import 'package:boat_booking/api/api.dart';
import 'package:boat_booking/core/utils/constants.dart';
import 'package:boat_booking/core/utils/shared_pref_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AddVendorScreen extends StatefulWidget {
  const AddVendorScreen({super.key});

  @override
  State<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen> {
  final _formKey = GlobalKey<FormState>();

  final companyController = TextEditingController();
  final nameController = TextEditingController();
  final phone1Controller = TextEditingController();
  final phone2Controller = TextEditingController();
  final addressController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F766E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Add Vendor",
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _headerCard(),
              const SizedBox(height: 16),
              _formCard(),
              const SizedBox(height: 24),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------
  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create New Vendor",
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Add vendor details for future bookings",
            style: GoogleFonts.lato(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // FORM CARD
  // --------------------------------------------------
  Widget _formCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(
                label: "Company Name",
                controller: companyController,
                icon: Icons.business,
              ),
              _field(
                label: "Contact Person",
                controller: nameController,
                icon: Icons.person,
              ),
              _field(
                label: "Phone Number",
                controller: phone1Controller,
                icon: Icons.phone,
                keyboard: TextInputType.phone,
              ),
              _field(
                label: "Alternate Phone",
                controller: phone2Controller,
                icon: Icons.phone_android,
                keyboard: TextInputType.phone,
                required: false,
              ),
              _field(
                label: "Address",
                controller: addressController,
                icon: Icons.location_on,
                maxLines: 3,
                required: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SUBMIT BUTTON
  // --------------------------------------------------
  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F766E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isLoading ? null : _submitVendor,
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Create Vendor",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // --------------------------------------------------
  // API SUBMIT
  // --------------------------------------------------
  Future<void> _submitVendor() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      final token = await SharedPrefManager.getString(Constants.USER_TOKEN);
      if (token == null) return;

      final payload = {
        "company_name": companyController.text.trim(),
        "name": nameController.text.trim(),
        "phone1": phone1Controller.text.trim(),
        "phone2": phone2Controller.text.trim(),
        "address": addressController.text.trim(),
      };

      final response = await Api()
          .createVendor(token: token, body: payload)
          .timeout(const Duration(seconds: 20));

      if (response.success) {
        showTopSnackBar(
          Overlay.of(context),
          Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center, // ✅ FIX
                children: const [
                  Icon(Icons.check_circle, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Vendor created successfully",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.2, 
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          displayDuration: const Duration(seconds: 2),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context, true);
        });
      } else {
        _snack(response.message);
      }
    } catch (_) {
      _snack("Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // --------------------------------------------------
  // HELPERS
  // --------------------------------------------------
  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (v) =>
            required && (v == null || v.isEmpty) ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
