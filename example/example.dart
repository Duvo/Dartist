library example;

import '../bin/dartist.dart';
import 'controller.dart';
import 'routes.dart';

main() {
  Server server = new Server('127.0.0.1', 8080, routes: routes);
  server.start();
}