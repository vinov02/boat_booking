class CreateBookingResponse {
  final bool? success;
  final String? status;
  final String? message;
  final BookingData? data;

  CreateBookingResponse({this.success, this.status, this.message, this.data});

  factory CreateBookingResponse.fromJson(Map<String, dynamic> json) {
    return CreateBookingResponse(
      success: json['success'],
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? BookingData.fromJson(json['data']) : null,
    );
  }
}

class BookingData {
  final Booking? booking;
  final Availability? availability;

  BookingData({this.booking, this.availability});

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      booking: json['booking'] != null
          ? Booking.fromJson(json['booking'])
          : null,
      availability: json['availability'] != null
          ? Availability.fromJson(json['availability'])
          : null,
    );
  }
}

class Booking {
  final int? id;
  final String? bookingDate;
  final String? checkinDateTime;
  final String? checkoutDateTime;
  final String? acStartTime;
  final String? acEndTime;
  final int? passangers;
  final int? kids;
  final dynamic rate;
  final dynamic collectionAmount;
  final int? vegFood;
  final int? nonVegFood;
  final int? jainFood;
  final String? name;
  final String? phone;
  final String? note;

  Booking({
    this.id,
    this.bookingDate,
    this.checkinDateTime,
    this.checkoutDateTime,
    this.acStartTime,
    this.acEndTime,
    this.passangers,
    this.kids,
    this.rate,
    this.collectionAmount,
    this.vegFood,
    this.nonVegFood,
    this.jainFood,
    this.name,
    this.phone,
    this.note,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      bookingDate: json['booking_date'],
      checkinDateTime: json['checkin_date_time'],
      checkoutDateTime: json['checkout_date_time'],
      acStartTime: json['ac_time_start'],
      acEndTime: json['ac_time_out'],
      passangers: json['passangers'],
      kids: json['kids'],
      rate: json['rate'],
      collectionAmount: json['collection_amount'],
      vegFood: json['veg_food'],
      nonVegFood: json['non_veg_food'],
      jainFood: json['jain_food'],
      name: json['name'],
      phone: json['phone'],
      note: json['note'],
    );
  }
}

class Availability {
  final int? id;
  final String? status;
  final String? date;
  final dynamic rate;

  Availability({this.id, this.status, this.date, this.rate});

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      id: json['id'],
      status: json['status'],
      date: json['date'],
      rate: json['rate'],
    );
  }
}
