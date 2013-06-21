part of dartist;

abstract class Controller {

  HttpRequest request;
  String action;
  Map<String, String> parameters;
  Map _fields;

  Controller(this.request, this.action, this.parameters) {
    new Future.sync(() => before())
    .then((_) => new Future.sync(() => execute()))
    .then((_) => new Future.sync(() => after()))
    .whenComplete(() => request.response.close());
  }

  before() {}

  execute() {
    InstanceMirror instanceMirror = reflect(this);
    ClassMirror classMirror = instanceMirror.type;
    for(Symbol symbol in classMirror.methods.keys) {
      MethodMirror methodMirror = classMirror.methods[symbol];
      if (methodMirror.isRegularMethod && !methodMirror.isAbstract) {
        if (action.toLowerCase() == MirrorSystem.getName(symbol).toLowerCase()) {
          return instanceMirror.invoke(symbol, []).reflectee;
        }
      }
    }
    send404(request);
  }

  after() {}

  Future<Map<String, String>> getFields() {
    if (_fields == null) {
      return request.first.then((data) {
        _fields = Uri.splitQueryString(new String.fromCharCodes(data));
        return _fields;
      });
    } else {
      return new Future.value(_fields);
    }
  }
}