import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showToast(BuildContext ctx, String msg) {
    final scaffold = ScaffoldMessenger.of(ctx);
    scaffold.showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }
}
