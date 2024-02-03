import 'package:flutter/material.dart';
import 'package:social_app/models/like_model.dart';
import 'package:social_app/shared/components/components.dart';

class LikesScreen extends StatelessWidget {
  // list of likes
  final List<LikeModel> likes;

  // index of the post
  final int index;

  const LikesScreen(this.likes, this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: defaultAppBar(
            context: context,
            title: 'Likes',
            ),
        body: SingleChildScrollView(
          child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return buildLikesItem(likes[index] , context);
              },
              itemCount: likes.length),
        ));
  }
  // build like item
  Widget buildLikesItem(LikeModel model, context) {
    return InkWell(
      onTap: () {
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundColor: Colors.white, // Set background color to white
              child: ClipOval(
                child: Image.network(
                  model.image!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // Return the main image when it's loaded
                    } else {
                      // Return a placeholder while the image is loading
                      return const Center(
                        child: Image(
                            image: AssetImage('assets/images/white.jpeg')),
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Image(
                        image: AssetImage('assets/images/white.jpeg'));
                  },
                ),
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            Text(model.name ?? ""),
          ],
        ),
      ),
    );
  }
}