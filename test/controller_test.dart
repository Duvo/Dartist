import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:dartist/dartist.dart';
import 'dart:io';

class HttpRequestMock extends Mock implements HttpRequest {
  HttpResponseMock response = new HttpResponseMock();
}

class HttpResponseMock extends Mock implements HttpResponse {
  int statusCode;
  var result;
  var beforeDone = false;
  var afterDone = false;
  var _onClose;
  void close() {
    if (_onClose != null) {
      _onClose();
    }
  }
}

class ControllerMock extends Controller {
  var result;

  ControllerMock(HttpRequestMock request, String action, Map<String, String> parameters) : super(request, action, parameters);

  before() {
    request.response.beforeDone = true;
  }

  after() {
    request.response.afterDone = true;
  }

  withParameters() {
    request.response.result = parameters['foo'];
  }

  withoutParameter() {
    request.response.result = 'ok';
  }
}

main() {
  test('execute the action with parameters', () {
    var expected = 'bar';
    var request = new HttpRequestMock();
    request.response._onClose = expectAsync0(() {
      expect(request.response.result, expected);
      expect(request.response.beforeDone, isTrue);
      expect(request.response.afterDone, isTrue);
    });
    var controller = new ControllerMock(request, 'withparameters', {'foo' : expected});
  });

  test('404', () {
    var request = new HttpRequestMock();
    request.response._onClose = expectAsync0(() {
      expect(request.response.statusCode, 404);
      expect(request.response.beforeDone, isTrue);
    }, count: 2);
    var controller = new ControllerMock(request, 'other', {});
  });

  test('action case sensitivity', () {
    var request = new HttpRequestMock();
    request.response._onClose = expectAsync0(() {
      expect(request.response.statusCode, 404);
      expect(request.response.beforeDone, isTrue);
    }, count: 2);
    var controller = new ControllerMock(request, 'WiThoUTpaRameTer', {});
  });
}