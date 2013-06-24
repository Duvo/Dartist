import 'package:dartist/dartist.dart';

final List<Route> routes = [
      new Route('/', defaultValues: {
          'library': 'example',
          'controller': 'index',
          'action': 'index'
      }),
      new Route('/<controller>/<action>(/<id>)', defaultValues: {
          'library': 'example'
      })
];