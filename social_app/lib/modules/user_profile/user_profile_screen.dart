import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/follow_model.dart';
import 'package:social_app/modules/chat_details/chat_details_screen.dart';
import 'package:social_app/modules/follow_user/follow_user_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

// this screen to show data of any user in the app
// that allow to show his name, bio , image , coverImage and posts

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        // if there is no posts
        if (state is SocialGetSpecificUserPostEmptyState) {
          messageScreen(
              message: "There is no more posts", state: ToastStates.WARNING);
        } else if (state is SocialGetSpecificUserPostErrorState) {
          messageScreen(
              message: "Check your internet connection",
              state: ToastStates.ERROR);
        }
      },
      builder: (context, state) {
        var loggedInUser = SocialCubit.get(context).userDataModel!.user;
        return Scaffold(
          appBar: AppBar(
            title: 
            
            Text(
                SocialCubit.get(context).specificUserDataModel?.user.name != null ? '${SocialCubit.get(context).specificUserDataModel?.user.name ?? ''}\'s profile  ' : '') ,
          ),
          body: ConditionalBuilder(
            condition:
                (SocialCubit.get(context).specificUserDataModel != null &&
                        SocialCubit.get(context)
                            .specificUserpostsData
                            .isNotEmpty) ||
                    state is SocialGetSpecificUserPostEmptyState,
            builder: (context) {
              bool isFollow = SocialCubit.get(context).isInMyFollowings(
                  followingUserId: SocialCubit.get(context)
                      .specificUserDataModel!
                      .user
                      .uId!);
              return SingleChildScrollView(
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
                                  SocialCubit.get(context)
                                      .specificUserDataModel!
                                      .user
                                      .cover!,
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
                                backgroundColor: Colors
                                    .white, // Set background color to white
                                child: ClipOval(
                                  child: Image.network(
                                    SocialCubit.get(context)
                                        .specificUserDataModel!
                                        .user
                                        .image!,
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
                        '${SocialCubit.get(context).specificUserDataModel!.user.name}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${SocialCubit.get(context).specificUserDataModel!.user.bio}',
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
                                              .specificUserDataModel!
                                              .followers,
                                          'Followers',
                                          ScreenType.PROFILE));
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      '${SocialCubit.get(context).specificUserDataModel!.followers.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    Text(
                                      'Followers',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
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
                                              .specificUserDataModel!
                                              .followings,
                                          'Followings',
                                          ScreenType.PROFILE));
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      '${SocialCubit.get(context).specificUserDataModel!.followings.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    Text(
                                      'Followings',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
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
                            child: defaultButton(
                              function: () {
                                !isFollow
                                    ? SocialCubit.get(context).followUser(
                                        followingUserId:
                                            SocialCubit.get(context)
                                                .specificUserDataModel!
                                                .user
                                                .uId!,
                                        followingUserName:
                                            SocialCubit.get(context)
                                                .specificUserDataModel!
                                                .user
                                                .name!,
                                        followingUserImage:
                                            SocialCubit.get(context)
                                                .specificUserDataModel!
                                                .user
                                                .image!,
                                        followingUserBio:
                                            SocialCubit.get(context)
                                                .specificUserDataModel!
                                                .user
                                                .bio!)
                                    : SocialCubit.get(context).unFollowUser(
                                        followingUserId:
                                            SocialCubit.get(context)
                                                .specificUserDataModel!
                                                .user
                                                .uId!);
                                !isFollow
                                    ? SocialCubit.get(context)
                                        .specificUserDataModel!
                                        .followers
                                        .add(FollowModel(
                                            uId: loggedInUser.uId,
                                            name: loggedInUser.name,
                                            bio: loggedInUser.bio,
                                            image: loggedInUser.image))
                                    : SocialCubit.get(context)
                                        .specificUserDataModel!
                                        .followers
                                        .removeWhere((followers) =>
                                            followers.uId == loggedInUser.uId);
                                isFollow = !isFollow;
                              },
                              text: isFollow ? "UnFollow" : "follow",
                              width: 115,
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              navigateTo(
                                  context,
                                  ChatDetailsScreen(SocialCubit.get(context)
                                      .specificUserDataModel!
                                      .user));
                            },
                            child: const Icon(
                              IconBroken.Message,
                              size: 16.0,
                            ),
                          ),
                        ],
                      ),

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
                            SocialCubit.get(context)
                                .specificUserpostsData[index],
                            SocialCubit.get(context).specificUserpostId,
                            index,
                            ScreenType.PROFILE),
                        itemCount: SocialCubit.get(context)
                            .specificUserpostsData
                            .length,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      // show more posts
                      ConditionalBuilder(
                        condition:
                            state is! SocialGetSpecificUserPostLoadingState,
                        builder: (context) => defaultTextButton(
                            fun: () {
                              SocialCubit.get(context).getSpecificUserPostsData(
                                  loadMore: true,
                                  specificUserId: SocialCubit.get(context)
                                      .specificUserDataModel!
                                      .user
                                      .uId!);
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
              );
            },
            fallback: (context) =>
                const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}

//================================================================================================================================
