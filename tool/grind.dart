import 'dart:async';
import 'dart:io';
import 'package:grinder/grinder.dart';


main(args) => grind(args);

@Task()
Future test() async {
  var tr = new TestRunner();
  tr.test(files: 'test/all_test.dart');
}

@Task()
Future doc() async {
  ProcessResult results = await Process.run('dartdoc', []);
  log(results.stdout);
}

@DefaultTask()
@Depends(test)
void build() {
  Pub.build();
}

@Task()
void clean() => defaultClean();