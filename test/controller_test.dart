library test.controller;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:dartist/dartist.dart';
import 'dart:io';

import 'examples/template.dart';

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

class Foobar {
  String foo;
  String bar;

  Foobar(this.foo, this.bar);
}

class ControllerMock extends Controller {
  var result;

  ControllerMock(HttpRequestMock request,
      Map<String,
      String> parameters)
      : super(request, parameters);

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

  withTemplate() {
    var context = {
                   'title' : 'My Title',
                   'options': ['Foo', 'Bar', 'Foobar']
    };
    request.response.result = template(context);
  }

  withMustache() {
    var context = {
                   'title' : 'My Title',
                   'options': [
                               new Foobar('foo1', 'bar1'),
                               new Foobar('foo2', 'bar2'),
                               new Foobar('foo3', 'bar3')
                   ]
    };
    request.response.result = renderMustache('examples/mustache.html', context);
  }
}

main() {

  test('with template', () {
    var expected = ['<li>Foo</li>','<li>Bar</li>', '<li>Foobar</li>'];
    var request = new HttpRequestMock();
    request.response._onClose = expectAsync0(() {
      expect(request.response.result, stringContainsInOrder(expected));
      expect(request.response.beforeDone, isTrue);
      expect(request.response.afterDone, isTrue);
    });
    var controller = new ControllerMock(request, {'action': 'withtemplate'});
  });

  test('with mustache', () {
    var expected = ['<li>foo1-bar1</li>','<li>foo2-bar2</li>', '<li>foo3-bar3</li>'];
    var request = new HttpRequestMock();
    request.response._onClose = expectAsync0(() {
      expect(request.response.result, stringContainsInOrder(expected));
      expect(request.response.beforeDone, isTrue);
      expect(request.response.afterDone, isTrue);
    });
    var controller = new ControllerMock(request, {'action': 'withmustache'});
  });

  test('execute the action with parameters', () {
    var expected = 'bar';
    var request = new HttpRequestMock();
    request.response._onClose = expectAsync0(() {
      expect(request.response.result, expected);
      expect(request.response.beforeDone, isTrue);
      expect(request.response.afterDone, isTrue);
    });
    var controller = new ControllerMock(request, {'action': 'withparameters', 'foo' : expected});
  });

  test('404', () {
    var request = new HttpRequestMock();
    request.response._onClose = expectAsync0(() {
      expect(request.response.statusCode, 404);
      expect(request.response.beforeDone, isTrue);
    }, count: 2);
    var controller = new ControllerMock(request, {'action': 'other'});
  });
}