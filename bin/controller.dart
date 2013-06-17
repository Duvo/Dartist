part of dartist;

abstract class Controller {

  HttpRequest request;
  String action;
  Map<String, String> parameters;

  Controller(this.request, this.action, this.parameters) {
    before();
    execute();
    after();
  }

  before() {}

  execute() {
    InstanceMirror instanceMirror = reflect(this);
    ClassMirror classMirror = instanceMirror.type;
    MethodMirror methodMirror = classMirror.methods[new Symbol(action)];
    if (methodMirror != null && methodMirror.isRegularMethod && !methodMirror.isAbstract) {
      instanceMirror.invoke(new Symbol(action), []);
    } else {
      send404(request);
    }
  }

  after() {}
}