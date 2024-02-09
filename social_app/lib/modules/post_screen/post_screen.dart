import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/post_data_model.dart';
import 'package:social_app/shared/components/components.dart';

// this screen to show data of any post in the app
// that allow to show his likes and comments

class PostScreen extends StatelessWidget {
  final PostDataModel postDataModel;

  final String postId;

  final int postIndex;

  final ScreenType screen;

  final ScreenType fromScreen;

  const PostScreen(this.postDataModel, this.postId, this.postIndex, this.screen,
      this.fromScreen,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: defaultAppBar(
            title: postDataModel.post.name != null
                ? '${postDataModel.post.name ?? ''}\'s post  '
                : '',
            context: context,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                buildPostItem(
                    context, postDataModel, postId, postIndex, fromScreen,
                    isPostScreen: true),
                const SizedBox(
                  height: 10,
                ),
                if (postDataModel.comments.isNotEmpty)
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 5.0,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('comments',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 25,
                                  )),
                    ),
                  ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return buildCommentItem(
                          postDataModel.comments[index],
                          context,
                          fromScreen,
                          postId,
                          postDataModel.commentsId[index],
                          postIndex,
                          index,
                          postDataModel.post.uId!);
                    },
                    itemCount: postDataModel.comments.length),
              ],
            ),
          ),
        );
      },
    );
  }
}

//================================================================================================================================
