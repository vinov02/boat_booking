import 'package:boat_booking/api/api.dart';
import 'package:boat_booking/core/enum/vendor_action_result.dart';
import 'package:boat_booking/core/utils/constants.dart';
import 'package:boat_booking/core/utils/shared_pref_manager.dart';
import 'package:boat_booking/model/vendor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class VendorDetailScreen extends StatefulWidget {
  final Vendor vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  @override
  State<VendorDetailScreen> createState() => VendorDetailScreenState();
}

class VendorDetailScreenState extends State<VendorDetailScreen> {
  late Vendor vendor;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    vendor = widget.vendor;
  }

  // --------------------------------------------------
  // REFRESH VENDOR
  // --------------------------------------------------
  Future<void> reloadVendor() async {
    try {
      setState(() => isLoading = true);

      final token = await SharedPrefManager.getString(Constants.USER_TOKEN);
      if (token == null) return;

      final updatedVendor = await Api().getVendorById(
        token: token,
        vendorId: vendor.id!,
      );

      if (mounted) {
        setState(() {
          vendor = updatedVendor;
        });
      }
    } catch (_) {
      safeSnack("Failed to refresh vendor");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        title: Text(
          vendor.companyName!,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      floatingActionButton: actionButtons(),

      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF0F766E),
          onRefresh: reloadVendor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                headerCard(),
                const SizedBox(height: 16),
                infoCard(Icons.person, "Vendor Name", vendor.name!),
                infoCard(Icons.phone, "Phone Number", vendor.phone1 ?? "-"),
                infoCard(
                  Icons.phone_android,
                  "Alternate Phone",
                  vendor.phone2 ?? "-",
                ),
                infoCard(
                  Icons.location_on,
                  "Address",
                  vendor.address ?? "-",
                  multiline: true,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER CARD
  // --------------------------------------------------
  Widget headerCard() {
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
            vendor.companyName!,
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            vendor.name!,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // INFO CARD
  // --------------------------------------------------
  Widget infoCard(
    IconData icon,
    String title,
    String value, {
    bool multiline = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      ),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF0F766E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // FLOATING BUTTONS
  // --------------------------------------------------
  Widget actionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "edit",
          backgroundColor: const Color(0xFF0F766E),
          onPressed: showEditSheet,
          child: const Icon(Icons.edit, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "delete",
          backgroundColor: Colors.red,
          onPressed: showDeleteSheet,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // EDIT VENDOR
  // --------------------------------------------------
  void showEditSheet() {
    final company = TextEditingController(text: vendor.companyName);
    final name = TextEditingController(text: vendor.name);
    final phone1 = TextEditingController(text: vendor.phone1);
    final phone2 = TextEditingController(text: vendor.phone2);
    final address = TextEditingController(text: vendor.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              editField("Company Name", company),
              editField("Contact Name", name),
              editField("Phone 1", phone1),
              editField("Phone 2", phone2),
              editField("Address", address, maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await updateVendor({
                      "company_name": company.text.trim(),
                      "name": name.text.trim(),
                      "phone1": phone1.text.trim(),
                      "phone2": phone2.text.trim(),
                      "address": address.text.trim(),
                    });
                  },
                  child: const Text(
                    "Update Vendor",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget editField(String label, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> updateVendor(Map<String, dynamic> body) async {
    try {
      final token = await SharedPrefManager.getString(Constants.USER_TOKEN);
      if (token == null) return;

      body.removeWhere((k, v) => v == null || v == "");

      final response = await Api().updateVendor(
        token: token,
        vendorId: vendor.id!,
        body: body,
      );

      if (response.success == true) {
        await reloadVendor();

        if (!mounted) return;

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
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Vendor updated successfully",
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
        await Future.delayed(const Duration(milliseconds: 400));

        Navigator.pop(context, VendorActionResult.updated);
      } else {
        safeSnack(response.message);
      }
    } catch (_) {
      safeSnack("Something went wrong");
    }
  }

  // --------------------------------------------------
  // DELETE
  // --------------------------------------------------
  void showDeleteSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const Icon(Icons.delete, color: Colors.red, size: 40),
              const SizedBox(height: 12),

              const Text(
                "Delete Vendor?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "This action cannot be undone.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        Navigator.of(sheetContext).pop(); 

                        final isDeleted = await deleteVendor();

                        if (!mounted) return;

                        if (isDeleted) {
                          showTopSnackBar(
                            Overlay.of(context),
                            successToast("Vendor deleted successfully"),
                            displayDuration: const Duration(seconds: 2),
                          );

                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );

                          Navigator.pop(
                            context,
                            VendorActionResult.deleted,
                          );
                        } else {
                          safeSnack("Delete failed");
                        }
                      },

                      child: const Text(
                        "Delete",
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

  Future<bool> deleteVendor() async {
  try {
    final token = await SharedPrefManager.getString(Constants.USER_TOKEN);
    if (token == null) return false;

    final response = await Api().deleteVendor(
      token: token,
      vendorId: vendor.id!,
    );

    return response.success == true;
  } catch (e) {
    debugPrint("DELETE ERROR: $e");
    return false;
  }
}


  Widget successToast(String msg) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
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
    );
  }

  void safeSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
