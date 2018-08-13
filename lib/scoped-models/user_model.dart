import 'package:flutter_course/models/user.dart';
import 'package:flutter_course/scoped-models/connected_products_model.dart';

class UserModel extends ConnectedProducts {

  void login(String email, String password) {
    authenticatedUser = User(
      id: 'dummyId',
      email: email,
      password: password,
    );
  }
}
