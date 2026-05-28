// フレームワーク。1ファイルで全画面を表示
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shellapp_runtime/shellapp_runtime.dart';
import '../shellapp/widget_factory_lite.dart';
import '../actions/app_actions.dart';

class DynamicScreen extends StatefulWidget {
  final String screenName;
  const DynamicScreen({required this.screenName, super.key});
  @override
  State<DynamicScreen> createState() => _DynamicScreenState();
}

class _DynamicScreenState extends State<DynamicScreen> {
  Map<String, dynamic>? _resolvedWidget;
  Map<String, dynamic> _state = {};
  bool _scrollable = true;
  String? _error;
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // ──────────────────────────────────────────────────────────
      // [Optional] Load UIDSL from a remote server instead of bundled assets.
      // Place the JSON files from assets/uidsl/screens/ on your server and
      // UI changes will be reflected instantly without any app update.
      //
      // import 'package:http/http.dart' as http;
      // const _uidslBaseUrl = 'https://your-server.com/uidsl';
      //
      // String uidslStr;
      // try {
      //   final res = await http.get(
      //     Uri.parse('$_uidslBaseUrl/screens/${widget.screenName}.json'),
      //   ).timeout(const Duration(seconds: 5));
      //   uidslStr = res.statusCode == 200
      //       ? res.body
      //       : await rootBundle.loadString( // fallback to bundled assets
      //           'assets/uidsl/screens/${widget.screenName}.json');
      // } catch (_) {
      //   uidslStr = await rootBundle.loadString( // fallback on network error
      //       'assets/uidsl/screens/${widget.screenName}.json');
      // }
      // ──────────────────────────────────────────────────────────
      final uidslStr = await rootBundle
          .loadString('assets/uidsl/screens/${widget.screenName}.json');
      final json       = jsonDecode(uidslStr) as Map<String, dynamic>;
      final uidsl      = (json['root'] ?? json) as Map<String, dynamic>;
      final scrollable = (json['scrollable'] as bool?) ?? true;

      // onInit: 初回ロード時に1度だけ実行するアクション
      if (!_didInit) {
        _didInit = true;
        final onInit = json['onInit'] as Map<String, dynamic>?;
        if (onInit != null) {
          AppActions.handle(
            onInit,
            state:          _state,
            onStateChanged: _onStateChanged,
            onNavigate:     (_) {},
          );
          return; // _onStateChanged → _load() が再実行される
        }
      }

      final result = ShellAppRuntime.execute(uidsl: uidsl, state: _state);
      if (result.ok && result.widget != null) {
        setState(() {
          _resolvedWidget = result.widget;
          _scrollable     = scrollable;
          _error          = null;
        });
      } else if (result.error == 'native_unavailable') {
        setState(() {
          _resolvedWidget = uidsl;
          _scrollable     = scrollable;
          _error          = null;
        });
      } else {
        setState(() => _error = result.error ?? 'Unknown error');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _onStateChanged(String key, dynamic value) {
    setState(() => _state[key] = value);
    _load();
  }

  void _onAction(Map<String, dynamic> action) {
    AppActions.handle(
      action,
      state:          _state,
      onStateChanged: _onStateChanged,
      onNavigate: (to) {
        if (to == '__back__') {
          Navigator.of(context).pop();
        } else if (to.startsWith('__replace__:')) {
          Navigator.of(context).pushReplacementNamed('/${to.substring(12)}');
        } else {
          Navigator.of(context).pushNamed('/$to');
        }
      },
    );
  }

  Color? _rootBgColor(Map<String, dynamic> node) {
    final props = node['props'] as Map<String, dynamic>? ?? {};
    final raw = props['color'] as String?;
    if (raw == null || !raw.startsWith('#')) return null;
    final hex = raw.replaceFirst('#', '');
    try {
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }
    if (_resolvedWidget == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: _rootBgColor(_resolvedWidget!),
      body: SafeArea(
        child: _scrollable
            ? SingleChildScrollView(
                child: WidgetFactoryLite.build(
                  _resolvedWidget!,
                  onStateChanged: _onStateChanged,
                  onAction:       _onAction,
                  state:          _state,
                ),
              )
            : SizedBox.expand(
                child: WidgetFactoryLite.build(
                  _resolvedWidget!,
                  onStateChanged: _onStateChanged,
                  onAction:       _onAction,
                  state:          _state,
                ),
              ),
      ),
    );
  }
}
