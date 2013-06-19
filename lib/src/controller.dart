part of dartist;

abstract class Controller {

  HttpRequest request;
  String action;
  Map<String, String> parameters;

  Controller(this.request, this.action, this.parameters) {
    before();
    execute();
    after();
    request.response.close();
  }

  before() {}

  execute() {
    bool found = false;
    InstanceMirror instanceMirror = reflect(this);
    ClassMirror classMirror = instanceMirror.type;
    for(Symbol symbol in classMirror.methods.keys) {
      MethodMirror methodMirror = classMirror.methods[symbol];
      if (methodMirror.isRegularMethod && !methodMirror.isAbstract) {
        if (action == MirrorSystem.getName(symbol).toLowerCase()) {
          instanceMirror.invoke(symbol, []);
          found = true;
          break;
        }
      }
    }
    if (!found) {
      send404(request);
    }
  }

  after() {}
}