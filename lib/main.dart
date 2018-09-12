import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/scoped-models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:flutter_course/pages/product.dart';
import 'package:flutter_course/pages/products.dart';
import 'package:flutter_course/pages/products_admin.dart';

import './pages/auth.dart';

void main() {
  // debugPaintSizeEnabled = true;

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _mainModel = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _mainModel.autoAuth();
    _mainModel.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _mainModel,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepPurple,
          buttonColor: Colors.deepPurple,
        ),
        routes: {
          '/': (BuildContext contexy) =>
              !_isAuthenticated ? AuthPage() : ProductsPage(_mainModel),
          '/admin': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ProductsAdminPage(_mainModel),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => AuthPage(),
            );
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product = _mainModel.allProducts
                .firstWhere((Product p) => p.id == productId);
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? AuthPage() : ProductPage(product),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return new MaterialPageRoute(
            builder: (BuildContext context) =>
                !_isAuthenticated ? AuthPage() : ProductsPage(_mainModel),
          );
        },
      ),
    );
  }
}
