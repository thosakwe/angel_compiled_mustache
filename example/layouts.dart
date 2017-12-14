import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_compiled_mustache/angel_compiled_mustache.dart';
import 'package:file/local.dart';

Future main() async {
  Angel angel = new Angel();
  var fs = const LocalFileSystem();
  await angel.configure(compiled_mustache(fs.directory('views'), defaultLayout: 'home'));

  // This will render the file 'views/pages/hello.mustache'
  // using the layout 'views/layouts/main.mustache'  (uses the specified layout)
  // with the context of 'name' = 'world'
  var rendered = await angel.viewGenerator('hello', {'layout': 'main', 'name': 'world'});
  print(rendered);
}