import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/layouts/cubit/social_states.dart';
import 'package:social_app/models/comment_model.dart';
import 'package:social_app/models/follow_model.dart';
import 'package:social_app/models/like_model.dart';
import 'package:social_app/models/message_model.dart';
import 'package:social_app/models/post_data_model.dart';
import 'package:social_app/models/post_model.dart';
import 'package:social_app/models/user_data_model.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/modules/chats/chats_screen.dart';
import 'package:social_app/modules/feeds/feeds_screen.dart';
import 'package:social_app/modules/new_post/new_post_screen.dart';
import 'package:social_app/modules/settings/settings_screen.dart';
import 'package:social_app/modules/users/users_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/components/constants.dart';

class SocialCubit extends Cubit<SocialStates> {
  SocialCubit() : super(SocialInitialState());

  static SocialCubit get(context) => BlocProvider.of(context);

  // Data of logged in user
  UserDataModel? userDataModel;

  void getUserData() async {
    emit(SocialGetUserLoadingState());

    try {
      Query userQuery = FirebaseFirestore.instance
          .collection('users')
          .where('uId', isEqualTo: uId);

      QuerySnapshot userQuerySnapshot = await userQuery.get();
      QueryDocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;

      List<FollowModel> followers = [];
      List<FollowModel> followings = [];

      // get followers of the user
      QuerySnapshot followersQuerySnapshot =
          await userSnapshot.reference.collection('followers').get();
      for (var userSnapshot in followersQuerySnapshot.docs) {
        followers.add(
            FollowModel.fromJson(userSnapshot.data() as Map<String, dynamic>));
      }

      // get followings of the user
      QuerySnapshot followingsQuerySnapshot =
          await userSnapshot.reference.collection('followings').get();

      for (var userSnapshot in followingsQuerySnapshot.docs) {
        followings.add(
            FollowModel.fromJson(userSnapshot.data() as Map<String, dynamic>));
      }

      // Create user data model instance
      UserDataModel userData = UserDataModel(
        user: UserModel.fromJson(userSnapshot.data() as Map<String, dynamic>),
        followers: followers,
        followings: followings,
      );

      userDataModel = userData;

      getPostsData();

      emit(SocialGetUserSuccessState());
    } catch (error) {
      emit(SocialGetUserErrorState(error.toString()));
    }
  }

//================================================================================================================================

// get posts of logged in user

// list that contains post id of logged in user
  List<String> loggedInUserpostId = [];

  // list that contains data of logged in posts
  List<PostDataModel> loggedInUserpostsData = [];

  // DocumentSnapshot to keep track of the last document
  DocumentSnapshot? lastDocument;

  // String to indicate that is no posts of specific user
  String? isLoggedInPosts;

  // get all the posts data
  void getLoggedInUserPostsData({bool loadMore = false}) async {
    emit(SocialGetLoggedInUserPostLoadingState());

    try {
      Query postQuery = FirebaseFirestore.instance
          .collection('posts')
          .where("uId", isEqualTo: uId)
          .orderBy('dateTime', descending: true)
          .limit(3);

      // if the user need to show more
      // If loading more and we have existing posts, fetch next batch after the last post
      if (loadMore && lastDocument != null) {
        postQuery = postQuery.startAfterDocument(lastDocument!);
      }

      // Execute the query
      QuerySnapshot postQuerySnapshot = await postQuery.get();

      if (postQuerySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot postSnapshot in postQuerySnapshot.docs) {
          List<LikeModel> likesUsers = [];
          List<CommentModel> commentUser = [];

          // get likes of the post
          QuerySnapshot likesQuerySnapshot =
              await postSnapshot.reference.collection('likes').get();
          for (var userSnapshot in likesQuerySnapshot.docs) {
            likesUsers.add(LikeModel.fromJson(
                userSnapshot.data() as Map<String, dynamic>));
          }

          // get comments of the post
          QuerySnapshot commentsQuerySnapshot =
              await postSnapshot.reference.collection('comments').get();

          for (var userSnapshot in commentsQuerySnapshot.docs) {
            commentUser.add(CommentModel.fromJson(
                userSnapshot.data() as Map<String, dynamic>));
          }

          bool isLiked = likesUsers.any((like) => like.uId == uId);

          // Create PostData instance
          PostDataModel postData = PostDataModel(
            post:
                PostModel.fromJson(postSnapshot.data() as Map<String, dynamic>),
            likes: likesUsers,
            comments: commentUser,
            isLiked: isLiked,
          );

          // Store post data in the map
          loggedInUserpostId.add(postSnapshot.id);
          loggedInUserpostsData.add(postData);

          // Update the last document
          lastDocument = postQuerySnapshot.docs.last;
        }
        emit(SocialGetLoggedInUserPostSuccessState());
      } else {
        isLoggedInPosts = "no";
        emit(SocialGetLoggedInUserPostEmptyState());
      }
    } catch (error) {
      emit(SocialGetLoggedInUserPostErrorState(error.toString()));
    }
  }

//================================================================================================================================
  // index of bottom nav bar
  int currentIndex = 0;

  // screens of the app
  List<Widget> screens = [
    const FeedsScreen(),
    const ChatsScreen(),
    NewPostScreen(),
    const UsersScreen(),
    const SettingsScreen(),
  ];

  // change the bottom nav bar index
  void changeBottomNavBar(index) {
    if (index == 1 || index == 3) {
      // get all user to chat
      getAllUsersData();
    }
    if (index == 2) {
      // emit state to navigate to create post screen
      emit(SocialNewPostState());
    } else {
      // else emit state to navigate to the specific screen
      currentIndex = index;
      emit(SocialChangeBottomNavBarState());
    }
  }

  // titles of appbar

  List<String> titles = [
    'Home',
    'Chats',
    'Post',
    'Users',
    'Settings',
  ];

//================================================================================================================================

  File? profileImage;
  final picker = ImagePicker();

  // get profile image
  Future getProfileImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      emit(SocialProfileImagePickedSuccessState());
    } else {
      emit(SocialProfileImagePickedErrorState());
    }
  }

//================================================================================================================================

  File? coverImage;

  // get cover image from the gallary
  Future getCoverImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      coverImage = File(pickedFile.path);
      emit(SocialCoverImagePickedSuccessState());
    } else {
      emit(SocialCoverImagePickedErrorState());
    }
  }

//================================================================================================================================

  // upload profile image to the firebase storage
  void uploadProfileImage({
    required String name,
    required String phone,
    required String bio,
  }) {
    emit(SocialUpdateUserLoadingState());

    FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(profileImage!.path).pathSegments.last}')
        .putFile(profileImage!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        updateUser(name: name, phone: phone, bio: bio, image: value);
        profileImage = null;
      }).catchError((error) {
        emit(SocialUploadProfileImageErrorState());
      });
    }).catchError((error) {
      emit(SocialUploadProfileImageErrorState());
    });
  }

//================================================================================================================================

  // upload cover image to the firebase storage

  void uploadCoverImage({
    required String name,
    required String phone,
    required String bio,
  }) {
    emit(SocialUpdateUserLoadingState());

    FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(coverImage!.path).pathSegments.last}')
        .putFile(coverImage!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        updateUser(name: name, phone: phone, bio: bio, cover: value);
        coverImage = null;
      }).catchError((error) {
        emit(SocialUploadCoverImageErrorState());
      });
    }).catchError((error) {
      emit(SocialUploadCoverImageErrorState());
    });
  }

//================================================================================================================================

  // update user data
  void updateUser({
    required String name,
    required String phone,
    required String bio,
    String? cover,
    String? image,
  }) {
    UserModel model = UserModel(
      name: name,
      email: userDataModel!.user.email,
      phone: phone,
      uId: uId,
      isEmailVerified: false,
      bio: bio,
      image: image ?? userDataModel!.user.image,
      cover: cover ?? userDataModel!.user.cover,
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .update(model.toMap())
        .then((value) {
      getUserData();
    }).catchError((error) {
      emit(SocialUpdateUserErrorState());
    });
  }

//================================================================================================================================

  File? postImage;

  // get post image from gallery
  Future getPostImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      postImage = File(pickedFile.path);
      emit(SocialPostImagePickedSuccessState());
    } else {
      emit(SocialPostImagePickedErrorState());
    }
  }

//================================================================================================================================

  // upload post image to the firebase storage
  void uplaodPostImage({
    required String dateTime,
    required String text,
  }) {
    emit(SocialCreatePostLoadingState());

    FirebaseStorage.instance
        .ref()
        .child('posts/${Uri.file(postImage!.path).pathSegments.last}')
        .putFile(postImage!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        createPost(dateTime: dateTime, text: text, postImage: value);
        postImage = null;
      }).catchError((error) {
        emit(SocialCreatePostErrorState());
      });
    }).catchError((error) {
      emit(SocialCreatePostErrorState());
    });
  }

//================================================================================================================================

  // create post model and add it to the posts collection
  void createPost({
    required String dateTime,
    required String text,
    String? postImage,
  }) {
    emit(SocialCreatePostLoadingState());
    PostModel model = PostModel(
      name: userDataModel!.user.name,
      uId: userDataModel!.user.uId,
      image: userDataModel!.user.image,
      dateTime: dateTime,
      text: text,
      postImage: postImage ?? '',
    );

    FirebaseFirestore.instance
        .collection('posts')
        .add(model.toMap())
        .then((value) {
      // Store the post ID in loggedInUserpostId list
      loggedInUserpostId.insert(0, value.id);

      // Add the created post model to loggedInUserpostsData list
      
      PostDataModel postData = PostDataModel(
        post: model,
        likes: [],
        comments: [],
        isLiked: false,
      );

      loggedInUserpostsData.insert(0, postData);

      emit(SocialCreatePostSuccessState());
    }).catchError((error) {
      emit(SocialCreatePostErrorState());
    });
  }

//================================================================================================================================

  // remove post image when creating new post
  void removePostImage() {
    postImage = null;
    emit(SocialRemovePostImageState());
  }

//================================================================================================================================

  // list that contains post id
  List<String> postId = [];

  // list that contains data of all posts
  List<PostDataModel> allpostsData = [];

  // get all the posts data
  void getPostsData({bool loadMore = false}) async {
    emit(SocialGetPostLoadingState());

    try {
      // get all the posts created by one of my followings
      List<String> followingIds =
          userDataModel!.followings.map((following) => following.uId!).toList();

      followingIds.add(uId!);

      Query postQuery = FirebaseFirestore.instance.collection('posts');

      // if the user need to show more
      // If loading more and we have existing posts, fetch next batch after the last post
      if (loadMore && postId.isNotEmpty) {
        postQuery =
            postQuery.orderBy(FieldPath.documentId).startAfter([postId.last]);
      }

      // get 3 posts only every time
      QuerySnapshot postQuerySnapshot =
          await postQuery.where('uId', whereIn: followingIds).limit(3).get();

      if (postQuerySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot postSnapshot in postQuerySnapshot.docs) {
          List<LikeModel> likesUsers = [];
          List<CommentModel> commentUser = [];

          // get likes of the post
          QuerySnapshot likesQuerySnapshot =
              await postSnapshot.reference.collection('likes').get();
          for (var userSnapshot in likesQuerySnapshot.docs) {
            likesUsers.add(LikeModel.fromJson(
                userSnapshot.data() as Map<String, dynamic>));
          }

          // get comments of the post
          QuerySnapshot commentsQuerySnapshot =
              await postSnapshot.reference.collection('comments').get();

          for (var userSnapshot in commentsQuerySnapshot.docs) {
            commentUser.add(CommentModel.fromJson(
                userSnapshot.data() as Map<String, dynamic>));
          }

          bool isLiked = likesUsers.any((like) => like.uId == uId);

          // Create PostData instance
          PostDataModel postData = PostDataModel(
            post:
                PostModel.fromJson(postSnapshot.data() as Map<String, dynamic>),
            likes: likesUsers,
            comments: commentUser,
            isLiked: isLiked,
          );

          // Store post data in the map
          postId.add(postSnapshot.id);
          allpostsData.add(postData);
        }
        emit(SocialGetPostSuccessState());
      } else {
        emit(SocialGetPostEmptyState());
      }
    } catch (error) {
      emit(SocialGetPostErrorState(error.toString()));
    }
  }

//================================================================================================================================

  // do like on the post
  Future<bool> likePost(
      {required String postID,
      required int index,
      required ScreenType screen}) async {
    try {
      emit(SocialLikePostLoadingState());

      LikeModel model = LikeModel(
        image: userDataModel!.user.image,
        name: userDataModel!.user.name,
        uId: userDataModel!.user.uId,
      );
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postID)
          .collection('likes')
          .add(model.toMap());

      if (screen == ScreenType.HOME) {
        // If screen is HOME, update the likes list in allpostsData
        allpostsData[index].likes.add(model);
        allpostsData[index].isLiked = true;

        // Check if the post is in the posts of the logged in user
        int userPostIndex = loggedInUserpostId.indexOf(postID);
        if (userPostIndex != -1) {
          // If the postId is found in the list, update the likes list in loggedInUserpostsData
          loggedInUserpostsData[userPostIndex].likes.add(model);
          loggedInUserpostsData[userPostIndex].isLiked = true;
        }
      } else if (screen == ScreenType.SETTINGS) {
        // If screen is SETTINGS, update the likes list in loggedInUserpostsData
        loggedInUserpostsData[index].likes.add(model);
        loggedInUserpostsData[index].isLiked = true;

        // Check if the post is in the posts of the home
        int userPostIndex = postId.indexOf(postID);
        if (userPostIndex != -1) {
          // If the postId is found in the list, update the likes list in the home
          allpostsData[userPostIndex].likes.add(model);
          allpostsData[userPostIndex].isLiked = true;
        }
      } else if (screen == ScreenType.PROFILE) {
        // If screen is PROFILE, update the likes list in specificUserpostsData

        specificUserpostsData[index].likes.add(model);
        specificUserpostsData[index].isLiked = true;

        // Check if the post is in the posts of the home
        int userPostIndex = postId.indexOf(postID);
        if (userPostIndex != -1) {
          // If the postId is found in the list, update the likes list in the home
          allpostsData[userPostIndex].likes.add(model);
          allpostsData[userPostIndex].isLiked = true;
        }
      }

      emit(SocialLikePostSuccessState());
      return true; // Return true to indicate success
    } catch (error) {
      emit(SocialLikePostErrorState(error.toString()));
      return false; // Return false to indicate failure
    }
  }

//================================================================================================================================

  // do unlike on the post
  Future<bool> unlikePost(
      {required String postID,
      required int index,
      required ScreenType screen}) async {
    try {
      emit(SocialUnlikePostLoadingState());

      // Perform the unlike operation
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postID)
          .collection('likes')
          .where('uId', isEqualTo: userDataModel!.user.uId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.first.reference
            .delete(); // Delete the first document directly (unique)
      });

      if (screen == ScreenType.HOME) {
        // If screen is HOME, update the likes list in allpostsData
        allpostsData[index]
            .likes
            .removeWhere((like) => like.uId == userDataModel!.user.uId);
        allpostsData[index].isLiked = false;

        // Check if the post is in the posts of the logged in user
        int userPostIndex = loggedInUserpostId.indexOf(postID);
        if (userPostIndex != -1) {
          // If the postId is found in the list, update the likes list in loggedInUserpostsData
          loggedInUserpostsData[userPostIndex]
              .likes
              .removeWhere((like) => like.uId == userDataModel!.user.uId);
          loggedInUserpostsData[userPostIndex].isLiked = false;
        }
      } else if (screen == ScreenType.SETTINGS) {
        // If screen is SETTINGS, update the likes list in loggedInUserpostsData
        loggedInUserpostsData[index]
            .likes
            .removeWhere((like) => like.uId == userDataModel!.user.uId);
        loggedInUserpostsData[index].isLiked = false;

        // Check if the post is in the posts of the home
        int userPostIndex = postId.indexOf(postID);
        if (userPostIndex != -1) {
          // If the postId is found in the list, update the likes list in the home
          allpostsData[userPostIndex]
              .likes
              .removeWhere((like) => like.uId == userDataModel!.user.uId);
          allpostsData[userPostIndex].isLiked = false;
        }
      } else if (screen == ScreenType.PROFILE) {
        // If screen is PROFILE, update the likes list in SpecificUserpostsData

        specificUserpostsData[index]
            .likes
            .removeWhere((like) => like.uId == userDataModel!.user.uId);
        specificUserpostsData[index].isLiked = false;

        // Check if the post is in the posts of the home
        int userPostIndex = postId.indexOf(postID);
        if (userPostIndex != -1) {
          // If the postId is found in the list, update the likes list in the home
          allpostsData[userPostIndex]
              .likes
              .removeWhere((like) => like.uId == userDataModel!.user.uId);
          allpostsData[userPostIndex].isLiked = false;
        }
      }

      emit(SocialUnlikePostSuccessState());
      return true; // Return true to indicate success
    } catch (error) {
      emit(SocialUnlikePostErrorState());
      return false; // Return false to indicate failure
    }
  }

//================================================================================================================================

  // get all users
  List<UserModel> users = [];

  // list to search for users
  List<UserModel> usersSearch = [];

  void getAllUsersData() {
    emit(SocialGetAllUsersLoadingState());
    if (users.isEmpty) {
      FirebaseFirestore.instance.collection('users').get().then((value) {
        if (value.docs.isNotEmpty) {
          for (var element in value.docs) {
            // store all users in the list expect the loggedIn user
            if (element.data()['uId'] != userDataModel!.user.uId) {
              users.add(UserModel.fromJson(element.data()));
            }
          }

          // store all users in the search list
          usersSearch = users;
        }
        emit(SocialGetAllUsersSuccessState());
      }).catchError((error) {
        emit(SocialGetAllUsersErrorState(error.toString()));
      });
    }
  }

//================================================================================================================================

  void searchUsers({required String name}) {
    emit(SocialGetSearchUsersLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .orderBy("name")
        .startAt([name])
        .endAt(["$name\uf8ff"])
        .get()
        .then((value) {
          usersSearch = [];
          if (value.docs.isNotEmpty) {
            for (var element in value.docs) {
              // store all search users in the list expect the loggedIn user
              if (element.data()['uId'] != userDataModel!.user.uId) {
                usersSearch.add(UserModel.fromJson(element.data()));
              }
            }
          }
          emit(SocialGetSearchUsersSuccessState());
        })
        .catchError((error) {
          emit(SocialGetSearchUsersErrorState(error.toString()));
        });
  }

//================================================================================================================================
  // send message to specific user
  void sendMessage({
    required String receiverId,
    required String text,
    required String dateTime,
  }) {
    MessageModel model = MessageModel(
      text: text,
      receiverId: receiverId,
      dateTime: dateTime,
      senderId: userDataModel!.user.uId,
    );

    // add message to the reciever
    FirebaseFirestore.instance
        .collection('users')
        .doc(userDataModel!.user.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .add(model.toMap())
        .then((value) {
      emit(SocialSendMessageSuccessState());
    }).catchError((error) {
      emit(SocialSendMessageErrorState());
    });

    // add message to the sender
    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userDataModel!.user.uId)
        .collection('messages')
        .add(model.toMap())
        .then((value) {
      emit(SocialSendMessageSuccessState());
    }).catchError((error) {
      emit(SocialSendMessageErrorState());
    });
  }

//================================================================================================================================

  List<MessageModel> messages = [];

  // get messages
  void getMessages({
    required String receiverId,
  }) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userDataModel!.user.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .orderBy('dateTime')
        .snapshots()
        .listen((event) {
      messages = [];
      for (var element in event.docs) {
        messages.add(MessageModel.fromJson(element.data()));
      }
      emit(SocialGetMessagesSuccessState());
    });
  }

//================================================================================================================================

  // add comment to the post collection
  void sendComment({
    required String text,
    required String postID,
    required int index,
    // to trigger the position of the post (home or settings)
    required ScreenType screen,
  }) {
    emit(SocialCommentPostLoadingState());

    CommentModel model = CommentModel(
      dateTime: DateTime.now().toString(),
      image: userDataModel!.user.image,
      name: userDataModel!.user.name,
      text: text,
      uId: userDataModel!.user.uId,
    );

    FirebaseFirestore.instance
        .collection('posts')
        .doc(postID)
        .collection('comments')
        .add(model.toMap())
        .then((value) {
      // Check the value of the screen parameter
      if (screen == ScreenType.HOME) {
        // If screen is HOME, update the comments list in allpostsData
        allpostsData[index].comments.add(model);
        // check if the post is in the posts of the logged in user
        int userPostIndex = loggedInUserpostId.indexOf(postID);

        if (userPostIndex != -1) {
          // If the postId is found in the list, update the comments list in loggedInUserpostsData
          loggedInUserpostsData[userPostIndex].comments.add(model);
        }
      } else if (screen == ScreenType.SETTINGS) {
        // If screen is Settings, update the comments list in loggedInUserpostsData
        loggedInUserpostsData[index].comments.add(model);
        // check if the post is in the posts of the home
        int userPostIndex = postId.indexOf(postID);

        if (userPostIndex != -1) {
          // If the postId is found in the list, update the comments list in the home
          allpostsData[userPostIndex].comments.add(model);
        }
      } else if (screen == ScreenType.PROFILE) {
        // If screen is profile, update the comments list in specificUserpostsData
        specificUserpostsData[index].comments.add(model);
        // check if the post is in the posts of the home
        int userPostIndex = postId.indexOf(postID);

        if (userPostIndex != -1) {
          // If the postId is found in the list, update the comments list in the home
          allpostsData[userPostIndex].comments.add(model);
        }
      }

      emit(SocialCommentPostSuccessState());
    }).catchError((error) {
      emit(SocialCommentPostErrorState());
    });
  }

//================================================================================================================================

  // follow user
  void followUser({
    required String followingUserId,
    required String followingUserName,
    required String followingUserImage,
    required String followingUserBio,
  }) {
    FollowModel followingModel = FollowModel(
      uId: followingUserId,
      name: followingUserName,
      image: followingUserImage,
      bio: followingUserBio,
    );
    emit(SocialFollowUserLoadingState());

    // add this user to the following list of the logged in user
    FirebaseFirestore.instance
        .collection('users')
        .doc(userDataModel!.user.uId)
        .collection('followings')
        .add(followingModel.toMap())
        .then((value) {
      userDataModel!.followings.add(followingModel);
      emit(SocialFollowUserSuccessState());
    }).catchError((error) {
      emit(SocialFollowUserErrorState());
    });

    FollowModel followerModel = FollowModel(
      uId: userDataModel!.user.uId,
      name: userDataModel!.user.name,
      image: userDataModel!.user.image,
      bio: userDataModel!.user.bio,
    );
    // add logged in user to the followers of the following user
    FirebaseFirestore.instance
        .collection('users')
        .doc(followingUserId)
        .collection('followers')
        .add(followerModel.toMap())
        .then((value) {
      emit(SocialFollowUserSuccessState());
    }).catchError((error) {
      emit(SocialFollowUserErrorState());
    });
  }

//================================================================================================================================
// unfollow user
  Future<bool> unFollowUser({required String followingUserId}) async {
    try {
      emit(SocialUnFollowUserLoadingState());

      // Perform the unfollow operation and remove following user from user collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userDataModel!.user.uId)
          .collection('followings')
          .where('uId', isEqualTo: followingUserId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.first.reference
            .delete(); // Delete the first document directly (unique)
      });

      userDataModel!.followings
          .removeWhere((following) => following.uId == followingUserId);

      // Perform the unfollow operation and remove follower user from following user collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(followingUserId)
          .collection('followers')
          .where('uId', isEqualTo: userDataModel!.user.uId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.first.reference
            .delete(); // Delete the first document directly (unique)
      });

      emit(SocialUnFollowUserSuccessState());
      return true; // Return true to indicate success
    } catch (error) {
      emit(SocialUnFollowUserErrorState());
      return false; // Return false to indicate failure
    }
  }

//================================================================================================================================

  bool isInMyFollowings({required String followingUserId}) {
    return userDataModel!.followings
        .any((following) => following.uId == followingUserId);
  }

//================================================================================================================================

  // get data of specific user

  UserDataModel? specificUserDataModel;

  void getSpecificUserData({required String specificUserId}) async {
    emit(SocialGetSpecificUserLoadingState());

    try {
      Query userQuery = FirebaseFirestore.instance
          .collection('users')
          .where('uId', isEqualTo: specificUserId);

      QuerySnapshot userQuerySnapshot = await userQuery.get();
      QueryDocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;

      List<FollowModel> followers = [];
      List<FollowModel> followings = [];

      // get followers of the user
      QuerySnapshot followersQuerySnapshot =
          await userSnapshot.reference.collection('followers').get();
      for (var userSnapshot in followersQuerySnapshot.docs) {
        followers.add(
            FollowModel.fromJson(userSnapshot.data() as Map<String, dynamic>));
      }

      // get followings of the user
      QuerySnapshot followingsQuerySnapshot =
          await userSnapshot.reference.collection('followings').get();

      for (var userSnapshot in followingsQuerySnapshot.docs) {
        followings.add(
            FollowModel.fromJson(userSnapshot.data() as Map<String, dynamic>));
      }

      // Create user data model instance
      UserDataModel userData = UserDataModel(
        user: UserModel.fromJson(userSnapshot.data() as Map<String, dynamic>),
        followers: followers,
        followings: followings,
      );

      specificUserDataModel = userData;

      getSpecificUserPostsData(specificUserId: specificUserId);

      emit(SocialGetSpecificUserSuccessState());
    } catch (error) {
      emit(SocialGetSpecificUserErrorState(error.toString()));
    }
  }

//================================================================================================================================

// get posts of Specific user

// list that contains post id of Specific user
  List<String> specificUserpostId = [];

  // list that contains data of logged in posts
  List<PostDataModel> specificUserpostsData = [];

  // DocumentSnapshot to keep track of the last document
  DocumentSnapshot? specificlastDocument;

  // String to indicate that is no posts of specific user
  String? isPosts;

  // get all the posts data
  void getSpecificUserPostsData(
      {bool loadMore = false, required String specificUserId}) async {
    emit(SocialGetSpecificUserPostLoadingState());

    try {
      Query postQuery = FirebaseFirestore.instance
          .collection('posts')
          .where("uId", isEqualTo: specificUserId)
          .orderBy('dateTime', descending: true)
          .limit(3);

      // if the user need to show more
      // If loading more and we have existing posts, fetch next batch after the last post
      if (loadMore && specificlastDocument != null) {
        postQuery = postQuery.startAfterDocument(specificlastDocument!);
      }

      // Execute the query
      QuerySnapshot postQuerySnapshot = await postQuery.get();

      if (postQuerySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot postSnapshot in postQuerySnapshot.docs) {
          List<LikeModel> likesUsers = [];
          List<CommentModel> commentUser = [];

          // get likes of the post
          QuerySnapshot likesQuerySnapshot =
              await postSnapshot.reference.collection('likes').get();
          for (var userSnapshot in likesQuerySnapshot.docs) {
            likesUsers.add(LikeModel.fromJson(
                userSnapshot.data() as Map<String, dynamic>));
          }

          // get comments of the post
          QuerySnapshot commentsQuerySnapshot =
              await postSnapshot.reference.collection('comments').get();

          for (var userSnapshot in commentsQuerySnapshot.docs) {
            commentUser.add(CommentModel.fromJson(
                userSnapshot.data() as Map<String, dynamic>));
          }

          bool isLiked = likesUsers.any((like) => like.uId == uId);

          // Create PostData instance
          PostDataModel postData = PostDataModel(
            post:
                PostModel.fromJson(postSnapshot.data() as Map<String, dynamic>),
            likes: likesUsers,
            comments: commentUser,
            isLiked: isLiked,
          );

          // Store post data in the map
          specificUserpostId.add(postSnapshot.id);
          specificUserpostsData.add(postData);

          // Update the last document
          specificlastDocument = postQuerySnapshot.docs.last;
        }
        emit(SocialGetSpecificUserPostSuccessState());
      } else {
        isPosts = "no";
        emit(SocialGetSpecificUserPostEmptyState());
      }
    } catch (error) {
      emit(SocialGetSpecificUserPostErrorState(error.toString()));
    }
  }

//================================================================================================================================

// clear data of specific user

  void clearSpecificUserData() {
    specificUserDataModel = null;
    specificUserpostId = [];
    specificlastDocument = null;
    specificUserpostsData = [];
    isPosts = null;
  }

//================================================================================================================================
}
