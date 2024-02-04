import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/modules/new_post/new_post_screen.dart';
import 'package:social_app/modules/users_search/users_search_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

class SocialLayout extends StatelessWidget {
  const SocialLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      // Listen to state changes in SocialCubit
      listener: (context, state) {
        // Execute when the state changes to SocialNewPostState
        if (state is SocialNewPostState) {
          navigateTo(context, NewPostScreen()); // Navigate to NewPostScreen
        }
      },
      builder: (context, state) {
        var cubit = SocialCubit.get(context); // Get the instance of SocialCubit
        return Scaffold(
          appBar: AppBar(
            title: Text(cubit
                .titles[cubit.currentIndex]), // Display current screen title
            actions: [
                IconButton(
                  icon: const Icon(
                    IconBroken.Notification, // Notification icon
                  ),
                  onPressed: () {},
                ),
              if (cubit.currentIndex == 3)
                IconButton(
                  icon: const Icon(
                    IconBroken.Search, // Search icon
                  ),
                  onPressed: () {
                    navigateTo(context, UsersSearchScreen());
                  },
                ),
            ],
          ),
          body: cubit.screens[cubit.currentIndex], // Display the current screen
          bottomNavigationBar: BottomNavigationBar(
            currentIndex:
                cubit.currentIndex, // Current index for bottom navigation
            onTap: (value) {
              cubit
                  .changeBottomNavBar(value); // Change the current screen index
            },
            items: const [
              // Bottom navigation items
              BottomNavigationBarItem(
                  icon: Icon(IconBroken.Home), label: 'Home'), // Home screen
              BottomNavigationBarItem(
                  icon: Icon(IconBroken.Chat), label: 'Chats'), // Chat screen
              BottomNavigationBarItem(
                  icon: Icon(IconBroken.Paper_Upload),
                  label: 'Post'), // Post screen
              BottomNavigationBarItem(
                  icon: Icon(IconBroken.Location),
                  label: 'Users'), // Users screen
              BottomNavigationBarItem(
                  icon: Icon(IconBroken.Setting),
                  label: 'Settings'), // Settings screen
            ],
          ),
        );
      },
    );
  }
}
