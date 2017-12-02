import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_compiled_mustache/angel_compiled_mustache.dart';

Future main() async {
  Angel angel = new Angel();
  await angel.configure(compiled_mustache(new Directory('views')));
  
  // This will render the file 'views/pages/hello.mustache'
  // using the layout 'views/layouts/main.mustache'
  // with the context of 'name' = 'world'
  var rendered = await angel.viewGenerator('hello', {'name': 'world'});
}