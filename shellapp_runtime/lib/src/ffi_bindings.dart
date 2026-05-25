import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef _RunShellAppNative = Pointer<Utf8> Function(Pointer<Utf8> requestJson);
typedef _FreeStringNative  = Void Function(Pointer<Utf8> ptr);

class ShellAppBindings {
  static ShellAppBindings? _instance;
  static bool _available = false;
  static bool get isAvailable => _available;

  static void tryInit() {
    try {
      _instance = ShellAppBindings._();
      _available = true;
    } catch (_) {
      _available = false;
    }
  }

  static ShellAppBindings get instance {
    if (!_available || _instance == null) {
      throw StateError('ShellAppBindings not available on this platform');
    }
    return _instance!;
  }

  late final _RunShellAppNative _runShellApp;
  late final void Function(Pointer<Utf8>) _freeString;

  ShellAppBindings._() {
    final lib = _openLibrary();
    _runShellApp = lib
        .lookup<NativeFunction<_RunShellAppNative>>('RunShellApp')
        .asFunction();
    _freeString = lib
        .lookup<NativeFunction<_FreeStringNative>>('FreeString')
        .asFunction();
  }

  String call(String requestJson) {
    final reqPtr = requestJson.toNativeUtf8();
    try {
      final resultPtr = _runShellApp(reqPtr);
      final result = resultPtr.toDartString();
      _freeString(resultPtr);
      return result;
    } finally {
      malloc.free(reqPtr);
    }
  }

  static DynamicLibrary _openLibrary() {
    if (Platform.isWindows) return DynamicLibrary.open('shellapp_runtime.dll');
    if (Platform.isMacOS)  return DynamicLibrary.open('libshellapp_runtime.dylib');
    return DynamicLibrary.open('libshellapp_runtime.so');
  }
}
