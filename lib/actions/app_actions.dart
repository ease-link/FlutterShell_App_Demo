// UIDSL の action を受け取る窓口。
// 各アクションタイプを責務別ファイルに振り分けるだけ。

import 'function_actions.dart';
import 'api_actions.dart';
import 'storage_actions.dart';
import 'navigation_actions.dart';

typedef StateChangedCallback = void Function(String key, dynamic value);

class AppActions {
  static void handle(
    Map<String, dynamic> action, {
    required Map<String, dynamic> state,
    required StateChangedCallback onStateChanged,
    required NavigationHandler onNavigate,
  }) {
    final type   = action['type'] as String?;
    final params = (action['params'] as Map<String, dynamic>?) ?? {};

    switch (type) {
      case 'functionCall':
        final name     = (action['name'] ?? params['name']) as String?;
        final args     = (action['args'] ?? params['args'] as Map<String, dynamic>?) ?? {};
        final storeKey = (action['storeKey'] ?? params['storeKey']) as String?;
        if (name != null) {
          FunctionActions.call(name, args, state: state).then((result) {
            if (result is Map<String, dynamic>) {
              result.forEach((k, v) => onStateChanged(k, v));
            } else if (storeKey != null && result != null) {
              onStateChanged(storeKey, result);
            }
          });
        }
        break;

      case 'apiCall':
        final endpoint = (action['endpoint'] ?? params['endpoint']) as String?;
        final method   = (action['method']   ?? params['method'])   as String? ?? 'GET';
        final body     = (action['body']     ?? params['body'])     as Map<String, dynamic>?;
        final storeKey = (action['storeKey'] ?? params['storeKey']) as String?;
        final errorKey = (action['errorKey'] ?? params['errorKey']) as String?;
        if (endpoint != null) {
          ApiActions.call(endpoint, method: method, body: body, state: state).then((result) {
            if (result != null) {
              if (storeKey != null) onStateChanged(storeKey, result);
            } else {
              if (errorKey != null) onStateChanged(errorKey, 'API call failed');
            }
          });
        }
        break;

      case 'storage.save':
        final key   = (action['key']   ?? params['key'])   as String?;
        final value = action['value']  ?? params['value'];
        if (key != null) StorageActions.save(key, value);
        break;

      case 'storage.load':
        final key      = (action['key']      ?? params['key'])      as String?;
        final storeKey = (action['storeKey'] ?? params['storeKey']) as String?;
        if (key != null) {
          StorageActions.load(key).then((value) {
            if (storeKey != null && value != null) {
              onStateChanged(storeKey, value);
            }
          });
        }
        break;

      case 'navigate':
        final to = (action['to'] ?? params['to']) as String?;
        if (to != null) onNavigate(to);
        break;

      case 'navigate.back':
        onNavigate('__back__');
        break;

      case 'navigate.replace':
        final to = (action['to'] ?? params['to']) as String?;
        if (to != null) onNavigate('__replace__:$to');
        break;

      case 'storage.remove':
        final key = (action['key'] ?? params['key']) as String?;
        if (key != null) StorageActions.remove(key);
        break;

      case 'setState':
        final key   = (action['key']   ?? params['key'])   as String?;
        final value = action['value']  ?? params['value'];
        if (key != null) onStateChanged(key, value);
        break;

      case 'increment':
        final key = (action['key'] ?? params['key']) as String?;
        final by  = ((action['by'] ?? params['by']) as num?)?.toDouble() ?? 1.0;
        if (key != null) {
          final cur  = (state[key] as num?)?.toDouble() ?? 0.0;
          final next = cur + by;
          onStateChanged(key, next == next.truncateToDouble() ? next.toInt() : next);
        }
        break;

      case 'decrement':
        final key = (action['key'] ?? params['key']) as String?;
        final by  = ((action['by'] ?? params['by']) as num?)?.toDouble() ?? 1.0;
        if (key != null) {
          final cur  = (state[key] as num?)?.toDouble() ?? 0.0;
          final next = cur - by;
          onStateChanged(key, next == next.truncateToDouble() ? next.toInt() : next);
        }
        break;

      case 'toggle':
        final key = (action['key'] ?? params['key']) as String?;
        if (key != null) {
          onStateChanged(key, !(state[key] == true));
        }
        break;

      default:
        break;
    }
  }
}

typedef NavigationHandler = void Function(String to);
