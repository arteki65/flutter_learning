import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/models/user.dart';
import 'package:scoped_model/scoped_model.dart';

class ConnectedProducts extends Model {
  List<Product> products = [];
  User authenticatedUser;
  int selProductIndex;

  void addProduct(
      String title, String description, String image, double price) {
    final newProduct = Product(
      description: description,
      imagePath: image,
      title: title,
      price: price,
      userEmail: authenticatedUser.email,
      userId: authenticatedUser.id,
    );
    products.add(newProduct);
    selProductIndex = null;
    notifyListeners();
  }
}
