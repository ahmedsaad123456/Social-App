abstract class SocialStates {}

class SocialInitialState extends SocialStates {}


// get user data
class SocialGetUserLoadingState extends SocialStates {}

class SocialGetUserSuccessState extends SocialStates {}

class SocialGetUserErrorState extends SocialStates {
  final String error;
  SocialGetUserErrorState(this.error);
}

// get all user data
class SocialGetAllUsersLoadingState extends SocialStates {}

class SocialGetAllUsersSuccessState extends SocialStates {}

class SocialGetAllUsersEmptyState extends SocialStates {}


class SocialGetAllUsersErrorState extends SocialStates {
  final String error;
  SocialGetAllUsersErrorState(this.error);
}

// change bottom nav bar

class SocialChangeBottomNavBarState extends SocialStates {}






// create new post 

class SocialNewPostState extends SocialStates {}


// picked profile image
class SocialProfileImagePickedSuccessState extends SocialStates {}


class SocialProfileImagePickedErrorState extends SocialStates {}


// picked cover image

class SocialCoverImagePickedSuccessState extends SocialStates {}


class SocialCoverImagePickedErrorState extends SocialStates {}



// upload profile image

class SocialUploadProfileImageSuccessState extends SocialStates {}


class SocialUploadProfileImageErrorState extends SocialStates {}


// upload cover image

class SocialUploadCoverImagePSuccessState extends SocialStates {}


class SocialUploadCoverImageErrorState extends SocialStates {}

// clear Image
class SocialClearImageSuccessState extends SocialStates {}


// update user data

class SocialUpdateUserSuccessState extends SocialStates {}

class SocialUpdateUserErrorState extends SocialStates {}

class SocialUpdateUserLoadingState extends SocialStates {}


// create post
class SocialCreatePostLoadingState extends SocialStates {}


class SocialCreatePostErrorState extends SocialStates {}


class SocialCreatePostSuccessState extends SocialStates {}



// delete post 
class SocialDeletePostLoadingState extends SocialStates {}

class SocialDeletePostSuccessState extends SocialStates {}

class SocialDeletePostErrorState extends SocialStates {}


// edit post 
class SocialEditPostLoadingState extends SocialStates {}

class SocialEditPostSuccessState extends SocialStates {}

class SocialEditPostErrorState extends SocialStates {}


// picked post image
class SocialPostImagePickedSuccessState extends SocialStates {}


class SocialPostImagePickedErrorState extends SocialStates {}

// remove post image
class SocialRemovePostImageState extends SocialStates {}



// get post data
class SocialGetPostLoadingState extends SocialStates {}

class SocialGetPostSuccessState extends SocialStates {}

class SocialGetPostErrorState extends SocialStates {
  final String error;
  SocialGetPostErrorState(this.error);
}




class SocialGetPostEmptyState extends SocialStates{}

// clear post data

class SocialClearPostSuccessState extends SocialStates {}


// like post
class SocialLikePostLoadingState extends SocialStates {}

class SocialLikePostSuccessState extends SocialStates {}

class SocialLikePostErrorState extends SocialStates {
  final String error;
  SocialLikePostErrorState(this.error);
}

// unlike post

class SocialUnlikePostLoadingState extends SocialStates {}

class SocialUnlikePostErrorState extends SocialStates {}

class SocialUnlikePostSuccessState extends SocialStates {}

// chat

// send message
class SocialSendMessageSuccessState extends SocialStates {}

class SocialSendMessageErrorState extends SocialStates {}

// get message

class SocialGetMessagesSuccessState extends SocialStates {}

// clear message

class SocialclearMessagesSuccessState extends SocialStates {}


// delete message

class SocialDeleteMessageSuccessState extends SocialStates {}

class SocialDeleteMessageErrorState extends SocialStates {}

// edit message

class SocialChangeIsEditMessageState extends SocialStates {}

class SocialEditMessageSuccessState extends SocialStates {}

class SocialEditMessageErrorState extends SocialStates {}

class SocialSetMessageModelState extends SocialStates {}

// delete chat

class SocialDeleteChatSuccessState extends SocialStates {}

class SocialDeleteChatErrorState extends SocialStates {}


// send comments

class SocialSendCommentPostLoadingState extends SocialStates {}

class SocialSendCommentPostSuccessState extends SocialStates {}

class SocialSendCommentPostErrorState extends SocialStates {}

// delete comments

class SocialDeleteCommentPostLoadingState extends SocialStates {}

class SocialDeleteCommentPostSuccessState extends SocialStates {}

class SocialDeleteCommentPostErrorState extends SocialStates {}


// edit comments

class SocialChangeIsEditCommentState extends SocialStates {}

class SocialEditCommentSuccessState extends SocialStates {}

class SocialEditCommentErrorState extends SocialStates {}

class SocialSetCommentModelState extends SocialStates {}

// search for users

class SocialGetSearchUsersLoadingState extends SocialStates {}

class SocialGetSearchUsersSuccessState extends SocialStates {}

class SocialGetSearchUsersErrorState extends SocialStates {
  final String error;
  SocialGetSearchUsersErrorState(this.error);
}


// get logged in user posts data
class SocialGetLoggedInUserPostLoadingState extends SocialStates {}

class SocialGetLoggedInUserPostSuccessState extends SocialStates {}

class SocialGetLoggedInUserPostErrorState extends SocialStates {
  final String error;
  SocialGetLoggedInUserPostErrorState(this.error);
}

class SocialGetLoggedInUserPostEmptyState extends SocialStates{}


// follow user

class SocialFollowUserLoadingState extends SocialStates {}

class SocialFollowUserSuccessState extends SocialStates {}

class SocialFollowUserErrorState extends SocialStates {}


// unfollow user

class SocialUnFollowUserLoadingState extends SocialStates {}

class SocialUnFollowUserSuccessState extends SocialStates {}

class SocialUnFollowUserErrorState extends SocialStates {}



// get specific user data
class SocialGetSpecificUserLoadingState extends SocialStates {}

class SocialGetSpecificUserSuccessState extends SocialStates {}

class SocialGetSpecificUserErrorState extends SocialStates {
  final String error;
  SocialGetSpecificUserErrorState(this.error);
}


// get Specific user posts data
class SocialGetSpecificUserPostLoadingState extends SocialStates {}

class SocialGetSpecificUserPostSuccessState extends SocialStates {}

class SocialGetSpecificUserPostErrorState extends SocialStates {
  final String error;
  SocialGetSpecificUserPostErrorState(this.error);
}

class SocialGetSpecificUserPostEmptyState extends SocialStates{}


// clear specific user data

class SocialClearSpecificUserSuccessState extends SocialStates{}


