part of dartist;

class Parameter {
  bool required;
  int index;
  String defaultValue;

  Parameter({this.required, this.index, this.defaultValue});
}

class Route {

  static const String LIBRARY = 'library';
  static const String CONTROLLER = 'controller';
  static const String ACTION = 'action';

  static const String SEGMENT = r'a-zA-Z0-9';

  UrlPattern urlPattern;
  String method;
  Map<String, String> defaultParameters;

  Map<String, ClassMirror> classes = {};

  Route(String uri, {this.method, defaultlibrary, defaultController, defaultAction}) {
    compile(uri);
  }

  compile(String uri) {
    String expression = uri.replaceAll(')', ')?');
    RegExp regexp = new RegExp(r'<[' + SEGMENT + ']+>');
    expression = expression.replaceAll(regexp, '([a-z]+)');
    print(expression);
    RegExp finalReg = new RegExp(expression);
    Match match = finalReg.firstMatch('/api/library/controller-action');
    for (var i = 0; i <= match.groupCount; i++) {
      print(i.toString() + ' - ' + match.group(i));
    }
  }
}

main() {
  new Route('/api(/<library>(/<controller>-<action>))');
}