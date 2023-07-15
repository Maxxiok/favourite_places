import 'package:favourite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final PlaceLocation location;
  final bool isSelecting;

  const MapScreen(
      {super.key,
      this.location = const PlaceLocation(37.422, -122.084, ''),
      this.isSelecting = true});

  @override
  State<MapScreen> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _location;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.location,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              widget.isSelecting ? 'Choose Your Location' : 'Your Location'),
          actions: [
            if (widget.isSelecting)
              IconButton(
                onPressed: () {
                  Navigator.pop(context, _location);
                },
                icon: const Icon(Icons.save),
              ),
          ],
        ),
        body: GoogleMap(
          onTap: widget.isSelecting ? (argument) => setState(() {
            _location = argument;
          }) : null,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.location.latitude,
              widget.location.longitude,
            ),
            zoom: 16,
          ),
          markers: _location == null && widget.isSelecting
              ? {}
              : {
                  Marker(
                    markerId: const MarkerId('m1'),
                    position: _location ??
                        LatLng(
                          widget.location.latitude,
                          widget.location.longitude,
                        ),
                  )
                },
        ),
      ),
    );
  }
}
