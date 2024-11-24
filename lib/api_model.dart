class UserModel {
  final String id, password, name, nickname, username, email, phonenumber;

  UserModel.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      password = json['password'],
      name = json['name'],
      nickname = json['nickname'],
      username = json['username'],
      email = json['email'],
      phonenumber= json['phonenumber'];
}