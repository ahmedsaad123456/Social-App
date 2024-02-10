import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/post_data_model.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

// this screen to show data of any post in the app
// that allow to show his likes and comments

class PostScreen extends StatelessWidget {
  final PostDataModel postDataModel;

  final String postId;

  final int postIndex;

  final ScreenType screen;

  final ScreenType fromScreen;
  final textController = TextEditingController();

  PostScreen(this.postDataModel, this.postId, this.postIndex, this.screen,
      this.fromScreen,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        // to check if the post updated successfully or not
        if (state is SocialEditPostSuccessState) {
          messageScreen(
              message: 'Updated Successfully', state: ToastStates.SUCCESS);
        }

        if (state is SocialEditPostErrorState) {
          messageScreen(message: "Failed", state: ToastStates.ERROR);
        }
        if (state is SocialSendCommentPostErrorState ||
            state is SocialLikePostErrorState ||
            state is SocialUnlikePostErrorState ||
            state is SocialDeleteCommentPostErrorState ||
            state is SocialEditCommentErrorState) {
          messageScreen(message: 'Connection error', state: ToastStates.ERROR);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: defaultAppBar(
            title: postDataModel.post.name != null
                ? '${postDataModel.post.name ?? ''}\'s post  '
                : '',
            context: context,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                                screen: fromScreen);

                            textController.text = '';
                          }
                        } else {
                          if (textController.text.isEmpty) {
                            messageScreen(
                                message: 'you can\'t update to empty comment',
                                state: ToastStates.ERROR);
                          } else {
                            SocialCubit.get(context)
                                .editComment(textController.text, fromScreen);
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
      },
    );
  }
}

//================================================================================================================================
