library controller;

import '../bin/dartist.dart';
import 'dart:io';

class MyController extends Controller {

  MyController(HttpRequest request, String action, Map<String, String> parameters) : super(request, action, parameters);

  index() {
    request.response.write('ID: ${parameters['id']}');
    request.response.close();
  }
}