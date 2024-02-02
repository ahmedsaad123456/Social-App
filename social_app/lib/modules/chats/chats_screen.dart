import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/modules/chat_details/chat_details_screen.dart';
import 'package:social_app/shared/components/components.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

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
                  buildChatItem(users[index], context),
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


  // build chat item
  Widget buildChatItem(UserModel model, context) {
    return InkWell(
      onTap: () {
        navigateTo(context, ChatDetailsScreen(model));
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25.0,
              backgroundImage: NetworkImage(
                model.image!,
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            Text(model.name!),
          ],
        ),
      ),
    );
  }
}

//================================================================================================================================

