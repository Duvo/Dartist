part of dartist;

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