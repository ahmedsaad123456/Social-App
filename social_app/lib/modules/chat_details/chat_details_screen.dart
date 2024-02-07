import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/message_model.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/modules/user_profile/user_profile_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/colors.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

// ignore: must_be_immutable
class ChatDetailsScreen extends StatelessWidget {
  // user in chat
  final UserModel userModel;
  ChatDetailsScreen(this.userModel, {super.key});

  final messageController = TextEditingController();

//================================================================================================================================

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // get messages of this chat
        SocialCubit.get(context).getMessages(receiverId: userModel.uId!);
        return BlocConsumer<SocialCubit, SocialStates>(
          listener: (context, state) {},
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                leading: BackButton(
                  onPressed: () {
                    SocialCubit.get(context).previousDate = null;
                    SocialCubit.get(context).messages = [];
                    Navigator.pop(context);
                  },
                ),
                titleSpacing: 0.0,
                title: InkWell(
                  onTap: () {
                    SocialCubit.get(context).previousDate = null;
                    SocialCubit.get(context).clearSpecificUserData();

                    SocialCubit.get(context)
                        .getSpecificUserData(specificUserId: userModel.uId!);
                    navigateTo(context, const UserProfileScreen());
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20.0,
                        backgroundColor:
                            Colors.white, // Set background color to white
                        child: ClipOval(
                          child: Image.network(
                            userModel.image!,
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
                                      image: AssetImage(
                                          'assets/images/white.jpeg')),
                                );
                              }
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Image(
                                  image:
                                      AssetImage('assets/images/white.jpeg'));
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15.0,
                      ),
                      Text(userModel.name ?? ""),
                    ],
                  ),
                ),
              ),
              body: ConditionalBuilder(
                condition: true,
                builder: (context) => Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        reverse: true,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              ListView.separated(
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Disable scrolling of this ListView
                                  shrinkWrap: true, // Wrap content
                                  itemBuilder: (context, index) {
                                    // if the message was sent by the loggedIn user
                                    if (SocialCubit.get(context)
                                            .userDataModel!
                                            .user
                                            .uId ==
                                        SocialCubit.get(context)
                                            .messages[index]
                                            .senderId) {
                                      return buildMyMessage(
                                          SocialCubit.get(context)
                                              .messages[index],
                                          context);
                                    }

                                    // if the message wasn't sent by the loggedIn user
                                    else {
                                      return buildOtherMessage(
                                          SocialCubit.get(context)
                                              .messages[index],
                                          context);
                                    }
                                  },
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                  itemCount:
                                      SocialCubit.get(context).messages.length),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Row(
                          // send message
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                                child: TextFormField(
                                  controller: messageController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'type your message here ...',
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 50.0,
                              color: defaultColor,
                              child: MaterialButton(
                                onPressed: () {
                                  if (messageController.text.isEmpty) {
                                    messageScreen(
                                        message: "can't send empty message",
                                        state: ToastStates.ERROR);
                                  } else {
                                    SocialCubit.get(context).previousDate = null;
                                    SocialCubit.get(context).sendMessage(
                                        receiverId: userModel.uId!,
                                        text: messageController.text,
                                        dateTime: DateTime.now().toString());
                                    messageController.text = '';
                                  }
                                },
                                minWidth: 1.0,
                                child: const Icon(
                                  IconBroken.Send,
                                  size: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                fallback: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            );
          },
        );
      },
    );
  }

//================================================================================================================================
  // build the message of the other user
  Widget buildOtherMessage(MessageModel model, context) {
    GlobalKey key = GlobalKey();

    return Column(
      children: [
        if (SocialCubit.get(context).showDate(model.dateTime!) ||
            SocialCubit.get(context).previousDate == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              model.dateTime!
                  .substring(0, 11), // Display the date above the message
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: InkWell(
            key: key,
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
                  SocialCubit.get(context)
                      .deleteMessage(model.dateTime!, model.senderId!, false);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadiusDirectional.only(
                  bottomEnd: Radius.circular(10.0),
                  topStart: Radius.circular(10.0),
                  topEnd: Radius.circular(10.0),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: RichText(
                text: TextSpan(
                  text: "${model.text!} \n", // original tex
                  style: Theme.of(context).textTheme.titleMedium,
                  children: [
                    TextSpan(
                      text: model.dateTime!.substring(11, 16), // dateTime text
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

//================================================================================================================================

  // build the message of the loggedIn user
  Widget buildMyMessage(MessageModel model, context) {
    GlobalKey key = GlobalKey();

    return Column(
      children: [
        if (SocialCubit.get(context).showDate(model.dateTime!) ||
            SocialCubit.get(context).previousDate == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              model.dateTime!
                  .substring(0, 11), // Display the date above the message
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: InkWell(
            key: key,
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
                  ]).then((value) {
                if (value == 1) {
                  SocialCubit.get(context)
                      .deleteMessage(model.dateTime!, model.receiverId!, true);
                } else if (value == 2) {
                  print("22222222222");
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: defaultColor.withOpacity(0.2),
                borderRadius: const BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(10.0),
                  topStart: Radius.circular(10.0),
                  topEnd: Radius.circular(10.0),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: RichText(
                text: TextSpan(
                  text: "${model.text!} \n", // original tex
                  style: Theme.of(context).textTheme.titleMedium,
                  children: [
                    TextSpan(
                      text: model.dateTime!.substring(11, 16), // dateTime text
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

//================================================================================================================================
}

//================================================================================================================================
