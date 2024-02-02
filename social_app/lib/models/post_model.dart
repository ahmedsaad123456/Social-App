class PostModel {
  String? name;
  String? uId;
  String? image;
  String? text;
  String? dateTime;
  String? postImage;

//================================================================================================================================

  // Constructor for post model

  PostModel({
    this.name,
    this.uId,
    this.image,
    this.text,
    this.dateTime,
    this.postImage,
  });

//================================================================================================================================

  //Named Constructor to convert JSON data to post model object

  PostModel.fromJson(Map<String, dynamic>? json) {
    name = json!['name'];
    uId = json['uId'];
    image = json['image'];
    text = json['text'];
    dateTime = json['dateTime'];
    postImage = json['postImage'];
  }

//================================================================================================================================


  // Convert post model object to a json object
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uId': uId,
      'image': image,
      'text': text,
      'dateTime': dateTime,
      'postImage': postImage,
    };
  }

//================================================================================================================================

}

//================================================================================================================================

