part of dartist;

abstract class Controller {

  HttpRequest request;
  String action;
  Map<String, String> parameters;

  Controller(this.request, this.action, this.parameters) {
    before()
    .then((_) => execute())
    .then((_) => after())
    .whenComplete(() => request.response.close());
  }

  Future before() => new Future.value();

  Future execute() {
    InstanceMirror instanceMirror = reflect(this);
    ClassMirror classMirror = instanceMirror.type;
    for(Symbol symbol in classMirror.methods.keys) {
      MethodMirror methodMirror = classMirror.methods[symbol];
      if (methodMirror.isRegularMethod && !methodMirror.isAbstract) {
        if (action == MirrorSystem.getName(symbol).toLowerCase()) {
          return instanceMirror.invoke(symbol, []).reflectee;
        }
      }
    }
    send404(request);
    return new Future.value();
  }

  Future after() => new Future.value();
}