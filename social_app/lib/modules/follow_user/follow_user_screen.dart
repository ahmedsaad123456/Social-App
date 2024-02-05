import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/follow_model.dart';
import 'package:social_app/shared/components/components.dart';

class FollowUserScreen extends StatelessWidget {
  // list of followers or followings users
  final List<FollowModel> followUsers;

  // title of the app bar
  final String title;

  // type of the screen
  final ScreenType? screen;

  const FollowUserScreen(this.followUsers, this.title, this.screen ,{super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) => Scaffold(
          appBar: defaultAppBar(
            context: context,
            title: title,
          ),
          body: Column(
            children: [
              SingleChildScrollView(
                child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) =>
                        buildFollowUserItem(followUsers[index], context , screen),
                    separatorBuilder: (context, index) => myDivider(),
                    itemCount: followUsers.length),
              ),
            ],
          )),
    );
  }
}
