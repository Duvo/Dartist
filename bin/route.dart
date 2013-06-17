part of dartist;

class Parameter {
  bool required;
  int index;
  String defaultValue;

  Parameter({this.required, this.index, this.defaultValue});
}

class Route {

  const String LIBRARY = 'library';
  const String CONTROLLER = 'controller';
  const String ACTION = 'action';

  const String SEGMENT = r'a-zA-Z0-9';

  UrlPattern urlPattern;
  String method;
  Map<String, String> defaultParameters;

  Map<String, ClassMirror> classes = {};

  Route(String uri, {this.method, defaultlibrary, defaultController, defaultAction}) {
    compile(uri);

    /*defaultParameters = {
        '$LIBRARY' : defaultlibrary,
        '$CONTROLLER' : defaultController,
        '$ACTION' : defaultAction
    };

    uri = uri.replaceAll(')', ')?');

    for (var parameter in [LIBRARY, CONTROLLER, ACTION]) {
      int index = uri.indexOf('<$parameter>');
      if (index == -1) {
        if (defaultParameters[parameter] == null || defaultParameters[parameter].isEmpty) {
          throw 'Need $parameter!';
        }
      } else {
        uri = uri.replaceAll('<$parameter>', '(.+)');
      }

    }
    urlPattern = new UrlPattern(uri);*/
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

List handleNested(String string, String left, String right) {
  var leftReg = new RegExp(left);
  var rightReg = new RegExp(right);
  if (leftReg.allMatches(string).length == rightReg.allMatches(string).length) {
    return  _handleNested(string, left, right);
  } else {
    throw 'Nested error!';
  }
}

List _handleNested(String string, String left, String right) {
  List matches = [];
  var regex = new RegExp(left + r'(.*)' + right);
  var match = regex.firstMatch(string);
  if (match != null) {
    String matched = match.group(1);
    matches.add(matched);
    matches.addAll(handleNested(matched, left, right));
  }
  return matches;
}