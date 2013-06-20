library test.full;

import 'controller_test.dart' as controller;
import 'route_test.dart' as route;
import 'server_test.dart' as server;
import 'mirrortools_test.dart' as mirrortools;

import 'package:unittest/vm_config.dart';
import 'package:args/args.dart';
import 'dart:io';

main() {
  controller.main();
  route.main();
  server.main();
  mirrortools.main();
}