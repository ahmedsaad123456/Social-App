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
import 'package:social_app/models/user_model.dart';
import 'package:social_app/modules/chats/chats_screen.dart';
import 'package:social_app/modules/feeds/feeds_screen.dart';
import 'package:social_app/modules/new_post/new_post_screen.dart';
import 'package:social_app/modules/settings/settings_screen.dart';
import 'package:social_app/modules/users/users_screen.dart';
import 'package:social_app/shared/components/constants.dart';

class SocialCubit extends Cubit<SocialStates> {
  SocialCubit() : super(SocialInitialState());

  static SocialCubit get(context) => BlocProvider.of(context);

  // Data of logged in user
  UserModel? userModel;

  // get data of the logged in user
  void getUserData() {
    emit(SocialGetUserLoadingState());

    FirebaseFirestore.instance.collection('users').doc(uId).get().then((value) {
      userModel = UserModel.fromJson(value.data());
      emit(SocialGetUserSuccessState());
    }).catchError((error) {
      emit(SocialGetUserErrorState(error));
    });
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
      email: userModel!.email,
      phone: phone,
      uId: uId,
      isEmailVerified: false,
      bio: bio,
      image: image ?? userModel!.image,
      cover: cover ?? userModel!.cover,
      
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
      name: userModel!.name,
      uId: userModel!.uId,
      image: userModel!.image,
      dateTime: dateTime,
      text: text,
      postImage: postImage ?? '',
    );

    FirebaseFirestore.instance
        .collection('posts')
        .add(model.toMap())
        .then((value) {
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
      Query postQuery = FirebaseFirestore.instance.collection('posts');

      // if the user need to show more
      // If loading more and we have existing posts, fetch next batch after the last post
      if (loadMore && postId.isNotEmpty) {
        postQuery =
            postQuery.orderBy(FieldPath.documentId).startAfter([postId.last]);
      }

      // get 3 posts only every time
      QuerySnapshot postQuerySnapshot = await postQuery.limit(3).get();

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

          // store all data in the lists
          bool isLiked = likesUsers.any((like) => like.uId == userModel!.uId);

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
  Future<bool> likePost({required String postId, required int index}) async {
    try {
      emit(SocialLikePostLoadingState());

      LikeModel model = LikeModel(
        image: userModel!.image,
        name: userModel!.name,
        uId: userModel!.uId,
      );
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .add(model.toMap());

      allpostsData[index].likes.add(model);
      allpostsData[index].isLiked = true;

      emit(SocialLikePostSuccessState());
      return true; // Return true to indicate success
    } catch (error) {
      emit(SocialLikePostErrorState(error.toString()));
      return false; // Return false to indicate failure
    }
  }

//================================================================================================================================

  // do unlike on the post
  Future<bool> unlikePost({required String postId, required int index}) async {
    try {
      emit(SocialUnlikePostLoadingState());

      // Perform the unlike operation
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .where('uId', isEqualTo: userModel!.uId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.first.reference
            .delete(); // Delete the first document directly (unique)
      });

      allpostsData[index]
          .likes
          .removeWhere((like) => like.uId == userModel!.uId);
      allpostsData[index].isLiked = false;

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
            if (element.data()['uId'] != userModel!.uId) {
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
              if (element.data()['uId'] != userModel!.uId) {
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
      senderId: userModel!.uId,
    );

    // add message to the reciever
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
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
        .doc(userModel!.uId)
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
        .doc(userModel!.uId)
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
    required String postId,
    required int index,
  }) {
    emit(SocialCommentPostLoadingState());

    CommentModel model = CommentModel(
      dateTime: DateTime.now().toString(),
      image: userModel!.image,
      name: userModel!.name,
      text: text,
      uId: userModel!.uId,
    );

    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(model.toMap())
        .then((value) {
      allpostsData[index].comments.add(model);

      emit(SocialCommentPostSuccessState());
    }).catchError((error) {
      emit(SocialCommentPostErrorState());
    });
  }

//================================================================================================================================

// get posts of logged in user

// list that contains post id of logged in user
  List<String> loggedInUserpostId = [];

  // list that contains data of logged in posts
  List<PostDataModel> loggedInUserpostsData = [];

  // get all the posts data
  void getLoggedInUserPostsData({bool loadMore = false}) async {
    emit(SocialGetPostLoadingState());

    try {
      Query postQuery = FirebaseFirestore.instance.collection('posts');

      // if the user need to show more
      // If loading more and we have existing posts, fetch next batch after the last post
      if (loadMore && postId.isNotEmpty) {
        postQuery =
            postQuery.orderBy(FieldPath.documentId).startAfter([postId.last]);
      }

      // get 3 posts only every time
      QuerySnapshot postQuerySnapshot =
          await postQuery.where("uId", isEqualTo: uId).limit(3).get();

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

          // store all data in the lists
          bool isLiked = likesUsers.any((like) => like.uId == userModel!.uId);

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
        }
        emit(SocialGetLoggedInUserPostSuccessState());
      } else {
        emit(SocialGetLoggedInUserPostEmptyState());
      }
    } catch (error) {
      emit(SocialGetLoggedInUserPostErrorState(error.toString()));
    }
  }

//================================================================================================================================

// get posts of user profile

//================================================================================================================================

  // send message to specific user
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

    // add this user to the following list of the logged in user
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('followings')
        .add(followingModel.toMap())
        .then((value) {
      emit(SocialFollowUserSuccessState());
    }).catchError((error) {
      emit(SocialFollowUserErrorState());
    });

    FollowModel followerModel = FollowModel(
      uId: userModel!.uId,
      name: userModel!.name,
      image: userModel!.image ,
      bio: userModel!.bio,
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
}

//================================================================================================================================
