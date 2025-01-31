import 'dart:convert';
import 'dart:async';
import 'dart:js_util' as js_util;
import 'dart:js' as js;
import '../models/shortcut.dart';

class StorageService {
  js.JsObject? get _chrome {
    if (js.context.hasProperty('chrome')) {
      return js.JsObject.fromBrowserObject(js.context['chrome']);
    }
    return null;
  }

  js.JsObject? get _storage {
    final chrome = _chrome;
    return chrome?.hasProperty('storage') == true
        ? js.JsObject.fromBrowserObject(chrome!['storage'])
        : null;
  }

  js.JsObject? get _sync {
    final storage = _storage;
    return storage?.hasProperty('sync') == true
        ? js.JsObject.fromBrowserObject(storage!['sync'])
        : null;
  }

  Future<List<Shortcut>> getShortcuts() async {
    try {
      final sync = _sync;
      if (sync == null) {
        print('Sync storage not available');
        return [];
      }

      final completer = Completer<List<Shortcut>>();
      
      sync.callMethod('get', [
        js.JsObject.jsify(['shortcuts']),
        js.allowInterop((result) {
          try {
            if (result == null || !js.JsObject.fromBrowserObject(result).hasProperty('shortcuts')) {
              completer.complete([]);
              return;
            }

            final shortcuts = result['shortcuts'];
            if (shortcuts == null) {
              completer.complete([]);
              return;
            }

            final List<dynamic> shortcutsList = json.decode(shortcuts.toString());
            final mappedShortcuts = shortcutsList.map((json) => Shortcut.fromJson(json)).toList();
            completer.complete(mappedShortcuts);
          } catch (e) {
            print('Error in get callback: $e');
            completer.complete([]);
          }
        })
      ]);

      return completer.future;
    } catch (e) {
      print('Error loading shortcuts: $e');
      return [];
    }
  }

  Future<void> saveShortcuts(List<Shortcut> shortcuts) async {
    try {
      final sync = _sync;
      if (sync == null) {
        print('Sync storage not available');
        return;
      }

      final completer = Completer<void>();
      
      final jsonList = shortcuts.map((s) => s.toJson()).toList();
      final data = {'shortcuts': json.encode(jsonList)};
      
      sync.callMethod('set', [
        js.JsObject.jsify(data),
        js.allowInterop(() {
          try {
            // Dispatch storage change event
            final event = js.JsObject(js.context['CustomEvent'], ['storage-changed']);
            js.context['window'].callMethod('dispatchEvent', [event]);
            completer.complete();
          } catch (e) {
            print('Error in set callback: $e');
            completer.completeError(e);
          }
        })
      ]);

      return completer.future;
    } catch (e) {
      print('Error saving shortcuts: $e');
      rethrow;
    }
  }
}
