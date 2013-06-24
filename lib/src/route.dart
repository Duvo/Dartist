part of dartist;

/**
 * Class [Segment].
 */
class Segment {
  String name;
  bool required;
  String defaultValue;

  Segment(this.name, {this.required: false, this.defaultValue});
}

/**
 * Class [Route].
 */
class Route {

  static const String LIBRARY = 'library';
  static const String CONTROLLER = 'controller';
  static const String ACTION = 'action';

  static const String SEGMENT = r'<\w+>';

  Map<String, Segment> segments = {};
  String uri;
  String urlPattern;
  String method;

  Route(this.uri, {this.method, Map<String, String> defaultValues}) {
    defaultValues = ?defaultValues ? defaultValues : {};
    List baseSegments = [LIBRARY, CONTROLLER, ACTION];

    // Check if parenthesis are correct.
    var nbParenthesis = new RegExp(r'\(').allMatches(uri).length;
    if (new RegExp(r'\)').allMatches(uri).length != nbParenthesis) {
      throw new ParenthesisException('URI must have the same number of opening and closing parenthesis.');
    }
    String end = new List.filled(nbParenthesis, ')').join('');
    if (!uri.endsWith(end)) {
      throw new ParenthesisException('The $nbParenthesis closing parenthesis must be in the end of the URI.');
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
        segments[segment] = new Segment(segment, required: required, defaultValue: defaultValues[segment]);
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
        throw new BaseSegmentException('Segment $key is needed.');
      } else {
        if (segment.required == false && segment.defaultValue == null) {
          throw new DefaultValueException('Segment $key needs a default value.');
        }
      }
    }

    // Get the URL pattern from the URI.
    urlPattern = uri.replaceAll(')', ')?');
    for(Segment segment in segments.values) {
      urlPattern = urlPattern.replaceAll('<${segment.name}>', '(' + segment.name + r':\w+)');
    }
    if (method != null) {
      urlPattern = '${method.toLowerCase()}:$urlPattern';
    }
  }
}

/**
 * Class [RouteException].
 */
class RouteException extends DartistException {
  const RouteException(String message) : super(message);
}

/**
 * Class [DefaultValueException].
 */
class DefaultValueException extends RouteException {
  const DefaultValueException(String message) : super(message);
}


/**
 * Class [BaseSegmentException].
 */
class BaseSegmentException extends RouteException {
  const BaseSegmentException(String message) : super(message);
}

/**
 * Class [ParenthesisException].
 */
class ParenthesisException extends RouteException {
  const ParenthesisException(String message) : super(message);
}