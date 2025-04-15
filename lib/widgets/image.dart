import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InputImage extends StatefulWidget {
  final Function(File pickedImg) onSelect;
  const InputImage({super.key, required this.onSelect});

  @override
  State<InputImage> createState() => _InputImageState();
}

class _InputImageState extends State<InputImage> {
  File? selectedImg;
  void takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImg = await imagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 300, imageQuality: 50);
    if (pickedImg == null) {
      return;
    }
    setState(() {
      selectedImg = File(pickedImg.path);
    });
    widget.onSelect(selectedImg!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          foregroundImage: selectedImg != null ? FileImage(selectedImg!) : null,
          backgroundColor: Colors.grey,
          radius: 50,
        ),
        TextButton.icon(
            onPressed: takePicture,
            icon: Icon(Icons.image),
            label: Text("Add a pic"))
      ],
    );
  }
}
