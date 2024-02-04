
class UserModel {
  String? name;
  String? email;
  String? phone;
  String? uId;
  bool? isEmailVerified;
  String? image;
  String? bio;
  String? cover;

  //================================================================================================================================

  // Constructor for user model
  UserModel({
    this.name,
    this.email,
    this.phone,
    this.uId,
    this.isEmailVerified,
    this.image,
    this.bio,
    this.cover,
  });

  //================================================================================================================================

  // Named Constructor to convert JSON data to user model object
  UserModel.fromJson(Map<String, dynamic>? json) {
    name = json!['name'];
    email = json['email'];
    phone = json['phone'];
    uId = json['uId'];
    isEmailVerified = json['isEmailVerified'];
    image = json['image'];
    bio = json['bio'];
    cover = json['cover'];
  }

  //================================================================================================================================

  // Convert user model object to a json object
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'uId': uId,
      'isEmailVerified': isEmailVerified,
      'image': image,
      'bio': bio,
      'cover': cover,
    };
  }

  //================================================================================================================================
}
