part of dartist;

class Route {
  UrlPattern urlPattern;
  String method;
  String library;

  Map<String, ClassMirror> classes = {};

  Route(String pattern, this.library, {this.method}) {
    urlPattern = new UrlPattern(r'/(.+)/(.+)/(.+)');
  }
}