library test.server;

import 'package:unittest/unittest.dart';
import 'package:dartist/dartist.dart';
import 'package:stream/stream.dart';
import 'package:http/http.dart' as http;
import 'dart:mirrors';
import 'dart:io';
import 'dart:async';

class FakeController extends Controller {

  FakeController(connect, parameters) : super(connect, parameters);

  segmentParameter() {
    connect.response.statusCode = 200;
    var param = parameters['param'];
    connect.response.write(param);
  }

  queryParameter() {
    connect.response.statusCode = 200;
    var param = connect.request.uri.queryParameters['param'];
    connect.response.write(param);
  }

  postContent() {
    return getFields().then((fields) {
      connect.response.statusCode = 200;
      connect.response.write(fields['param']);
    });
  }

  html() {
    connect.response.statusCode = 200;
    connect.response.write(loadFile('examples/test.html'));
  }

  error() {
    throw new Http500();
  }
}

Future handler(HttpConnect connect) {
  return new Future.sync(() {
    throw new Http500();
  });
}

Future error500() {
  return new Future.sync(() {
    throw new Http500();
  });
}

main() {
  var library = MirrorSystem.getName(currentMirrorSystem().isolate.rootLibrary.qualifiedName);
  var controller = 'fakecontroller';
  var routes = [
                new Route('/default/<controller>-<action>/<param>', method: 'GET', defaultValues: {
                  'library' : library
                }),
                new Route('/default/<controller>-<action>', method: 'GET', defaultValues: {
                  'library' : library
                }),
                new Route('/<library>/<controller>-<action>', method: 'GET'),
                new Route('/post/<controller>-<action>', method: 'POST', defaultValues: {
                  'library' : library
                })
  ];

  print(routes[0].urlPattern);

  group('server', () {
    Server server = new Server(routes: routes);
    setUp(() {
      return server.server.start();
    });

    tearDown(() {
      server.server.stop();
    });

    group('post', () {
      test('with content', () {
        var param = 'foobar';
        http.post('http://127.0.0.1:8080/post/$controller-postcontent', fields: {'param' : param})
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, param);
        }))
        .catchError(expectAsync1((e) {print(e);}, count: 0));
      });

      test('with strange content', () {
        var param = 'foo&bar=foobar';
        http.post('http://127.0.0.1:8080/post/$controller-postcontent', fields: {'param' : param})
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, param);
        }))
        .catchError(expectAsync1((e) {print(e);}, count: 0));
      });
    });

    group('get', () {
      test('resource', () {
        http.get('http://127.0.0.1:8080/examples/test.css')
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, 'body{color:blue;}');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('resource 404', () {
        http.get('http://127.0.0.1:8080/examples/foo.css')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('resource forbidden', () {
        http.get('http://127.0.0.1:8080/webapp/test.html')
        .then(expectAsync1((response) {
          expect(response.statusCode, 403);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('with query', () {
        var param = 'foobar';
        http.get('http://127.0.0.1:8080/default/$controller-queryparameter?param=$param')
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, param);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('with parameter', () {
        var param = 'foobar';
        http.get('http://127.0.0.1:8080/default/$controller-segmentparameter/$param')
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, param);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('case sensitivity', () {
        http.get('http://127.0.0.1:8080/default/${controller.toUpperCase()}-segmentparameter')
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, 'null');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('action error', (){
        http.get('http://127.0.0.1:8080/default/$controller-error')
        .then(expectAsync1((response) {
          expect(response.statusCode, 500);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('bad url', (){
        http.get('http://127.0.0.1:8080/foo/bar')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('bad library', (){
        http.get('http://127.0.0.1:8080/foobar/$controller-ok')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('bad controller', (){
        http.get('http://127.0.0.1:8080/default/foobar-ok')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('bad action', (){
        http.get('http://127.0.0.1:8080/default/$controller-foobar')
        .then(expectAsync1((response) {
          print(response.body);
          expect(response.statusCode, 404);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });
    });
  });
}