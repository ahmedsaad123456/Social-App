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

// if i want to change variables in the cubit , must do it with function and emit state in it

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
      List<FollowModel> userChatsModel = [];

      // Iterate over the chats collection and add document IDs to the set
      QuerySnapshot chatsQuerySnapshot =
          await userSnapshot.reference.collection('chats').get();
      for (var chatSnapshot in chatsQuerySnapshot.docs) {
        userChatsModel.add(
            FollowModel.fromJson(chatSnapshot.data() as Map<String, dynamic>));
      }

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
          userChatsModel: userChatsModel);

      userDataModel = userData;

      getPostsData();
      getAllUsersData();

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
          List<String> commentsIds = [];

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
            commentsIds.add(userSnapshot.id);
          }

          bool isLiked = likesUsers.any((like) => like.uId == uId);

          // Create PostData instance
          PostDataModel postData = PostDataModel(
              post: PostModel.fromJson(
                  postSnapshot.data() as Map<String, dynamic>),
              likes: likesUsers,
              comments: commentUser,
              isLiked: isLiked,
              commentsId: commentsIds);

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

  // clear profile image and cover image
  void clearImage() {
    profileImage = null;
    coverImage = null;
    emit(SocialClearImageSuccessState());
  }

//================================================================================================================================

  // update user data
  // update user information for name , image and bio will affect on all users collection and posts collection
  // this is trade-off to get data faster but in the same time update user information will be slower
  // i do that because the operation of editing the profile is done rarely (in my opinion)
  // i can change this in the future

  void updateUser({
    required String name,
    required String phone,
    required String bio,
    String? cover,
    String? image,
  }) async {
    try {
      emit(SocialUpdateUserLoadingState());
      await _updateUserDocument(
          userDataModel!.user.uId!, name, phone, bio, cover, image);

      // Check if name, bio, or image have changed
      if (name != userDataModel!.user.name ||
          bio != userDataModel!.user.bio ||
          image != userDataModel!.user.image) {
        await _updateUserRelatedDocuments(
            userDataModel!.user.uId!, name, image, bio);
        await _updateUserPosts(userDataModel!.user.uId!, name, image);
      }

      // in memory
      updateUserDataAndPosts(
          name: name, phone: phone, bio: bio, image: image, cover: cover);
      // Success state
      emit(SocialUpdateUserSuccessState());
    } catch (error) {
      // Error state
      emit(SocialUpdateUserErrorState());
    }
  }

  //================================================================================================================================

  // update user information
  Future<void> _updateUserDocument(String userId, String name, String phone,
      String bio, String? cover, String? image) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'name': name,
      'phone': phone,
      'bio': bio,
      'image': image ?? userDataModel!.user.image,
      'cover': cover ?? userDataModel!.user.cover,
    });
  }

  //================================================================================================================================

  // update chats , followings and followers in collection users
  Future<void> _updateUserRelatedDocuments(
      String userId, String name, String? image, String bio) async {
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      // ignore if user is userId equal to userDocId
      if (userDoc.id == userId) {
        continue;
      }

      // Update chats a collection within the users
      QuerySnapshot chatsSnapshot = await userDoc.reference
          .collection('chats')
          .where('uId', isEqualTo: userId)
          .get();
      for (QueryDocumentSnapshot chatDoc in chatsSnapshot.docs) {
        await chatDoc.reference.update({
          'name': name,
          'image': image ?? userDataModel!.user.image,
          'bio': bio,
        });
      }
      // Update followers a collection within the users

      QuerySnapshot followersSnapshot = await userDoc.reference
          .collection('followers')
          .where('uId', isEqualTo: userId)
          .get();
      for (QueryDocumentSnapshot followerDoc in followersSnapshot.docs) {
        await followerDoc.reference.update({
          'name': name,
          'image': image ?? userDataModel!.user.image,
          'bio': bio,
        });
      }

      // Update followings a collection within the users

      QuerySnapshot followingsSnapshot = await userDoc.reference
          .collection('followings')
          .where('uId', isEqualTo: userId)
          .get();
      for (QueryDocumentSnapshot followingDoc in followingsSnapshot.docs) {
        await followingDoc.reference.update({
          'name': name,
          'image': image ?? userDataModel!.user.image,
          'bio': bio,
        });
      }
    }
  }

  //================================================================================================================================

  // update all posts , comments and likes

  Future<void> _updateUserPosts(
      String userId, String name, String? image) async {
    QuerySnapshot postsSnapshot =
        await FirebaseFirestore.instance.collection('posts').get();

    for (QueryDocumentSnapshot postDoc in postsSnapshot.docs) {
      final postData = postDoc.data();

      final PostModel model =
          PostModel.fromJson(postData as Map<String, dynamic>?);

      // Update post if the postUid is equal to userId
      if (model.uId == userId) {
        await postDoc.reference.update({
          'name': name,
          'image': image ?? userDataModel!.user.image,
        });
      }

      // Update comments and likes collections within the post
      QuerySnapshot commentsSnapshot = await postDoc.reference
          .collection('comments')
          .where('uId', isEqualTo: userId)
          .get();
      for (QueryDocumentSnapshot commentDoc in commentsSnapshot.docs) {
        await commentDoc.reference.update({
          'name': name,
          'image': image ?? userDataModel!.user.image,
        });
      }

      QuerySnapshot likesSnapshot = await postDoc.reference
          .collection('likes')
          .where('uId', isEqualTo: userId)
          .get();
      for (QueryDocumentSnapshot likeDoc in likesSnapshot.docs) {
        await likeDoc.reference.update({
          'name': name,
          'image': image ?? userDataModel!.user.image,
        });
      }
    }
  }

//================================================================================================================================

  // update data in the memory
  void updateUserDataAndPosts({
    required String name,
    required String phone,
    required String bio,
    String? cover,
    String? image,
  }) {
    bool isChanged =
        userDataModel!.user.name != name || userDataModel!.user.image != image;
    // Update userDataModel
    userDataModel!.user.name = name;
    userDataModel!.user.phone = phone;
    userDataModel!.user.bio = bio;
    if (cover != null) userDataModel!.user.cover = cover;
    if (image != null) userDataModel!.user.image = image;

    if (isChanged) {
      // Update posts in loggedInUserpostsData
      for (var post in loggedInUserpostsData) {
        post.post.name = name;
        if (image != null) post.post.image = image;

        for (var comment in post.comments) {
          if (comment.uId == userDataModel!.user.uId) {
            comment.name = name;
            if (image != null) comment.image = image;
          }
        }
        for (var like in post.likes) {
          if (like.uId == userDataModel!.user.uId) {
            like.name = name;
            if (image != null) like.image = image;
          }
        }
      }

      // Update posts in allpostsData
      for (var post in allpostsData) {
        for (var comment in post.comments) {
          if (comment.uId == userDataModel!.user.uId) {
            comment.name = name;
            if (image != null) comment.image = image;
          }
        }
        for (var like in post.likes) {
          if (like.uId == userDataModel!.user.uId) {
            like.name = name;
            if (image != null) like.image = image;
          }
        }
        if (post.post.uId == userDataModel!.user.uId) {
          post.post.name = name;
          if (image != null) post.post.image = image;
        }
      }
    }
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
        commentsId: [],
      );

      loggedInUserpostsData.insert(0, postData);

      emit(SocialCreatePostSuccessState());
    }).catchError((error) {
      emit(SocialCreatePostErrorState());
    });
  }

//================================================================================================================================

// delete post
  void deletePost(String postID, int index, ScreenType screen) {
    emit(SocialDeletePostLoadingState());

    // Reference to the post document
    var postRef = FirebaseFirestore.instance.collection('posts').doc(postID);

    // Delete the comments subcollection
    var commentsRef = postRef.collection('comments');
    commentsRef.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }

      // Delete the likes subcollection
      var likesRef = postRef.collection('likes');
      return likesRef.get();
    }).then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }

      // Once subcollections are deleted, delete the post document
      return postRef.delete();
    }).then((value) {
      // Remove post from appropriate lists
      if (screen == ScreenType.HOME) {
        allpostsData.removeAt(index);
        postId.remove(postID);

        int userPostIndex = loggedInUserpostId.indexOf(postID);
        if (userPostIndex != -1) {
          loggedInUserpostsData.removeAt(userPostIndex);
          loggedInUserpostId.remove(postID);
        }
      } else if (screen == ScreenType.SETTINGS) {
        loggedInUserpostsData.removeAt(index);
        loggedInUserpostId.remove(postID);

        int userPostIndex = postId.indexOf(postID);
        if (userPostIndex != -1) {
          allpostsData.removeAt(userPostIndex);
          postId.remove(postID);
        }
      }

      emit(SocialDeletePostSuccessState());
    }).catchError((error) {
      emit(SocialDeletePostErrorState());
    });
  }

//================================================================================================================================

// edit post
  void editPost(PostDataModel model, String postID, int index,
      ScreenType screen, String text) {
    model.post.text = text;
    emit(SocialEditPostLoadingState());
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postID)
        .update(model.post.toMap())
        .then((value) {
      if (screen == ScreenType.HOME) {
        // If screen is HOME, update the post in the home
        allpostsData[index] = model;
        // Check if the post is in the posts of the logged in user
        int userPostIndex = loggedInUserpostId.indexOf(postID);
        if (userPostIndex != -1) {
          // If the postId is found in the list, update the post in loggedInUserpostsData
          loggedInUserpostsData[userPostIndex] = model;
        }
      } else if (screen == ScreenType.SETTINGS) {
        // If screen is SETTINGS, update the post in loggedInUserpostsData
        loggedInUserpostsData[index] = model;

        // Check if the post is in the posts of the home
        int userPostIndex = postId.indexOf(postID);
        if (userPostIndex != -1) {
          // If the postId is found in the list, update the post in the home
          allpostsData[userPostIndex] = model;
        }
      }

      emit(SocialEditPostSuccessState());
    }).catchError((error) {
      emit(SocialEditPostErrorState());
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
          List<String> commentsId = [];

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
            commentsId.add(userSnapshot.id);
          }

          bool isLiked = likesUsers.any((like) => like.uId == uId);

          // Create PostData instance
          PostDataModel postData = PostDataModel(
              post: PostModel.fromJson(
                  postSnapshot.data() as Map<String, dynamic>),
              likes: likesUsers,
              comments: commentUser,
              isLiked: isLiked,
              commentsId: commentsId);

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
// clear data of all posts

  void clearPostData() {
    allpostsData = [];
    postId = [];
    emit(SocialClearPostSuccessState());
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
  List<FollowModel> users = [];

  // list to search for users
  List<FollowModel> usersSearch = [];

// function to get users data
  void getAllUsersData({bool loadMore = false}) {
    emit(SocialGetAllUsersLoadingState());

    if (!loadMore) {
      // Clear the existing users list if not loading more
      users.clear();
    }

    // Query reference for users collection
    Query usersQuery = FirebaseFirestore.instance
        .collection('users')
        .where('uId', isNotEqualTo: userDataModel!.user.uId);

    // If loading more and we have existing users, fetch next batch after the last user
    if (loadMore && users.isNotEmpty) {
      usersQuery =
          usersQuery.orderBy('uId').startAfter([users.last.uId]).limit(3);
    } else {
      usersQuery = usersQuery.orderBy('uId').limit(3);
    }

    // Fetch users based on the query
    usersQuery.get().then((value) {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          users.add(
              FollowModel.fromJson(element.data() as Map<String, dynamic>?));
        }
        emit(SocialGetAllUsersSuccessState());
      } else {
        // If no more users are available
        emit(SocialGetAllUsersEmptyState());
      }
    }).catchError((error) {
      emit(SocialGetAllUsersErrorState(error.toString()));
    });
  }

//================================================================================================================================

  void searchUsers({required String name}) {
    emit(SocialGetSearchUsersLoadingState());
    if (name.isNotEmpty) {
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
                  usersSearch.add(FollowModel.fromJson(element.data()));
                }
              }
            }
            emit(SocialGetSearchUsersSuccessState());
          })
          .catchError((error) {
            emit(SocialGetSearchUsersErrorState(error.toString()));
          });
    } else {
      usersSearch = [];
      emit(SocialGetSearchUsersSuccessState());
    }
  }

//================================================================================================================================
  void sendMessage({
    required FollowModel user,
    required String text,
    required String dateTime,
  }) {
    MessageModel model = MessageModel(
      text: text,
      receiverId: user.uId,
      dateTime: dateTime,
      senderId: userDataModel!.user.uId,
    );

    // add receiver to the chat list to appear in the chats
    bool isFound = userDataModel!.userChatsModel
        .any((chatUser) => chatUser.uId == user.uId);

    if (!isFound) {
      userDataModel!.userChatsModel.add(user);
    }

    // follow model to logged in user
    FollowModel loggedInModel = FollowModel(
      bio: userDataModel!.user.bio,
      uId: userDataModel!.user.uId,
      image: userDataModel!.user.image,
      name: userDataModel!.user.name,
    );

    // Add message to the receiver's chat collection
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uId)
        .collection('chats')
        .doc(userDataModel!.user.uId)
        .set(loggedInModel.toMap())
        .then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uId)
          .collection('chats')
          .doc(userDataModel!.user.uId)
          .collection('messages')
          .add(model.toMap())
          .then((value) {
        previousDate = null;
        emit(SocialSendMessageSuccessState());
      }).catchError((error) {
        emit(SocialSendMessageErrorState());
      });
    }).catchError((error) {
      emit(SocialSendMessageErrorState());
    });

    // Add message to the sender's chat collection
    FirebaseFirestore.instance
        .collection('users')
        .doc(userDataModel!.user.uId)
        .collection('chats')
        .doc(user.uId)
        .set(user.toMap())
        .then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userDataModel!.user.uId)
          .collection('chats')
          .doc(user.uId)
          .collection('messages')
          .add(model.toMap())
          .then((value) {
        previousDate = null;

        emit(SocialSendMessageSuccessState());
      }).catchError((error) {
        emit(SocialSendMessageErrorState());
      });
    }).catchError((error) {
      emit(SocialSendMessageErrorState());
    });
  }
//================================================================================================================================

  // Method to delete a message from Firestore collection based on its dateTime (unique format)
  void deleteMessage(String dateTime, String receiverId, bool isMyMessage) {
    // delete the message from the sender collection
    FirebaseFirestore.instance
        .collection('users')
        .doc(userDataModel!.user.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .where('dateTime', isEqualTo: dateTime)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.first.reference.delete();
      }
      previousDate = null;

      emit(SocialDeleteMessageSuccessState());
    }).catchError((error) {
      emit(SocialDeleteMessageErrorState());
    });

    // delete the message from the receiver collection if the message is sent by the sender
    if (isMyMessage) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .collection('chats')
          .doc(userDataModel!.user.uId)
          .collection('messages')
          .where('dateTime', isEqualTo: dateTime)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.delete();
        }
        previousDate = null;

        emit(SocialDeleteMessageSuccessState());
      }).catchError((error) {
        emit(SocialDeleteMessageErrorState());
      });
    }
  }

  //================================================================================================================================
  // edit message

  bool isEditMessage = false;

  void changeEditMessage(bool edit) {
    isEditMessage = edit;
    emit(SocialChangeIsEditMessageState());
  }

  //================================================================================================================================

  MessageModel? editMessageModel;

  void setEditMessageModel(MessageModel editModel) {
    editMessageModel = editModel;
    emit(SocialSetMessageModelState());
  }

  // Method to edit a message in Firestore collection based on its dateTime (unique format)
  void editMessage(String receiverId, String newText) {
    editMessageModel!.text = newText;
    // edit the message in the sender collection
    FirebaseFirestore.instance
        .collection('users')
        .doc(userDataModel!.user.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .where('dateTime', isEqualTo: editMessageModel!.dateTime)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.first.reference.update(editMessageModel!.toMap());
      }
      previousDate = null;

      emit(SocialEditMessageSuccessState());
    }).catchError((error) {
      emit(SocialEditMessageErrorState());
    });

    // edit the message in the receiver collection
    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userDataModel!.user.uId)
        .collection('messages')
        .where('dateTime', isEqualTo: editMessageModel!.dateTime)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.first.reference.update(editMessageModel!.toMap());
      }
      previousDate = null;

      emit(SocialEditMessageSuccessState());
    }).catchError((error) {
      emit(SocialEditMessageErrorState());
    });
  }

//================================================================================================================================
  // Method to delete a chat from Firestore collection
  void deleteChat(String receiverId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userDataModel!.user.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .get()
        .then((querySnapshot) {
      for (DocumentSnapshot doc in querySnapshot.docs) {
        doc.reference.delete();
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(userDataModel!.user.uId)
          .collection('chats')
          .doc(receiverId)
          .delete()
          .then((value) {
        userDataModel!.userChatsModel
            .removeWhere((userModel) => userModel.uId == receiverId);
        emit(SocialDeleteChatSuccessState());
      }).catchError((error) {
        emit(SocialDeleteChatErrorState());
      });
    }).catchError((error) {
      emit(SocialDeleteChatErrorState());
    });
  }

//================================================================================================================================

  List<MessageModel> messages = [];

  String? previousDate; // Track previous date

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
      previousDate = null;
      messages = [];
      for (var element in event.docs) {
        messages.add(MessageModel.fromJson(element.data()));
      }
      emit(SocialGetMessagesSuccessState());
    });
  }
//================================================================================================================================

// clear all messages

  void clearMessages() {
    messages = [];
    emit(SocialclearMessagesSuccessState());
  }
//================================================================================================================================

  // Function to check if the date is different from the previous message
  bool showDate(String dateTime) {
    bool show = false;
    if (previousDate == null || previousDate != dateTime.substring(0, 11)) {
      show = true;
      previousDate = dateTime.substring(0, 11);
    }
    return show;
  }

//================================================================================================================================

  // add comment to the post collection
  void sendComment({
    required String text,
    required String postID,
    required int index,
    // to trigger the position of the post (home or settings or profile)
    required ScreenType screen,
  }) {
    emit(SocialSendCommentPostLoadingState());

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
        allpostsData[index].commentsId.add(value.id);
        // check if the post is in the posts of the logged in user
        int userPostIndex = loggedInUserpostId.indexOf(postID);

        if (userPostIndex != -1) {
          // If the postId is found in the list, update the comments list in loggedInUserpostsData
          loggedInUserpostsData[userPostIndex].comments.add(model);
          loggedInUserpostsData[userPostIndex].commentsId.add(value.id);
        }
      } else if (screen == ScreenType.SETTINGS) {
        // If screen is Settings, update the comments list in loggedInUserpostsData
        loggedInUserpostsData[index].comments.add(model);
        loggedInUserpostsData[index].commentsId.add(value.id);

        // check if the post is in the posts of the home
        int userPostIndex = postId.indexOf(postID);

        if (userPostIndex != -1) {
          // If the postId is found in the list, update the comments list in the home
          allpostsData[userPostIndex].comments.add(model);
          allpostsData[userPostIndex].commentsId.add(value.id);
        }
      } else if (screen == ScreenType.PROFILE) {
        // If screen is profile, update the comments list in specificUserpostsData
        specificUserpostsData[index].comments.add(model);
        specificUserpostsData[index].commentsId.add(value.id);

        // check if the post is in the posts of the home
        int userPostIndex = postId.indexOf(postID);

        if (userPostIndex != -1) {
          // If the postId is found in the list, update the comments list in the home
          allpostsData[userPostIndex].comments.add(model);
          allpostsData[userPostIndex].commentsId.add(value.id);
        }
      }

      emit(SocialSendCommentPostSuccessState());
    }).catchError((error) {
      emit(SocialSendCommentPostErrorState());
    });
  }

//================================================================================================================================

// delete comment from specific post
  void deleteComment({
    required String commentID,
    required String postID,
    required int postindex,
    required int commentIndex,
    // to trigger the position of the post (home or settings or profile)
    required ScreenType screen,
  }) {
    emit(SocialDeleteCommentPostLoadingState());

    FirebaseFirestore.instance
        .collection('posts')
        .doc(postID)
        .collection('comments')
        .doc(commentID)
        .delete()
        .then((value) {
      // Check the value of the screen parameter
      if (screen == ScreenType.HOME) {
        // If screen is HOME, remove the comment from allpostsData
        allpostsData[postindex].comments.removeAt(commentIndex);
        allpostsData[postindex].commentsId.removeAt(commentIndex);
        // check if the post is in the posts of the logged in user
        int userPostIndex = loggedInUserpostId.indexOf(postID);

        if (userPostIndex != -1) {
          // If the postId is found in the list, delete the comment from loggedInUserpostsData
          loggedInUserpostsData[userPostIndex].comments.removeAt(commentIndex);
          loggedInUserpostsData[userPostIndex]
              .commentsId
              .removeAt(commentIndex);
        }
      } else if (screen == ScreenType.SETTINGS) {
        // If screen is Settings, delete the comment from loggedInUserpostsData
        loggedInUserpostsData[postindex].comments.removeAt(commentIndex);
        loggedInUserpostsData[postindex].commentsId.removeAt(commentIndex);

        // check if the post is in the posts of the home
        int userPostIndex = postId.indexOf(postID);

        if (userPostIndex != -1) {
          // If the postId is found in the list, delete the comment from the home
          allpostsData[userPostIndex].comments.removeAt(commentIndex);
          allpostsData[userPostIndex].commentsId.removeAt(commentIndex);
        }
      } else if (screen == ScreenType.PROFILE) {
        // If screen is profile, delete the comment from specificUserpostsData
        specificUserpostsData[postindex].comments.removeAt(commentIndex);
        specificUserpostsData[postindex].commentsId.removeAt(commentIndex);

        // check if the post is in the posts of the home
        int userPostIndex = postId.indexOf(postID);

        if (userPostIndex != -1) {
          // If the postId is found in the list, delete the comment from the home
          allpostsData[userPostIndex].comments.removeAt(commentIndex);
          allpostsData[userPostIndex].commentsId.removeAt(commentIndex);
        }
      }

      emit(SocialDeleteCommentPostSuccessState());
    }).catchError((error) {
      emit(SocialDeleteCommentPostErrorState());
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
      previousDate = null;
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
        userChatsModel: [],
      );

      specificUserDataModel = userData;
      previousDate = null;

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
          List<String> commentsIds = [];

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
            commentsIds.add(userSnapshot.id);
          }

          bool isLiked = likesUsers.any((like) => like.uId == uId);

          // Create PostData instance
          PostDataModel postData = PostDataModel(
              post: PostModel.fromJson(
                  postSnapshot.data() as Map<String, dynamic>),
              likes: likesUsers,
              comments: commentUser,
              isLiked: isLiked,
              commentsId: commentsIds);

          // Store post data in the map
          specificUserpostId.add(postSnapshot.id);
          specificUserpostsData.add(postData);

          // Update the last document
          specificlastDocument = postQuerySnapshot.docs.last;
        }
        previousDate = null;
        emit(SocialGetSpecificUserPostSuccessState());
      } else {
        isPosts = "no";
        previousDate = null;
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
    previousDate = null;
    emit(SocialClearSpecificUserSuccessState());
  }

//================================================================================================================================
}
