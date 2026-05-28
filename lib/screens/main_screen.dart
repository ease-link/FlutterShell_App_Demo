import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shellapp_runtime/shellapp_runtime.dart';
import '../shellapp/widget_factory_lite.dart';
import '../actions/app_actions.dart';
import '../actions/function_actions.dart';
import '../plugins/navigation_rail_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<String, dynamic>? _resolvedWidget;
  final Map<String, dynamic> _state = FunctionActions.initialState();
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
          await rootBundle.loadString('assets/uidsl/screens/main.json');
      final json       = jsonDecode(uidslStr) as Map<String, dynamic>;
      final uidsl      = (json['root'] ?? json) as Map<String, dynamic>;
      final scrollable = (json['scrollable'] as bool?) ?? true;
      final result     = ShellAppRuntime.execute(uidsl: uidsl, state: _state);
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  void _onStateChanged(String key, dynamic value) {
    _state[key] = value;
    if (key == 'favorites' && value is List) {
      _state['favoritesCount'] = value.length;
    }
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
          Navigator.of(context).pushReplacementNamed('/${to.substring(12)}', arguments: _state);
        } else {
          Navigator.of(context).pushNamed('/$to', arguments: _state);
        }
      },
    );
  }

  Widget _buildWidget(Map<String, dynamic> node) {
    switch (node['type'] as String? ?? '') {
      case 'navigation_rail':
        return NavigationRailWidget(
          node:           node,
          state:          _state,
          onStateChanged: _onStateChanged,
          onAction:       _onAction,
        );
      default:
        return WidgetFactoryLite.build(
          node,
          onStateChanged: _onStateChanged,
          onAction:       _onAction,
          state:          _state,
        );
    }
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
            ? SingleChildScrollView(child: _buildWidget(_resolvedWidget!))
            : SizedBox.expand(child: _buildWidget(_resolvedWidget!)),
      ),
    );
  }
}
