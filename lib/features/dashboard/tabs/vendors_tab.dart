import 'package:boat_booking/core/enum/vendor_action_result.dart';
import 'package:boat_booking/features/vendor/add_vendor_screen.dart';
import 'package:boat_booking/features/vendor/vendor_detail_screen.dart';
import 'package:boat_booking/model/vendor.dart';
import 'package:boat_booking/providers/vendors_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class VendorsTab extends StatefulWidget {
  const VendorsTab({super.key});

  @override
  State<VendorsTab> createState() => VendorsTabState();
}

class VendorsTabState extends State<VendorsTab> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorsProvider>().loadVendors();
    });

    searchController.addListener(() {
      context.read<VendorsProvider>().onSearchChanged(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------
  // UI
  // ------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Consumer<VendorsProvider>(
      builder: (context, provider, _) {
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
                buildSearchBar(),
            
                if (provider.isSearching)
                  const LinearProgressIndicator(minHeight: 2),
            
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: context.read<VendorsProvider>().loadVendors,
                    child: provider.filteredVendors.isEmpty
                        ? const Center(child: Text("No vendors found"))
                        : ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: provider.filteredVendors.length,
                            itemBuilder: (context, index) {
                              return vendorCard(
                                context,
                                provider.filteredVendors[index],
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF0F766E),
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddVendorScreen()));
              if(result == true){
                context.read<VendorsProvider>().loadVendors();
              }
            },
          ),
        );
      },
    );
  }

  // ------------------------------------------------------
  // SEARCH BAR
  // ------------------------------------------------------
  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search vendors, company, etc...",
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

  // ------------------------------------------------------
  // VENDOR CARD
  // ------------------------------------------------------
  Widget vendorCard(BuildContext context, Vendor vendor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          vendor.companyName!,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(vendor.name!, style: GoogleFonts.lato(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VendorDetailScreen(vendor: vendor),
            ),
          );

          if (result == VendorActionResult.updated ||
              result == VendorActionResult.deleted) {
            context.read<VendorsProvider>().loadVendors();
          }
        },
      ),
    );
  }
}
