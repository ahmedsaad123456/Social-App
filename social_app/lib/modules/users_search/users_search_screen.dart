//================================================================================================================================

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/follow_model.dart';
import 'package:social_app/shared/components/components.dart';

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
  Widget searchBuilder(List<FollowModel> list, context, {isSearch = false}) => ConditionalBuilder(
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

}


//================================================================================================================================