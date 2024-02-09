import 'package:social_app/models/comment_model.dart';
import 'package:social_app/models/like_model.dart';
import 'package:social_app/models/post_model.dart';

class PostDataModel {
  PostModel post;
  List<LikeModel> likes;
  List<CommentModel> comments;
  List<String> commentsId;
  bool isLiked;

  PostDataModel({
    required this.post,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.commentsId
  });
}
