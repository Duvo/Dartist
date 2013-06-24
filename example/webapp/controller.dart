part of example;

class Index extends Controller {

  Index(connect, parameters) : super(connect, parameters);

  index() {
    Map context = {
                   'title': 'Dart example',
                   'options': ['option 1', 'option 2', 'option 3']
    };
    connect.response.write(renderMustache(connect.server.homeDir.toString() + '/webapp/views/index.html', context));
  }
}

class Api extends Controller {

  Api(request, parameters) : super(request, parameters);

  Map<String, String> users = {
                               'bob': 'Bob',
                               'john': 'John',
                               'author': 'Duvo'
  };

  before() {
    connect.response.headers.set(HttpHeaders.CONTENT_TYPE, 'application/json; charset=utf8');
  }

  user() {
    var id = parameters['id'];
    if (id != null) {
      if (users.containsKey(id)) {
        connect.response.write(users[id]);
      } else {
        connect.response.write('User $id dosen\'t exist');
      }
    } else {
      connect.response.write(users.toString());
    }
  }
}