part of dartist;

class Server {
  var address;
  int port;
  int backlog;
  Map<String, Route> routes;
  List<String> extensionsAllowed;
  List<String> foldersAllowed;
  HttpServer _server;

  Server(this.address, this.port, {this.backlog: 0, Map<String, Route> routes, this.extensionsAllowed, this.foldersAllowed}) {
    this.routes = ?routes ? routes : {};
  }

  Future<Server> start() {
    Completer completer = new Completer();
    HttpServer.bind(address, port, backlog: backlog).then((HttpServer server) {
      _server = server;
      var router = new Router(_server);

      if (extensionsAllowed != null) {
        var extensionsPattern = new UrlPattern(r'(.*)\.((' + extensionsAllowed.join(')|(') + r'))');
        router.filter(extensionsPattern, _directAccessFilter);
      }
      if (foldersAllowed != null) {
        var foldersPattern = new UrlPattern(r'((' + foldersAllowed.join(')|(') + '))/(.*)');
        router.filter(foldersPattern, _directAccessFilter);
      }

      routes.forEach((var key, Route route) {
        router.serve(route.urlPattern, method: route.method).listen((request) {
          _dispatch(route, request);
        });
      });
      completer.complete(this);
    });
    return completer.future;
  }

  void stop() {
    _server.close();
  }

  Future<bool> _directAccessFilter(HttpRequest request) {
    final File file = new File('.' + request.uri.path);
    return file.exists().then((bool found) {
      if (found) {
        file.fullPath().then((String fullPath) {
          file.openRead()
          .pipe(request.response)
          .catchError((e) { });
        });
        return false;
      } else {
        return true;
      }
    });
  }

  Future<bool> _folderFilter(HttpRequest request) {
    final File file = new File('.' + request.uri.path);
    return file.exists().then((bool found) {
      if (found) {
        file.fullPath().then((String fullPath) {
          file.openRead()
          .pipe(request.response)
          .catchError((e) { });
        });
        return false;
      } else {
        return true;
      }
    });
  }

  Map<String, String> _handleSegments(List<String> groups, Iterable<Segment> segments) {
    Map<String, String> handle = {};
    for(Segment segment in segments) {
      var value;
      if (segment.required) {
        if (segment.index >= groups.length) {
          throw new RequiredSegmentException('Missing required segment ${segment.name}');
        } else {
          value = groups[segment.index];
        }
      } else {
        if (segment.index == null) {
          value = segment.defaultValue;
        } else {
          if (groups[segment.index] == null) {
            value = segment.defaultValue;
          } else {
            value = groups[segment.index];
          }
        }
      }
      handle[segment.name] = value;
    }
    return handle;
  }

  _dispatch(Route route, HttpRequest request) {
    var groups = route.urlPattern.parse(request.uri.path);
    var segments = _handleSegments(groups, route.segments.values);
    String library = segments['library'];
    String controller = segments['controller'];

    var libraryMirror = findLibrary(library);
    if (libraryMirror == null) {
      send404(request);
    } else {
      var classMirror = findClass(controller, libraryMirror);
      if (classMirror == null) {
        send404(request);
      } else {
        if (subclassOf(classMirror, Controller)) {
          classMirror.newInstance(new Symbol(''), [request, segments]);
        } else {
          send404(request);
        }
      }
    }
  }
}

class ServerException extends DartistException {
  const ServerException(String message) : super(message);
}

class RequiredSegmentException extends ServerException {
  const RequiredSegmentException(String message) : super(message);
}