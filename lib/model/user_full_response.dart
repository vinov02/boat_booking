import 'package:boat_booking/model/vendor.dart';

class UserFullResponse {
  final bool? success;
  final String? status;
  final String? message;
  final UserData? data;

  UserFullResponse({this.success, this.status, this.message, this.data});

  factory UserFullResponse.fromJson(Map<String, dynamic> json) {
    return UserFullResponse(
      success: json['success'],
      status: json['status'],
      message: json['message'],
      data: json['data'] is Map<String, dynamic>
          ? UserData.fromJson(json['data'])
          : null,
    );
  }
}

/* ---------------- USER DATA ---------------- */

class UserData {
  final int? id;
  final String? name;
  final String? email;
  final String? role;
  final String? status;
  final UserDetail? userDetail;
  final KycDetail? kycDetail;
  final List<BankDetail> bankDetails;
  final List<BoatContact> boatContacts;

  UserData({
    this.id,
    this.name,
    this.email,
    this.role,
    this.status,
    this.userDetail,
    this.kycDetail,
    required this.bankDetails,
    required this.boatContacts,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
      userDetail: json['user_detail'] is Map<String, dynamic>
          ? UserDetail.fromJson(json['user_detail'])
          : null,
      kycDetail: json['kyc_detail'] is Map<String, dynamic>
          ? KycDetail.fromJson(json['kyc_detail'])
          : null,
      bankDetails: (json['bank_details'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => BankDetail.fromJson(e))
          .toList(),
      boatContacts: (json['boat_contacts'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => BoatContact.fromJson(e))
          .toList(),
    );
  }
}

/* ---------------- USER DETAIL ---------------- */

class UserDetail {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? location;
  final String? contact1;
  final String? contact2;
  final bool? isVerified;

  UserDetail({
    this.id,
    this.firstName,
    this.lastName,
    this.address,
    this.location,
    this.contact1,
    this.contact2,
    this.isVerified,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      address: json['address'],
      location: json['location'],
      contact1: json['contact_number_1'],
      contact2: json['contact_number_2'],
      isVerified: json['is_verified'],
    );
  }
}

/* ---------------- KYC DETAIL ---------------- */

class KycDetail {
  final String? panNumber;
  final String? aadharNumber;
  final String? kycStatus;

  KycDetail({this.panNumber, this.aadharNumber, this.kycStatus});

  factory KycDetail.fromJson(Map<String, dynamic> json) {
    return KycDetail(
      panNumber: json['pan_number'],
      aadharNumber: json['aadhar_number'],
      kycStatus: json['kyc_status'],
    );
  }
}

/* ---------------- BANK DETAIL ---------------- */

class BankDetail {
  final String? bankName;
  final String? accountNumber;
  final String? ifsc;
  final bool? isPrimary;

  BankDetail({this.bankName, this.accountNumber, this.ifsc, this.isPrimary});

  factory BankDetail.fromJson(Map<String, dynamic> json) {
    return BankDetail(
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      ifsc: json['ifsc_code'],
      isPrimary: json['is_primary'],
    );
  }
}

/* ---------------- BOAT CONTACT ---------------- */

class BoatContact {
  final int? id;
  final String? name;
  final String? phone;
  final String? priorityOrder;
  final List<BoatAvailability> availabilities;

  BoatContact({
    this.id,
    this.name,
    this.phone,
    this.priorityOrder,
    required this.availabilities,
  });

  factory BoatContact.fromJson(Map<String, dynamic> json) {
    return BoatContact(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      priorityOrder: json['priority_order'],
      availabilities: (json['boat_availabilities'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => BoatAvailability.fromJson(e))
          .toList(),
    );
  }
}

/* ---------------- AVAILABILITY ---------------- */

class BoatAvailability {
  final int? id;
  final String? status;
  final String? date;
  final String? rate;
  final CruiseType? cruiseType;
  final BoatBookingDetail? bookingDetail;

  BoatAvailability({
    this.id,
    this.status,
    this.date,
    this.rate,
    this.cruiseType,
    this.bookingDetail,
  });

  factory BoatAvailability.fromJson(Map<String, dynamic> json) {
    return BoatAvailability(
      id: json['id'],
      status: json['status'],
      date: json['date'],
      rate: json['rate']?.toString(),
      cruiseType: json['cruise_type'] is Map<String, dynamic>
          ? CruiseType.fromJson(json['cruise_type'])
          : null,
      bookingDetail: json['boat_booking_detail'] is Map<String, dynamic>
          ? BoatBookingDetail.fromJson(json['boat_booking_detail'])
          : null,
    );
  }
}

/* ---------------- BOOKING DETAIL ---------------- */

class BoatBookingDetail {
  final int? id;
  final String? bookingDate;
  final String? checkin;
  final String? checkout;
  final String? acStartTime;
  final String? acEndTime;
  final int? passangers;
  final int? kids;
  final String? rate;
  final String? collectionAmount;
  final int? vegCount;
  final int? nonVegCount;
  final int? jainFood;
  final String? name;
  final String? phone;
  final String? note;
  final CruiseType? cruiseType;
  final Category? category;
  final Vendor? vendor;

  BoatBookingDetail({
    this.id,
    this.bookingDate,
    this.checkin,
    this.checkout,
    this.acStartTime,
    this.acEndTime,
    this.passangers,
    this.kids,
    this.rate,
    this.collectionAmount,
    this.vegCount,
    this.nonVegCount,
    this.jainFood,
    this.name,
    this.phone,
    this.note,
    this.cruiseType,
    this.category,
    this.vendor,
  });

  factory BoatBookingDetail.fromJson(Map<String, dynamic> json) {
    return BoatBookingDetail(
      id: json['id'],
      bookingDate: json['booking_date'],
      checkin: json['checkin_date_time'],
      checkout: json['checkout_date_time'],
      acStartTime: json['ac_time_start'],
      acEndTime: json['ac_time_out'],
      passangers: json['passangers'],
      kids: json['kids'],
      rate: json['rate']?.toString(),
      collectionAmount: json['collection_amount']?.toString(),
      vegCount: json['veg_food'],
      nonVegCount: json['non_veg_food'],
      jainFood: json['jain_food'],
      name: json['name'],
      phone: json['phone'],
      note: json['note'],
      cruiseType: json['cruise_type'] is Map<String, dynamic>
          ? CruiseType.fromJson(json['cruise_type'])
          : null,
      category: json['category'] is Map<String, dynamic>
          ? Category.fromJson(json['category'])
          : null,
      vendor: json['vendor'] is Map<String, dynamic>
          ? Vendor.fromJson(json['vendor'])
          : null,
    );
  }
}

/* ---------------- COMMON ---------------- */

class CruiseType {
  final int? id;
  final String? name;

  CruiseType({this.id, this.name});

  factory CruiseType.fromJson(Map<String, dynamic> json) {
    return CruiseType(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Category {
  final int? id;
  final String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}
