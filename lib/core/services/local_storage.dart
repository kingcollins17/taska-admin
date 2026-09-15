import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

/// A safe local storage service for Jaspr applications.
/// 
/// Uses [universal_web] and checks [kIsWeb] to ensure safety 
/// during both server-side rendering and client-side web execution.
class LocalStorageService {
  const LocalStorageService._();

  /// Reads a string value from localStorage for the given [key].
   String? getItem(String key) {
    if (kIsWeb) {
      try {
        return web.window.localStorage.getItem(key);
      } catch (e) {
        print('Error reading from localStorage: $e');
      }
    }
    return null;
  }

  /// Saves a string [value] to localStorage under the given [key].
   void setItem(String key, String value) {
    if (kIsWeb) {
      try {
        web.window.localStorage.setItem(key, value);
      } catch (e) {
        print('Error writing to localStorage: $e');
      }
    }
  }

  /// Removes an item from localStorage by [key].
   void removeItem(String key) {
    if (kIsWeb) {
      try {
        web.window.localStorage.removeItem(key);
      } catch (e) {
        print('Error removing from localStorage: $e');
      }
    }
  }

  /// Clears all keys from localStorage.
   void clear() {
    if (kIsWeb) {
      try {
        web.window.localStorage.clear();
      } catch (e) {
        print('Error clearing localStorage: $e');
      }
    }
  }
}

/// Instance to be used throughout in app
final localStorage=LocalStorageService._();