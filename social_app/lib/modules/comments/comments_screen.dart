import 'package:flutter/material.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/models/comment_model.dart';
import 'package:social_app/modules/likes/likes_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

class CommentsScreen extends StatelessWidget {
  // list of comments
  final List<CommentModel> comments;

  // index of the post
  final int index;

  const CommentsScreen(this.comments, this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: defaultAppBar(
            context: context,
            title: 'comments',
            actions: [buildNumberOfLikes(context, index)]),
        body: Column(
          children: [
            SingleChildScrollView(
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return buildCommentItem(comments[index]);
                  },
                  itemCount: comments.length),
            ),
          ],
        ));
  }

  // =================================================================================================================

  // build comment item
  Widget buildCommentItem(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20.0,
        left: 20.0,
        right: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18.0,
                backgroundColor: Colors.white, // Set background color to white
                child: ClipOval(
                  child: Image.network(
                    comment.image!,
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
              Expanded(
                child: IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.name ?? "",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Expanded(
                              child: Text(
                            comment.text ?? "Loading!!",
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 15.0),
                          ))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 65.0,
            ),
            child: Text(comment.dateTime!.substring(0, 16)),
          )
        ],
      ),
    );
  }

  // =================================================================================================================

  // number of likes on the post
  Widget buildNumberOfLikes(context, index) => InkWell(
        onTap: () {
          navigateTo(context,
              LikesScreen(SocialCubit.get(context).likes[index], index));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ),
          child: Row(
            children: [
              const Icon(
                IconBroken.Heart,
                color: Colors.red,
                size: 20.0,
              ),
              const SizedBox(
                width: 5.0,
              ),
              Text(
                '${SocialCubit.get(context).likes[index].length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
}
