import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/modules/edit_profile/edit_profile_screen.dart';
import 'package:social_app/modules/follow_user/follow_user_screen.dart';
import 'package:social_app/modules/login/login_screen.dart';
import 'package:social_app/modules/new_post/new_post_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/network/local/cache_helper.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        // if there is no posts
        if (state is SocialGetLoggedInUserPostEmptyState) {
          messageScreen(
              message: "create more posts", state: ToastStates.WARNING);
        } else if (state is SocialGetLoggedInUserPostErrorState) {
          messageScreen(
              message: "Check your internet connection",
              state: ToastStates.ERROR);
        }
        // to check if the post updated successfully or not
        if (state is SocialEditPostSuccessState) {
          messageScreen(
              message: 'Updated Successfully', state: ToastStates.SUCCESS);
        }

        if (state is SocialEditPostErrorState) {
          messageScreen(message: "Failed", state: ToastStates.ERROR);
        }
      },
      builder: (context, state) {

        return ConditionalBuilder(
          condition: (SocialCubit.get(context).userDataModel != null),
          builder: (context) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    height: 190.0,
                    child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: Container(
                            height: 140.0,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0)),
                            ),
                            // Use the loadingBuilder property of NetworkImage to show a placeholder while the image is loading
                            child: Image.network(
                              SocialCubit.get(context).userDataModel!.user.cover?? '',
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child; // Return the main image when it's loaded
                                } else {
                                  // Return a placeholder while the image is loading
                                  return const Center(
                                    child: Image(
                                        image: AssetImage(
                                            'assets/images/white.jpeg')),
                                  );
                                }
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Image(
                                    image: AssetImage(
                                        'assets/images/white.jpeg')); // Show an error icon if image loading fails
                              },
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 64.0,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          child: CircleAvatar(
                            radius: 60.0,
                            backgroundColor:
                                Colors.white, // Set background color to white
                            child: ClipOval(
                              child: Image.network(
                                SocialCubit.get(context).userDataModel!.user.image ?? '',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child; // Return the main image when it's loaded
                                  } else {
                                    // Return a placeholder while the image is loading
                                    return const Center(
                                      child: Image(
                                          image: AssetImage(
                                              'assets/images/white.jpeg')),
                                    );
                                  }
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Image(
                                      image: AssetImage(
                                          'assets/images/white.jpeg'));
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    '${SocialCubit.get(context).userDataModel!.user.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${SocialCubit.get(context).userDataModel!.user.bio}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              navigateTo(
                                  context,
                                  FollowUserScreen(
                                      SocialCubit.get(context)
                                          .userDataModel!
                                          .followers,
                                      'Followers',
                                      ScreenType.SETTINGS));
                            },
                            child: Column(
                              children: [
                                Text(
                                  '${SocialCubit.get(context).userDataModel!.followers.length}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Followers',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              navigateTo(
                                  context,
                                  FollowUserScreen(
                                      SocialCubit.get(context)
                                          .userDataModel!
                                          .followings,
                                      'Followings',
                                      ScreenType.SETTINGS));
                            },
                            child: Column(
                              children: [
                                Text(
                                  '${SocialCubit.get(context).userDataModel!.followings.length}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Followings',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            navigateTo(context, NewPostScreen());
                          },
                          child: const Text('Add Posts'),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          navigateTo(context, EditProfileScreen());
                        },
                        child: const Icon(
                          IconBroken.Edit,
                          size: 16.0,
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Log out"),
                              content: const Text(
                                  "Are you sure you want to log out?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Container(
                                    color: Colors.red,
                                    padding: const EdgeInsets.all(14),
                                    child: const Text(
                                      "No",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    signOut(context);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Container(
                                    color: Colors.green,
                                    padding: const EdgeInsets.all(14),
                                    child: const Text(
                                      "Yes",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.exit_to_app,
                          size: 16.0,
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     OutlinedButton(
                  //       onPressed: ()
                  //       {
                  //         FirebaseMessaging.instance.subscribeToTopic('announcements');
                  //       },
                  //       child: Text(
                  //         'subscribe',
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: 20.0,
                  //     ),
                  //     OutlinedButton(
                  //       onPressed: ()
                  //       {
                  //         FirebaseMessaging.instance.unsubscribeFromTopic('announcements');
                  //       },
                  //       child: Text(
                  //         'unsubscribe',
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(
                    height: 5,
                  ),
                  // show my posts
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 8.0,
                    ),
                    itemBuilder: (context, index) => buildPostItem(
                        context,
                        SocialCubit.get(context).loggedInUserpostsData[index],
                        SocialCubit.get(context).loggedInUserpostId[index],
                        index,
                        ScreenType.SETTINGS),
                    itemCount:
                        SocialCubit.get(context).loggedInUserpostsData.length,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  // show more posts
                  ConditionalBuilder(
                    condition: state is! SocialGetLoggedInUserPostLoadingState,
                    builder: (context) => defaultTextButton(
                        fun: () {
                          SocialCubit.get(context)
                              .getLoggedInUserPostsData(loadMore: true);
                        },
                        text: "show more"),
                    fallback: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                ],
              ),
            ),
          ),
          fallback: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

//================================================================================================================================

// Function to sign out the user by removing the token from local storage and resetting relevant data in the Social cubit.
void signOut(context) {
  CacheHelper.removeData(
    key: 'uId',
  ).then((value) {
    if (value) {
      // If the token is successfully removed, reset user-related data in the HomeCubit.
      uId = null;
      SocialCubit.get(context).userDataModel = null;
      SocialCubit.get(context).loggedInUserpostsData = [];
      SocialCubit.get(context).loggedInUserpostId = [];
      SocialCubit.get(context).postId = [];
      SocialCubit.get(context).allpostsData = [];
      SocialCubit.get(context).users = [];
      SocialCubit.get(context).usersSearch = [];
      SocialCubit.get(context).changeBottomNavBar(0);
      SocialCubit.get(context).isLoggedInPosts = null;

      // Navigate to the LoginScreen after signing out.
      navigateAndFinish(
        context,
        LoginScreen(),
      );
    }
  });
}
