import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:like_button/like_button.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/post_model.dart';
import 'package:social_app/shared/styles/colors.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

class FeedsScreen extends StatelessWidget {
  const FeedsScreen({super.key});

//================================================================================================================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var postList = SocialCubit.get(context).postList;
        return ConditionalBuilder(
          condition:
              postList.isNotEmpty && SocialCubit.get(context).userModel != null,
          builder: (context) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
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
                  itemBuilder: (context, index) =>
                      buildPostItem(context, postList[index], index),
                  itemCount: postList.length,
                ),
                const SizedBox(
                  height: 8.0,
                )
              ],
            ),
          ),
          fallback: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

//================================================================================================================================

  Widget buildPostItem(context, PostModel model, index) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5.0,
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${model.name}',
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          const Icon(
                            Icons.check_circle,
                            size: 16.0,
                            color: defaultColor,
                          )
                        ],
                      ),
                      Text(
                        '${model.dateTime}'.substring(0, 16),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
                IconButton(
                    icon: const Icon(
                      Icons.more_horiz,
                      size: 16.0,
                    ),
                    onPressed: () {}),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
              ),
              child: Container(
                width: double.infinity,
                height: 1.0,
                color: Colors.grey[300],
              ),
            ),
            Text(
              '${model.text}',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            // Padding(
            //   padding: const EdgeInsets.only(
            //     bottom: 10.0,
            //     top: 5.0,
            //   ),

            //   child: Container(
            //     width: double.infinity,
            //     child: Wrap(
            //       children: [
            //         Padding(
            //           padding: const EdgeInsetsDirectional.only(
            //             end: 6.0,
            //           ),
            //           child: Container(
            //             height: 25.0,
            //             child: MaterialButton(
            //               onPressed: () {},
            //               minWidth: 1.0,
            //               padding: EdgeInsets.zero,
            //               child: Text(
            //                 '#software',
            //                 style: Theme.of(context)
            //                     .textTheme
            //                     .bodySmall!
            //                     .copyWith(
            //                       color: defaultColor,
            //                     ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         Padding(
            //           padding: const EdgeInsetsDirectional.only(
            //             end: 6.0,
            //           ),
            //           child: Container(
            //             height: 25.0,
            //             child: MaterialButton(
            //               onPressed: () {},
            //               minWidth: 1.0,
            //               padding: EdgeInsets.zero,
            //               child: Text(
            //                 '#flutter',
            //                 style: Theme.of(context)
            //                     .textTheme
            //                     .bodySmall!
            //                     .copyWith(
            //                       color: defaultColor,
            //                     ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            if (model.postImage != '')
              Padding(
                padding: const EdgeInsets.only(
                  top: 15.0,
                ),
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5.0,
                  margin: const EdgeInsets.all(0.0),
                  child: Image(
                    image: NetworkImage(model.postImage!),
                    fit: BoxFit.cover,
                    height: 140.0,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => const Image(
                        image: AssetImage('assets/images/image_error.jpeg')),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              IconBroken.Heart,
                              color: Colors.red,
                              size: 16.0,
                            ),
                            const SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              '${SocialCubit.get(context).likes[index].length}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              IconBroken.Chat,
                              color: Colors.amber,
                              size: 16.0,
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text('521 comments'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 10.0,
              ),
              child: Container(
                width: double.infinity,
                height: 1.0,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18.0,
                          backgroundImage: NetworkImage(
                            SocialCubit.get(context).userModel!.image!,
                          ),
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Text(
                          'Write a comment...',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(),
                        ),
                      ],
                    ),
                  ),
                ),
                LikeButton(
                  isLiked: SocialCubit.get(context).isLikedPostList[index],
                  size: 16.0,
                  circleColor: const CircleColor(
                      start: Color(0xff00ddff), end: Color(0xff0099cc)),
                  bubblesColor: const BubblesColor(
                    dotPrimaryColor: Color(0xff33b5e5),
                    dotSecondaryColor: Color(0xff0099cc),
                  ),
                  likeBuilder: (bool isLiked) {
                    return Icon(
                      IconBroken.Heart,
                      color: isLiked ? Colors.deepPurpleAccent : Colors.grey,
                      size: 16.0,
                    );
                  },
                  likeCount: 0,
                  countBuilder: (likeCount, isLiked, text) {
                    var color = isLiked ? Colors.deepPurpleAccent : Colors.grey;
                    return Text('Love', style: TextStyle(color: color));
                  },
                  onTap: (isLiked) async {
                    if (!isLiked) {
                      final cubit = SocialCubit.get(context);
                      bool likeSuccess = await cubit.likePost(
                        postId: cubit.postId[index],
                        index: index,
                      );

                      return !isLiked &&
                          likeSuccess; // Return the opposite of isLiked only if the like was successful
                    } else {
                      final cubit = SocialCubit.get(context);
                      bool unlikeSuccess = await cubit.unlikePost(
                          postId: cubit.postId[index], index: index);
                      return isLiked &&
                          unlikeSuccess; // Return true to indicate unliking was successful
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
