import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:dartist/dartist.dart';
import 'dart:async';
import 'dart:io';

class HttpRequestMock extends Mock implements HttpRequest {
  HttpResponseMock response = new HttpResponseMock();
}

class HttpResponseMock extends Mock implements HttpResponse {
  int statusCode;
  var _onClose;
  void close() {
    if (_onClose != null) {
      _onClose();
    }
  }
}

class ControllerMock extends Controller {
  var result;
  var beforeDone = false;
  var afterDone = false;

  ControllerMock(HttpRequest request, String action, Map<String, String> parameters) : super(request, action, parameters);

  before() {
    beforeDone = true;
  }

  after() {
    afterDone = true;
  }

  withParameters() {
    result = parameters['foo'];
  }

  withoutParameter() {
    result = 'ok';
  }
}

main() {
  test('action case sensitivity', () {
    var request = new HttpRequestMock();
    request.response._onClose = expectAsync0(() {
      expect(request.response.statusCode, 404);
    });
    var controller = new ControllerMock(request, 'WiThoUTpaRameTer', {});
  });

  test('execute the action with parameters', () {
    var expected = 'bar';
    var controller = new ControllerMock(null, 'withparameters', {'foo' : expected});
    expect(controller.result, expected);
  });

  test('404', () {
    var request = new HttpRequestMock();
    request.response._onClose = expectAsync0(() {
      expect(request.response.statusCode, 404);
    });
    var controller = new ControllerMock(request, 'other', {});
  });

  test('before', () {
    var controller = new ControllerMock(null, 'withoutparameter', {});
    expect(controller.beforeDone, isTrue);
  });

  test('after', () {
    var controller = new ControllerMock(null, 'withoutparameter', {});
    expect(controller.afterDone, isTrue);
  });
}