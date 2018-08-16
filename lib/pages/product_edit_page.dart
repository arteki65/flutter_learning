import 'package:flutter/material.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/scoped-models/main_model.dart';
import 'package:flutter_course/widgets/helpers/ensure-visible.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg'
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();

  Widget _buildTitleTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(
          labelText: 'Product Title',
        ),
        initialValue: product != null ? product.title : '',
        validator: (String value) {
          if (value.isEmpty || value.length < 5) {
            return 'Title is required and should be 5+ characters long';
          }
        },
        onSaved: (String value) {
          _formData['title'] = value;
        },
      ),
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
        focusNode: _descriptionFocusNode,
        decoration: InputDecoration(
          labelText: 'Product Description',
        ),
        maxLines: 4,
        initialValue: product != null ? product.description : '',
        onSaved: (String value) {
          _formData['description'] = value;
        },
        validator: (String value) {
          if (value.isEmpty || value.length < 10) {
            return 'Title is required and should be 10+ characters long';
          }
        },
      ),
    );
  }

  Widget _buildPriceTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _priceFocusNode,
      child: TextFormField(
        focusNode: _priceFocusNode,
        decoration: InputDecoration(
          labelText: 'Product Price',
        ),
        initialValue: product != null ? product.price.toString() : '',
        onSaved: (String value) {
          _formData['price'] = double.parse(value);
        },
        keyboardType: TextInputType.number,
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
            return 'Price is required and should be number.';
          }
        },
      ),
    );
  }

  Widget _buildSubmitButton(MainModel model) {
    return model.isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : RaisedButton(
            child: Text('Save'),
            color: Theme.of(context).accentColor,
            textColor: Colors.white,
            onPressed: () => _submitForm(model),
          );
  }

  Widget _buildPageContent(BuildContext context, MainModel model) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(model.selectedProduct),
              _buildDescriptionTextField(model.selectedProduct),
              _buildPriceTextField(model.selectedProduct),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(model),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm(MainModel model) {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (model.selectedProduct == null) {
      model
          .addProduct(
            _formData['title'],
            _formData['description'],
            _formData['image'],
            _formData['price'],
          )
          .then((_) => Navigator
              .pushReplacementNamed(context, '/products')
              .then((_) => model.selectProduct(null)));
    } else {
      model
          .updateProduct(
            _formData['title'],
            _formData['description'],
            _formData['image'],
            _formData['price'],
          )
          .then((_) => Navigator
              .pushReplacementNamed(context, '/products')
              .then((_) => model.selectProduct(null)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget widget, MainModel model) {
        final Widget pageContent = _buildPageContent(context, model);
        return model.selectedProductIndex == null
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit product'),
                ),
                body: pageContent,
              );
      },
    );
  }
}
