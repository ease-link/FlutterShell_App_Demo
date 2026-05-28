import 'package:flutter/material.dart';
import '../shellapp/widget_factory_lite.dart';

class NavigationRailWidget extends StatelessWidget {
  const NavigationRailWidget({
    super.key,
    required this.node,
    required this.state,
    this.onStateChanged,
    this.onAction,
  });

  final Map<String, dynamic> node;
  final Map<String, dynamic> state;
  final StateChangedCallback? onStateChanged;
  final ActionCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final props = node['props'] as Map<String, dynamic>? ?? {};

    final bindKey = node['bind']?.toString() ?? node['bind_key']?.toString();

    // Prefer live state; fall back to DLL-resolved value.
    final liveIndex = bindKey != null ? state[bindKey] : null;
    final resolvedVal = liveIndex ?? node['resolved_value'];
    final selectedIndex =
        (resolvedVal is int ? resolvedVal : int.tryParse(resolvedVal?.toString() ?? '0') ?? 0)
            .clamp(0, 9);

    final rawDests = props['destinations'] as List? ?? [];
    final destinations = rawDests.map((e) {
      final m = e is Map ? e : <String, dynamic>{};
      return NavigationRailDestination(
        icon:  Icon(_iconData(m['icon']?.toString() ?? 'home')),
        label: Text(m['label']?.toString() ?? ''),
      );
    }).toList();

    final rawChildren = node['children'] as List? ?? [];
    final childDsls = rawChildren.whereType<Map<String, dynamic>>().toList();
    final safeIndex = selectedIndex.clamp(0, childDsls.isEmpty ? 0 : childDsls.length - 1);

    final bgHex = props['background']?.toString();
    final bgColor = bgHex != null ? _parseColor(bgHex) : null;

    return Row(
      children: [
        NavigationRail(
          backgroundColor: bgColor,
          destinations: destinations,
          selectedIndex: safeIndex,
          labelType: NavigationRailLabelType.all,
          onDestinationSelected: (index) {
            if (bindKey != null) {
              onStateChanged?.call(bindKey, index);
            }
          },
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: childDsls.isEmpty
              ? const SizedBox.shrink()
              : WidgetFactoryLite.build(
                  childDsls[safeIndex],
                  onStateChanged: onStateChanged,
                  onAction: onAction,
                  state: state,
                ),
        ),
      ],
    );
  }
}

IconData _iconData(String name) {
  const map = <String, IconData>{
    'home':      Icons.home,
    'favorite':  Icons.favorite,
    'star':      Icons.star,
    'person':    Icons.person,
    'settings':  Icons.settings,
    'search':    Icons.search,
    'skip_next': Icons.skip_next,
  };
  return map[name] ?? Icons.circle;
}

Color? _parseColor(String hex) {
  final s = hex.replaceFirst('#', '');
  final v = int.tryParse(s.length == 6 ? 'FF$s' : s, radix: 16);
  return v != null ? Color(v) : null;
}
