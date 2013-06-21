import 'package:dartist/dartist.dart';

final Map<String, Route> routes = {
      'index' : new Route('/', defaultValues: {
          'library': 'example',
          'controller': 'index',
          'action': 'index'
      }),
          'default' : new Route('/<controller>/<action>(/<id>)', defaultValues: {
          'library': 'example'
      })
};

final List<String> folders = ['/public', '/packages'];