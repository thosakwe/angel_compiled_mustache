import 'dart:async';
import 'dart:io';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_compiled_mustache/angel_compiled_mustache.dart';
import 'package:test/test.dart';


Directory viewsDir = new Directory('test/views');


Future main() async {
  Angel angel = new Angel();
  await angel.configure(compiled_mustache(viewsDir, defaultLayout: 'raw'));
  
  group('renderer', () {
    test('can render templates', () async {
      var hello = await angel.viewGenerator('hello', {'name': 'world'});
      expect(hello, equals('Hello, world!'));
      
      var bar = await angel.viewGenerator('foo/bar', {'framework': 'angel'});
      expect(bar, equals('angel_framework'));
    });

    test('throws if view is not found', () async {
      expect(new Future(() async {
        await angel.viewGenerator('fail');
      }), throwsA(new isInstanceOf<FileSystemException>()));
    });
  });
  
  group('layouts', () {
    Angel angel = new Angel();
    setUp(() async {
      await angel.configure(compiled_mustache(viewsDir));
    });
    
    test('should use default if none is given', () async {
      var res = await angel.viewGenerator('hello', {'name': 'world'});
      expect(res, equals('Main: Hello, world!'));
    });
    
    test('should respect user-set default layout', () async {
      Angel ang = new Angel();
      await ang.configure(compiled_mustache(viewsDir, defaultLayout: 'other'));
      var res = await ang.viewGenerator('hello', {'name': 'world'});
      expect(res, equals('Other: Hello, world!'));
    });
    
    test('should use specific layout if given', () async {
      var res = await angel.viewGenerator('hello', {'layout': 'other', 'name': 'world'});
      expect(res, equals('Other: Hello, world!'));
    });
    
    test('should throw if template couldn\'t be found', () async {
      expect(new Future(() async {
        await angel.viewGenerator('main', {'layout': 'fail', 'name': 'world'});
      }), throwsA(new isInstanceOf<FileSystemException>()));
    });
  });
  
  group('partials', () {
    test('should work', () async {
      var withPartial = await angel.viewGenerator('with-partial');
      expect(withPartial, equals('Partial-ly successful!'));
    });
    
    test('should properly render nesteds', () async {
      var withNestedPartial = await angel.viewGenerator('nested-partial', {'status': 'successful'});
      expect(withNestedPartial, equals('Nesting was successful!'));
    });
    
    test('should be blank if not found', () async {
      expect(new Future<String>(() async {
          return await angel.viewGenerator('unknown-partial');
      }), completion(equals('Have you seen this partial: ?')));
    });
  });
  
  group('cache', () {
    const cachePath = 'test/views/pages/caching';
    
    if (angel.isProduction) {
      test('should be used in production mode', () async {
          Angel angelProd = new Angel();
          await angelProd.configure(compiled_mustache(viewsDir, defaultLayout: 'raw'));
          
          await (new File('$cachePath/before.mustache')).copy('$cachePath/cache.mustache');
          var before = await angelProd.viewGenerator('caching/cache');
          await (new File('$cachePath/after.mustache')).copy('$cachePath/cache.mustache');
          var after = await angelProd.viewGenerator('caching/cache');
          
          expect(before, equals('Before'));
          expect(after,  equals('Before'));
      });
    } else {
      test('should be bypassed in debug mode', () async {
        Angel angelDebug = new Angel();
        await angelDebug.configure(compiled_mustache(viewsDir, defaultLayout: 'raw'));
        
        await (new File('$cachePath/before.mustache')).copy('$cachePath/cache.mustache');
        var before = await angelDebug.viewGenerator('caching/cache');
        await (new File('$cachePath/after.mustache')).copy('$cachePath/cache.mustache');
        var after = await angelDebug.viewGenerator('caching/cache');
        
        expect(before, equals('Before'));
        expect(after,  equals('After'));
      });
    }
  });
}