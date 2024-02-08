import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/modules/chat_details/chat_details_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

//================================================================================================================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        SocialCubit.get(context).filterUsersForChats();
        var chatUsers = SocialCubit.get(context).userChatsModel;
        return ConditionalBuilder(
          condition: SocialCubit.get(context).users.isNotEmpty,
          builder: (context) => ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) =>
                  buildChatItem(chatUsers[index], context),
              separatorBuilder: (context, index) => myDivider(),
              itemCount: chatUsers.length),
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
    GlobalKey key = GlobalKey();

    return InkWell(
      key: key,
      onTap: () {
        navigateTo(context, ChatDetailsScreen(model));
      },
      onLongPress: () {
        final RenderBox overlay =
            key.currentContext!.findRenderObject() as RenderBox;
        final tapPosition = overlay.localToGlobal(Offset.zero);
        showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              tapPosition.dx,
              tapPosition.dy,
              MediaQuery.of(context).size.width - tapPosition.dx,
              MediaQuery.of(context).size.height - tapPosition.dy,
            ),
            items: [
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
            ]).then((value) {
          if (value == 1) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Delete chat"),
                content: const Text(
                    "This will lead to delete all messages in this chat"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.all(14),
                      child: const Text(
                        "cancel",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      SocialCubit.get(context).deleteChat(model.uId!);
                      Navigator.of(ctx).pop();

                    },
                    child: Container(
                      color: Colors.green,
                      padding: const EdgeInsets.all(14),
                      child: const Text(
                        "confirm",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        });
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
            Text(model.name ?? ""),
          ],
        ),
      ),
    );
  }
}

//================================================================================================================================

