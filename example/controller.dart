library controller;

import 'dart:io';
import 'package:dartist/dartist.dart';

class MyController extends Controller {

  MyController(HttpRequest request, String action, Map<String, String> parameters) : super(request, action, parameters);

  index() {
    request.response.write('ID: ${parameters['id']}');
    request.response.close();
  }
}