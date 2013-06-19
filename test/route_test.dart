import 'package:unittest/unittest.dart';
import 'package:dartist/dartist.dart';

main() {
  final defaultLibrary = 'defaultLibrary';
  final defaultController = 'defaultController';
  final defaultAction = 'defaultAction';
  final defaultID = 'defaultID';

  test('constructor', () {
    final uri = '/api/<library>/<controller>-<action>';
    Route route1 = new Route(uri);
    expect(route1.method, isNull);
    expect(route1.uri, uri);

    Route route2 = new Route(uri, method:'GET');
    expect(route2.method, 'GET');
    expect(route2.uri, uri);
  });

  group('works', () {
    test('without optionnal', () {
      Route route = new Route('/api/<library>/<controller>-<action>');
      expect(route.urlPattern.pattern, r'(/api/(\w+)/(\w+)-(\w+))');

      expect(route.segments['library'].required, isTrue);
      expect(route.segments['library'].defaultValue, isNull);
      expect(route.segments['library'].index, 1);

      expect(route.segments['controller'].required, isTrue);
      expect(route.segments['controller'].defaultValue, isNull);
      expect(route.segments['controller'].index, 2);

      expect(route.segments['action'].required, isTrue);
      expect(route.segments['action'].defaultValue, isNull);
      expect(route.segments['action'].index, 3);
    });

    test('with additional parameter', () {
      Route route = new Route('/api/<library>/<controller>-<action>/<id>');
      expect(route.urlPattern.pattern, r'(/api/(\w+)/(\w+)-(\w+)/(\w+))');

      expect(route.segments['id'].required, isTrue);
      expect(route.segments['id'].defaultValue, isNull);
      expect(route.segments['id'].index, 4);
    });

    test('with optionnals', () {
      Route route = new Route('/api/<library>(/<controller>-<action>)',
          defaultValues: {
            'controller' : defaultController,
            'action' : defaultAction
          });
      expect(route.urlPattern.pattern, r'(/api/(\w+)(/(\w+)-(\w+))?)');

      expect(route.segments['library'].required, isTrue);
      expect(route.segments['library'].defaultValue, isNull);
      expect(route.segments['library'].index, 1);

      expect(route.segments['controller'].required, isFalse);
      expect(route.segments['controller'].defaultValue, defaultController);
      expect(route.segments['controller'].index, 3);

      expect(route.segments['action'].required, isFalse);
      expect(route.segments['action'].defaultValue, defaultAction);
      expect(route.segments['action'].index, 4);
    });

    test('with additional optionnal parameter', () {
      Route route = new Route('/api/<library>(/<controller>-<action>(/<id>))',
          defaultValues: {
            'controller' : defaultController,
            'action' : defaultAction,
            'id' : defaultID
          });
      expect(route.urlPattern.pattern, r'(/api/(\w+)(/(\w+)-(\w+)(/(\w+))?)?)');

      expect(route.segments['id'].required, isFalse);
      expect(route.segments['id'].defaultValue, defaultID);
      expect(route.segments['id'].index, 6);
    });

    test('with full optionnals', () {
      Route route = new Route('(/api/<library>(/<controller>-<action>))',
          defaultValues: {
            'library' : defaultLibrary,
            'controller' : defaultController,
            'action' : defaultAction
          });
      expect(route.urlPattern.pattern, r'((/api/(\w+)(/(\w+)-(\w+))?)?)');

      expect(route.segments['library'].required, isFalse);
      expect(route.segments['library'].defaultValue, defaultLibrary);
      expect(route.segments['library'].index, 2);

      expect(route.segments['controller'].required, isFalse);
      expect(route.segments['controller'].defaultValue, defaultController);
      expect(route.segments['controller'].index, 4);

      expect(route.segments['action'].required, isFalse);
      expect(route.segments['action'].defaultValue, defaultAction);
      expect(route.segments['action'].index, 5);
    });

    test('without needed segment', () {
      Route route = new Route('/api/<controller>-<action>',
          defaultValues: {
            'library' : 'defaultLibrary'
          });
      expect(route.urlPattern.pattern, r'(/api/(\w+)-(\w+))');

      expect(route.segments['library'].required, isFalse);
      expect(route.segments['library'].defaultValue, defaultLibrary);
      expect(route.segments['library'].index, isNull);

      expect(route.segments['controller'].required, isTrue);
      expect(route.segments['controller'].defaultValue, isNull);
      expect(route.segments['controller'].index, 1);

      expect(route.segments['action'].required, isTrue);
      expect(route.segments['action'].defaultValue, isNull);
      expect(route.segments['action'].index, 2);
    });
  });

  group('exception', () {
    test('default value exception', () {
      expect(() => new Route('/api/<library>(/<controller>-<action>)'),
          throwsA(new isInstanceOf<DefaultValueException>())
      );
      expect(() => new Route('/api/<controller>-<action>'),
          throwsA(new isInstanceOf<BaseSegmentException>())
      );
    });

    test('parenthesis number exception', () {
      expect(() => new Route('/api/<library>(/<controller>-<action>'),
          throwsA(new isInstanceOf<ParenthesisException>())
      );
    });

    test('closing parenthesis eception', () {
      expect(() => new Route('/api/<library>(/<controller>)-<action>'),
          throwsA(new isInstanceOf<ParenthesisException>())
      );
    });
  });
}