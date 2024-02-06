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

  final ScreenType? screen;

  const CommentsScreen(this.comments, this.index, this.screen, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: defaultAppBar(
            context: context,
            title: 'comments',
            actions: [buildNumberOfLikes(context, index , screen)]),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return buildCommentItem(comments[index], context, screen);
                  },
                  itemCount: comments.length),
            ],
          ),
        ));
  }

  // =================================================================================================================

 


  // number of likes on the post
  Widget buildNumberOfLikes(context, index , ScreenType? screen) => InkWell(
        onTap: () {
          navigateTo(
              context,
              LikesScreen(
                  SocialCubit.get(context).allpostsData[index].likes, index , screen));
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
                '${SocialCubit.get(context).allpostsData[index].likes.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
}
