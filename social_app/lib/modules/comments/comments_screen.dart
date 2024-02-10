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
    return BlocConsumer<SocialCubit, SocialStates>(listener: (context, state) {
      if (state is SocialSendCommentPostErrorState ||
          state is SocialEditCommentErrorState ||
          state is SocialDeleteCommentPostErrorState) {
        messageScreen(message: 'Connection error', state: ToastStates.ERROR);
      }
    }, builder: (context, state) {
      TextEditingController textController = TextEditingController();

      return Scaffold(
        appBar: defaultAppBar(
            fun: () {
              SocialCubit.get(context).changeEditComment(false);
              Navigator.pop(context);
            },
            context: context,
            title: 'comments',
            actions: [buildNumberOfLikes(context, postIndex, screen)]),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
              ),
            ),
            if (SocialCubit.get(context).isEditComment)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius:
                          BorderRadiusDirectional.all(Radius.circular(10))),
                  child: Row(
                    children: [
                      const Icon(IconBroken.Edit),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.grey[400],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Edit Comment"),
                              Text(
                                  SocialCubit.get(context)
                                          .editCommentModel
                                          .text ??
                                      "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            textController.text = "";
                            SocialCubit.get(context).changeEditComment(false);
                          },
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [
                    Color.fromRGBO(143, 148, 251, 1),
                    Color.fromRGBO(143, 148, 251, .6),
                  ])),
              margin: const EdgeInsets.all(10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.0,
                    backgroundColor:
                        Colors.white, // Set background color to white
                    child: ClipOval(
                      child: Image.network(
                        SocialCubit.get(context).userDataModel!.user.image!,
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
                                  image:
                                      AssetImage('assets/images/white.jpeg')),
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
                    child: Builder(builder: (context) {
                      if (SocialCubit.get(context).isEditComment) {
                        textController.text =
                            SocialCubit.get(context).editCommentModel.text ??
                                "";
                      }
                      return TextFormField(
                        keyboardType: TextInputType.text,
                        controller: textController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write a comment...',
                        ),
                      );
                    }),
                  ),
                  IconButton(
                    onPressed: () {
                      if (!SocialCubit.get(context).isEditComment) {
                        if (textController.text.isEmpty) {
                          messageScreen(
                              message: 'you can\'t send empty comment',
                              state: ToastStates.ERROR);
                        } else {
                          SocialCubit.get(context).sendComment(
                              text: textController.text,
                              postID: postId,
                              index: postIndex,
                              screen: screen!);

                          textController.text = '';
                        }
                      } else {
                        if (textController.text.isEmpty) {
                          messageScreen(
                              message: 'you can\'t update to empty comment',
                              state: ToastStates.ERROR);
                        } else {
                          SocialCubit.get(context)
                              .editComment(textController.text, screen!);
                          SocialCubit.get(context).changeEditComment(false);
                          textController.text = '';
                        }
                      }
                    },
                    icon: !SocialCubit.get(context).isEditComment
                        ? const Icon(IconBroken.Arrow___Right_Square)
                        : const Icon(
                            Icons.check,
                            size: 25.0,
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // =================================================================================================================

  // number of likes on the post
  Widget buildNumberOfLikes(context, index, ScreenType? screen) => InkWell(
        onTap: () {
          SocialCubit.get(context).changeEditComment(false);

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
                color: Colors.deepPurple,
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
