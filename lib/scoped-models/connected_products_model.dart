import 'dart:async';
import 'dart:convert';

import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/models/user.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

final String _productsApiUrl =
    'https://flutter-products-2d429.firebaseio.com/products.json';
final String _productApiUrl =
    'https://flutter-products-2d429.firebaseio.com/products/';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  User _authenticatedUser;
  String _selProductId;
  bool _isLoading = false;

  Future<bool> addProduct(
      String title, String description, String image, double price) {
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
    return http
        .post(
      'https://flutter-products-2d429.firebaseio.com/products.json',
      body: json.encode(productData),
    )
        .then((http.Response response) {
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
    });
  }
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

  Future<Null> updateProduct(
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
      _productApiUrl + '${selectedProduct.id}.json',
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
    });
  }

  void deleteProduct() {
    _isLoading = false;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();
    http
        .delete(_productApiUrl + '$deletedProductId.json')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    notifyListeners();
    return http
        .get('https://flutter-products-2d429.firebaseio.com/products.json')
        .then((http.Response response) {
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
  void login(String email, String password) {
    _authenticatedUser = User(
      id: 'dummyId',
      email: email,
      password: password,
    );
  }
}

class UtilityModel extends ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
