class UserAttributes {
  String email;
  String password;
  String emailChangeToken;
  dynamic data;

  UserAttributes({this.email, this.password, this.emailChangeToken, this.data});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> values = {};
    if (email != null) values['email'] = email;
    if (password != null) values['password'] = email;
    if (emailChangeToken != null) values['email_change_token'] = email;
    if (data != null) values['data'] = data;
    return values;
  }
}