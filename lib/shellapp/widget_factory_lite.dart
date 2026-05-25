// ShellApp Widget Factory Lite
// DLL が解決済みの UIDSL ノードを Flutter Widget に変換するだけの純レンダラー。
// bind / access / visibility の計算は DLL 側で完結している。

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

typedef StateChangedCallback = void Function(String key, dynamic value);
typedef ActionCallback = void Function(Map<String, dynamic> action);

class WidgetFactoryLite {
  static Widget build(
    Map<String, dynamic> resolved, {
    StateChangedCallback? onStateChanged,
    ActionCallback? onAction,
    Map<String, dynamic>? state,
  }) =>
      _buildNode(resolved,
          onStateChanged: onStateChanged, onAction: onAction, state: state);

  static Widget _buildNode(
    Map<String, dynamic> node, {
    StateChangedCallback? onStateChanged,
    ActionCallback? onAction,
    Map<String, dynamic>? state,
  }) {
    if (!(node['visible'] as bool? ?? true)) return const SizedBox.shrink();

    final type          = node['type'] as String? ?? 'error';
    final props         = (node['props'] as Map<String, dynamic>?) ?? {};
    final resolvedValue = node['resolved_value'];
    final bindKey       = node['bind_key'] as String?;
    final childrenRaw   = node['children'] as List? ?? [];

    List<Widget> children() => childrenRaw
        .map((c) => _buildNode(c as Map<String, dynamic>,
            onStateChanged: onStateChanged, onAction: onAction, state: state))
        .toList();

    Widget firstChild() => childrenRaw.isNotEmpty
        ? _buildNode(childrenRaw.first as Map<String, dynamic>,
            onStateChanged: onStateChanged, onAction: onAction, state: state)
        : const SizedBox.shrink();

    Widget result;

    // ---------------------------------------------------------------
    // selfTapTypes — これらは自身でタップを処理するため GestureDetector で
    // 二重ラップしない
    // ---------------------------------------------------------------
    const selfTapTypes = {
      'button', 'text_field', 'number_field',
      'checkbox', 'switch', 'radio', 'dropdown', 'slider', 'date_picker',
    };

    switch (type) {
      // ─── Display ──────────────────────────────────────────────────
      case 'text':
        final val =
            resolvedValue?.toString() ?? props['value']?.toString() ?? '';
        result = Text(
          val,
          style: _textStyle(props['style']),
          textAlign: _textAlign(props['textAlign'] as String?),
          maxLines: props['maxLines'] as int?,
          overflow: TextOverflow.clip,
        );
        break;

      case 'image':
        final src =
            resolvedValue?.toString() ?? props['src']?.toString() ?? '';
        if (src.isEmpty) return const SizedBox.shrink();
        result = Image.network(
          src,
          width:  (props['width']  as num?)?.toDouble(),
          height: (props['height'] as num?)?.toDouble(),
          fit: _boxFit(props['fit'] as String?),
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, color: Colors.grey),
        );
        break;

      case 'icon':
        final iconSet  = props['set']  as String? ?? 'material';
        final iconName = props['name'] as String? ?? 'star';
        final baseSize  = (props['size'] as num?)?.toDouble() ?? 24.0;
        final iconW = (props['width']  as num?)?.toDouble() ?? baseSize;
        final iconH = (props['height'] as num?)?.toDouble() ?? baseSize;
        final iconColor = _color(props['color']);
        if (iconSet == 'custom') {
          final src = props['src'] as String? ?? '';
          return src.isNotEmpty
              ? SvgPicture.asset(src,
                  width: iconW, height: iconH,
                  colorFilter: iconColor != null
                      ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                      : null)
              : const SizedBox.shrink();
        }
        if (iconSet == 'fa') {
          result = FaIcon(_parseFaIconData(iconName),
              size: iconW, color: iconColor);
        } else {
          result = Icon(_parseIconData(iconName),
              size: iconW, color: iconColor);
        }
        break;

      case 'divider':
        result = Divider(
          color:     _color(props['color']),
          thickness: (props['thickness'] as num?)?.toDouble(),
          indent:    (props['indent'] as num?)?.toDouble(),
          endIndent: (props['indent'] as num?)?.toDouble(),
        );
        break;

      case 'badge':
        final badgeLabel = props['label']?.toString();
        final badgeBg    = _color(props['backgroundColor']) ?? Colors.red;
        final badgeFg    = _color(props['textColor'])       ?? Colors.white;
        final badgeChild = childrenRaw.isNotEmpty ? firstChild() : const Icon(Icons.notifications);
        result = Badge(
          label: badgeLabel != null
              ? Text(badgeLabel, style: TextStyle(color: badgeFg))
              : null,
          backgroundColor: badgeBg,
          child: badgeChild,
        );
        break;

      case 'tooltip':
        final ttMessage = props['message']?.toString() ?? '';
        final ttChild = childrenRaw.isNotEmpty ? firstChild() : const Icon(Icons.info_outline);
        result = Tooltip(message: ttMessage, child: ttChild);
        break;

      case 'visibility':
        final isVisible = resolvedValue is bool
            ? resolvedValue
            : (props['visible'] != false);
        result = Visibility(visible: isVisible, child: firstChild());
        break;

      case 'animated_container':
        result = AnimatedContainer(
          duration: Duration(
              milliseconds: (props['duration'] as num?)?.toInt() ?? 300),
          width:     (props['width']  as num?)?.toDouble(),
          height:    (props['height'] as num?)?.toDouble(),
          color:     _color(props['color']),
          padding:   _edgeInsets(props['padding']),
          alignment: _alignment(props['alignment'] as String?),
          child:     childrenRaw.isNotEmpty ? firstChild() : null,
        );
        break;

      case 'animated_opacity':
        final aoOpacity = ((resolvedValue ?? props['opacity'] ?? 1.0) as num)
            .toDouble()
            .clamp(0.0, 1.0);
        result = AnimatedOpacity(
          opacity: aoOpacity,
          duration: Duration(
              milliseconds: (props['duration'] as num?)?.toInt() ?? 300),
          child: childrenRaw.isNotEmpty ? firstChild() : const SizedBox.shrink(),
        );
        break;

      // ─── Input ────────────────────────────────────────────────────
      case 'card':
        // card は _applyCommonStyle の width/height ラップを skip
        Widget cardResult = Card(
          elevation: (props['elevation'] as num?)?.toDouble() ?? 2.0,
          color: _color(props['color']),
          child: Padding(
            padding: _edgeInsets(props['padding']) ?? const EdgeInsets.all(12),
            child: childrenRaw.isNotEmpty
                ? firstChild()
                : const SizedBox.shrink(),
          ),
        );
        // card では width/height は内部では不要（外部スタイルのみ margin/opacity）
        return _applyCommonStyleSkipSize(cardResult, props);

      case 'button':
        final label = props['label']?.toString() ?? '';
        final onTapAction =
            (node['on_tap'] ?? props['onTap'] ?? props['action']) is Map
                ? (node['on_tap'] ?? props['onTap'] ?? props['action'])
                    as Map<String, dynamic>
                : null;
        final variant = props['variant']?.toString() ?? 'elevated';
        final br      = (props['borderRadius'] as num?)?.toDouble() ?? 0.0;
        final shape   =
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(br));
        final onPressed =
            onTapAction != null && onAction != null
                ? () => onAction(onTapAction)
                : null;
        final btnStyleMap = props['style'] is Map
            ? Map<String, dynamic>.from(props['style'] as Map)
            : null;
        final btnTextStyle = _textStyle(btnStyleMap);
        final btnIconName = props['icon']?.toString();
        final btnIcon = btnIconName != null
            ? Icon(_parseIconData(btnIconName), size: 18)
            : null;
        switch (variant) {
          case 'text':
            result = TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(shape: shape),
                child: btnIcon != null
                    ? Row(mainAxisSize: MainAxisSize.min, children: [btnIcon, const SizedBox(width: 6), Text(label, style: btnTextStyle)])
                    : Text(label, style: btnTextStyle));
            break;
          case 'outlined':
            result = OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(shape: shape),
                child: btnIcon != null
                    ? Row(mainAxisSize: MainAxisSize.min, children: [btnIcon, const SizedBox(width: 6), Text(label, style: btnTextStyle)])
                    : Text(label, style: btnTextStyle));
            break;
          default:
            result = ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(shape: shape),
                child: btnIcon != null
                    ? Row(mainAxisSize: MainAxisSize.min, children: [btnIcon, const SizedBox(width: 6), Text(label, style: btnTextStyle)])
                    : Text(label, style: btnTextStyle));
        }
        break;

      case 'text_field':
        result = _InputField(
          label:        props['label'] as String?,
          hint:         props['hint'] as String?,
          variant:      props['variant']?.toString() ?? 'outline',
          borderRadius: (props['borderRadius'] as num?)?.toDouble() ?? 8.0,
          initialValue: resolvedValue?.toString() ?? '',
          multiline:    props['multiline'] == true,
          onChanged: bindKey != null && onStateChanged != null
              ? (v) => onStateChanged(bindKey, v)
              : null,
        );
        break;

      case 'number_field':
        result = _InputField(
          label:        props['label'] as String?,
          hint:         props['hint'] as String?,
          variant:      props['variant']?.toString() ?? 'outline',
          borderRadius: (props['borderRadius'] as num?)?.toDouble() ?? 8.0,
          initialValue: resolvedValue?.toString() ?? '',
          numeric:      true,
          onChanged: bindKey != null && onStateChanged != null
              ? (v) => onStateChanged(bindKey, num.tryParse(v) ?? v)
              : null,
        );
        break;

      case 'search_field':
        result = _SearchField(
          placeholder:  props['placeholder']?.toString() ?? '検索...',
          borderRadius: (props['borderRadius'] as num?)?.toDouble() ?? 24.0,
          initialValue: resolvedValue?.toString() ?? '',
          onChanged: bindKey != null && onStateChanged != null
              ? (v) => onStateChanged(bindKey, v)
              : null,
        );
        break;

      case 'checkbox':
        result = Row(children: [
          Checkbox(
            value: resolvedValue == true,
            onChanged: bindKey != null && onStateChanged != null
                ? (v) => onStateChanged(bindKey, v)
                : null,
          ),
          Text(props['label']?.toString() ?? ''),
        ]);
        break;

      case 'switch':
        result = Row(children: [
          Switch(
            value: resolvedValue == true,
            onChanged: bindKey != null && onStateChanged != null
                ? (v) => onStateChanged(bindKey, v)
                : null,
          ),
          Text(props['label']?.toString() ?? ''),
        ]);
        break;

      case 'radio':
        result = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<dynamic>(
              value: props['value'],
              groupValue: resolvedValue,
              onChanged: bindKey != null && onStateChanged != null
                  ? (v) => onStateChanged(bindKey, v)
                  : null,
            ),
            Text(props['label']?.toString() ?? ''),
          ],
        );
        break;

      case 'radio_group':
        final rgItems = (props['items'] as List? ?? [])
            .map((e) => e.toString())
            .toList();
        final rgSelected = resolvedValue?.toString();
        final rgIsHorizontal = props['direction'] == 'horizontal';
        final rgLabel = props['label']?.toString();
        final rgRadios = rgItems.map((item) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value:      item,
              groupValue: rgSelected,
              onChanged: bindKey != null && onStateChanged != null
                  ? (v) => onStateChanged(bindKey, v)
                  : null,
            ),
            Text(item),
          ],
        )).toList();
        result = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rgLabel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(rgLabel),
              ),
            rgIsHorizontal
                ? Wrap(children: rgRadios)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: rgRadios,
                  ),
          ],
        );
        break;

      case 'dropdown':
        final items = (props['items'] as List? ?? []).cast<String>();
        result = DropdownButton<String>(
          value: resolvedValue as String?,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: bindKey != null && onStateChanged != null
              ? (v) => onStateChanged(bindKey, v)
              : null,
        );
        break;

      case 'slider':
        final min = (props['min'] as num?)?.toDouble() ?? 0.0;
        final max = (props['max'] as num?)?.toDouble() ?? 100.0;
        final val =
            ((resolvedValue ?? min) as num).toDouble().clamp(min, max);
        result = Slider(
          value: val,
          min:   min,
          max:   max,
          onChanged: bindKey != null && onStateChanged != null
              ? (v) => onStateChanged(bindKey, v)
              : null,
        );
        break;

      case 'date_picker':
        final dpLabel = props['label']?.toString() ?? '日付を選択';
        final dpValue = resolvedValue;
        result = Builder(builder: (ctx) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: InkWell(
              onTap: () async {
                DateTime initial;
                try {
                  initial = dpValue != null
                      ? DateTime.parse(dpValue.toString())
                      : DateTime.now();
                } catch (_) {
                  initial = DateTime.now();
                }
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: initial,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (picked != null && bindKey != null && onStateChanged != null) {
                  onStateChanged(bindKey, picked.toIso8601String());
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: dpLabel,
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today, size: 16),
                ),
                child: Text(
                  dpValue != null ? _formatDate(dpValue.toString()) : '',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        });
        break;

      case 'time_picker':
        final tpLabel = props['label']?.toString() ?? '時刻を選択';
        final tpValue = resolvedValue?.toString() ?? '';
        result = Builder(builder: (ctx) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: ctx,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null && bindKey != null && onStateChanged != null) {
                  if (ctx.mounted) {
                    onStateChanged(bindKey, picked.format(ctx));
                  }
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: tpLabel,
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.access_time, size: 16),
                ),
                child: Text(
                  tpValue.isNotEmpty ? tpValue : '',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        });
        break;

      // ─── Layout ───────────────────────────────────────────────────
      case 'column':
        result = Column(
          mainAxisAlignment:
              _mainAxis(props['mainAxisAlignment'] as String?),
          crossAxisAlignment:
              _crossAxis(props['crossAxisAlignment'] as String?),
          children: children(),
        );
        break;

      case 'row':
        result = Row(
          mainAxisAlignment:
              _mainAxis(props['mainAxisAlignment'] as String?),
          crossAxisAlignment:
              _crossAxis(props['crossAxisAlignment'] as String?),
          children: children(),
        );
        break;

      case 'stack':
        final stackWidget = Stack(
          alignment: _alignment(props['alignment'] as String?) ??
              AlignmentDirectional.topStart,
          children: childrenRaw.map((c) {
            final child = c as Map<String, dynamic>;
            final cp    = (child['props'] as Map<String, dynamic>?) ?? {};
            final w     = _buildNode(child,
                onStateChanged: onStateChanged, onAction: onAction, state: state);
            final hasPos = cp.containsKey('left') ||
                cp.containsKey('top') ||
                cp.containsKey('right') ||
                cp.containsKey('bottom');
            if (!hasPos) return w;
            double? td(dynamic v) => v is num ? v.toDouble() : null;
            return Positioned(
                left:   td(cp['left']),
                top:    td(cp['top']),
                right:  td(cp['right']),
                bottom: td(cp['bottom']),
                child:  w);
          }).toList(),
        );
        // width 未指定・height 未指定のとき横幅いっぱいに広げる（コアと同じ）
        if (props['width'] == null && props['height'] == null) {
          result = SizedBox(width: double.infinity, child: stackWidget);
        } else {
          result = stackWidget;
        }
        break;

      case 'container':
        // container は width/height を内部で処理するため _applyCommonStyle では skip
        final cw    = (props['width']  as num?)?.toDouble();
        final ch    = (props['height'] as num?)?.toDouble();
        final cmaxW = (props['maxWidth']  as num?)?.toDouble();
        final cmaxH = (props['maxHeight'] as num?)?.toDouble();
        final needsClip = cw != null || ch != null;
        final childList = children();
        Widget? innerChild;
        if (childList.isNotEmpty) {
          // maxWidth があるコンテナ（パネル/カード系）は center、
          // それ以外のフル幅コンテナは stretch（デフォルト）
          final innerCross = cmaxW != null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.stretch;
          final inner = childList.length == 1
              ? childList.first
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: innerCross,
                  children: childList,
                );
          innerChild = needsClip ? ClipRect(child: inner) : inner;
        }
        Widget cResult = Container(
          width:     cw,
          height:    ch,
          color:     _color(props['color']),
          padding:   _edgeInsets(props['padding']),
          margin:    _edgeInsets(props['margin']),
          alignment: _alignment(props['alignment'] as String?),
          child:     innerChild,
        );
        if (cmaxW != null || cmaxH != null) {
          cResult = ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:  cmaxW ?? double.infinity,
              maxHeight: cmaxH ?? double.infinity,
            ),
            child: cResult,
          );
        }
        return _applyCommonStyleSkipSize(cResult, props);

      case 'padding':
        result = Padding(
          padding: _edgeInsets(props['padding']) ?? EdgeInsets.zero,
          child: childrenRaw.isNotEmpty ? firstChild() : const SizedBox.shrink(),
        );
        break;

      case 'sized_box':
      case 'vspacer':
        result = SizedBox(
            height: (props['height'] as num?)?.toDouble() ?? 16.0);
        break;

      case 'hspacer':
        result = SizedBox(
            width: (props['width'] as num?)?.toDouble() ?? 16.0);
        break;

      case 'expanded':
        final exFlex = (props['flex'] as num?)?.toInt() ?? 1;
        result = Expanded(flex: exFlex, child: firstChild());
        break;

      case 'flexible':
        final flFlex = (props['flex'] as num?)?.toInt() ?? 1;
        final flFit  = props['fit'] == 'tight' ? FlexFit.tight : FlexFit.loose;
        result = Flexible(flex: flFlex, fit: flFit, child: firstChild());
        break;

      case 'wrap':
        final wrapSpacing    = (props['spacing']    as num?)?.toDouble() ?? 8.0;
        final wrapRunSpacing = (props['runSpacing'] as num?)?.toDouble() ?? 8.0;
        final wrapAxis = props['direction'] == 'vertical'
            ? Axis.vertical
            : Axis.horizontal;
        result = Wrap(
          direction:  wrapAxis,
          spacing:    wrapSpacing,
          runSpacing: wrapRunSpacing,
          children:   children(),
        );
        break;

      case 'form':
        final onSubmitAction = (node['on_submit'] ?? props['onSubmit'] ?? props['on_submit']) is Map
            ? (node['on_submit'] ?? props['onSubmit'] ?? props['on_submit']) as Map<String, dynamic>
            : null;
        final submitLabel = props['submitLabel']?.toString() ?? '送信';
        result = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...children(),
            if (onSubmitAction != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: onAction != null
                      ? () => onAction(onSubmitAction)
                      : null,
                  child: Text(submitLabel),
                ),
              ),
          ],
        );
        break;

      case 'accordion':
        final acTitle   = props['title']?.toString() ?? 'アコーディオン';
        final acInitial = props['initiallyExpanded'] == true;
        final acBg      = _color(props['backgroundColor']);
        result = ExpansionTile(
          title:             Text(acTitle),
          initiallyExpanded: acInitial,
          backgroundColor:   acBg,
          children:          children(),
        );
        break;

      case 'drawer':
        final drawerW  = (props['width'] as num?)?.toDouble() ?? 280.0;
        final drawerBg = _color(props['backgroundColor']) ?? Colors.grey.shade100;
        result = Container(
          width: drawerW,
          color: drawerBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children(),
          ),
        );
        break;

      case 'app_bar':
        final abTitle    = props['title']?.toString() ?? '';
        final abBg       = _color(props['backgroundColor']);
        final abFg       = _color(props['foregroundColor']);
        final abElevation = (props['elevation'] as num?)?.toDouble() ?? 0.0;
        final abCenter   = props['centerTitle'] as bool? ?? true;
        result = PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppBar(
            title:           Text(abTitle),
            backgroundColor: abBg,
            foregroundColor: abFg,
            elevation:       abElevation,
            centerTitle:     abCenter,
          ),
        );
        break;

      case 'bottom_navigation_bar':
        var bnbItems = (props['items'] as List? ?? []).map((e) {
          final m = e is Map ? e as Map<String, dynamic> : <String, dynamic>{};
          return BottomNavigationBarItem(
            icon:  Icon(_parseIconData(m['icon']?.toString() ?? 'home')),
            label: m['label']?.toString() ?? '',
          );
        }).toList();
        if (bnbItems.length < 2) {
          bnbItems = [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ];
        }
        final bnbSelected = (props['selectedIndex'] as num?)?.toInt() ?? 0;
        result = BottomNavigationBar(
          items:        bnbItems,
          currentIndex: bnbSelected.clamp(0, bnbItems.length - 1),
          backgroundColor:  _color(props['backgroundColor']),
          selectedItemColor: _color(props['selectedColor']),
          onTap: (i) {
            if (bindKey != null && onStateChanged != null) {
              onStateChanged(bindKey, i);
            }
          },
        );
        break;

      case 'page_view':
        final pvAxis = props['scrollDirection'] == 'vertical'
            ? Axis.vertical
            : Axis.horizontal;
        final pvHeight = (props['height'] as num?)?.toDouble() ?? 200.0;
        result = SizedBox(
          height: pvHeight,
          child: PageView(
            scrollDirection: pvAxis,
            children:        children(),
          ),
        );
        break;

      case 'tab_bar':
        final tbTabs = (props['tabs'] as List? ?? []).map((e) {
          final m = e is Map ? e as Map<String, dynamic> : <String, dynamic>{};
          return Tab(
            text: m['label']?.toString(),
            icon: m['icon'] != null
                ? Icon(_parseIconData(m['icon'].toString()))
                : null,
          );
        }).toList();
        final tbBg        = _color(props['backgroundColor']);
        final tbLabelColor = _color(props['labelColor']);
        final tbIndicator  = _color(props['indicatorColor']);
        result = DefaultTabController(
          length: tbTabs.length,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                tabs:           tbTabs,
                labelColor:     tbLabelColor,
                indicatorColor: tbIndicator,
              ),
              if (childrenRaw.isNotEmpty)
                SizedBox(
                  height: 300,
                  child: TabBarView(children: children()),
                ),
            ],
          ),
        );
        break;

      // ─── Grid ─────────────────────────────────────────────────────
      case 'grid':
        result = GridView.count(
          shrinkWrap:      true,
          physics:         const NeverScrollableScrollPhysics(),
          crossAxisCount:  (props['crossAxisCount'] as num?)?.toInt() ?? 2,
          crossAxisSpacing:(props['crossAxisSpacing'] as num?)?.toDouble() ?? 8,
          mainAxisSpacing: (props['mainAxisSpacing'] as num?)?.toDouble() ?? 8,
          childAspectRatio:(props['childAspectRatio'] as num?)?.toDouble() ?? 1,
          children: children(),
        );
        break;

      // ─── List ─────────────────────────────────────────────────────
      case 'list_view':
        final rawBind  = node['bind']?.toString();
        final lvItems  = (resolvedValue as List?)
            ?? (rawBind != null ? (state?[rawBind] as List?) : null)
            ?? (props['items'] as List?)
            ?? [];
        if (lvItems.isEmpty) {
          result = Column(children: children());
          break;
        }
        final itemDsl =
            (props['item_template'] ?? props['item']) as Map<String, dynamic>?;
        if (itemDsl == null) return const SizedBox.shrink();
        result = ListView.builder(
          shrinkWrap:   true,
          physics:      const NeverScrollableScrollPhysics(),
          itemCount:    lvItems.length,
          itemBuilder:  (ctx, i) => _buildNode(
              _injectItem(itemDsl, lvItems[i]),
              onStateChanged: onStateChanged, onAction: onAction, state: state),
        );
        break;

      case 'loop':
        final loopItems = props['items'] as List? ?? [];
        final loopTemplate = (props['item_template'] ?? props['item']) as Map<String, dynamic>?;
        if (loopItems.isEmpty || loopTemplate == null) {
          result = const SizedBox.shrink();
          break;
        }
        result = Column(
          mainAxisSize: MainAxisSize.min,
          children: loopItems.map((_) => _buildNode(
            loopTemplate,
            onStateChanged: onStateChanged,
            onAction:       onAction,
            state:          state,
          )).toList(),
        );
        break;

      case 'data_table':
        final dtCols = (props['columns'] as List? ?? ['列1', '列2'])
            .map((c) => DataColumn(label: Text(c.toString())))
            .toList();
        final dtRows = (resolvedValue as List? ?? []).map((row) {
          final cells = row is List
              ? row.map((c) => DataCell(Text(c.toString()))).toList()
              : [DataCell(Text(row.toString()))];
          return DataRow(cells: cells);
        }).toList();
        result = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(columns: dtCols, rows: dtRows),
        );
        break;

      case 'sortable_list':
        result = ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (_, __) {},
          children: childrenRaw.asMap().entries.map((e) {
            return KeyedSubtree(
              key: ValueKey(e.key),
              child: _buildNode(
                e.value as Map<String, dynamic>,
                onStateChanged: onStateChanged,
                onAction:       onAction,
                state:          state,
              ),
            );
          }).toList(),
        );
        break;

      // ─── Interaction ──────────────────────────────────────────────
      case 'gesture_detector':
        final gdChild = childrenRaw.isNotEmpty ? firstChild() : const SizedBox.shrink();
        Map<String, dynamic>? toAct(String key) {
          final raw = node[key] ?? props[key];
          return raw is Map ? raw as Map<String, dynamic> : null;
        }
        final gdOnTap       = toAct('on_tap');
        final gdOnLp        = toAct('on_long_press');
        final gdOnDoubleTap = toAct('on_double_tap');
        if (gdOnTap == null && gdOnLp == null && gdOnDoubleTap == null) {
          result = gdChild;
        } else {
          result = GestureDetector(
            behavior:    HitTestBehavior.opaque,
            onTap:       gdOnTap       != null && onAction != null ? () => onAction(gdOnTap)       : null,
            onLongPress: gdOnLp        != null && onAction != null ? () => onAction(gdOnLp)        : null,
            onDoubleTap: gdOnDoubleTap != null && onAction != null ? () => onAction(gdOnDoubleTap) : null,
            child: gdChild,
          );
        }
        break;

      case 'pull_to_refresh':
        final ptrOnRefresh = (node['on_refresh'] ?? props['on_refresh']) is Map
            ? (node['on_refresh'] ?? props['on_refresh']) as Map<String, dynamic>
            : null;
        final ptrColor = _color(props['color']) ?? Colors.blueAccent;
        final ptrChild = childrenRaw.isNotEmpty ? firstChild() : const SizedBox.shrink();
        if (ptrOnRefresh == null) {
          result = ptrChild;
          break;
        }
        result = Builder(builder: (ctx) {
          return RefreshIndicator(
            color: ptrColor,
            onRefresh: () async {
              if (onAction != null) onAction(ptrOnRefresh);
            },
            child: ptrChild,
          );
        });
        break;

      case 'async_loader':
        final isLoading = resolvedValue == null;
        if (isLoading) {
          final loadColor = _color(props['loading_color']) ?? Colors.blueAccent;
          final loadLabel = props['loading_text']?.toString() ?? '読み込み中...';
          result = Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: loadColor, strokeWidth: 2),
                const SizedBox(height: 12),
                Text(loadLabel, style: TextStyle(color: loadColor, fontSize: 12)),
              ],
            ),
          );
        } else {
          result = childrenRaw.isNotEmpty ? firstChild() : const SizedBox.shrink();
        }
        break;

      case 'breadcrumb':
        final bcItems     = (props['items'] as List? ?? ['ホーム', '現在'])
            .map((e) => e.toString())
            .toList();
        final bcSep       = props['separator']?.toString() ?? '/';
        final bcColor     = _color(props['color']) ?? Colors.grey;
        final bcActive    = _color(props['activeColor']) ?? Colors.blue;
        final bcWidgets   = <Widget>[];
        for (var i = 0; i < bcItems.length; i++) {
          if (i > 0) {
            bcWidgets.add(Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(bcSep, style: TextStyle(color: bcColor)),
            ));
          }
          final isLast = i == bcItems.length - 1;
          bcWidgets.add(Text(
            bcItems[i],
            style: TextStyle(
              color: isLast ? bcActive : bcColor,
              fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
            ),
          ));
        }
        result = Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: bcWidgets,
        );
        break;

      // ─── Media placeholders ───────────────────────────────────────
      case 'lottie':
      case 'video_player':
      case 'youtube':
      case 'webview':
        final phW = (props['width']  as num?)?.toDouble();
        final phH = (props['height'] as num?)?.toDouble() ?? 200.0;
        final phLabel = type == 'lottie' ? 'Lottie'
            : type == 'video_player' ? '動画(MP4)'
            : type == 'youtube'      ? 'YouTube'
            : 'WebView';
        final phIcon = type == 'lottie'        ? Icons.auto_awesome
            : type == 'video_player' ? Icons.play_circle_outline
            : type == 'youtube'      ? Icons.smart_display_outlined
            : Icons.public;
        result = Container(
          width:  phW,
          height: phH,
          color:  Colors.grey.shade800,
          child:  Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(phIcon, color: Colors.white54, size: 32),
                const SizedBox(height: 8),
                Text(phLabel,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        );
        break;

      // ─── Navigation ───────────────────────────────────────────────
      case 'navigation_rail':
        final navBind = node['bind']?.toString();
        final navResolved = resolvedValue ?? (navBind != null ? (state?[navBind]) : null);
        final navIndex = (navResolved is int
                ? navResolved
                : int.tryParse(navResolved?.toString() ?? '0') ?? 0)
            .clamp(0, 9);

        final rawDests = props['destinations'] as List? ?? [];
        final navDests = rawDests.map((e) {
          final m = e is Map ? e as Map<String, dynamic> : <String, dynamic>{};
          return NavigationRailDestination(
            icon:  Icon(_parseIconData(m['icon']?.toString() ?? 'home')),
            label: Text(m['label']?.toString() ?? ''),
          );
        }).toList();
        if (navDests.isEmpty) return const SizedBox.shrink();

        final navChildDsls = childrenRaw.whereType<Map<String, dynamic>>().toList();
        final navSafe = navIndex.clamp(0, navChildDsls.isEmpty ? 0 : navChildDsls.length - 1);
        final navBg = _color(props['background']?.toString());

        return Row(
          children: [
            NavigationRail(
              backgroundColor: navBg,
              destinations: navDests,
              selectedIndex: navSafe,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (i) {
                if (navBind != null && onStateChanged != null) {
                  onStateChanged(navBind, i);
                }
              },
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: navChildDsls.isEmpty
                  ? const SizedBox.shrink()
                  : _buildNode(navChildDsls[navSafe],
                      onStateChanged: onStateChanged,
                      onAction: onAction,
                      state: state),
            ),
          ],
        );

      // ─── Pass-through (no-op) types ───────────────────────────────
      case 'interval_trigger':
      case 'realtime_listener':
        result = childrenRaw.isNotEmpty ? firstChild() : const SizedBox.shrink();
        break;

      default:
        return const SizedBox.shrink();
    }

    // ---------------------------------------------------------------
    // on_tap GestureDetector ラップ（selfTapTypes 以外）
    // ---------------------------------------------------------------
    if (!selfTapTypes.contains(type)) {
      final onTapRaw = node['on_tap'] ?? props['onTap'];
      if (onTapRaw is Map && onAction != null) {
        final tapAction = onTapRaw as Map<String, dynamic>;
        result = GestureDetector(
          onTap: () => onAction(tapAction),
          child: result,
        );
      }
    }

    // ---------------------------------------------------------------
    // _applyCommonStyle（width/height/margin/opacity）
    // container / card はここに到達しない（上で return している）
    // expanded / flexible も layout parent が管理するので skip
    // ---------------------------------------------------------------
    if (type != 'expanded' && type != 'flexible') {
      result = _applyCommonStyle(result, props);
    }

    return result;
  }

  // ---------------------------------------------------------------
  // list_view アイテムテンプレートにアイテム値を再帰注入
  // bind: "." のノードに resolved_value をセットする
  // ---------------------------------------------------------------
  static Map<String, dynamic> _injectItem(Map<String, dynamic> node, dynamic value) {
    final n = Map<String, dynamic>.from(node);
    if (n['bind']?.toString() == '.') n['resolved_value'] = value;
    if (n['children'] is List) {
      n['children'] = (n['children'] as List)
          .map((c) => _injectItem(c as Map<String, dynamic>, value))
          .toList();
    }
    return n;
  }

  // ---------------------------------------------------------------
  // 共通スタイル適用 — width/height/margin/opacity
  // ---------------------------------------------------------------
  static Widget _applyCommonStyle(Widget w, Map<String, dynamic> props) {
    final width   = (props['width']   as num?)?.toDouble();
    final height  = (props['height']  as num?)?.toDouble();
    final opacity = (props['opacity'] as num?)?.toDouble()?.clamp(0.0, 1.0);
    final margin  = _edgeInsets(props['margin']);

    if (width != null || height != null) {
      w = SizedBox(width: width, height: height, child: w);
    }
    if (margin != null) {
      w = Padding(padding: margin, child: w);
    }
    if (opacity != null && opacity < 1.0) {
      w = Opacity(opacity: opacity, child: w);
    }
    return w;
  }

  // container / card — size は内部処理済みなので margin/opacity のみ
  static Widget _applyCommonStyleSkipSize(Widget w, Map<String, dynamic> props) {
    final opacity = (props['opacity'] as num?)?.toDouble()?.clamp(0.0, 1.0);
    final margin  = _edgeInsets(props['margin']);

    if (margin != null) {
      w = Padding(padding: margin, child: w);
    }
    if (opacity != null && opacity < 1.0) {
      w = Opacity(opacity: opacity, child: w);
    }
    return w;
  }

  // ---------------------------------------------------------------
  // _textFieldDecoration — variant / borderRadius 対応
  // ---------------------------------------------------------------
  static InputDecoration _textFieldDecoration(
      Map<String, dynamic> props, String? error) {
    final label   = props['label']  as String?;
    final hint    = props['hint']   as String?;
    final variant = props['variant']?.toString() ?? 'outline';
    final br      = (props['borderRadius'] as num?)?.toDouble() ?? 8.0;
    final radius  = BorderRadius.circular(br);

    switch (variant) {
      case 'underline':
        return InputDecoration(
          labelText: label,
          hintText:  hint,
          errorText: error,
        );
      case 'filled':
        return InputDecoration(
          labelText: label,
          hintText:  hint,
          errorText: error,
          filled:    true,
          border:    UnderlineInputBorder(borderRadius: radius),
        );
      case 'none':
        return InputDecoration(
          labelText:     label,
          hintText:      hint,
          errorText:     error,
          border:        InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        );
      default: // outline
        return InputDecoration(
          labelText: label,
          hintText:  hint,
          errorText: error,
          border:        OutlineInputBorder(borderRadius: radius),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide:   const BorderSide(color: Colors.black38),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide:   const BorderSide(color: Colors.blue, width: 2),
          ),
        );
    }
  }

  // ---------------------------------------------------------------
  // 日付フォーマット
  // ---------------------------------------------------------------
  static String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  // ---------------------------------------------------------------
  // 色・スタイル・配置ユーティリティ
  // ---------------------------------------------------------------
  static Color? _color(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.startsWith('#')) {
      final hex = s.replaceFirst('#', '');
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    }
    return null;
  }

  static TextStyle? _textStyle(dynamic v) {
    if (v is! Map) return null;
    final m = v as Map<String, dynamic>;
    final base = TextStyle(
      fontSize:   (m['fontSize'] as num?)?.toDouble(),
      color:      _color(m['color']),
      fontWeight: m['weight'] == 'bold' ? FontWeight.bold : FontWeight.normal,
      fontStyle:  m['italic'] == true ? FontStyle.italic : FontStyle.normal,
    );
    final fontFamily = m['fontFamily'] as String?;
    if (fontFamily != null && fontFamily.isNotEmpty) {
      try { return GoogleFonts.getFont(fontFamily, textStyle: base); } catch (_) {
        return base.copyWith(fontFamily: fontFamily);
      }
    }
    return GoogleFonts.notoSansJp(textStyle: base);
  }

  static TextAlign? _textAlign(String? v) {
    switch (v) {
      case 'center':  return TextAlign.center;
      case 'right':   return TextAlign.right;
      case 'justify': return TextAlign.justify;
      default:        return null;
    }
  }

  static BoxFit _boxFit(String? v) {
    switch (v) {
      case 'contain':   return BoxFit.contain;
      case 'fill':      return BoxFit.fill;
      case 'fitWidth':  return BoxFit.fitWidth;
      case 'fitHeight': return BoxFit.fitHeight;
      default:          return BoxFit.cover;
    }
  }

  static MainAxisAlignment _mainAxis(String? v) {
    switch (v) {
      case 'center':       return MainAxisAlignment.center;
      case 'end':          return MainAxisAlignment.end;
      case 'spaceBetween': return MainAxisAlignment.spaceBetween;
      case 'spaceAround':  return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':  return MainAxisAlignment.spaceEvenly;
      default:             return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment _crossAxis(String? v) {
    switch (v) {
      case 'center':  return CrossAxisAlignment.center;
      case 'end':     return CrossAxisAlignment.end;
      case 'stretch': return CrossAxisAlignment.stretch;
      default:        return CrossAxisAlignment.start;
    }
  }

  static AlignmentGeometry? _alignment(String? v) {
    switch (v) {
      case 'center':       return Alignment.center;
      case 'topLeft':      return Alignment.topLeft;
      case 'topCenter':    return Alignment.topCenter;
      case 'topRight':     return Alignment.topRight;
      case 'centerLeft':   return Alignment.centerLeft;
      case 'centerRight':  return Alignment.centerRight;
      case 'bottomLeft':   return Alignment.bottomLeft;
      case 'bottomCenter': return Alignment.bottomCenter;
      case 'bottomRight':  return Alignment.bottomRight;
      default:             return null;
    }
  }

  static EdgeInsets? _edgeInsets(dynamic v) {
    if (v == null) return null;
    if (v is num) return EdgeInsets.all(v.toDouble());
    if (v is Map) {
      double s(String k) => (v[k] as num?)?.toDouble() ?? 0.0;
      return EdgeInsets.fromLTRB(s('left'), s('top'), s('right'), s('bottom'));
    }
    return null;
  }

  // ---------------------------------------------------------------
  // FontAwesome アイコンマップ
  // ---------------------------------------------------------------
  static FaIconData _parseFaIconData(String name) {
    const map = <String, FaIconData>{
      'arrow-left': FontAwesomeIcons.arrowLeft,
      'arrow-right': FontAwesomeIcons.arrowRight,
      'arrow-up': FontAwesomeIcons.arrowUp,
      'arrow-down': FontAwesomeIcons.arrowDown,
      'arrows-left-right': FontAwesomeIcons.arrowsLeftRight,
      'arrows-up-down': FontAwesomeIcons.arrowsUpDown,
      'arrows-rotate': FontAwesomeIcons.arrowsRotate,
      'arrow-up-right-from-square': FontAwesomeIcons.arrowUpRightFromSquare,
      'arrow-up-from-bracket': FontAwesomeIcons.arrowUpFromBracket,
      'chevron-left': FontAwesomeIcons.chevronLeft,
      'chevron-right': FontAwesomeIcons.chevronRight,
      'chevron-up': FontAwesomeIcons.chevronUp,
      'chevron-down': FontAwesomeIcons.chevronDown,
      'angles-left': FontAwesomeIcons.anglesLeft,
      'angles-right': FontAwesomeIcons.anglesRight,
      'angles-up': FontAwesomeIcons.anglesUp,
      'angles-down': FontAwesomeIcons.anglesDown,
      'rotate': FontAwesomeIcons.rotate,
      'rotate-left': FontAwesomeIcons.rotateLeft,
      'rotate-right': FontAwesomeIcons.rotateRight,
      'right-from-bracket': FontAwesomeIcons.rightFromBracket,
      'right-to-bracket': FontAwesomeIcons.rightToBracket,
      'house': FontAwesomeIcons.house,
      'bars': FontAwesomeIcons.bars,
      'ellipsis': FontAwesomeIcons.ellipsis,
      'ellipsis-vertical': FontAwesomeIcons.ellipsisVertical,
      'plus': FontAwesomeIcons.plus,
      'minus': FontAwesomeIcons.minus,
      'xmark': FontAwesomeIcons.xmark,
      'check': FontAwesomeIcons.check,
      'circle-plus': FontAwesomeIcons.circlePlus,
      'circle-minus': FontAwesomeIcons.circleMinus,
      'circle-check': FontAwesomeIcons.circleCheck,
      'circle-xmark': FontAwesomeIcons.circleXmark,
      'circle-info': FontAwesomeIcons.circleInfo,
      'circle-question': FontAwesomeIcons.circleQuestion,
      'circle-exclamation': FontAwesomeIcons.circleExclamation,
      'triangle-exclamation': FontAwesomeIcons.triangleExclamation,
      'sliders': FontAwesomeIcons.sliders,
      'filter': FontAwesomeIcons.filter,
      'sort': FontAwesomeIcons.sort,
      'list': FontAwesomeIcons.list,
      'list-ul': FontAwesomeIcons.listUl,
      'list-ol': FontAwesomeIcons.listOl,
      'table-columns': FontAwesomeIcons.tableColumns,
      'table-list': FontAwesomeIcons.tableList,
      'grip': FontAwesomeIcons.grip,
      'grip-lines': FontAwesomeIcons.gripLines,
      'grip-lines-vertical': FontAwesomeIcons.gripLinesVertical,
      'grip-vertical': FontAwesomeIcons.gripVertical,
      'square-check': FontAwesomeIcons.squareCheck,
      'toggle-on': FontAwesomeIcons.toggleOn,
      'toggle-off': FontAwesomeIcons.toggleOff,
      'spinner': FontAwesomeIcons.spinner,
      'expand': FontAwesomeIcons.expand,
      'compress': FontAwesomeIcons.compress,
      'maximize': FontAwesomeIcons.maximize,
      'magnifying-glass': FontAwesomeIcons.magnifyingGlass,
      'magnifying-glass-plus': FontAwesomeIcons.magnifyingGlassPlus,
      'magnifying-glass-minus': FontAwesomeIcons.magnifyingGlassMinus,
      'pen': FontAwesomeIcons.pen,
      'pen-to-square': FontAwesomeIcons.penToSquare,
      'pencil': FontAwesomeIcons.pencil,
      'eraser': FontAwesomeIcons.eraser,
      'trash': FontAwesomeIcons.trash,
      'trash-can': FontAwesomeIcons.trashCan,
      'scissors': FontAwesomeIcons.scissors,
      'copy': FontAwesomeIcons.copy,
      'paste': FontAwesomeIcons.paste,
      'paperclip': FontAwesomeIcons.paperclip,
      'file': FontAwesomeIcons.file,
      'file-lines': FontAwesomeIcons.fileLines,
      'file-code': FontAwesomeIcons.fileCode,
      'file-image': FontAwesomeIcons.fileImage,
      'file-pdf': FontAwesomeIcons.filePdf,
      'file-zipper': FontAwesomeIcons.fileZipper,
      'file-invoice': FontAwesomeIcons.fileInvoice,
      'file-invoice-dollar': FontAwesomeIcons.fileInvoiceDollar,
      'file-signature': FontAwesomeIcons.fileSignature,
      'file-export': FontAwesomeIcons.fileExport,
      'file-import': FontAwesomeIcons.fileImport,
      'folder': FontAwesomeIcons.folder,
      'folder-open': FontAwesomeIcons.folderOpen,
      'folder-plus': FontAwesomeIcons.folderPlus,
      'folder-minus': FontAwesomeIcons.folderMinus,
      'play': FontAwesomeIcons.play,
      'pause': FontAwesomeIcons.pause,
      'stop': FontAwesomeIcons.stop,
      'forward': FontAwesomeIcons.forward,
      'backward': FontAwesomeIcons.backward,
      'fast-forward': FontAwesomeIcons.forwardFast,
      'fast-backward': FontAwesomeIcons.backwardFast,
      'music': FontAwesomeIcons.music,
      'headphones': FontAwesomeIcons.headphones,
      'microphone': FontAwesomeIcons.microphone,
      'microphone-slash': FontAwesomeIcons.microphoneSlash,
      'video': FontAwesomeIcons.video,
      'video-slash': FontAwesomeIcons.videoSlash,
      'film': FontAwesomeIcons.film,
      'tv': FontAwesomeIcons.tv,
      'radio': FontAwesomeIcons.radio,
      'volume-high': FontAwesomeIcons.volumeHigh,
      'volume-low': FontAwesomeIcons.volumeLow,
      'volume-off': FontAwesomeIcons.volumeOff,
      'volume-xmark': FontAwesomeIcons.volumeXmark,
      'podcast': FontAwesomeIcons.podcast,
      'record-vinyl': FontAwesomeIcons.recordVinyl,
      'compact-disc': FontAwesomeIcons.compactDisc,
      'camera': FontAwesomeIcons.camera,
      'camera-retro': FontAwesomeIcons.cameraRetro,
      'image': FontAwesomeIcons.image,
      'images': FontAwesomeIcons.images,
      'photo-film': FontAwesomeIcons.photoFilm,
      'phone': FontAwesomeIcons.phone,
      'phone-slash': FontAwesomeIcons.phoneSlash,
      'phone-flip': FontAwesomeIcons.phoneFlip,
      'envelope': FontAwesomeIcons.envelope,
      'envelope-open': FontAwesomeIcons.envelopeOpen,
      'comment': FontAwesomeIcons.comment,
      'comment-dots': FontAwesomeIcons.commentDots,
      'comments': FontAwesomeIcons.comments,
      'paper-plane': FontAwesomeIcons.paperPlane,
      'share-nodes': FontAwesomeIcons.shareNodes,
      'share': FontAwesomeIcons.share,
      'link': FontAwesomeIcons.link,
      'at': FontAwesomeIcons.at,
      'hashtag': FontAwesomeIcons.hashtag,
      'inbox': FontAwesomeIcons.inbox,
      'reply': FontAwesomeIcons.reply,
      'reply-all': FontAwesomeIcons.replyAll,
      'message': FontAwesomeIcons.message,
      'bell': FontAwesomeIcons.bell,
      'bell-slash': FontAwesomeIcons.bellSlash,
      'star': FontAwesomeIcons.star,
      'star-half-stroke': FontAwesomeIcons.starHalfStroke,
      'heart': FontAwesomeIcons.heart,
      'heart-crack': FontAwesomeIcons.heartCrack,
      'heart-pulse': FontAwesomeIcons.heartPulse,
      'bookmark': FontAwesomeIcons.bookmark,
      'user': FontAwesomeIcons.user,
      'user-plus': FontAwesomeIcons.userPlus,
      'user-minus': FontAwesomeIcons.userMinus,
      'user-check': FontAwesomeIcons.userCheck,
      'user-slash': FontAwesomeIcons.userSlash,
      'user-secret': FontAwesomeIcons.userSecret,
      'user-tie': FontAwesomeIcons.userTie,
      'users': FontAwesomeIcons.users,
      'user-group': FontAwesomeIcons.userGroup,
      'person': FontAwesomeIcons.person,
      'person-running': FontAwesomeIcons.personRunning,
      'person-walking': FontAwesomeIcons.personWalking,
      'person-biking': FontAwesomeIcons.personBiking,
      'person-swimming': FontAwesomeIcons.personSwimming,
      'child': FontAwesomeIcons.child,
      'children': FontAwesomeIcons.children,
      'handshake': FontAwesomeIcons.handshake,
      'hand-pointer': FontAwesomeIcons.handPointer,
      'thumbs-up': FontAwesomeIcons.thumbsUp,
      'thumbs-down': FontAwesomeIcons.thumbsDown,
      'fingerprint': FontAwesomeIcons.fingerprint,
      'face-smile': FontAwesomeIcons.faceSmile,
      'face-frown': FontAwesomeIcons.faceFrown,
      'face-angry': FontAwesomeIcons.faceAngry,
      'face-surprise': FontAwesomeIcons.faceSurprise,
      'face-grimace': FontAwesomeIcons.faceGrimace,
      'face-grin': FontAwesomeIcons.faceGrin,
      'face-laugh': FontAwesomeIcons.faceLaugh,
      'face-meh': FontAwesomeIcons.faceMeh,
      'face-tired': FontAwesomeIcons.faceTired,
      'sun': FontAwesomeIcons.sun,
      'moon': FontAwesomeIcons.moon,
      'cloud': FontAwesomeIcons.cloud,
      'cloud-sun': FontAwesomeIcons.cloudSun,
      'cloud-rain': FontAwesomeIcons.cloudRain,
      'cloud-showers-heavy': FontAwesomeIcons.cloudShowersHeavy,
      'cloud-bolt': FontAwesomeIcons.cloudBolt,
      'snowflake': FontAwesomeIcons.snowflake,
      'wind': FontAwesomeIcons.wind,
      'tornado': FontAwesomeIcons.tornado,
      'bolt': FontAwesomeIcons.bolt,
      'umbrella': FontAwesomeIcons.umbrella,
      'rainbow': FontAwesomeIcons.rainbow,
      'fire': FontAwesomeIcons.fire,
      'fire-flame-curved': FontAwesomeIcons.fireFlameCurved,
      'water': FontAwesomeIcons.water,
      'droplet': FontAwesomeIcons.droplet,
      'tree': FontAwesomeIcons.tree,
      'leaf': FontAwesomeIcons.leaf,
      'seedling': FontAwesomeIcons.seedling,
      'mountain': FontAwesomeIcons.mountain,
      'earth-americas': FontAwesomeIcons.earthAmericas,
      'globe': FontAwesomeIcons.globe,
      'paw': FontAwesomeIcons.paw,
      'dove': FontAwesomeIcons.dove,
      'fish': FontAwesomeIcons.fish,
      'utensils': FontAwesomeIcons.utensils,
      'mug-hot': FontAwesomeIcons.mugHot,
      'wine-glass': FontAwesomeIcons.wineGlass,
      'beer-mug-empty': FontAwesomeIcons.beerMugEmpty,
      'pizza-slice': FontAwesomeIcons.pizzaSlice,
      'burger': FontAwesomeIcons.burger,
      'hotdog': FontAwesomeIcons.hotdog,
      'ice-cream': FontAwesomeIcons.iceCream,
      'lemon': FontAwesomeIcons.lemon,
      'carrot': FontAwesomeIcons.carrot,
      'egg': FontAwesomeIcons.egg,
      'bread-slice': FontAwesomeIcons.breadSlice,
      'apple-whole': FontAwesomeIcons.appleWhole,
      'cake-candles': FontAwesomeIcons.cakeCandles,
      'candy-cane': FontAwesomeIcons.candyCane,
      'cookie': FontAwesomeIcons.cookie,
      'blender': FontAwesomeIcons.blender,
      'car': FontAwesomeIcons.car,
      'car-side': FontAwesomeIcons.carSide,
      'bus': FontAwesomeIcons.bus,
      'train': FontAwesomeIcons.train,
      'train-subway': FontAwesomeIcons.trainSubway,
      'plane': FontAwesomeIcons.plane,
      'plane-up': FontAwesomeIcons.planeUp,
      'ship': FontAwesomeIcons.ship,
      'bicycle': FontAwesomeIcons.bicycle,
      'motorcycle': FontAwesomeIcons.motorcycle,
      'truck': FontAwesomeIcons.truck,
      'taxi': FontAwesomeIcons.taxi,
      'rocket': FontAwesomeIcons.rocket,
      'helicopter': FontAwesomeIcons.helicopter,
      'sailboat': FontAwesomeIcons.sailboat,
      'road': FontAwesomeIcons.road,
      'gas-pump': FontAwesomeIcons.gasPump,
      'traffic-light': FontAwesomeIcons.trafficLight,
      'anchor': FontAwesomeIcons.anchor,
      'suitcase': FontAwesomeIcons.suitcase,
      'suitcase-rolling': FontAwesomeIcons.suitcaseRolling,
      'passport': FontAwesomeIcons.passport,
      'map-location-dot': FontAwesomeIcons.mapLocationDot,
      'location-dot': FontAwesomeIcons.locationDot,
      'location-crosshairs': FontAwesomeIcons.locationCrosshairs,
      'map': FontAwesomeIcons.map,
      'map-pin': FontAwesomeIcons.mapPin,
      'compass': FontAwesomeIcons.compass,
      'route': FontAwesomeIcons.route,
      'street-view': FontAwesomeIcons.streetView,
      'building': FontAwesomeIcons.building,
      'building-columns': FontAwesomeIcons.buildingColumns,
      'hospital': FontAwesomeIcons.hospital,
      'school': FontAwesomeIcons.school,
      'store': FontAwesomeIcons.store,
      'landmark': FontAwesomeIcons.landmark,
      'church': FontAwesomeIcons.church,
      'mosque': FontAwesomeIcons.mosque,
      'synagogue': FontAwesomeIcons.synagogue,
      'hotel': FontAwesomeIcons.hotel,
      'warehouse': FontAwesomeIcons.warehouse,
      'industry': FontAwesomeIcons.industry,
      'city': FontAwesomeIcons.city,
      'briefcase': FontAwesomeIcons.briefcase,
      'clipboard': FontAwesomeIcons.clipboard,
      'clipboard-list': FontAwesomeIcons.clipboardList,
      'clipboard-check': FontAwesomeIcons.clipboardCheck,
      'tag': FontAwesomeIcons.tag,
      'tags': FontAwesomeIcons.tags,
      'cart-shopping': FontAwesomeIcons.cartShopping,
      'cart-plus': FontAwesomeIcons.cartPlus,
      'bag-shopping': FontAwesomeIcons.bagShopping,
      'credit-card': FontAwesomeIcons.creditCard,
      'money-bill': FontAwesomeIcons.moneyBill,
      'money-bill-wave': FontAwesomeIcons.moneyBillWave,
      'coins': FontAwesomeIcons.coins,
      'piggy-bank': FontAwesomeIcons.piggyBank,
      'hand-holding-dollar': FontAwesomeIcons.handHoldingDollar,
      'dollar-sign': FontAwesomeIcons.dollarSign,
      'euro-sign': FontAwesomeIcons.euroSign,
      'yen-sign': FontAwesomeIcons.yenSign,
      'sterling-sign': FontAwesomeIcons.sterlingSign,
      'receipt': FontAwesomeIcons.receipt,
      'calculator': FontAwesomeIcons.calculator,
      'chart-bar': FontAwesomeIcons.chartBar,
      'chart-line': FontAwesomeIcons.chartLine,
      'chart-pie': FontAwesomeIcons.chartPie,
      'chart-simple': FontAwesomeIcons.chartSimple,
      'gauge': FontAwesomeIcons.gauge,
      'percent': FontAwesomeIcons.percent,
      'trophy': FontAwesomeIcons.trophy,
      'award': FontAwesomeIcons.award,
      'medal': FontAwesomeIcons.medal,
      'crown': FontAwesomeIcons.crown,
      'gem': FontAwesomeIcons.gem,
      'gear': FontAwesomeIcons.gear,
      'gears': FontAwesomeIcons.gears,
      'laptop': FontAwesomeIcons.laptop,
      'desktop': FontAwesomeIcons.desktop,
      'mobile-screen': FontAwesomeIcons.mobileScreen,
      'tablet-screen-button': FontAwesomeIcons.tabletScreenButton,
      'keyboard': FontAwesomeIcons.keyboard,
      'print': FontAwesomeIcons.print,
      'server': FontAwesomeIcons.server,
      'database': FontAwesomeIcons.database,
      'microchip': FontAwesomeIcons.microchip,
      'memory': FontAwesomeIcons.memory,
      'hard-drive': FontAwesomeIcons.hardDrive,
      'wifi': FontAwesomeIcons.wifi,
      'signal': FontAwesomeIcons.signal,
      'qrcode': FontAwesomeIcons.qrcode,
      'barcode': FontAwesomeIcons.barcode,
      'robot': FontAwesomeIcons.robot,
      'code': FontAwesomeIcons.code,
      'code-branch': FontAwesomeIcons.codeBranch,
      'terminal': FontAwesomeIcons.terminal,
      'bug': FontAwesomeIcons.bug,
      'newspaper': FontAwesomeIcons.newspaper,
      'cloud-arrow-down': FontAwesomeIcons.cloudArrowDown,
      'cloud-arrow-up': FontAwesomeIcons.cloudArrowUp,
      'download': FontAwesomeIcons.download,
      'upload': FontAwesomeIcons.upload,
      'lock': FontAwesomeIcons.lock,
      'lock-open': FontAwesomeIcons.lockOpen,
      'eye': FontAwesomeIcons.eye,
      'eye-slash': FontAwesomeIcons.eyeSlash,
      'shield-halved': FontAwesomeIcons.shieldHalved,
      'key': FontAwesomeIcons.key,
      'ban': FontAwesomeIcons.ban,
      'shield': FontAwesomeIcons.shield,
      'clock': FontAwesomeIcons.clock,
      'hourglass': FontAwesomeIcons.hourglass,
      'hourglass-half': FontAwesomeIcons.hourglassHalf,
      'stopwatch': FontAwesomeIcons.stopwatch,
      'calendar': FontAwesomeIcons.calendar,
      'calendar-days': FontAwesomeIcons.calendarDays,
      'calendar-check': FontAwesomeIcons.calendarCheck,
      'calendar-plus': FontAwesomeIcons.calendarPlus,
      'calendar-minus': FontAwesomeIcons.calendarMinus,
      'calendar-xmark': FontAwesomeIcons.calendarXmark,
      'wrench': FontAwesomeIcons.wrench,
      'hammer': FontAwesomeIcons.hammer,
      'screwdriver': FontAwesomeIcons.screwdriver,
      'screwdriver-wrench': FontAwesomeIcons.screwdriverWrench,
      'toolbox': FontAwesomeIcons.toolbox,
      'paintbrush': FontAwesomeIcons.paintbrush,
      'palette': FontAwesomeIcons.palette,
      'eye-dropper': FontAwesomeIcons.eyeDropper,
      'ruler': FontAwesomeIcons.ruler,
      'ruler-combined': FontAwesomeIcons.rulerCombined,
      'drafting-compass': FontAwesomeIcons.compassDrafting,
      'wand-magic-sparkles': FontAwesomeIcons.wandMagicSparkles,
      'stethoscope': FontAwesomeIcons.stethoscope,
      'pills': FontAwesomeIcons.pills,
      'syringe': FontAwesomeIcons.syringe,
      'bandage': FontAwesomeIcons.bandage,
      'kit-medical': FontAwesomeIcons.kitMedical,
      'prescription-bottle': FontAwesomeIcons.prescriptionBottle,
      'wheelchair': FontAwesomeIcons.wheelchair,
      'weight-scale': FontAwesomeIcons.weightScale,
      'dumbbell': FontAwesomeIcons.dumbbell,
      'futbol': FontAwesomeIcons.futbol,
      'basketball': FontAwesomeIcons.basketball,
      'baseball': FontAwesomeIcons.baseball,
      'football': FontAwesomeIcons.football,
      'volleyball': FontAwesomeIcons.volleyball,
      'golf-ball-tee': FontAwesomeIcons.golfBallTee,
      'table-tennis-paddle-ball': FontAwesomeIcons.tableTennisPaddleBall,
      'gift': FontAwesomeIcons.gift,
      'ribbon': FontAwesomeIcons.ribbon,
      'ticket': FontAwesomeIcons.ticket,
      'gamepad': FontAwesomeIcons.gamepad,
      'dice': FontAwesomeIcons.dice,
      'puzzle-piece': FontAwesomeIcons.puzzlePiece,
      'lightbulb': FontAwesomeIcons.lightbulb,
      'satellite': FontAwesomeIcons.satellite,
      'satellite-dish': FontAwesomeIcons.satelliteDish,
      'tower-broadcast': FontAwesomeIcons.towerBroadcast,
      'atom': FontAwesomeIcons.atom,
      'flask': FontAwesomeIcons.flask,
      'microscope': FontAwesomeIcons.microscope,
      'recycle': FontAwesomeIcons.recycle,
      'circle': FontAwesomeIcons.circle,
      'square': FontAwesomeIcons.square,
      'infinity': FontAwesomeIcons.infinity,
      'question': FontAwesomeIcons.question,
      'exclamation': FontAwesomeIcons.exclamation,
      'flag': FontAwesomeIcons.flag,
      'up-right-and-down-left-from-center': FontAwesomeIcons.upRightAndDownLeftFromCenter,
      'down-left-and-up-right-to-center': FontAwesomeIcons.downLeftAndUpRightToCenter,
    };
    return map[name] ?? FontAwesomeIcons.star;
  }

  // ---------------------------------------------------------------
  // Material アイコンマップ
  // ---------------------------------------------------------------
  static IconData _parseIconData(String name) {
    const map = <String, IconData>{
      'home': Icons.home,
      'search': Icons.search,
      'person': Icons.person,
      'settings': Icons.settings,
      'star': Icons.star,
      'favorite': Icons.favorite,
      'add': Icons.add,
      'remove': Icons.remove,
      'close': Icons.close,
      'check': Icons.check,
      'arrow_back': Icons.arrow_back,
      'arrow_forward': Icons.arrow_forward,
      'arrow_upward': Icons.arrow_upward,
      'arrow_downward': Icons.arrow_downward,
      'menu': Icons.menu,
      'info': Icons.info,
      'warning': Icons.warning,
      'error': Icons.error,
      'phone': Icons.phone,
      'email': Icons.email,
      'lock': Icons.lock,
      'camera': Icons.camera_alt,
      'image': Icons.image,
      'map': Icons.map,
      'location_on': Icons.location_on,
      'notifications': Icons.notifications,
      'calendar_today': Icons.calendar_today,
      'download': Icons.download,
      'upload': Icons.upload,
      'refresh': Icons.refresh,
      'more_vert': Icons.more_vert,
      'filter_list': Icons.filter_list,
      'sort': Icons.sort,
      'list': Icons.list,
      'grid_view': Icons.grid_view,
      'bar_chart': Icons.bar_chart,
      'help': Icons.help,
      'bolt': Icons.bolt,
      'logout': Icons.logout,
      'shopping_cart': Icons.shopping_cart,
      'credit_card': Icons.credit_card,
      'store': Icons.store,
      'label': Icons.label,
      'work': Icons.work,
      'group': Icons.group,
      'chat': Icons.chat,
      'thumb_up': Icons.thumb_up,
      'thumb_down': Icons.thumb_down,
      'schedule': Icons.schedule,
      'bookmark': Icons.bookmark,
      'article': Icons.article,
      'qr_code': Icons.qr_code,
      'wifi': Icons.wifi,
      'smartphone': Icons.smartphone,
      'laptop': Icons.laptop,
      'desktop_mac': Icons.desktop_mac,
      'keyboard': Icons.keyboard,
      'print': Icons.print,
      'content_copy': Icons.content_copy,
      'link': Icons.link,
      'flag': Icons.flag,
      'security': Icons.security,
      'key': Icons.key,
      'block': Icons.block,
      'local_fire_department': Icons.local_fire_department,
      'bug_report': Icons.bug_report,
      'cloud': Icons.cloud,
      'cloud_download': Icons.cloud_download,
      'cloud_upload': Icons.cloud_upload,
      'show_chart': Icons.show_chart,
      'pie_chart': Icons.pie_chart,
      'speed': Icons.speed,
      'paid': Icons.paid,
      'receipt': Icons.receipt,
      'calculate': Icons.calculate,
      'local_hospital': Icons.local_hospital,
      'healing': Icons.healing,
      'medication': Icons.medication,
    };
    return map[name] ?? Icons.help_outline;
  }
}

// =================================================================
// _InputField — text_field / number_field 用 StatefulWidget
// =================================================================
class _InputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String  variant;
  final double  borderRadius;
  final String  initialValue;
  final bool    multiline;
  final bool    numeric;
  final ValueChanged<String>? onChanged;

  const _InputField({
    this.label,
    this.hint,
    this.variant      = 'outline',
    this.borderRadius = 8.0,
    this.initialValue = '',
    this.multiline    = false,
    this.numeric      = false,
    this.onChanged,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_InputField old) {
    super.didUpdateWidget(old);
    if (old.initialValue != widget.initialValue &&
        _ctrl.text != widget.initialValue) {
      _ctrl.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = WidgetFactoryLite._textFieldDecoration(
      {
        'label': widget.label,
        'hint':  widget.hint,
        'variant':      widget.variant,
        'borderRadius': widget.borderRadius,
      },
      null,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: TextField(
        controller:   _ctrl,
        decoration:   decoration,
        keyboardType: widget.numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : widget.multiline
                ? TextInputType.multiline
                : TextInputType.text,
        maxLines:  widget.multiline ? null : 1,
        onChanged: widget.onChanged,
      ),
    );
  }
}

// =================================================================
// _SearchField — search_field 用 StatefulWidget
// =================================================================
class _SearchField extends StatefulWidget {
  final String  placeholder;
  final double  borderRadius;
  final String  initialValue;
  final ValueChanged<String>? onChanged;

  const _SearchField({
    this.placeholder  = '検索...',
    this.borderRadius = 24.0,
    this.initialValue = '',
    this.onChanged,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_SearchField old) {
    super.didUpdateWidget(old);
    if (old.initialValue != widget.initialValue &&
        _ctrl.text != widget.initialValue) {
      _ctrl.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final br = widget.borderRadius;
    return TextField(
      controller: _ctrl,
      onChanged:  widget.onChanged,
      decoration: InputDecoration(
        hintText:   widget.placeholder,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(br),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(br),
          borderSide:   const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(br),
          borderSide:   const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}
