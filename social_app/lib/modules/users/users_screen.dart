import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/modules/chat_details/chat_details_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

//================================================================================================================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var users = SocialCubit.get(context).users;
        return ConditionalBuilder(
          condition: users.isNotEmpty,
          builder: (context) => ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) =>
                  buildUserItem(users[index], context),
              separatorBuilder: (context, index) => myDivider(),
              itemCount: users.length),
          fallback: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

//================================================================================================================================

  // build user item
  Widget buildUserItem(UserModel model, context) {
    bool isFollow =
        SocialCubit.get(context).isInMyFollowings(followingUserId: model.uId!);
    return InkWell(
      onTap: () {},
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
}

//================================================================================================================================

