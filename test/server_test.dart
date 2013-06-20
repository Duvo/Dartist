library test.server;

import 'package:unittest/unittest.dart';
import 'package:dartist/dartist.dart';
import 'package:http/http.dart' as http;
import 'dart:mirrors';
import 'dart:io';

class FakeController extends Controller {

  FakeController(request, String action, Map<String, String> parameters) : super(request, action, parameters);

  ok() {
    request.response.statusCode = 200;
    request.response.write('foo');
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
                'default': new Route('/default/<controller>-<action>', defaultValues: {
                  'library' : library
                }),
                'library': new Route('/<library>>/<controller>-<action>')
  };

  group('server', () {
    Server server = new Server('127.0.0.1', 8080, routes: routes);
    setUp(() {
      return server.start();
    });

    tearDown(() {
      server.stop();
    });

    group('gets', () {
      test('action ok', (){
        http.get('http://127.0.0.1:8080/default/$controller-ok')
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, 'foo');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('action ok', (){
        http.get('http://127.0.0.1:8080/default/$controller-ok')
        .then(expectAsync1((response) {
          expect(response.statusCode, 200);
          expect(response.body, 'foo');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('action ok', (){
        http.get('http://127.0.0.1:8080/default/$controller-error')
        .then(expectAsync1((response) {
          expect(response.statusCode, 500);
          expect(response.body, isEmpty);
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('action ok', (){
        http.get('http://127.0.0.1:8080/default/$controller-notfound')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
          expect(response.body, 'Not Found');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('action ok', (){
        http.get('http://127.0.0.1:8080/foo/bar')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
          expect(response.body, 'Not Found');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('action ok', (){
        http.get('http://127.0.0.1:8080/foobar/$controller-ok')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
          expect(response.body, 'Not Found');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('action ok', (){
        http.get('http://127.0.0.1:8080/default/foobar-ok')
        .then(expectAsync1((response) {
          expect(response.statusCode, 404);
          expect(response.body, 'Not Found');
        }))
        .catchError(expectAsync1((e) {}, count: 0));
      });

      test('action ok', (){
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