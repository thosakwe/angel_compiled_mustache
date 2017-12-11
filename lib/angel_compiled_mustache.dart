/// An Angel interface with [compiled_mustache](https://pub.dartlang.org/packages/compiled_mustache).

library angel_compiled_mustache;

import 'dart:async';
import 'dart:io' as io;
import 'package:file/file.dart' as pf;
import 'package:file/local.dart' as pfl;
import 'package:angel_framework/angel_framework.dart';
import 'package:compiled_mustache/compiled_mustache.dart' show compile, CompiledTemplate;
import 'package:path/path.dart' as path;

part 'src/cache_controller.dart';

/// Returns an [AngelConfigurer] that sets the app's [viewGenerator] to use mustache.
compiled_mustache(io.Directory viewsDirectory,
    {String fileExtension: '.mustache', String defaultLayout: 'main',
     String layoutsPath: './layouts', String pagesPath: './pages', String partialsPath: './partials', pf.FileSystem fileSystem: const pfl.LocalFileSystem()}) {
  
  pf.Directory layoutsDirectory  = fileSystem.directory(path.join(path.fromUri(viewsDirectory.uri), layoutsPath));
  pf.Directory pagesDirectory    = fileSystem.directory(path.join(path.fromUri(viewsDirectory.uri), pagesPath));
  pf.Directory partialsDirectory = fileSystem.directory(path.join(path.fromUri(viewsDirectory.uri), partialsPath));
  
  _CacheController cache = new _CacheController(fileExtension, layoutsDirectory, pagesDirectory, partialsDirectory, fileSystem);

  return (Angel app) async {
    app.viewGenerator = (String name, [Map data]) async {
      var partialProvider = (String n) => cache.get_partial_sync(n, app);
      
      var cntxt = data ?? {};
      
      var layout = await cache.get_layout(cntxt['layout'] ?? defaultLayout, app);
      var page   = await cache.get_page(name, app);
      
      cntxt['body'] = page.renderWithPartialProvider(cntxt, partialProvider);
      return layout.renderWithPartialProvider(cntxt, partialProvider);
    };
  };
}