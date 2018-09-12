import 'package:flutter/material.dart';
import 'package:flutter_course/scoped-models/main_model.dart';

import 'package:scoped_model/scoped_model.dart';

class LogoutListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () {
            model.logout();
          },
        );
      },
    );
  }
}
