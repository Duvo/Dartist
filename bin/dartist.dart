library dartist;

import 'package:route/server.dart';
import 'package:route/pattern.dart';
import 'dart:mirrors';
import 'dart:io';

part 'route.dart';
part 'controller.dart';

class Server {

  var address;
  int port;
  int backlog;
  Map<String, Route> routes;

  Map<String, Map<String, ClassMirror>> _libraries = {};

  Server(this.address, this.port, {this.backlog: 0, Map<String, Route> routes}) {
    this.routes = ?routes ? routes : {};
  }

  start() {
    HttpServer.bind(address, port, backlog: backlog).then((HttpServer server) {
      var router = new Router(server);
      routes.forEach((var key, Route route) {
        if (!_libraries.containsKey(route.library)) {
          _handleRoute(route);
        }
        router.serve(route.urlPattern, method: route.method).listen((HttpRequest request) {
          _dispatch(request, route.library);
        });
      });
    });
  }

  _handleRoute(Route route) {
    LibraryMirror libraryMirror = currentMirrorSystem().findLibrary(new Symbol(route.library)).first;
    _libraries[route.library] = {};
    libraryMirror.classes.forEach((Symbol key, ClassMirror classMirror) {
      var current = classMirror;
      bool isController = false;
      ClassMirror object = reflectClass(Object);
      ClassMirror controller = reflectClass(Controller);
      while(current.qualifiedName != object.qualifiedName && !isController) {
        current = current.superclass;
        if (current.qualifiedName == controller.qualifiedName) {
          isController = true;
        }
      }
      if (isController) {
        String className = MirrorSystem.getName(key).toLowerCase();
        _libraries[route.library][className] = classMirror;
      }
    });
  }

  _dispatch(HttpRequest request, String library) {
    List<String> segments = request.uri.pathSegments;
    String controller = segments[0];
    String action = segments[1];
    Map parameters = {'id': segments[2]};
    ClassMirror classMirror = _libraries[library][controller];
    InstanceMirror instanceMirror = classMirror.newInstance(new Symbol(''), [request, action, parameters]);
  }
}