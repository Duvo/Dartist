library example;

import 'routes.dart';
import 'package:dartist/dartist.dart';
import 'dart:io';

part 'controller.dart';

main() {
  Server server = new Server('127.0.0.1', 8080, routes: routes, foldersAllowed: folders);
  server.start();
}