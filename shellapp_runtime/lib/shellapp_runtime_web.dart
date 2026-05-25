library shellapp_runtime;

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

class ShellAppBindings {
  static bool get isAvailable => false;
}

class ShellAppRuntime {
  ShellAppRuntime._();

  static Future<void> init() async {}

  static ExecuteResult execute({
    required Map<String, dynamic> uidsl,
    Map<String, dynamic>? state,
    List<String>? roles,
  }) =>
      ExecuteResult.error('native_unavailable');
}
