import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/post_data_model.dart';
import 'package:social_app/shared/components/components.dart';

class EditPostScreen extends StatelessWidget {
  final textController = TextEditingController();
  final PostDataModel postDataModel;

  final List<String> postId;

  final int index;

  final ScreenType screen;

  EditPostScreen(this.postDataModel, this.postId, this.index, this.screen,
      {super.key}) {
    textController.text = postDataModel.post.text!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
      },
      builder: (context, state) {
        return Scaffold(
          appBar: defaultAppBar(
            context: context,
            title: 'Edit Post',
            actions: [
              defaultTextButton(
                  fun: () {
                    if (textController.text.isEmpty) {
                      messageScreen(
                          message: "can't update to empty post",
                          state: ToastStates.ERROR);
                    } else {
                      SocialCubit.get(context).editPost(postDataModel,
                          postId[index], index, screen, textController.text);
                      Navigator.pop(context);
                    }
                  },
                  text: 'Edit'),
            ],
          ),
          body: ConditionalBuilder(
            condition: SocialCubit.get(context).userDataModel != null,
            builder: (context) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    if (state is SocialEditPostLoadingState)
                      const LinearProgressIndicator(),
                    if (state is SocialCreatePostLoadingState)
                      const SizedBox(
                        height: 10.0,
                      ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25.0,
                          backgroundColor:
                              Colors.white, // Set background color to white
                          child: ClipOval(
                            child: Image.network(
                              SocialCubit.get(context)
                                  .userDataModel!
                                  .user
                                  .image!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    SocialCubit.get(context)
                                            .userDataModel!
                                            .user
                                            .name ??
                                        '',
                                    style: const TextStyle(height: 1.4),
                                  ),
                                ],
                              ),
                              Text(
                                'public',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      maxLines: 10,
                      controller: textController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (postDataModel.post.postImage != '')
                      Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: [
                          Card(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            elevation: 5.0,
                            margin: const EdgeInsets.all(0.0),
                            child: LimitedBox(
                              maxHeight: 500.0,
                              child: Image(
                                image:
                                    NetworkImage(postDataModel.post.postImage!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Image(
                                        image: AssetImage(
                                            'assets/images/image_error.jpeg')),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (postDataModel.post.postImage == null)
                      const SizedBox(
                        height: 250,
                      ),
                  ],
                ),
              ),
            ),
            fallback: (context) =>
                const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
