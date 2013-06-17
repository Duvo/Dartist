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
    InstanceMirror instance = reflect(this);
    instance.invoke(new Symbol(action), []);
  }

  after() {}
}