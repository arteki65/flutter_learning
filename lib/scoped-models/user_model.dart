import 'package:flutter_course/models/user.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {
  User _authenticatedUser;

  void login(String email, String password) {
    _authenticatedUser = User(
      id: 'dummyId',
      email: email,
      password: password,
    );
  }
}
