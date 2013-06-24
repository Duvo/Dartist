part of dartist;

class Server {

  StreamServer server;

  Server({List<Route> routes,
    Map errorMapping, Map<String, RequestFilter> filterMapping,
    String homeDir, LoggingConfigurer loggingConfigurer, bool futureOnly: false}) {

    Map<String, dynamic> uriMapping = {};

    for(Route route in routes) {
      uriMapping[route.urlPattern] = (HttpConnect connect) => _dispatch(route, connect);
    }

    server = new StreamServer(uriMapping: uriMapping,
        errorMapping: errorMapping,
        filterMapping: filterMapping,
        homeDir: homeDir,
        loggingConfigurer: loggingConfigurer,
        futureOnly: futureOnly);
  }

  Future _dispatch(Route route, HttpConnect connect) {
    Map<String, dynamic> parameters = {};
    for(Segment segment in route.segments.values) {
      var value = connect.dataset[segment.name];
      parameters[segment.name] = value == null ? segment.defaultValue : value;
    }

    String library = parameters['library'];
    String controller = parameters['controller'];

    LibraryMirror libraryMirror = mirror.findLibrary(library);
    if (libraryMirror == null) {
      throw new Http404();
    } else {
      ClassMirror classMirror = mirror.findClass(controller, libraryMirror);
      if (classMirror == null) {
        throw new Http404();
      } else {
        var instance = classMirror.newInstance(new Symbol(''), [connect, parameters]).reflectee;
        if (instance is Controller) {
          return instance.execute();
        } else {
          throw new Http404();
        }
      }
    }
  }
}

  /**
   * Class [ServerException].
   */
  class ServerException extends DartistException {
    const ServerException(String message) : super(message);
  }

  /**
   * Class [RequiredSegmentException].
   */
  class RequiredSegmentException extends ServerException {
    const RequiredSegmentException(String message) : super(message);
  }