import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/shared/components/components.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

//================================================================================================================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        // if there is no users
        if (state is SocialGetAllUsersEmptyState) {
          messageScreen(
              message: "there is no more users available",
              state: ToastStates.WARNING);
        } else if (state is SocialGetAllUsersErrorState) {
          messageScreen(
              message: "Check your internet connection",
              state: ToastStates.ERROR);
        }
      },
      builder: (context, state) {
        var users = SocialCubit.get(context).users;
        return SingleChildScrollView(
          child: Column(
            children: [
              ConditionalBuilder(
                condition: users.isNotEmpty,
                builder: (context) => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) =>
                        buildUserItem(users[index], context),
                    separatorBuilder: (context, index) => myDivider(),
                    itemCount: users.length),
                fallback: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              // show more users
              ConditionalBuilder(
                condition: state is! SocialGetAllUsersLoadingState,
                builder: (context) => defaultTextButton(
                    fun: () {
                      SocialCubit.get(context).getAllUsersData(loadMore: true);
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
        );
      },
    );
  }
}
//================================================================================================================================

