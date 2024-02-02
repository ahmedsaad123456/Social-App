class MessageModel {
  String? senderId;
  String? receiverId;
  String? text;
  String? dateTime;

//================================================================================================================================

  // Constructor for message model

  MessageModel({this.senderId, this.receiverId, this.text, this.dateTime});

//================================================================================================================================

  // Named Constructor to convert JSON data to message model object

  MessageModel.fromJson(Map<String, dynamic>? json) {
    senderId = json!['senderId'];
    receiverId = json['receiverId'];
    text = json['text'];
    dateTime = json['dateTime'];
  }

//================================================================================================================================


  // Convert message model object to a json object

  Map<String, dynamic> toMap() {
    return {
      'senderId' : senderId,
      'text' : text,
      'dateTime' : dateTime,
      'receiverId' : receiverId
    };
  }

//================================================================================================================================

}

//================================================================================================================================
