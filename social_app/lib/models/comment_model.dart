class CommentModel {
  String? name;
  String? uId;
  String? image;
  String? text;
  String? dateTime;

//================================================================================================================================

  // Constructor for comment model

  CommentModel({
    this.name,
    this.uId,
    this.image,
    this.text,
    this.dateTime,
  });

//================================================================================================================================

  //Named Constructor to convert JSON data to comment model object

  CommentModel.fromJson(Map<String, dynamic>? json) {
    name = json!['name'];
    uId = json['uId'];
    image = json['image'];
    text = json['text'];
    dateTime = json['dateTime'];
  }

//================================================================================================================================


  // Convert comment model object to a json object

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uId': uId,
      'image': image,
      'text': text,
      'dateTime': dateTime,
    };
  }

//================================================================================================================================

}

//================================================================================================================================

