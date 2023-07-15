import 'package:uuid/uuid.dart';
import 'dart:io';

class Place {
  final String id;
  final String title;
  final File image;
  final PlaceLocation location;

  Place(this.title, this.image, this.location, {id})
      : id = id ?? const Uuid().v4();
}

class PlaceLocation {
  final double latitude;
  final double longitude;
  final String address;

  const PlaceLocation(this.latitude, this.longitude, this.address);
}
