part of dartist;

/**
 * The [Controller] is the processing part of the [Server].
 * The subclasses have to call the super constructor.
 *
 * The [Controller] must be routed to the [Server] with a [Route].
 * For ease of use, the [Controller] must have a simple library name. It will be
 * referenced by the **<library>** [Segment] in the [Route]. The class name of
 * this [Controller] is important too, it will be referenced by the
 * **<controller>** [Segment]. And finally, functions names are also important,
 * because the **<action>** [Segment] can be used.
 *
 *      library mylibrary;
 *      import package:dartist/dartist.dart;
 *
 *      class MyController extends Controller {
 *        MyController(connect, parameters) : super(connect, parameters);
 *
 *        myAction() {
 *          this.connect.response.write('Hello world!');
 *        }
 *      }
 *
 * All of these [Segment]s are not case sensitive, but they are required. They
 * must be present in the route either in the URL or in the defaults values. For
 * example with the [Route]:
 *
 *      new Route('/<library>/<controller>/<action>');
 *
 * Our **<action>** can be reached by the URL:
 *
 *      /mylibrary/mycontroller/myaction?param=foobar
 *
 * Or with defaults values:
 *
 *      new Route('/api/<action>', defaultValues: {
 *                'library': mylibrary
 *                'controller': mycontroller
 *      });
 *
 * URL will be:
 *
 *      /api/myaction?param=foobar
 *
 * The [Controller] knows the [HttpConnect] that called it. Thus, it can
 * access to all [HttpConnect] information, like query parameters or
 * posted data. For example:
 *
 *      this.connect.request.uri.queryParameters['param'];
 */
abstract class Controller {

  /**
   * The [HttpConnect] that called this [Controller].
   */
  HttpConnect connect;

  /**
   * The [Map] that contains [Segment] values.
   */
  Map<String, String> parameters;

  /**
   * The [Map] that contains parsed fields of the [connect.request] content.
   * It is used for cache.
   */
  Map _fields;

  /**
   * Create a [Controller] with the given [connect] and [parameters] that
   * contains a [Map] of [Segment]s values.
   */
  Controller(this.connect, this.parameters);

  /**
   * Calls [before], then [runAction], depending on the **<action>** [parameters]
   * and finally calls [after].
   */
  Future execute() {
    return new Future.sync(() => before())
    .then((_) => new Future.sync(() => runAction()))
    .then((_) => new Future.sync(() => after()));
  }

  /**
   * The function executed before [runAction].
   *
   * If the return is a [Future] the [Controller] will wait until
   * the returned [Future] completes. Otherwise the [Controller] simply runs the
   * [runAction] afterwards.
   */
  dynamic before() {}

  /**
   * The main function of the [Controller]. It handles the **<action>** from
   * [parameters], then checks and calls the correct **<action>**.
   *
   * Return the value returned by the called **<action>**, or send a 404 error
   * if this **<action>** doesn't exist, then return [:null:].
   */
  dynamic runAction() {
    String action = parameters['action'];
    InstanceMirror instanceMirror = reflect(this);
    ClassMirror classMirror = instanceMirror.type;
    for(Symbol symbol in classMirror.methods.keys) {
      MethodMirror methodMirror = classMirror.methods[symbol];
      if (methodMirror.isRegularMethod && !methodMirror.isAbstract) {
        if (action.toLowerCase() == MirrorSystem.getName(symbol).toLowerCase()) {
          try {
            return instanceMirror.invoke(symbol, []).reflectee;
          } on MirroredUncaughtExceptionError catch(e) {
            throw e.exception_mirror.reflectee;
          }
        }
      }
    }
    throw new Http404();
  }

  /**
   * The function executed after [runAction].
   *
   * If the return is a [Future] the [Controller] will wait until
   * the returned future completes. Otherwise the [Controller] directly close
   * the [connect.response].
   */
  dynamic after() {}

  /**
   * Parse the content of the [connect.request], and extract a [Map] of its
   * values.
   *
   * This [Map] is stored in the [Controller] instance, so, for the next call,
   * the values will be directly retrieved from its attribut, and not parsed
   * from the [connect.request].
   *
   * Return a [Future] containing the [Map] of the [connect.request] content.
   */
  Future<Map<String, String>> getFields() {
    if (_fields == null) {
      return connect.request.single.then((data) {
        _fields = Uri.splitQueryString(new String.fromCharCodes(data));
        return _fields;
      });
    } else {
      return new Future.value(_fields);
    }
  }

  /**
   * Load the content of the [File] targeted by the [filepath].
   *
   * Return the [String] content of the [File], or [:null:] if the
   * [File] doesn't exist.
   */
  String loadFile(String filepath) {
    final File file = new File(filepath);
    if (file.existsSync()) {
      return file.readAsStringSync();
    }
  }

  /**
   * Render the mustache template targeted by the [filepath] with the [context]
   * given.
   *
   * Return the result [String] generated, or [:null:] if the [File] doesn't
   * exist.
   */
  String renderMustache(String filepath, dynamic context) {
    var source = loadFile(filepath);
    if (source == null) {
      return null;
    } else {
      return mustache.render(source, context);
    }
  }
}