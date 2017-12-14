/// An Angel interface with [compiled_mustache](https://pub.dartlang.org/packages/compiled_mustache).

library angel_compiled_mustache;

import 'dart:async';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:compiled_mustache/compiled_mustache.dart'
    show compile, CompiledTemplate;
import 'package:path/path.dart' as path;

part 'src/cache_controller.dart';

/// Returns an [AngelConfigurer] that sets the app's [viewGenerator] to use mustache.
compiled_mustache(Directory viewsDirectory,
    {String fileExtension: '.mustache',
    String defaultLayout: 'main',
    String layoutsPath: './layouts',
    String pagesPath: './pages',
    String partialsPath: './partials',
    FileSystem fileSystem: const LocalFileSystem()}) {
  Directory layoutsDirectory = fileSystem
      .directory(path.join(path.fromUri(viewsDirectory.uri), layoutsPath));
  Directory pagesDirectory = fileSystem
      .directory(path.join(path.fromUri(viewsDirectory.uri), pagesPath));
  Directory partialsDirectory = fileSystem
      .directory(path.join(path.fromUri(viewsDirectory.uri), partialsPath));

  _CacheController cache = new _CacheController(fileExtension, layoutsDirectory,
      pagesDirectory, partialsDirectory, fileSystem);

  return (Angel app) async {
    app.viewGenerator = (String name, [Map data]) async {
      var partialProvider = (String n) => cache.getPartialSync(n, app);

      var cntxt = data ?? {};

      var layout =
          await cache.getLayout(cntxt['layout'] ?? defaultLayout, app);
      var page = await cache.getPage(name, app);

      cntxt['body'] = page.renderWithPartialProvider(cntxt, partialProvider);
      return layout.renderWithPartialProvider(cntxt, partialProvider);
    };
  };
}
