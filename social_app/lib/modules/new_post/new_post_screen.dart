import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

class NewPostScreen extends StatelessWidget {
  final textController = TextEditingController();
  NewPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        // to check if the post created successfully or not
        if (state is SocialCreatePostSuccessState) {
          messageScreen(
              message: 'Created Successfully', state: ToastStates.SUCCESS);
        }

        if (state is SocialCreatePostErrorState) {
          messageScreen(message: "Failed", state: ToastStates.ERROR);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: defaultAppBar(
            context: context,
            title: 'Create Post',
            actions: [
              defaultTextButton(
                  fun: () {
                    // if the post has image
                    if (SocialCubit.get(context).postImage != null) {
                      SocialCubit.get(context).uplaodPostImage(
                          dateTime: DateTime.now().toString(),
                          text: textController.text);
                    }

                    // if the post hasn't image
                    else {
                      SocialCubit.get(context).createPost(
                          dateTime: DateTime.now().toString(),
                          text: textController.text);
                    }
                  },
                  text: 'POST'),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (state is SocialCreatePostLoadingState)
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
                          SocialCubit.get(context).userModel!.image!,
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
                                    image:
                                        AssetImage('assets/images/white.jpeg')),
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
                          Row(
                            children: [
                              Text(
                                SocialCubit.get(context).userModel!.name ?? '',
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
                Expanded(
                  child: TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'what is on your mind',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (SocialCubit.get(context).postImage != null)
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 5.0,
                        margin: const EdgeInsets.all(0.0),
                        child: Image(
                          image: FileImage(SocialCubit.get(context).postImage!),
                          fit: BoxFit.cover,
                          height: 140.0,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Image(
                                  image: AssetImage(
                                      'assets/images/image_error.jpeg')),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          SocialCubit.get(context).removePostImage();
                        },
                        icon: const CircleAvatar(
                          radius: 20.0,
                          child: Icon(
                            Icons.close,
                            size: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          SocialCubit.get(context).getPostImage();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(IconBroken.Image),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text('add photo'),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
