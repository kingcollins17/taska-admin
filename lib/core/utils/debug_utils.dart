import 'dart:collection';
import 'dart:convert';
import 'package:jaspr/jaspr.dart';

void debugLog(dynamic data, {DebugLevel level = DebugLevel.info}) {
  final json = _convertToJson(data);
  print('[$level] $json');
}

dynamic _convertToJson(dynamic data) {
  if (data == null) return 'null';
  try {
    final encoder = JsonEncoder.withIndent('  ', (object) {
      if (object == null) return null;
      try {
        return (object as dynamic).toJson();
      } catch (_) {
        return object.toString();
      }
    });
    return encoder.convert(data);
  } catch (_) {
   data.toString();
  }
}

enum DebugLevel { info, warn, network, error }

class DebugData {
  final dynamic data;
  final DebugLevel level;
  final DateTime timestamp;

  DebugData({required this.data, required this.level, required this.timestamp});
}

class DebugCache extends ChangeNotifier {
  final List<DebugData> _cache = [];

  UnmodifiableListView<DebugData> get cache => UnmodifiableListView(_cache);

  void add(DebugData value) {
    _cache.add(value);
    notifyListeners();
  }

  void clear() {
    _cache.clear();
    notifyListeners();
  }
}