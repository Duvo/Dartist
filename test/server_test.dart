library test;

import 'package:unittest/unittest.dart';
import 'package:dartist/dartist.dart';
import 'package:http/http.dart' as http;
import 'dart:mirrors';

class FakeController extends Controller {
  ok() {
    request.response.statusCode = 200;
    request.response.write('foo');
  }

  error() {
    request.response.statusCode = 500;
  }

  notFound() {
    request.response.statusCode = 404;
    request.response.write('Not found');
    request.response.close();
  }
}

main() {
  var library = MirrorSystem.getName(currentMirrorSystem().isolate.rootLibrary.qualifiedName);
  var controller = 'fakecontroller';
  var routes = {'default': new Route('/api/<library>/<controller>-<action>')};

  test ('basic example', (){
    Server server = new Server('127.0.0.1', 8080, routes: routes);
    server.start().then((server) {
      http.get('http://127.0.0.1:8080/api/$library/$controller/ok')
      .then(expectAsync1((response) {
        expect(response.statusCode, 200);
      }).catchError(expectAsync1((e) => expect(false, 'Should not be reached'), count:0));
    });
  });
}