import 'dart:io';

import 'package:flutter/material.dart';

class CheckInternetConnection {
  Future<bool> checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (e) {
      return false;
    }
  }
}
