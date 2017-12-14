part of angel_compiled_mustache;

class _CacheController {
  final String _fileExtension;
  
  final Directory _layoutsDirectory;
  final Directory _pagesDirectory;
  final Directory _partialsDirectory;
  final FileSystem _fileSystem;
  
  Map<String, CompiledTemplate> cache = {};
  
  
  _CacheController(this._fileExtension, this._layoutsDirectory, this._pagesDirectory, this._partialsDirectory, this._fileSystem);
  
  
  Future<CompiledTemplate> get_layout(String name, Angel app) async {
    return await _get_cached(name, app, 'layout');
  }
  Future<CompiledTemplate> get_page(String name, Angel app) async {
    return await _get_cached(name, app, 'page');
  }
  Future<CompiledTemplate> get_partial(String name, Angel app) async {
    return await _get_cached(name, app, 'partial', suppressError: true);
  }
  
  CompiledTemplate get_partial_sync(String name, Angel app) {
    return _get_cached_sync(name, app, 'partial', suppressError: true);
  }
  
  
  Future<CompiledTemplate> _get_cached(String name, Angel app, String type, {bool suppressError: false}) async {
    if (app.isProduction) { // Production node, cache.
      CompiledTemplate ct = cache['$type/$name'];
      if (ct == null) {
        ct = await _load_from_disk(type, name, suppressError);
        cache['$type/$name'] = ct;
      }
      return ct;
    } else { // Debug mode, always load from disk.
      return await _load_from_disk(type, name, suppressError);
    }
  }
  
  CompiledTemplate _get_cached_sync(String name, Angel app, String type, {bool suppressError: false}) {
    if (app.isProduction) { // Production node, cache.
      CompiledTemplate ct = cache['$type/$name'];
      if (ct == null) {
        ct = _load_from_disk_sync(type, name, suppressError);
        cache['$type/$name'] = ct;
      }
      return ct;
    } else { // Debug mode, always load from disk.
      return _load_from_disk_sync(type, name, suppressError);
    }
  }
  
  
  Future<CompiledTemplate> _load_from_disk(String type, String name, bool suppressError) async {
    if (path.extension(name).isEmpty) {
      name += _fileExtension;
    }
    
    String dirPath = _dirPathForType(type);
    File f = _fileSystem.file(path.join(dirPath, name));
    
    bool exists = await f.exists();
    if (!exists) {
      if (suppressError) {
        return null;
      } else {
        throw new FileSystemException('${_capitalize(type)} \'$name\' was not found.', f.path);
      }
    }
    
    String tmpltStr = await f.readAsString();
    CompiledTemplate ct = compile(tmpltStr);
    cache['$type/$name'] = ct;
    return ct;
  }
  
  
  CompiledTemplate _load_from_disk_sync(String type, String name, bool suppressError) {
    if (path.extension(name).isEmpty) {
      name += _fileExtension;
    }
    
    String dirPath = _dirPathForType(type);
    File f = _fileSystem.file(path.join(dirPath, name));
    
    bool exists = f.existsSync();
    if (!exists) {
      if (suppressError) {
        return null;
      } else {
        throw new FileSystemException('${_capitalize(type)} \'$name\' was not found.', f.path);
      }
    }
    
    String tmpltStr = f.readAsStringSync();
    CompiledTemplate ct = compile(tmpltStr);
    cache['$type/$name'] = ct;
    return ct;
  }
  
  String _dirPathForType(String type) {
    switch (type) {
      case 'layout':  return _layoutsDirectory.path;
      case 'page':    return _pagesDirectory.path;
      case 'partial': return _partialsDirectory.path;
    }

    throw new ArgumentError();
  }
}

String _capitalize(String input) {
  if (input == null) {
    throw new ArgumentError.notNull('input');
  }
  if (input.length == 0) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}