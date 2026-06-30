import 'location_model.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final LocationModel? location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastOrderAt;
  final bool active;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.location,
    required this.createdAt,
    this.updatedAt,
    this.lastOrderAt,
    this.active = true,
  });

  factory CustomerModel.fromMap(String id, Map<String, dynamic> map) {
    return CustomerModel(
      id: id,
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      location: map['location'] != null
          ? LocationModel.fromMap(map['location'])
          : null,
      createdAt: map['createdAt'].toDate(),
      updatedAt: map['updatedAt']?.toDate(),
      lastOrderAt: map['lastOrderAt']?.toDate(),
      active: map['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'location': location?.toMap(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastOrderAt': lastOrderAt,
      'active': active,
    };
  }

  CustomerModel copyWith({
    String? name,
    String? phone,
    String? address,
    LocationModel? location,
    DateTime? lastOrderAt,
    bool? active,
  }) {
    return CustomerModel(
      id: this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      location: location ?? this.location,
      createdAt: this.createdAt,
      lastOrderAt: lastOrderAt ?? this.lastOrderAt,
      active: active ?? this.active,
    );
  }
}
