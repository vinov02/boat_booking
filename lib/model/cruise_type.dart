class CruiseType {
  final int? id;
  final String? name;

  CruiseType({
    this.id,
    this.name,
  });

  factory CruiseType.fromJson(Map<String, dynamic> json) {
    return CruiseType(
      id: json['id'],
      name: json['name'],
    );
  }
}

