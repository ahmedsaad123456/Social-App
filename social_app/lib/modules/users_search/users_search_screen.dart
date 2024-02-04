//================================================================================================================================

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/modules/chat_details/chat_details_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

//================================================================================================================================
// This screen allows users to search for users

class UsersSearchScreen extends StatelessWidget {
  UsersSearchScreen({super.key});

  final searchController = TextEditingController();
  final formKey = GlobalKey<FormState>();

//================================================================================================================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var list = SocialCubit.get(context).usersSearch;
        return Scaffold(
          appBar: AppBar(),
          body: Form(
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: defaultFormField(
                    controller: searchController,
                    type: TextInputType.text,
                    label: 'Search',
                    validate: (value) {
                      if (value!.isEmpty) {
                        return 'Search must not be empty';
                      }
                      return null;
                    },
                    prefix: Icons.search,
                    onChange: (value) {
                      SocialCubit.get(context).searchUsers(name: value);
                    },
                  ),
                ),
                const SizedBox(height: 10.0,),
                if (state is SocialGetSearchUsersLoadingState) const LinearProgressIndicator(),
                Expanded(child: searchBuilder(list, context, isSearch: true)),
              ],
            ),
          ),
        );
      },
    );
  }

//================================================================================================================================

  // Widget to build the search results
  Widget searchBuilder(List<UserModel> list, context, {isSearch = false}) => ConditionalBuilder(
    condition: list.isNotEmpty ,
    builder: (context) => ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) => buildUserItem(list[index], context),
      separatorBuilder: (context, index) => myDivider(),
      itemCount: list.length, 
    ),
    fallback: (context) => isSearch ? Container() : const Center(child: CircularProgressIndicator()),
  );

//================================================================================================================================

  // build user item
  Widget buildUserItem(UserModel model, context) {
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


//================================================================================================================================