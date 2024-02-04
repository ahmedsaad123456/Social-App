class FollowModel {
  String? name; 
  String? uId; 
  String? image; 
  String? bio; 

  //================================================================================================================================

  // Constructor for follow model
  FollowModel({
    this.name,
    this.uId,
    this.image,
    this.bio,
  });

  //================================================================================================================================

  // Named Constructor to convert JSON data to follow model object
  FollowModel.fromJson(Map<String, dynamic>? json) {
    name = json!['name']; 
    uId = json['uId']; 
    image = json['image']; 
    bio = json['bio']; 
  }

  //================================================================================================================================

  // Convert follow model object to a json object
  Map<String, dynamic> toMap() {
    return {
      'name': name, 
      'uId': uId,
      'image': image, 
      'bio': bio, 
    };
  }

  //================================================================================================================================
}
