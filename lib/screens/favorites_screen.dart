import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shellapp_runtime/shellapp_runtime.dart';
import '../shellapp/widget_factory_lite.dart';
import '../actions/app_actions.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Map<String, dynamic>? _resolvedWidget;
  final Map<String, dynamic> _state = {};
  bool _scrollable = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final uidslStr =
          await rootBundle.loadString('assets/uidsl/screens/favorites.json');
      final json     = jsonDecode(uidslStr) as Map<String, dynamic>;
      final uidsl    = (json['root'] ?? json) as Map<String, dynamic>;
      final scrollable = (json['scrollable'] as bool?) ?? true;
      final result   = ShellAppRuntime.execute(uidsl: uidsl, state: _state);
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
                ),
              )
            : SizedBox.expand(
                child: WidgetFactoryLite.build(
                  _resolvedWidget!,
                  onStateChanged: _onStateChanged,
                  onAction:       _onAction,
                ),
              ),
      ),
    );
  }
}
