library test.mirrortools;

import 'package:unittest/unittest.dart';
import '../lib/mirrortools.dart';
import 'dart:mirrors';

class Foo {
  List<String> list = ['a', 'b', 'c'];
}
class Bar extends Foo {}

class Foobar {
  String string = 'string';
  String get getter => 'getter';
  Foo foo = new Foo();
  Map map = {'a':'a', 'b':'b'};
}

main() {

  group('find library', () {
    test('with case', () {
      var library = MirrorSystem.getName(currentMirrorSystem().isolate.rootLibrary.simpleName);
      expect(findLibrary(library, caseSensitive: true), isNotNull);
    });

    test('with wrong case', () {
      var library = MirrorSystem.getName(currentMirrorSystem().isolate.rootLibrary.simpleName);
      expect(findLibrary(library.toUpperCase(), caseSensitive: true), isNull);
    });

    test('without case', () {
      var library = MirrorSystem.getName(currentMirrorSystem().isolate.rootLibrary.simpleName);
      expect(findLibrary(library.toUpperCase()), isNotNull);
    });
  });

  group('find class', () {
    test(' with case', () {
      var library = currentMirrorSystem().isolate.rootLibrary;
      expect(findClass('Foo', library, caseSensitive: true), isNotNull);
    });

    test('with wrong case', () {
      var library = currentMirrorSystem().isolate.rootLibrary;
      expect(findClass('foo', library, caseSensitive: true), isNull);
    });

    test('without case', () {
      var library = currentMirrorSystem().isolate.rootLibrary;
      expect(findClass('fOO', library), isNotNull);
    });
  });

  group('subclass of', () {
    test('true', () {
      var subclass = reflectClass(Bar);
      expect(subclassOf(subclass, Foo), isTrue);
    });

    test('false', () {
      var subclass = reflectClass(Foo);
      expect(subclassOf(subclass, Bar), isFalse);
    });

    test('itself', () {
      var subclass = reflectClass(Foo);
      expect(subclassOf(subclass, Foo), isTrue);
    });
  });

  group('map from object', () {
    test('full', () {
      Map<String, dynamic> map = mapFromObject(new Foobar());
      expect(map.toString(), '{map: {a: a, b: b}, string: string, foo: {list: [a, b, c]}, getter: getter}');
    });
  });
}