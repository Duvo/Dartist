part of dartist;

class Segment {
  String name;
  bool required;
  int index;
  String defaultValue;

  Segment(this.name, {this.index, this.required: false, this.defaultValue}) {
    if (!required && defaultValue == null) {
      throw 'Segment $name needs a default value.';
    }
  }
  
  String toString()  {
    return '\n\tindex: $index\n\trequired: $required\n\tdefaultValue: $defaultValue\n';
  }
}

class Route {

  static const String LIBRARY = 'library';
  static const String CONTROLLER = 'controller';
  static const String ACTION = 'action';

  static const String SEGMENT = r'<\w+>';
  
  Map<String, Segment> segments = {};
  String uri;
  UrlPattern urlPattern;
  String method;

  Route(this.uri, {this.method, Map<String, String> defaultValues}) {    
    defaultValues = ?defaultValues ? defaultValues : {};
    List baseSegments = [LIBRARY, CONTROLLER, ACTION];
    
    // Check if parenthesis are correct.
    var nbParenthesis = new RegExp(r'\(').allMatches(uri).length;
    if (new RegExp(r'\)').allMatches(uri).length != nbParenthesis) {
      throw 'URI must have the same number of opening and closing parenthesis.';
    }
    String end = new List.filled(nbParenthesis, ')').join('');
    if (!uri.endsWith(end)) {
      throw 'The $nbParenthesis closing parenthesis must be in the end of the URI.';
    }
    
    // Handle URI to extract segments.
    RegExp regExp = new RegExp(r'(\()|(' + SEGMENT + ')');
    Iterable matches = regExp.allMatches(uri);
    var required = true;
    for (var i = 0; i < matches.length; i++) {
      String match = matches.elementAt(i).group(0);
      var length = match.length;
      if (length > 1) {
        var segment = match.substring(1, length-1);
        segments[segment] = new Segment(segment, index: i+1, required: required==0, defaultValue: defaultValues[segment]);
      } else {
        required = false;
      }
    }
    
    // Check if there is all the needed values.
    defaultValues.forEach((String key, String value) {
      segments.putIfAbsent(key, () => new Segment(key, defaultValue: value));
    });
    
    // Check if there is all the base segments.
    for (var key in baseSegments) {
      Segment segment = segments[key];
      if (segment == null) {
        throw 'Segment $key is needed.';
      }
    }
    
    // Get the URL pattern from the URI.
    String expression = uri.replaceAll(')', ')?');
    regExp = new RegExp(SEGMENT);
    expression = expression.replaceAll(regExp, '(\w+)');
    urlPattern = new UrlPattern(expression);
    print(uri);
    print(expression);
    print(segments);
  }
}

main() {
  new Route('/api(/<library>(/<controller>-<action>))', defaultValues: {
    'library': 'controller',
    'controller': 'mycontroller',
    'action': 'index'
  });
}