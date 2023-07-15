import 'dart:convert';

import 'package:favourite_places/models/place.dart';
import 'package:favourite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.setLocationFn});
  final Function(PlaceLocation loc) setLocationFn;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;
  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();

    if (locationData.latitude == null || locationData.longitude == null) {
      return;
    }

    _savePlace(locationData.latitude!, locationData.longitude!);
  }

  void _savePlace(double lat, double long) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${long}&key=AIzaSyDbI9JAjr02xmnRh1uGHtBgGbwqESP3cNU');

    final resp = await http.get(url);

    final geoData = json.decode(resp.body)['results'][0]['formatted_address'];

    setState(() {
      _pickedLocation = PlaceLocation(lat, long, geoData);
      widget.setLocationFn(_pickedLocation!);
      _isGettingLocation = false;
    });
  }

  String get locationImage {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=${_pickedLocation!.latitude},${_pickedLocation!.longitude}&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C${_pickedLocation!.latitude},${_pickedLocation!.longitude}&key=AIzaSyDbI9JAjr02xmnRh1uGHtBgGbwqESP3cNU';
  }

  void _selectOnMap() async {
    final res = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(
          isSelecting: true,
        ),
      ),
    );

    if (res != null) {
      _savePlace(res.latitude, res.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: _pickedLocation != null
              ? Image.network(
                  locationImage,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                )
              : !_isGettingLocation
                  ? Text(
                      'No Location',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    )
                  : const CircularProgressIndicator(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            ),
          ],
        )
      ],
    );
  }
}
