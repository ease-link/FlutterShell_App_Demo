/// ShellApp Runtime — public API
///
/// Desktop/Mobile: dart:ffi 経由で Go ランタイムを呼び出す
/// Web: スタブ（FFI 不使用、native_unavailable を返す）
library shellapp_runtime;

export 'shellapp_runtime_native.dart'
    if (dart.library.html) 'shellapp_runtime_web.dart';
