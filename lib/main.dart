import 'package:flutter/material.dart';
import 'package:flutter_course/pages/product.dart';
import 'package:flutter_course/pages/products.dart';
import 'package:flutter_course/pages/products_admin.dart';

import './pages/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  List<Map<String, String>> _products = [];

  void _addProduct(Map<String, String> product) {
    setState(() {
      _products.add(product);
    });
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.deepPurple,
      ),
      //home: AuthPage(),
      routes: {
        '/': (BuildContext context) =>
            ProductsPage(_products, _addProduct, _deleteProduct),
        '/admin': (BuildContext context) => ProductsAdminPage(),
      },
      onGenerateRoute: (RouteSettings settings) {
        final List<String> pathElements = settings.name.split('/');
        if (pathElements[0] != '') {
          return null;
        }
        if (pathElements[1] == 'product') {
          final int index = int.parse(pathElements[2]);
          return MaterialPageRoute<bool>(
            builder: (BuildContext context) => ProductPage(
                  _products[index]['title'],
                  _products[index]['image'],
                ),
          );
        }
        return null;
      },
      onUnknownRoute: (RouteSettings settings) {
        return new MaterialPageRoute(
          builder: (BuildContext context) =>
              ProductsPage(_products, _addProduct, _deleteProduct),
        );
      },
    );
  }
}
