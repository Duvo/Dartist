library test.controller;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:dartist/dartist.dart';
import 'package:stream/stream.dart';
import 'dart:io';

import 'examples/template.dart';

class HttpConnectMock extends Mock implements HttpConnect {
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

  ControllerMock(HttpConnectMock connect,
      Map<String,
      String> parameters)
      : super(connect, parameters);

  before() {
    connect.response.beforeDone = true;
  }

  after() {
    connect.response.afterDone = true;
    connect.response.close();
  }

  withParameters() {
    connect.response.result = parameters['foo'];
  }

  withoutParameter() {
    connect.response.result = 'ok';
  }

  withTemplate() {
    var context = {
                   'title' : 'My Title',
                   'options': ['Foo', 'Bar', 'Foobar']
    };
    connect.response.result = template(context);
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
    connect.response.result = renderMustache('examples/mustache.html', context);
  }
}

main() {

  test('with template', () {
    var expected = ['<li>Foo</li>','<li>Bar</li>', '<li>Foobar</li>'];
    var connect = new HttpConnectMock();
    connect.response._onClose = expectAsync0(() {
      expect(connect.response.result, stringContainsInOrder(expected));
      expect(connect.response.beforeDone, isTrue);
      expect(connect.response.afterDone, isTrue);
    });
    var controller = new ControllerMock(connect, {'action': 'withtemplate'});
    controller.execute();
  });

  test('with mustache', () {
    var expected = ['<li>foo1-bar1</li>','<li>foo2-bar2</li>', '<li>foo3-bar3</li>'];
    var connect = new HttpConnectMock();
    connect.response._onClose = expectAsync0(() {
      expect(connect.response.result, stringContainsInOrder(expected));
      expect(connect.response.beforeDone, isTrue);
      expect(connect.response.afterDone, isTrue);
    });
    var controller = new ControllerMock(connect, {'action': 'withmustache'});
    controller.execute();
  });

  test('execute the action with parameters', () {
    var expected = 'bar';
    var connect = new HttpConnectMock();
    connect.response._onClose = expectAsync0(() {
      expect(connect.response.result, expected);
      expect(connect.response.beforeDone, isTrue);
      expect(connect.response.afterDone, isTrue);
    });
    var controller = new ControllerMock(connect, {'action': 'withparameters', 'foo' : expected});
    controller.execute();
  });

  test('404', () {
    var connect = new HttpConnectMock();
    var controller = new ControllerMock(connect, {'action': 'other'});
    expect(controller.execute(), throwsA(new isInstanceOf<Http404>()));
  });
}