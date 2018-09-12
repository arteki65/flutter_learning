import 'dart:async';
import 'dart:convert';

import 'package:flutter_course/models/auth.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/models/user.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

final String _productsApiUrl =
    'https://flutter-products-2d429.firebaseio.com/products.json';
final String _productApiUrl =
    'https://flutter-products-2d429.firebaseio.com/products/';
final String _signupApiUrl =
    'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyC68wUNJbBXj9b7m0thUmzRpJQJrniJ0MM';
final String _signinApiUrl =
    'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyC68wUNJbBXj9b7m0thUmzRpJQJrniJ0MM';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  User _authenticatedUser;
  String _selProductId;
  bool _isLoading = false;
}

class ProductsModel extends ConnectedProductsModel {
  bool _showFavorites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product p) => p.id == _selProductId);
  }

  String get selectedProductId {
    return _selProductId;
  }

  Product get selectedProduct {
    if (selectedProductId == null) {
      return null;
    }
    return _products.firstWhere((Product p) => p.id == _selProductId);
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<bool> addProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://www.ketoconnect.net/wp-content/uploads/2018/01/keto-chocolate-bar-broke.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    try {
      final http.Response response = await http.post(
        'https://flutter-products-2d429.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
        body: json.encode(productData),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final newProduct = Product(
        id: responseData['name'],
        description: description,
        imagePath: image,
        title: title,
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
      );
      _products.add(newProduct);
      _selProductId = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(
      String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image': image,
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
    };
    return http
        .put(
      _productApiUrl +
          '${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
      body: json.encode(updateData),
    )
        .then((http.Response response) {
      _isLoading = false;
      final updatedProduct = Product(
        id: selectedProduct.id,
        description: description,
        imagePath: image,
        title: title,
        price: price,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
      );
      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteProduct() {
    _isLoading = false;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();
    return http
        .delete(_productApiUrl +
            '$deletedProductId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    notifyListeners();
    return http
        .get(
            'https://flutter-products-2d429.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String porudctId, dynamic productData) {
        final Product product = Product(
            id: porudctId,
            description: productData['description'],
            imagePath: productData['image'],
            title: productData['title'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId']);
        fetchedProductList.add(product);
      });
      _products = fetchedProductList;
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
      return;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  void toggleProductFavorite() {
    final bool isCurrentlyFavourite = selectedProduct.isFavorite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;
    final Product updatedProduct = Product(
      id: selectedProduct.id,
      title: selectedProduct.title,
      description: selectedProduct.description,
      imagePath: selectedProduct.imagePath,
      price: selectedProduct.price,
      isFavorite: newFavouriteStatus,
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.userId,
    );
    _products[selectedProductIndex] = updatedProduct;
    _selProductId = null;
    notifyListeners();
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    if (productId != null) {
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

class UserModel extends ConnectedProductsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        _signinApiUrl,
        body: json.encode(authData),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } else {
      response = await http.post(
        _signupApiUrl,
        body: jsonEncode(authData),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong!';
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded!';
      _authenticatedUser = User(
        id: responseData['localId'],
        email: responseData['email'],
        token: responseData['idToken'],
      );
      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', responseData['email']);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Invalid password.';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'Provided email already has been registered.';
    }
    _isLoading = false;
    notifyListeners();
    return {
      'success': !hasError,
      'message': message,
    };
  }

  void autoAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final DateTime paredExpiryTime = DateTime.parse(expiryTimeString);
      if (paredExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      final tokenLifespan = paredExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifespan);
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
    notifyListeners();
  }

  void setAuthTimeout(int seconds) {
    _authTimer = Timer(Duration(seconds: seconds), () {
      logout();
    });
  }
}

class UtilityModel extends ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
