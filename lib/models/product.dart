import 'package:flutter/material.dart';

class Product {
  final String title;
  final String description;
  final String imagePath;
  final double price;
  final bool isFavorite;

  Product(
      {@required this.title,
      @required this.description,
      @required this.imagePath,
      @required this.price,
      this.isFavorite = false});
}