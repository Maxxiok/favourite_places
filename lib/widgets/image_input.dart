import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  final Function(File img) storeImgFn;
  const ImageInput({super.key, required this.storeImgFn});

  @override
  State<ImageInput> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File? imageTaken;

  void _takePicture() async {
    final imgPicker = ImagePicker();
    final img = await imgPicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (img != null) {
      setState(() {
        imageTaken = File(img.path);
      });
      widget.storeImgFn(imageTaken!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              width: 1, color: Theme.of(context).colorScheme.primary)),
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: imageTaken == null
          ? TextButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera),
              label: const Text('Take Picture'),
            )
          : GestureDetector(
              onTap: _takePicture,
              child: Image.file(
                imageTaken!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
    );
  }
}
