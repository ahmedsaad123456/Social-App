import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/comment_model.dart';
import 'package:social_app/modules/likes/likes_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

class CommentsScreen extends StatelessWidget {
  // list of comments
  final List<CommentModel> comments;

  final List<String> commentsId;

  // index of the post
  final int postIndex;

  final ScreenType? screen;

  // id of the post
  final String postId;

  // id of the post creator

  final String postUserId;

  const CommentsScreen(this.comments, this.commentsId, this.postIndex,
      this.screen, this.postId, this.postUserId,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) => Scaffold(
          appBar: defaultAppBar(
              context: context,
              title: 'comments',
              actions: [buildNumberOfLikes(context, postIndex, screen)]),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return buildCommentItem(
                          comments[index],
                          context,
                          screen,
                          postId,
                          commentsId[index],
                          postIndex,
                          index,
                          postUserId);
                    },
                    itemCount: comments.length),
              ],
            ),
          )),
    );
  }

  // =================================================================================================================

  // number of likes on the post
  Widget buildNumberOfLikes(context, index, ScreenType? screen) => InkWell(
        onTap: () {
          navigateTo(
              context,
              LikesScreen(SocialCubit.get(context).allpostsData[index].likes,
                  index, screen));
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
