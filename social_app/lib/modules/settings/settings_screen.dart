import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/modules/edit_profile/edit_profile_screen.dart';
import 'package:social_app/modules/login/login_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/network/local/cache_helper.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var userModel = SocialCubit.get(context).userModel;
        return ConditionalBuilder(
          condition: userModel != null,
          builder: (context) => Padding(
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
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4.0),
                                topRight: Radius.circular(4.0)),
                            image: DecorationImage(
                                image: NetworkImage('${userModel!.cover}'),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 64.0,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        child: CircleAvatar(
                          radius: 60.0,
                          backgroundImage: NetworkImage(
                            '${userModel.image}',
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
                  '${userModel.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${userModel.bio}',
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
                          onTap: () {},
                          child: Column(
                            children: [
                              Text(
                                '100',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                'Posts',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: Column(
                            children: [
                              Text(
                                '265',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                'Photos',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: Column(
                            children: [
                              Text(
                                '10K',
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
                          onTap: () {},
                          child: Column(
                            children: [
                              Text(
                                '64',
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
                        onPressed: () {},
                        child: const Text('Add Photos'),
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
                        signOut(context);
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
              ],
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
      SocialCubit.get(context).userModel = null;
      SocialCubit.get(context).postList = [];
      SocialCubit.get(context).changeBottomNavBar(0);

      // Navigate to the LoginScreen after signing out.
      navigateAndFinish(
        context,
        LoginScreen(),
      );
    }
  });
}
