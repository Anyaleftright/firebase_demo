class ChatRoomModel {
  String? roomId;
  Map<String, dynamic>? participants;
  String? lastMessage;

  ChatRoomModel({this.roomId, this.participants, this.lastMessage});

  ChatRoomModel.fromMap(Map<String, dynamic> map){
    roomId = map['roomId'];
    participants = map['participants'];
    lastMessage = map['lastMessage'];
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'participants': participants,
      'lastMessage': lastMessage,
    };
  }
}