library mirrortools;

import 'dart:mirrors';

/**
 * First-level method [findLibrary].
 */
findLibrary(String library, {caseSensitive: false}) {
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
 * First-level method [mapFromObject].
 */
mapFromObject(dynamic object) {
  if (object == null || object is String) {
    return object;
  }else if (object is Map) {
    Map map = {};
    for (var key in object.keys) {
      String tmpKey;
      if (key is int) {
        tmpKey = key.toString();
      } else if (key is String) {
        tmpKey = key;
      } else {
        throw 'Map keys must be int or String.';
      }
      map[tmpKey] = mapFromObject(object[key]);
    }
    return map;
  } else if (object is Iterable) {
    var length = object.length;
    return new List.generate(length, (i) => mapFromObject(object[i]), growable: false);
  } else {
    Map map = {};
    InstanceMirror instanceMirror = reflect(object);
    ClassMirror classMirror = instanceMirror.type;
    for(Symbol key in classMirror.variables.keys) {
      map[MirrorSystem.getName(key)] = mapFromObject(instanceMirror.getField(key).reflectee);
    }
    for(Symbol key in classMirror.getters.keys) {
      map[MirrorSystem.getName(key)] = mapFromObject(instanceMirror.getField(key).reflectee);
    }
    return map;
  }
}