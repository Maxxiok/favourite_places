import 'package:favourite_places/models/place.dart';
import 'package:favourite_places/providers/favourite_places_provider.dart';
import 'package:favourite_places/screens/new_place.dart';
import 'package:favourite_places/screens/place_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesListScreen extends ConsumerStatefulWidget {
  const PlacesListScreen({super.key});

  @override
  ConsumerState<PlacesListScreen> createState() {
    return _PlacesListScreenState();
  }
}

class _PlacesListScreenState extends ConsumerState<PlacesListScreen> {
  late Future<void> _placesLoaded;

  @override
  void initState() {
    super.initState();
    _placesLoaded = ref.read(favPlaceProvider.notifier).loadPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewPlaceScreen(),
                  )),
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
        future: _placesLoaded,
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ref.watch(favPlaceProvider).isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          Place pl = ref.watch(favPlaceProvider)[index];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundImage: FileImage(pl.image),
                            ),
                            title: Text(
                              pl.title,
                              style: Theme.of(context)
                                  .copyWith()
                                  .textTheme
                                  .titleMedium,
                            ),
                            subtitle: Text(
                              pl.location.address,
                              style: Theme.of(context)
                                  .copyWith()
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Colors.white),
                            ),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaceDetailsScreen(pl),
                                )),
                          );
                        },
                        itemCount: ref.watch(favPlaceProvider).length,
                      ),
                    )
                  : Center(
                      child: Text(
                        'You have no places added yet',
                        style:
                            Theme.of(context).copyWith().textTheme.titleLarge,
                      ),
                    );
        },
      ),
    );
  }
}
