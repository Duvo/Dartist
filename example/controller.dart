part of example;

class Index extends Controller {

  Index(request, action, parameters) : super(request, action, parameters);

  index() {
    request.response.write(loadFile('views/index.html'));
  }
}

class Api extends Controller {

  Api(request, action, parameters) : super(request, action, parameters);

  Map<String, String> users = {
                               'bob': 'Bob',
                               'john': 'John',
                               'author': 'Duvo'
  };

  before() {
    request.response.headers.set(HttpHeaders.CONTENT_TYPE, 'application/json; charset=utf8');
  }

  user() {
    var id = parameters['id'];
    if (id != null) {
      if (users.containsKey(id)) {
        request.response.write(users[id]);
      } else {
        request.response.write('User $id dosen\'t exist');
      }
    } else {
      request.response.write(users.toString());
    }
  }
}