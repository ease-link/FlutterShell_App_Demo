library shellapp_runtime;

import 'dart:convert';
import 'package:flutter/services.dart';
import 'src/ffi_bindings.dart';

export 'src/ffi_bindings.dart' show ShellAppBindings;

class ExecuteResult {
  final bool ok;
  final String? error;
  final Map<String, dynamic>? widget;

  const ExecuteResult({required this.ok, this.error, this.widget});

  factory ExecuteResult.fromJson(Map<String, dynamic> json) => ExecuteResult(
        ok: json['ok'] as bool? ?? false,
        error: json['error'] as String?,
        widget: json['widget'] as Map<String, dynamic>?,
      );

  factory ExecuteResult.error(String message) =>
      ExecuteResult(ok: false, error: message);
}

class ShellAppRuntime {
  ShellAppRuntime._();

  static const String _projectId   = 'r1ImPItNtOVFMi9ALcSN';
  static const String _packageName = '';
  static String? _licenseJwt;

  static Future<void> init() async {
    ShellAppBindings.tryInit();
    try {
      _licenseJwt = (await rootBundle.loadString('assets/license.jwt')).trim();
      if (_licenseJwt!.isEmpty) _licenseJwt = null;
    } catch (_) {
      _licenseJwt = null;
    }
  }

  static ExecuteResult execute({
    required Map<String, dynamic> uidsl,
    Map<String, dynamic>? state,
    List<String>? roles,
  }) {
    if (!ShellAppBindings.isAvailable) {
      return ExecuteResult.error('native_unavailable');
    }
    try {
      final request = jsonEncode({
        'uidsl':        uidsl,
        'state':        state ?? {},
        'roles':        roles ?? [],
        'project_id':   _projectId,
        'package_name': _packageName,
        if (_licenseJwt != null) 'license_jwt': _licenseJwt,
      });
      final responseJson = ShellAppBindings.instance(request);
      final decoded = jsonDecode(responseJson) as Map<String, dynamic>;
      return ExecuteResult.fromJson(decoded);
    } catch (e) {
      return ExecuteResult.error('ShellAppRuntime.execute failed: $e');
    }
  }
}
