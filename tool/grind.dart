import 'dart:io';
import 'package:grinder/grinder.dart';


main(args) => grind(args);

@Task()
Future test() {
  var tr = new TestRunner();
  tr.test(file: 'test/withDartIO.dart');
  tr.test(file: 'test/withPackageFile.dart');
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