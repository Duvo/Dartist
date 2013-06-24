library mirrortools;

import 'dart:mirrors';

/**
 * First-level method [findLibrary].
 */
findLibrary(String library, {caseSensitive: false}) {
  if (library == null) {
    return null;
  } else {
    if (caseSensitive) {
      Iterable libraries = currentMirrorSystem().findLibrary(new Symbol(library));
      return libraries.isEmpty ? null : libraries.first;
    } else {
      for (LibraryMirror mirror in currentMirrorSystem().libraries.values) {
        if (MirrorSystem.getName(mirror.simpleName).toLowerCase() == library.toLowerCase()) {
          return mirror;
        }
      }
    }
  }
}

/**
 * First-level method [findClass].
 */
findClass(String className, LibraryMirror libraryMirror, {caseSensitive: false}) {
  if (caseSensitive) {
    return libraryMirror.classes[new Symbol(className)];
  } else {
    for (ClassMirror classMirror in libraryMirror.classes.values) {
      if (MirrorSystem.getName(classMirror.simpleName).toLowerCase() == className.toLowerCase()) {
        return classMirror;
      }
    }
  }
}

/**
 * First-level method [subclassOf].
 */
subclassOf(ClassMirror subclassMirror, Type superclass) {
  ClassMirror objectMirror = reflectClass(Object);
  ClassMirror superclassMirror = reflectClass(superclass);
  ClassMirror currentMirror = subclassMirror;
  while(currentMirror.qualifiedName != objectMirror.qualifiedName) {
    if (currentMirror.qualifiedName == superclassMirror.qualifiedName) {
      return true;
    }
    currentMirror = currentMirror.superclass;
  }
  return false;
}

/**
 * First-level method [mappify].
 */
dynamic mappify(dynamic object) {
  List seen = [];

  void checkCycle(final object) {
    for (var item in seen) {
      if (identical(item, object)) {
        throw new MapperCyclicException(object);
      }
    }
    seen.add(object);
  }

  dynamic mapFromObject(dynamic object) {
    if (object is num || object is String || object is bool || object == null) {
      return object;
    }else if (object is Map) {
      checkCycle(object);
      Map map = {};
      object.forEach((key, value) {
        map[key.toString()] = mapFromObject(value);
      });
      seen.remove(object);
      return map;
    } else if (object is Iterable) {
      checkCycle(object);
      var tmp = new List.generate(object.length, (i) => mapFromObject(object[i]), growable: false);
      seen.remove(object);
      return tmp;
    } else {
      checkCycle(object);
      Map map = {};
      InstanceMirror instanceMirror = reflect(object);
      ClassMirror classMirror = instanceMirror.type;
      for(Symbol key in classMirror.variables.keys) {
        map[MirrorSystem.getName(key)] = mapFromObject(instanceMirror.getField(key).reflectee);
      }
      for(Symbol key in classMirror.getters.keys) {
        map[MirrorSystem.getName(key)] = mapFromObject(instanceMirror.getField(key).reflectee);
      }
      seen.remove(object);
      return map;
    }
  }

  return mapFromObject(object);
}

/**
 * Class [MapperCyclicException].
 */
class MapperCyclicException implements Exception {
  final Object object;
  const MapperCyclicException(this.object);
  String toString() => '$runtimeType: Cyclic error in mappify ${object.runtimeType}.';
}
