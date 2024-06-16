import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> isConnect() async {
  final List<ConnectivityResult> connectivityResult =
      await (Connectivity().checkConnectivity());

  if (connectivityResult.contains(ConnectivityResult.none)) {
    return false;
  }
  return true;
}

Future<void> main() async {
  stdout.write('hello');
  stdout.write(isConnect().toString());
}
