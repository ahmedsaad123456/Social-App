import 'package:flutter/material.dart';
import 'package:social_app/shared/components/components.dart';

class ImageScreen extends StatelessWidget {
  final String imageFile;

  const ImageScreen({required this.imageFile, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context: context),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Close the screen when tapped
          },
          child: Image(
            image: NetworkImage(imageFile),
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => const Image(
                image: AssetImage('assets/images/image_error.jpeg')),
          ),
        ),
      ),
    );
  }
}
