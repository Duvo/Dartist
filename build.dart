import 'dart:io';
import 'package:args/args.dart';
import 'package:unittest/vm_config.dart';

main() {
  if (false) {
    var args = new List.from(new Options().arguments);
    var parser = new ArgParser();
    parser.addOption('removed');
    parser.addOption('changed');
    parser.addFlag('full');
    parser.addFlag('machine');
    var results = parser.parse(args);
    if (results['changed'] != 'tests.txt') {
      Process.run('/home/beemoov/Eclipse/dart-sdk/bin/dart', ['--checked', 'test/full_test.dart']).then((ProcessResult results) {
        if (results.exitCode == 0) {
          print('BUILD SUCCESSFUL!');
        } else {
          print(results.stdout);
        }
        exit(1);
      });
    }
  }
}