import 'package:social_app/models/follow_model.dart';
import 'package:social_app/models/user_model.dart';

class UserDataModel {
  UserModel user;
  List<FollowModel> followers;
  List<FollowModel> followings;

  UserDataModel({
    required this.user,
    required this.followers,
    required this.followings,
  });
}
