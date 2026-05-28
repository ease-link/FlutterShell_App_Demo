# ShellApp_Codelabs_flutter 起動〜画面描画フロー

```mermaid
flowchart TD
    A["main()"] --> B["ShellAppRuntime.init()"]
    B --> C["runApp(ShellApp)"]
    C --> D["MaterialApp<br/>initialRoute: /main"]
    D --> E["MainScreen<br/>initState()"]
    E --> F["FunctionActions.initialState()<br/>state を初期化<br/>currentWord / favorites / selectedNavIndex"]
    F --> G["rootBundle.loadString<br/>assets/uidsl/screens/main.json"]
    G --> H["jsonDecode<br/>UIDSL Map を取得"]
    H --> I["ShellAppRuntime.execute<br/>uidsl + state を渡す"]

    I --> J{Native DLL<br/>利用可能?}
    J -->|Yes Desktop| K["Go DLL<br/>bind 解決 / visibility 評価<br/>resolved_widget を返す"]
    J -->|No Web| L["native_unavailable<br/>生 UIDSL をそのまま使用"]

    K --> M["setState<br/>_resolvedWidget に格納"]
    L --> M

    M --> N["build<br/>Scaffold + SafeArea"]
    N --> O{root type ==<br/>navigation_rail?}

    O -->|Yes| P["NavigationRailWidget<br/>state の selectedNavIndex で<br/>アクティブタブ決定"]
    O -->|No| Q["WidgetFactoryLite.build()"]

    P --> R["NavigationRail<br/>左サイドバー描画"]
    P --> S["選択中タブの子ノード<br/>WidgetFactoryLite.build()"]

    S --> T["_buildNode 再帰処理<br/>type で switch"]
    Q --> T

    T -->|column / row| U["Column / Row<br/>children 再帰"]
    T -->|text| V["Text<br/>currentWord をテンプレート補間"]
    T -->|card| W["Card<br/>children 再帰"]
    T -->|button| X["ElevatedButton<br/>onPressed に _onAction をセット"]
    T -->|list_view| Y["ListView.builder<br/>favorites リストを展開"]

    U & V & W & X & Y --> Z["Flutter Widget ツリー完成<br/>画面表示"]

    Z --> AA["Next ボタン押下"]
    AA --> AB["_onAction<br/>type: functionCall<br/>name: getNext<br/>storeKey: currentWord"]
    AB --> AC["AppActions.handle<br/>type で振り分け"]
    AC --> AD["FunctionActions.call<br/>getNext<br/>新しい単語ペアを返す"]
    AD --> AE["onStateChanged<br/>currentWord = cozy castle"]
    AE --> AF["setState<br/>_state 更新"]
    AF --> G
```

---

## 各レイヤーの役割

| レイヤー | ファイル | 役割 |
|---|---|---|
| エントリーポイント | `main.dart` | アプリ初期化・ルーティング定義 |
| 画面ホルダー | `screens/main_screen.dart` | state 管理・UIDSL ロード・再描画サイクル |
| ランタイム | `shellapp_runtime` | bind 解決・visibility 評価（Desktop: Go DLL / Web: スタブ） |
| ビジネスロジック | `actions/function_actions.dart` | 単語生成・お気に入り管理 |
| アクション振り分け | `actions/app_actions.dart` | functionCall / navigate / setState 等を各ハンドラへ委譲 |
| UI プラグイン | `plugins/navigation_rail_widget.dart` | NavigationRail の UIDSL → Widget 変換 |
| Widget 変換エンジン | `shellapp/widget_factory_lite.dart` | UIDSL type → Flutter Widget への再帰変換 |
| UI 定義 | `assets/uidsl/screens/main.json` | 画面構造・バインド・アクションを JSON で記述 |
