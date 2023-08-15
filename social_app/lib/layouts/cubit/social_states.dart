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

class SocialGetAllUsersErrorState extends SocialStates {
  final String error;
  SocialGetAllUsersErrorState(this.error);
}

// change bottom nav bar

class SocialChangeBottomNavBarState extends SocialStates {}



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

// upload user data

class SocialUpdateUserErrorState extends SocialStates {}

class SocialUpdateUserLoadingState extends SocialStates {}


// create post
class SocialCreatePostLoadingState extends SocialStates {}


class SocialCreatePostErrorState extends SocialStates {}


class SocialCreatePostSuccessState extends SocialStates {}


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

class SocialSendMessageSuccessState extends SocialStates {}

class SocialSendMessageErrorState extends SocialStates {}

class SocialGetMessagesSuccessState extends SocialStates {}


// send comments

class SocialCommentPostLoadingState extends SocialStates {}

class SocialCommentPostSuccessState extends SocialStates {}

class SocialCommentPostErrorState extends SocialStates {
  
}
