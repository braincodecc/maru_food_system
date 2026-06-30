import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  final GeoPoint geopoint;
  final String? address;

  LocationModel({
    required this.geopoint,
    this.address,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      geopoint: map['geopoint'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'geopoint': geopoint,
      'address': address,
    };
  }
}
