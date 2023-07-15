import 'dart:io';

import 'package:favourite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> getDb() async {
  final dbPath = await sql.getDatabasesPath();
  return await sql.openDatabase(
    join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
    },
    version: 1,
  );
}

class FavouritePlaceNotifier extends StateNotifier<List<Place>> {
  FavouritePlaceNotifier() : super([]);

  Future<void> loadPlaces() async {
    final db = await getDb();
    final tbRows = await db.query('user_places');
    final places = [];

    for (var element in tbRows) {
      final place = Place(
        element['title'].toString(),
        File(element['image'].toString()),
        PlaceLocation(
          element['lat'] as double,
          element['lng'] as double,
          element['address'] as String,
        ),
        id: element['id'],
      );
      places.add(place);
    }

    state = [...places];
  }

  void addPlace(Place place) async {
    final appDir = await syspath.getApplicationDocumentsDirectory();
    final filename = basename(place.image.path);
    final copiedImage = await place.image.copy('${appDir.path}/$filename');
    final updPlace = Place(place.title, copiedImage, place.location);
    final db = await getDb();
    db.insert(
      'user_places',
      {
        'id': updPlace.id,
        'title': updPlace.title,
        'image': updPlace.image.path,
        'lat': updPlace.location.latitude,
        'lng': updPlace.location.longitude,
        'address': updPlace.location.address,
      },
    );
    state = [...state, updPlace];
  }
}

final favPlaceProvider =
    StateNotifierProvider<FavouritePlaceNotifier, List<Place>>(
        (ref) => FavouritePlaceNotifier());
