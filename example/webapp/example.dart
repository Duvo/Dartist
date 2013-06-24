library example;

import 'routes.dart';
import 'package:dartist/dartist.dart';
import 'dart:io';

part 'controller.dart';

main() {
  Server server = new Server(routes: routes);
  server.server.start();
}