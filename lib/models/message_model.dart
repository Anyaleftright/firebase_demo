class MessageModel {
  String? sender, text, messageId, type;
  DateTime? createdOn;
  bool? seen;

  MessageModel({this.messageId, this.sender, this.text, this.createdOn, this.seen, this.type});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map['messageId'];
    sender = map['sender'];
    text = map['text'];
    createdOn = map['createdOn'].toDate();
    seen = map['seen'];
    type = map['type'];
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'sender': sender,
      'text': text,
      'createdOn': createdOn,
      'seen': seen,
      'type': type,
    };
  }
}