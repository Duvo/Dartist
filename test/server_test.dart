library test.server;

import 'package:unittest/unittest.dart';
import 'package:dartist/dartist.dart';
import 'package:http/http.dart' as http;
import 'dart:mirrors';
import 'dart:io';
import 'dart:async';

class FakeController extends Controller {

  FakeController(request, parameters) : super(request, parameters);

  segmentParameter() {
    request.response.statusCode = 200;
    var param = parameters['param'];
    request.response.write(param);
  }

  queryParameter() {
    request.response.statusCode = 200;
    var param = request.uri.queryParameters['param'];
    request.response.write(param);
  }

  postContent() {
    return getFields().then((fields) {
      request.response.statusCode = 200;
      request.response.write(fields['param']);
    });
  }

  html() {
    request.response.statusCode = 200;
    request.response.write(loadFile('examples/test.html'));
  }

  error() {
    request.response.statusCode = 500;
  }

  notFound() {
    request.response.statusCode = 404;
    request.response.write('Not Found');
    request.response.close();
  }
}

main() {
  var library = MirrorSystem.getName(currentMirrorSystem().isolate.rootLibrary.qualifiedName);
  var controller = 'fakecontroller';
  var routes = {
                'default': new Route('/default/<controller>-<action>(/<param>)', method: 'GET', defaultValues: {
                  'library' : library
                }),
                'library': new Route('/<library>/<controller>-<action>', method: 'GET'),
                'post': new Route('/post/<controller>-<action>', method: 'POST', defaultValues: {
                  'library' : library
                })
  };

  group('server', () {
    Server server = new Server('127.0.0.1', 8080, routes: routes,
        extensionsAllowed: ['css', 'jpg', 'js'],
        foldersAllowed: ['/examples/public']);
    setUp(() {
      return server.start();
    });

    tearDown(() {
      server.stop();
    });

    group('post', () {
      test('with content', () {
        var param = 'foobar';
        http.post('http://127.0.0.1:8080/post/$controller-postcontent', fields: {'param' : param})
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, param);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('with strange content', () {
        var param = 'foo&bar=foobar';
        http.post('http://127.0.0.1:8080/post/$controller-postcontent', fields: {'param' : param})
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, param);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
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

      test('resource case extension', () {
        http.get('http://127.0.0.1:8080/examples/case.CSS')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
          expect(response.body, 'Not Found');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('resource folder', () {
        http.get('http://127.0.0.1:8080/examples/public/test.html')
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, 'It works!');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('resource 404', () {
        http.get('http://127.0.0.1:8080/examples/foo.css')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
          expect(response.body, 'Not Found');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('resource forbidden', () {
        http.get('http://127.0.0.1:8080/examples/test.html')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
          expect(response.body, 'Not Found');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('html', () {
        http.get('http://127.0.0.1:8080/default/$controller-html')
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, 'It works!');
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

      test('without parameter', () {
        http.get('http://127.0.0.1:8080/default/$controller-segmentparameter')
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, 'null');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('case', () {
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
          expect(response.body, isEmpty);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('action not found', (){
        http.get('http://127.0.0.1:8080/default/$controller-notfound')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
          expect(response.body, 'Not Found');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('bad url', (){
        http.get('http://127.0.0.1:8080/foo/bar')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
          expect(response.body, 'Not Found');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('bad library', (){
        http.get('http://127.0.0.1:8080/foobar/$controller-ok')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
          expect(response.body, 'Not Found');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('bad controller', (){
        http.get('http://127.0.0.1:8080/default/foobar-ok')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
          expect(response.body, 'Not Found');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('bad action', (){
        http.get('http://127.0.0.1:8080/default/$controller-foobar')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
          expect(response.body, 'Not Found');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });
    });
  });
}