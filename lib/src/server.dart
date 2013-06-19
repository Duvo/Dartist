part of dartist;

class Server {

  var address;
  int port;
  int backlog;
  Map<String, Route> routes;

  Server(this.address, this.port, {this.backlog: 0, Map<String, Route> routes}) {
    this.routes = ?routes ? routes : {};
  }

  Future<HttpServer> start() {
    return HttpServer.bind(address, port, backlog: backlog).then((HttpServer server) {
      var router = new Router(server);
      routes.forEach((var key, Route route) {
        router.serve(route.urlPattern, method: route.method).listen((HttpRequest request) {
          _dispatch(route, request);
        });
      });
      return new Future.value(server);
    });
  }

  _dispatch(Route route, HttpRequest request) {
    List<String> groups = route.urlPattern.parse(request.uri.path);
    Map<String, String> segments = {};
    for(Segment segment in route.segments.values) {
      var value;
      if (segment.required) {
        if (segment.index >= groups.length) {
          throw 'Missing required segment';
        } else {
          value = groups[segment.index];
        }
      } else {
        if (segment.index >= groups.length) {
          value = segment.defaultValue;
        } else {
          value = groups[segment.index];
        }
      }
      segments[segment.name] = value.toLowerCase();
    }
    String library = segments['library'];
    String controller = segments['controller'];
    String action = segments['action'];

    LibraryMirror libraryMirror;
    for (LibraryMirror mirror in currentMirrorSystem().libraries.values) {
      if (MirrorSystem.getName(mirror.qualifiedName).toLowerCase() == library) {
        libraryMirror = mirror;
        break;
      }
    }
    if (libraryMirror == null) {
      send404(request);
    } else {
      ClassMirror classMirror;
      ClassMirror object = reflectClass(Object);
      ClassMirror controller = reflectClass(Controller);
      for (ClassMirror mirror in libraryMirror.classes.values) {
        var current = mirror;
        bool isController = false;
        while(current.qualifiedName != object.qualifiedName && !isController) {
          current = current.superclass;
          if (current.qualifiedName == controller.qualifiedName) {
            isController = true;
          }
        }
        if (isController) {
          if (MirrorSystem.getName(mirror.qualifiedName).toLowerCase() == controller) {
            classMirror = mirror;
            break;
          }
        }
      }
      if (classMirror == null) {
        send404(request);
      } else {
        InstanceMirror instanceMirror = classMirror.newInstance(new Symbol(''), [request, action, segments]);
      }
    }
  }
}