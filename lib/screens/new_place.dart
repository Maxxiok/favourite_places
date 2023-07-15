import 'package:favourite_places/models/place.dart';
import 'package:favourite_places/providers/favourite_places_provider.dart';
import 'package:favourite_places/widgets/image_input.dart';
import 'package:favourite_places/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class NewPlaceScreen extends ConsumerStatefulWidget {
  const NewPlaceScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _NewPlaceScreenState();
  }
}

class _NewPlaceScreenState extends ConsumerState<NewPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _placeTitle;
  File? _image;
  late PlaceLocation _location;

  void _addPlace() {
    if (_formKey.currentState!.validate() && _image != null) {
      _formKey.currentState!.save();
      ref.read(favPlaceProvider.notifier).addPlace(Place(
            _placeTitle!,
            _image!,
            _location,
          ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Place'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        maxLength: 50,
                        decoration: const InputDecoration(
                          label: Text('Title'),
                        ),
                        onSaved: (newValue) => _placeTitle = newValue,
                        validator: (value) => value == null ||
                                value.isEmpty ||
                                value.trim().length <= 1 ||
                                value.trim().length > 50
                            ? 'Invalid value'
                            : null,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                ImageInput(storeImgFn: (img) => _image = img),
                const SizedBox(
                  height: 16,
                ),
                LocationInput(setLocationFn: (loc) => _location = loc),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addPlace,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Place'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
