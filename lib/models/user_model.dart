class UserModel {
  String? uid, name, email, avatar;

  UserModel({this.uid, this.name, this.email, this.avatar});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    name = map['name'];
    email = map['email'];
    avatar = map['avatar'];
  }

  Map<String, dynamic> toMap() {
    return {
    'uid': uid,
    'name': name,
    'email': email,
    'avatar': avatar,
    };
  }
}