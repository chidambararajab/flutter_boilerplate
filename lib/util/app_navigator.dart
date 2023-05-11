import 'package:flutter/material.dart';

/// Navigator tool class
/// It is more recommended to use 'routers/fluro_navigator.dart'
class AppNavigator {
  static void push(BuildContext context, Widget scene) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => scene,
      ),
    );
  }

  /// Replace the page When the new page enters, the previous page will execute the dispose method
  static void pushReplacement(BuildContext context, Widget scene) {
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => scene,
      ),
    );
  }

  /// Add the specified page to the route, and then pop all other pages
  static void pushAndRemoveUntil(BuildContext context, Widget scene) {
    Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => scene,
        ),
        (route) => false);
  }

  static void pushResult(
      BuildContext context, Widget scene, Function(Object?) function) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => scene,
      ),
    ).then((dynamic result) {
      // The page returns result as null
      if (result == null) {
        return;
      }
      function(result);
    }).catchError((dynamic error) {
      debugPrint('$error');
    });
  }

  /// return
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// Return with parameters
  static void goBackWithParams(BuildContext context, dynamic result) {
    Navigator.pop<dynamic>(context, result);
  }
}
