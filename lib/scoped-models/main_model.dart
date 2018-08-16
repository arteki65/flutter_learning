import 'package:flutter_course/scoped-models/connected_products_model.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model
    with ConnectedProductsModel, ProductsModel, UserModel, UtilityModel {}
