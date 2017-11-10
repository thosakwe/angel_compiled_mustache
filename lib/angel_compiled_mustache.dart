library angel_compiled_mustache;

import 'dart:async';
import 'dart:io';
import 'package:angel_framework/angel_framework.dart';
import 'package:compiled_mustache/compiled_mustache.dart' show compile, CompiledTemplate;
import 'package:path/path.dart' as path;

part 'src/cache_controller.dart';

compiled_mustache(Directory viewsDirectory,
    {String fileExtension: '.mustache', String layoutsPath: './layouts', String pagesPath: './pages', String partialsPath: './partials', String defaultLayout: 'main'}) {
  
  Directory layoutsDirectory  = new Directory(path.join(path.fromUri(viewsDirectory.uri), layoutsPath));
  Directory pagesDirectory    = new Directory(path.join(path.fromUri(viewsDirectory.uri), pagesPath));
  Directory partialsDirectory = new Directory(path.join(path.fromUri(viewsDirectory.uri), partialsPath));
  
  _CacheController cache = new _CacheController(fileExtension, layoutsDirectory, pagesDirectory, partialsDirectory);

  return (Angel app) async {
    app.viewGenerator = (String name, [Map data]) async {
      var partialProvider = (String n) => cache.get_partial_sync(n, app);
      
      var cntxt = data ?? {};
      
      var layout = await cache.get_layout(cntxt['layout'] ?? defaultLayout, app);
      var page   = await cache.get_page(name, app);
      
      cntxt['body'] = page.renderWithPartialsProvider(cntxt, partialProvider);
      return layout.renderWithPartialsProvider(cntxt, partialProvider);
    };
  };
}