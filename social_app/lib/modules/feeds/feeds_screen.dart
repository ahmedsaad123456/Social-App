import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/shared/components/components.dart';

class FeedsScreen extends StatelessWidget {
  const FeedsScreen({super.key});

//================================================================================================================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        // if there is no posts
        if (state is SocialGetPostEmptyState) {
          messageScreen(
              message: "follow more users to show more posts",
              state: ToastStates.WARNING);
        } else if (state is SocialGetPostErrorState) {
          messageScreen(
              message: "Check your internet connection",
              state: ToastStates.ERROR);
        }
        // to check if the post updated successfully or not
        if (state is SocialEditPostSuccessState) {
          messageScreen(
              message: 'Updated Successfully', state: ToastStates.SUCCESS);
        }

        if (state is SocialEditPostErrorState) {
          messageScreen(message: "Failed", state: ToastStates.ERROR);
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            SocialCubit.get(context).clearPostData();
            SocialCubit.get(context).getPostsData();
            await Future.delayed(const Duration(seconds: 1));
          },
          child: ConditionalBuilder(
            condition: (SocialCubit.get(context).allpostsData.isNotEmpty &&
                    SocialCubit.get(context).userDataModel != null) ||
                SocialCubit.get(context).isLoggedInPosts != null,
            builder: (context) => SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 5.0,
                    margin: const EdgeInsets.all(
                      8.0,
                    ),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        Image(
                          image: const NetworkImage(
                              'https://image.freepik.com/free-photo/horizontal-shot-smiling-curly-haired-woman-indicates-free-space-demonstrates-place-your-advertisement-attracts-attention-sale-wears-green-turtleneck-isolated-vibrant-pink-wall_273609-42770.jpg'),
                          fit: BoxFit.cover,
                          height: 200.0,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Image(
                                  image: AssetImage(
                                      'assets/images/image_error.jpeg')),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'communicate with friends',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 8.0,
                    ),
                    itemBuilder: (context, index) => buildPostItem(
                        context,
                        SocialCubit.get(context).allpostsData[index],
                        SocialCubit.get(context).postId[index],
                        index,
                        ScreenType.HOME),
                    itemCount: SocialCubit.get(context).allpostsData.length,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  // show more posts
                  ConditionalBuilder(
                    condition: state is! SocialGetPostLoadingState,
                    builder: (context) => defaultTextButton(
                        fun: () {
                          SocialCubit.get(context).getPostsData(loadMore: true);
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
            ),
            fallback: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

//================================================================================================================================
}
