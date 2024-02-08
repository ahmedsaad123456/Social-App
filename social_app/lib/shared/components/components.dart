import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/models/comment_model.dart';
import 'package:social_app/models/follow_model.dart';
import 'package:social_app/models/post_data_model.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/modules/chat_details/chat_details_screen.dart';
import 'package:social_app/modules/comments/comments_screen.dart';
import 'package:social_app/modules/edit_post/edit_post_screen.dart';
import 'package:social_app/modules/image_screen/image_screen.dart';
import 'package:social_app/modules/likes/likes_screen.dart';
import 'package:social_app/modules/post_screen/post_screen.dart';
import 'package:social_app/modules/user_profile/user_profile_screen.dart';
import 'package:social_app/shared/styles/colors.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

//==========================================================================================================================================================

// divider between the widgets
Widget myDivider() => Container(
      width: double.infinity,
      height: 1.0,
      color: Colors.grey[300],
    );

//==========================================================================================================================================================

// defulat text form field
Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  required final String? label,
  required String? Function(String?)? validate,
  required IconData prefix,
  bool isPassword = false,
  IconData? suffix,
  Function()? suffixPressed,
  Function()? onTap,
  Function(String)? onSubmit,
  var onChange,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      onTap: onTap,
      obscureText: isPassword,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      validator: validate,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: suffix != null
            ? IconButton(
                icon: Icon(suffix),
                onPressed: suffixPressed,
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );

//==========================================================================================================================================================

// method to navigate to new screen
void navigateTo(context, widget) => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
//==========================================================================================================================================================

// method to navigate to new screen with remove all screens in the stack
void navigateAndFinish(context, widget) => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => widget),
      (Route<dynamic> route) => false,
    );

//================================================================================================================================

// default text button
Widget defaultTextButton({required VoidCallback fun, required String text}) {
  return TextButton(onPressed: fun, child: Text(text));
}

//================================================================================================================================

// default button
Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  bool isUpperCase = true,
  double radius = 3.0,
  required VoidCallback function,
  required String text,
}) =>
    Container(
      width: width,
      height: 40.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          radius,
        ),
        color: background,
      ),
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );

//================================================================================================================================

// message screen
Future<bool?> messageScreen({
  required String? message,
  Toast toastLength = Toast.LENGTH_SHORT,
  ToastGravity gravity = ToastGravity.BOTTOM,
  int time = 5,
  required ToastStates state,
  Color textColor = Colors.white,
  double fontSize = 16.0,
}) {
  return Fluttertoast.showToast(
    msg: message ?? "Error",
    toastLength: toastLength,
    gravity: gravity,
    timeInSecForIosWeb: time,
    backgroundColor: chooseToastColor(state),
    textColor: textColor,
    fontSize: fontSize,
  );
}

//================================================================================================================================

// enum to indicate the state of the toast screen
enum ToastStates { SUCCESS, ERROR, WARNING }

// enum to indicate the position of the post
enum ScreenType { HOME, SETTINGS, PROFILE, POST }
//================================================================================================================================

// return the color of the toast screen according to the state
Color chooseToastColor(ToastStates state) {
  Color color;

  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }

  return color;
}

//================================================================================================================================

// email verification
Widget
    emailVerification() => // if (FirebaseAuth.instance.currentUser!.emailVerified == false)
        Container(
          color: Colors.amber.withOpacity(0.6),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(
                  width: 15.0,
                ),
                const Expanded(child: Text('please verify your email')),
                const SizedBox(
                  width: 20,
                ),
                defaultTextButton(
                    text: 'SEND',
                    fun: () {
                      // FirebaseAuth.instance.currentUser!
                      //     .sendEmailVerification()
                      //     .then((value) {
                      //   messageScreen(
                      //       message: 'check your mail',
                      //       state: ToastStates.SUCCESS);
                      // }).catchError((error) {});
                    })
              ],
            ),
          ),
        );

//================================================================================================================================

// default app bar
PreferredSizeWidget defaultAppBar({
  required BuildContext context,
  String? title,
  List<Widget>? actions,
}) =>
    AppBar(
      leading: IconButton(
        icon: const Icon(IconBroken.Arrow___Left_2),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      titleSpacing: 5.0,
      title: Text(title ?? ''),
      actions: actions,
    );

//================================================================================================================================

Widget buildPostItem(
    context, PostDataModel model, List<String> postId, index, ScreenType screen,
    {bool isPostScreen = false}) {
  var textController = TextEditingController();

  return Card(
    clipBehavior: Clip.antiAliasWithSaveLayer,
    elevation: 5.0,
    margin: const EdgeInsets.symmetric(
      horizontal: 8.0,
    ),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if (screen != ScreenType.PROFILE) {
                if (model.post.uId !=
                    SocialCubit.get(context).userDataModel!.user.uId) {
                  SocialCubit.get(context).clearSpecificUserData();

                  SocialCubit.get(context)
                      .getSpecificUserData(specificUserId: model.post.uId!);

                  navigateTo(context, const UserProfileScreen());
                } else {
                  messageScreen(
                      message: "go to settings to show your profile",
                      state: ToastStates.WARNING);
                }
              }
            },
            child: Row(
              children: [
                // image of the user's post
                CircleAvatar(
                  radius: 25.0,
                  backgroundColor:
                      Colors.white, // Set background color to white
                  child: ClipOval(
                    child: Image.network(
                      model.post.image!,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // name of the user's post
                          Text(
                            '${model.post.name}',
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          const Icon(
                            Icons.check_circle,
                            size: 16.0,
                            color: defaultColor,
                          )
                        ],
                      ),
                      Text(
                        // dateTime of the post
                        '${model.post.dateTime}'
                            .substring(0, 16)
                            .replaceAll('T', '  '),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
                if (model.post.uId ==
                    SocialCubit.get(context).userDataModel!.user.uId)
                  PopupMenuButton(
                    color: Colors.grey[300],
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(IconBroken.Delete),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Delete")
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 2,
                          child: Row(
                            children: [
                              Icon(IconBroken.Edit),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Edit")
                            ],
                          ),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      if (value == 1) {
                        SocialCubit.get(context)
                            .deletePost(postId[index], index, screen);
                        if (isPostScreen) {
                          Navigator.pop(context);
                        }
                      } else if (value == 2) {
                        navigateTo(context,
                            EditPostScreen(model, postId, index, screen));
                      }
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
            ),
            child: Container(
              width: double.infinity,
              height: 1.0,
              color: Colors.grey[300],
            ),
          ),
          InkWell(
            onTap: () {
              if (!isPostScreen) {
                navigateTo(context,
                    PostScreen(model, postId, index, ScreenType.POST, screen));
              }
            },
            child: Text(
              // text of the post
              '${model.post.text}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // if the post has image
          if (model.post.postImage != '')
            Padding(
              padding: const EdgeInsets.only(
                top: 15.0,
              ),
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 5.0,
                margin: const EdgeInsets.all(0.0),
                child: GestureDetector(
                  onTap: () {
                    navigateTo(
                        context, ImageScreen(imageFile: model.post.postImage!));
                  },
                  child: LimitedBox(
                    maxHeight: 500.0,
                    child: Image(
                      image: NetworkImage(model.post.postImage!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Image(
                          image: AssetImage('assets/images/image_error.jpeg')),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              children: [
                Expanded(
                  // number of likes on the post
                  child: InkWell(
                    onTap: () {
                      navigateTo(
                          context, LikesScreen(model.likes, index, screen));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            IconBroken.Heart,
                            color: Colors.red,
                            size: 16.0,
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            '${model.likes.length}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  // number of comments on the post
                  child: InkWell(
                    onTap: () {
                      navigateTo(context,
                          CommentsScreen(model.comments, index, screen));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            IconBroken.Chat,
                            color: Colors.amber,
                            size: 16.0,
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            '${model.comments.length} comments',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 10.0,
            ),
            child: Container(
              width: double.infinity,
              height: 1.0,
              color: Colors.grey[300],
            ),
          ),
          Row(
            children: [
              // write comment on the post
              Expanded(
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
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: textController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write a comment...',
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          if (textController.text.isEmpty) {
                            messageScreen(
                                message: 'you can\'t send empty comment',
                                state: ToastStates.ERROR);
                          } else {
                            SocialCubit.get(context).sendComment(
                                text: textController.text,
                                postID: postId[index],
                                index: index,
                                screen: screen);

                            textController.text = '';
                          }
                        },
                        icon: const Icon(IconBroken.Arrow___Right_Square)),
                  ],
                ),
              ),
              // do like on the post
              LikeButton(
                isLiked: model.isLiked,
                size: 16.0,
                circleColor: const CircleColor(
                    start: Color(0xff00ddff), end: Color(0xff0099cc)),
                bubblesColor: const BubblesColor(
                  dotPrimaryColor: Color(0xff33b5e5),
                  dotSecondaryColor: Color(0xff0099cc),
                ),
                likeBuilder: (bool isLiked) {
                  return Icon(
                    IconBroken.Heart,
                    color: isLiked ? Colors.deepPurpleAccent : Colors.grey,
                    size: 16.0,
                  );
                },
                likeCount: 0,
                countBuilder: (likeCount, isLiked, text) {
                  var color = isLiked ? Colors.deepPurpleAccent : Colors.grey;
                  return Text('Love', style: TextStyle(color: color));
                },
                onTap: (isLiked) async {
                  if (!isLiked) {
                    final cubit = SocialCubit.get(context);
                    bool likeSuccess = await cubit.likePost(
                        postID: postId[index], index: index, screen: screen);

                    return !isLiked &&
                        likeSuccess; // Return the opposite of isLiked only if the like was successful
                  } else {
                    final cubit = SocialCubit.get(context);
                    bool unlikeSuccess = await cubit.unlikePost(
                        postID: postId[index], index: index, screen: screen);
                    return isLiked &&
                        unlikeSuccess; // Return true to indicate unliking was successful
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

//================================================================================================================================

// build user item
Widget buildUserItem(UserModel model, context) {
  bool isFollow =
      SocialCubit.get(context).isInMyFollowings(followingUserId: model.uId!);
  return InkWell(
    onTap: () {
      if (model.uId != SocialCubit.get(context).userDataModel!.user.uId) {
        SocialCubit.get(context).clearSpecificUserData();

        SocialCubit.get(context)
            .getSpecificUserData(specificUserId: model.uId!);

        navigateTo(context, const UserProfileScreen());
      } else {
        messageScreen(
            message: "go to settings to show your profile",
            state: ToastStates.WARNING);
      }
    },
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.0,
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
                      child:
                          Image(image: AssetImage('assets/images/white.jpeg')),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model.name ?? ""),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  model.bio ?? "",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        height: 1.4,
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          defaultButton(
            function: () {
              !isFollow
                  ? SocialCubit.get(context).followUser(
                      followingUserId: model.uId!,
                      followingUserName: model.name!,
                      followingUserImage: model.image!,
                      followingUserBio: model.bio!)
                  : SocialCubit.get(context)
                      .unFollowUser(followingUserId: model.uId!);
              isFollow = !isFollow;
            },
            text: isFollow ? "UnFollow" : "follow",
            width: 115,
          ),
          const SizedBox(width: 5),
          IconButton(
            icon: const Icon(
              IconBroken.Message, // Notification icon
            ),
            onPressed: () {
              navigateTo(context, ChatDetailsScreen(model));
            },
          ),
        ],
      ),
    ),
  );
}

//========================================================================================================================

// build follow user item
Widget buildFollowUserItem(FollowModel model, context, ScreenType? screen) {
  bool isFollow =
      SocialCubit.get(context).isInMyFollowings(followingUserId: model.uId!);
  return InkWell(
    onTap: () {
      if (screen != ScreenType.PROFILE) {
        if (model.uId != SocialCubit.get(context).userDataModel!.user.uId) {
          SocialCubit.get(context).clearSpecificUserData();
          SocialCubit.get(context)
              .getSpecificUserData(specificUserId: model.uId!);

          navigateTo(context, const UserProfileScreen());
        } else {
          messageScreen(
              message: "go to settings to show your profile",
              state: ToastStates.WARNING);
        }
      }
    },
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.0,
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
                      child:
                          Image(image: AssetImage('assets/images/white.jpeg')),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model.name ?? ""),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  model.bio ?? "",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        height: 1.4,
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          if (model.uId != SocialCubit.get(context).userDataModel!.user.uId)
            defaultButton(
              function: () {
                !isFollow
                    ? SocialCubit.get(context).followUser(
                        followingUserId: model.uId!,
                        followingUserName: model.name!,
                        followingUserImage: model.image!,
                        followingUserBio: model.bio!)
                    : SocialCubit.get(context)
                        .unFollowUser(followingUserId: model.uId!);
                isFollow = !isFollow;
              },
              text: isFollow ? "UnFollow" : "follow",
              width: 115,
            ),
        ],
      ),
    ),
  );
}

// =============================================================================================================================

// build comment item
Widget buildCommentItem(CommentModel comment, context, ScreenType? screen) {
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
            InkWell(
              onTap: () {
                if (screen != ScreenType.PROFILE) {
                  if (comment.uId !=
                      SocialCubit.get(context).userDataModel!.user.uId) {
                    SocialCubit.get(context).clearSpecificUserData();

                    SocialCubit.get(context)
                        .getSpecificUserData(specificUserId: comment.uId!);

                    navigateTo(context, const UserProfileScreen());
                  } else {
                    messageScreen(
                        message: "go to settings to show your profile",
                        state: ToastStates.WARNING);
                  }
                }
              },
              child: CircleAvatar(
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
