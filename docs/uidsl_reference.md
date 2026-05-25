# UIDSL リファレンス

UIDSL（UI Domain Specific Language）は Flutter の Widget Tree を JSON で表現したもの。  
ShellApp Runtime が解決し、ネイティブ Flutter Widget として描画される。

---

## UIDSL の思想

ShellApp が UIDSL を採用している理由は、「UI をサーバーから配信する」という設計思想にある。

| 目的 | 説明 |
|------|------|
| **動的更新** | アプリを再ビルド・再審査することなく、UIをサーバーから即時変更できる |
| **マルチテナント対応** | テナントごとに異なる UIDSL を配信するだけで画面をカスタマイズできる |
| **A/B テスト** | `ab` コンポーネントでユーザーセグメント別の UI を切り替えられる |
| **審査対策** | UIDSL は「設定データ」であり任意コードを含まないため、Apple/Google 規約に適合する |
| **分業の実現** | デザイナーは UIDSL を編集、エンジニアは `actions/` だけ触ればよい。完全並列開発が可能 |
| **仕様書との一体化** | UIDSL が UI の仕様書を兼ねるため、別途ドキュメントが不要になる |

> **コアコンセプト：UI × Action × State の三位一体**  
> UIDSL が「見た目」を定義し、Action が「動作」を定義し、BindStore（State）が「状態」を一元管理する。  
> この分離により、変更の影響範囲が明確になり、バグの切り分けが容易になる。

---

## 基本構造

```json
{
  "id": "unique_id",
  "type": "widget_type",
  "props": { },
  "bind": "stateKey",
  "children": []
}
```

| フィールド | 必須 | 説明 |
|-----------|------|------|
| `id` | ✅ | ユニークなID |
| `type` | ✅ | ウィジェットタイプ |
| `props` | — | 表示プロパティ |
| `bind` | — | stateのキーを紐付け（双方向バインド） |
| `children` | — | 子ウィジェット |

### 共通スタイル props（全ウィジェットに使える）

| props | 型 | 説明 |
|-------|----|------|
| `backgroundColor` | String | 背景色（`#RRGGBB`） |
| `borderRadius` | num / Object | 角丸（数値で全角、`{"topLeft":8,"topRight":8}` で個別指定） |
| `shadow` | Object | 影（`{"color":"#00000033","blurRadius":8,"offsetX":0,"offsetY":4}`） |
| `border` | Object | 枠線（`{"color":"#CCCCCC","width":1}`） |
| `width` | num | 横幅 |
| `height` | num | 縦幅 |
| `margin` | num / Object | 外側の余白 |
| `opacity` | num | 透明度（0.0〜1.0） |
| `padding` | num / Object | 内側の余白（`container` / `padding` / `card` 以外で使用可） |
| `hover` | Object | ホバー時のスタイル（`{"backgroundColor":"#EEEEEE"}`） |
| `active` | Object | タップ中のスタイル |
| `transition` | num | アニメーション時間（ms）。`hover` / `active` と合わせて使う |
| `onTap` | Object | タップ時アクション（ボタン・入力系以外のウィジェットに付与可） |
| `onLongPress` | Object | 長押し時アクション |

---

## Meta スキーマ

業務アプリの画面は「リスト・詳細・フォーム・タブ・ステップ・テーブル・ダッシュボード」の  
**7パターンで90%以上が構成される**。

`meta` フィールドを使うと、この画面パターンを Widget の組み合わせではなく  
「画面の型」として宣言的に定義できる。

```
通常の UIDSL（Widget 単位）
  type / props / bind / children の4層を毎回記述

Meta スキーマ（画面パターン単位）
  meta で型を宣言 → 詳細は meta 専用フィールドで埋めるだけ
  → 記述量が通常の 1/5〜1/10 になる
```

### `meta: "list"` — リスト画面

```json
{
  "meta": "list",
  "source": "api/products",
  "item": {
    "type": "row",
    "children": [
      { "id": "item_name",  "type": "text", "bind": "name" },
      { "id": "item_price", "type": "text", "bind": "price" }
    ]
  }
}
```

| フィールド | 説明 |
|-----------|------|
| `source` | データソース（API エンドポイントまたは BindStore キー） |
| `item` | 各行の DSL ノード |

---

### `meta: "detail"` — 詳細画面

```json
{
  "meta": "detail",
  "source": "api/products/{{productId}}",
  "layout": [
    { "label": "商品名",   "field": "name" },
    { "label": "価格",     "field": "price" },
    { "label": "在庫数",   "field": "stock" },
    { "label": "カテゴリ", "field": "category.name" }
  ]
}
```

| フィールド | 説明 |
|-----------|------|
| `source` | データ取得 URL（`{{key}}` 展開可） |
| `layout` | 表示するフィールドの定義。`label` と `field`（ドット記法可）のペア |

---

### `meta: "form"` — 入力フォーム画面

```json
{
  "meta": "form",
  "bind": "productForm",
  "fields": [
    { "type": "text_field",   "bind": "name",     "props": { "label": "商品名",   "required": true } },
    { "type": "number_field", "bind": "price",    "props": { "label": "価格",     "required": true } },
    { "type": "dropdown",     "bind": "category", "props": { "label": "カテゴリ", "items": "api/categories" } },
    { "type": "text_field",   "bind": "memo",     "props": { "label": "備考",     "multiline": true } }
  ],
  "onSubmit": { "type": "functionCall", "name": "saveProduct" }
}
```

| フィールド | 説明 |
|-----------|------|
| `bind` | フォーム全体の BindStore キー（フォーム状態をオブジェクトとして管理） |
| `fields` | 入力フィールドの DSL ノード配列 |
| `onSubmit` | バリデーション通過後に実行するアクション |

---

### `meta: "tabs"` — タブ画面

```json
{
  "meta": "tabs",
  "tabs": [
    { "label": "基本情報", "content": { "type": "column", "children": [...] } },
    { "label": "履歴",     "content": { "type": "list_view", "props": { "bind": "history" } } },
    { "label": "設定",     "content": { "type": "column", "children": [...] } }
  ]
}
```

| フィールド | 説明 |
|-----------|------|
| `tabs` | タブ定義の配列。`label`（タブラベル）と `content`（コンテンツ DSL）のペア |

---

### `meta: "flow"` — ステップ／ウィザード画面

```json
{
  "meta": "flow",
  "steps": [
    { "title": "配送先入力",   "content": { ... } },
    { "title": "内容確認",     "content": { ... } },
    { "title": "お支払い",     "content": { ... } },
    { "title": "完了",         "content": { ... } }
  ]
}
```

| フィールド | 説明 |
|-----------|------|
| `steps` | ステップ定義の配列。`title`（ステップ名）と `content`（コンテンツ DSL）のペア |

進捗バーと「次へ」「戻る」ボタンは Meta ランタイムが自動で生成する。

---

### `meta: "table"` — テーブル表示

```json
{
  "meta": "table",
  "source": "api/orders",
  "columns": [
    { "label": "注文ID",   "field": "id" },
    { "label": "顧客名",   "field": "customer.name" },
    { "label": "金額",     "field": "totalAmount" },
    { "label": "ステータス", "field": "status" }
  ]
}
```

| フィールド | 説明 |
|-----------|------|
| `source` | データ取得 URL または BindStore キー |
| `columns` | 列定義。`label`（ヘッダー）と `field`（ドット記法可）のペア |

---

### `meta: "dashboard"` — ダッシュボード

```json
{
  "meta": "dashboard",
  "widgets": [
    { "type": "stat",  "props": { "label": "今月売上",   "bind": "monthlySales" } },
    { "type": "stat",  "props": { "label": "注文件数",   "bind": "orderCount" } },
    { "type": "chart", "props": { "label": "売上推移",   "source": "api/chart/monthly" } },
    { "type": "list",  "props": { "label": "最近の注文", "source": "api/orders/recent" } }
  ]
}
```

| フィールド | 説明 |
|-----------|------|
| `widgets` | ダッシュボードカードの配列。`type`（`stat`/`chart`/`list`）と `props` |

---

### Meta スキーマと通常 UIDSL の使い分け

| 状況 | 推奨 |
|------|------|
| 標準的なリスト・フォーム・詳細画面 | Meta スキーマ |
| 複雑なカスタムレイアウト | 通常 UIDSL |
| Meta スキーマで大枠を作り、一部をカスタマイズ | Meta + 通常 UIDSL の混在 |

Meta スキーマの `content` / `item` フィールド内には通常の UIDSL を入れ子にできる。

---

## コンポーネント一覧

### 📝 表示系（Display）

#### `text` — テキスト表示

```json
{
  "id": "title",
  "type": "text",
  "props": {
    "value": "Hello, World!",
    "style": {
      "fontSize": 24,
      "color": "#FFFFFF",
      "weight": "bold",
      "italic": false
    },
    "textAlign": "center",
    "maxLines": 2
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `value` | String | 表示テキスト（bind キーで動的にも可） |
| `style.fontSize` | num | フォントサイズ |
| `style.color` | String | 文字色（`#RRGGBB`） |
| `style.weight` | String | `"bold"` / `"normal"` |
| `style.italic` | bool | イタリック |
| `textAlign` | String | `"left"` / `"center"` / `"right"` / `"justify"` |
| `maxLines` | int | 最大行数 |

---

#### `image` — 画像表示

```json
{
  "id": "hero_image",
  "type": "image",
  "props": {
    "src": "https://example.com/image.png",
    "width": 300,
    "height": 200,
    "fit": "cover"
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `src` | String | 画像URL（必須） |
| `width` | num | 幅 |
| `height` | num | 高さ |
| `fit` | String | `"cover"` / `"contain"` / `"fill"` / `"fitWidth"` / `"fitHeight"` |

---

#### `icon` — アイコン

```json
{
  "id": "star_icon",
  "type": "icon",
  "props": {
    "name": "star",
    "size": 32,
    "color": "#A78BFA"
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `name` | String | アイコン名（必須）。Material Icons のスネークケース名（例: `"home"` / `"settings"` / `"arrow_back"`） |
| `size` | num | サイズ（デフォルト 24） |
| `color` | String | 色（`#RRGGBB`） |

---

#### `divider` — 区切り線

```json
{
  "id": "sep",
  "type": "divider",
  "props": {
    "color": "#333333",
    "thickness": 1,
    "indent": 16
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `color` | String | 線の色 |
| `thickness` | num | 太さ |
| `indent` | num | 左右の余白 |

---

#### `card` — カード

```json
{
  "id": "my_card",
  "type": "card",
  "props": {
    "color": "#1A1A2E",
    "elevation": 4,
    "padding": { "left": 16, "right": 16, "top": 12, "bottom": 12 }
  },
  "children": [...]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `elevation` | num | 影の高さ（デフォルト 2） |
| `color` | String | カード背景色 |
| `padding` | num / Object | 内側の余白（デフォルト 12） |

---

#### `badge` — バッジ

子ウィジェット（アイコンなど）の右上にバッジを表示する。

```json
{
  "id": "notif_badge",
  "type": "badge",
  "props": {
    "label": "3",
    "backgroundColor": "#E53935",
    "textColor": "#FFFFFF"
  },
  "children": [
    { "id": "icon", "type": "icon", "props": { "name": "notifications" } }
  ]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `label` | String | バッジのテキスト |
| `backgroundColor` | String | バッジ背景色（デフォルト 赤） |
| `textColor` | String | テキスト色（デフォルト 白） |

---

#### `tooltip` — ツールチップ

長押し / ホバーでメッセージを表示する。

```json
{
  "id": "info_tip",
  "type": "tooltip",
  "props": {
    "message": "ここをタップすると保存されます"
  },
  "children": [
    { "id": "icon", "type": "icon", "props": { "name": "info_outline" } }
  ]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `message` | String | ツールチップのテキスト（必須） |

---

#### `visibility` — 表示・非表示切り替え

`bind` キーの値（bool）で子ウィジェットを表示・非表示にする。

```json
{
  "id": "err_msg",
  "type": "visibility",
  "bind": "showError",
  "props": { "visible": false },
  "children": [
    { "id": "err", "type": "text", "props": { "value": "エラーが発生しました" } }
  ]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `visible` | bool | 初期値（デフォルト `true`）。`bind` で動的に切り替え可 |

---

#### `lottie` — Lottie アニメーション

```json
{
  "id": "anim",
  "type": "lottie",
  "props": {
    "src": "https://example.com/animation.json",
    "width": 200,
    "height": 200,
    "repeat": true
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `src` | String | Lottie JSON の URL（必須） |
| `width` | num | 幅 |
| `height` | num | 高さ |
| `repeat` | bool | ループ再生（デフォルト `true`） |

---

#### `video_player` — 動画再生（MP4）

```json
{
  "id": "promo_video",
  "type": "video_player",
  "props": {
    "src": "https://example.com/video.mp4",
    "width": 360,
    "height": 200,
    "autoplay": false,
    "loop": false
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `src` | String | 動画URL（必須） |
| `width` | num | 幅 |
| `height` | num | 高さ（デフォルト 200） |
| `autoplay` | bool | 自動再生（デフォルト `false`） |
| `loop` | bool | ループ（デフォルト `false`） |

---

#### `youtube` — YouTube動画

```json
{
  "id": "yt_video",
  "type": "youtube",
  "props": {
    "src": "https://www.youtube.com/watch?v=XXXXXXX",
    "width": 360,
    "height": 200,
    "autoplay": false,
    "loop": false
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `src` | String | YouTube URL（必須） |
| `width` | num | 幅 |
| `height` | num | 高さ |
| `autoplay` | bool | 自動再生 |
| `loop` | bool | ループ |

---

#### `webview` — WebView

```json
{
  "id": "browser",
  "type": "webview",
  "props": {
    "url": "https://example.com",
    "width": 400,
    "height": 300
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `url` | String | 表示するURL（必須） |
| `width` | num | 幅 |
| `height` | num | 高さ |

---

#### `animated_container` — アニメーション付きコンテナ

width / height / color / padding が変化したとき、`duration` ms かけてアニメーションする。

```json
{
  "id": "anim_box",
  "type": "animated_container",
  "bind": "isExpanded",
  "props": {
    "width": 200,
    "height": 100,
    "color": "#4A90D9",
    "duration": 400,
    "alignment": "center"
  },
  "children": [...]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `width` | num | 幅 |
| `height` | num | 高さ |
| `color` | String | 背景色 |
| `padding` | num / Object | 内側余白 |
| `duration` | num | アニメーション時間（ms、デフォルト 300） |
| `alignment` | String | 子ウィジェットの配置（`"center"` など） |

---

#### `animated_opacity` — フェードイン・アウト

`bind` キーの値（0.0〜1.0）で透明度をアニメーションする。

```json
{
  "id": "fade",
  "type": "animated_opacity",
  "bind": "contentOpacity",
  "props": {
    "opacity": 1.0,
    "duration": 500
  },
  "children": [...]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `opacity` | num | 初期透明度（0.0〜1.0、デフォルト 1.0）。`bind` で動的に変更可 |
| `duration` | num | アニメーション時間（ms、デフォルト 300） |

---

#### `animate` — 汎用アニメーション

opacity / 移動 / スケールを組み合わせたアニメーションを子ウィジェットに適用する。

```json
{
  "id": "slide_in",
  "type": "animate",
  "props": {
    "trigger": "onAppear",
    "duration": 400,
    "curve": "easeOut",
    "from": { "opacity": 0, "translateY": 40 },
    "to":   { "opacity": 1, "translateY": 0 },
    "repeat": false
  },
  "children": [...]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `trigger` | String | `"onAppear"` / `"onTap"` / `"bind"` |
| `duration` | num | アニメーション時間（ms、デフォルト 400） |
| `curve` | String | `"linear"` / `"easeIn"` / `"easeOut"` / `"easeInOut"` / `"bounceOut"` / `"elasticOut"` / `"decelerate"` |
| `from` | Object | 開始状態（`opacity` / `translateX` / `translateY` / `scale`） |
| `to` | Object | 終了状態（同上） |
| `repeat` | bool | ループ再生（デフォルト `false`） |

`trigger: "bind"` の場合は `bind` キーが `true` になるとアニメーション開始。

---

#### `async_loader` — 非同期ローダー

`bind` キーの値が `null` の間ローディングを表示し、セット後に子ウィジェットを描画する。

```json
{
  "id": "user_loader",
  "type": "async_loader",
  "bind": "userData",
  "props": {
    "loading_text": "読み込み中...",
    "error_text": "エラーが発生しました",
    "loading_color": "#4A90D9"
  },
  "children": [
    { "id": "content", "type": "text", "bind": "userData" }
  ]
}
```

`{bind}_error`（例: `userData_error`）に値がある場合はエラー表示になる。

| props | 型 | 説明 |
|-------|----|------|
| `loading_text` | String | ローディングテキスト（デフォルト `"読み込み中..."`） |
| `error_text` | String | エラーテキスト（デフォルト `"エラーが発生しました"`） |
| `loading_color` | String | インジケーター色 |

---

#### `conditional` — 条件分岐

`cases` の `when` 式を上から評価し、最初に一致した `child` を描画する。どれも一致しない場合は `default` を描画する。

```json
{
  "id": "status_view",
  "type": "conditional",
  "props": {
    "cases": [
      {
        "when": "status == 'active'",
        "child": { "id": "active_label", "type": "text", "props": { "value": "有効" } }
      },
      {
        "when": "status == 'inactive'",
        "child": { "id": "inactive_label", "type": "text", "props": { "value": "無効" } }
      }
    ],
    "default": { "id": "unknown_label", "type": "text", "props": { "value": "不明" } }
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `cases` | Array | `{ when: "式", child: dslNode }` の配列 |
| `default` | Object | どの case にも一致しない場合に描画する DSL ノード |

---

#### `state_machine` — ステートマシン

`bind` キーの値をステート名として受け取り、対応する UI を描画する。ステート遷移時に `onEnter` / `onExit` アクションを発火できる。

```json
{
  "id": "order_flow",
  "type": "state_machine",
  "bind": "orderStatus",
  "props": {
    "default": "idle",
    "states": {
      "idle": {
        "ui": { "id": "idle_ui", "type": "text", "props": { "value": "注文待ち" } },
        "onEnter": { "type": "setState", "key": "btnLabel", "value": "注文する" }
      },
      "processing": {
        "ui": { "id": "proc_ui", "type": "text", "props": { "value": "処理中..." } }
      },
      "done": {
        "ui": { "id": "done_ui", "type": "text", "props": { "value": "完了！" } }
      }
    }
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `states` | Object | `{ ステート名: { ui, onEnter?, onExit?, guard? } }` |
| `default` | String | フォールバックのステート名 |

各ステート定義:

| フィールド | 説明 |
|-----------|------|
| `ui` | そのステートで描画する DSL ノード |
| `onEnter` | ステートに入ったときに発火するアクション |
| `onExit` | ステートを抜けるときに発火するアクション |
| `guard` | この式が `true` のときのみ遷移できる（例: `"isLoggedIn"`） |

---

#### `ab` — A/B テスト

ユーザーID に基づいてバリアントを決定し、対応する UI を描画する。

```json
{
  "id": "hero_ab",
  "type": "ab",
  "props": {
    "experiment": "new_hero_button",
    "userId": "user_123",
    "variants": {
      "A": { "weight": 50, "ui": { "id": "btn_a", "type": "button", "props": { "label": "無料で始める" } } },
      "B": { "weight": 50, "ui": { "id": "btn_b", "type": "button", "props": { "label": "今すぐ試す" } } }
    }
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `experiment` | String | 実験ID（必須） |
| `userId` | String | バケット決定に使うユーザーID（必須） |
| `variants` | Object | `{ バリアント名: { weight: int, ui: dslNode } }`（必須） |

---

### 🎮 インタラクション系（Input）

#### `button` — ボタン

```json
{
  "id": "submit_btn",
  "type": "button",
  "props": {
    "label": "送信する",
    "variant": "elevated",
    "borderRadius": 12,
    "onTap": {
      "type": "apiCall",
      "endpoint": "https://api.example.com/submit",
      "method": "POST",
      "storeKey": "result"
    }
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `label` | String | ボタンラベル（必須） |
| `variant` | String | `"elevated"` / `"outlined"` / `"text"` |
| `borderRadius` | num | 角丸（デフォルト 0） |
| `onTap` / `action` | Object | タップ時のアクション |

---

#### `text_field` — テキスト入力

```json
{
  "id": "email_input",
  "type": "text_field",
  "bind": "email",
  "props": {
    "label": "メールアドレス",
    "hint": "example@mail.com",
    "multiline": false,
    "variant": "outline",
    "borderRadius": 8
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `label` | String | フィールドラベル |
| `hint` | String | プレースホルダーテキスト |
| `multiline` | bool | 複数行入力（デフォルト `false`） |
| `variant` | String | `"outline"` / `"underline"` / `"filled"` / `"none"` |
| `borderRadius` | num | 角丸（デフォルト 8） |

---

#### `number_field` — 数値入力

```json
{
  "id": "amount_input",
  "type": "number_field",
  "bind": "amount",
  "props": {
    "label": "金額",
    "hint": "0",
    "variant": "outline",
    "borderRadius": 8
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `label` | String | フィールドラベル |
| `hint` | String | プレースホルダーテキスト |
| `variant` | String | `"outline"` / `"underline"` / `"filled"` / `"none"` |
| `borderRadius` | num | 角丸（デフォルト 8） |

---

#### `search_field` — 検索フィールド

左端に検索アイコンが付いたテキストフィールド。

```json
{
  "id": "search_box",
  "type": "search_field",
  "bind": "searchQuery",
  "props": {
    "placeholder": "キーワードで検索...",
    "borderRadius": 24,
    "variant": "outline"
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `placeholder` | String | プレースホルダー（デフォルト `"検索..."`） |
| `borderRadius` | num | 角丸（デフォルト 24） |
| `variant` | String | `"outline"` / `"filled"` / `"underline"` / `"none"` |

---

#### `checkbox` — チェックボックス

```json
{
  "id": "agree_check",
  "type": "checkbox",
  "bind": "isAgreed",
  "props": {
    "label": "利用規約に同意する"
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `label` | String | チェックボックスのラベル |

---

#### `switch` — トグルスイッチ

```json
{
  "id": "notify_switch",
  "type": "switch",
  "bind": "notifyEnabled",
  "props": {
    "label": "通知を受け取る"
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `label` | String | スイッチのラベル |

---

#### `radio` — ラジオボタン（単体）

グループで使う場合は同じ `bind` キーを共有し、各 `radio` に異なる `value` を設定する。

```json
{
  "id": "plan_free",
  "type": "radio",
  "bind": "selectedPlan",
  "props": {
    "label": "無料プラン",
    "value": "free"
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `label` | String | ラジオボタンのラベル（必須） |
| `value` | String | このボタンの値（必須）。`bind` キーにセットされる |

---

#### `radio_group` — ラジオグループ（まとめて）

items をまとめてラジオボタンとして表示するコンポーネント。

```json
{
  "id": "gender_group",
  "type": "radio_group",
  "bind": "gender",
  "props": {
    "label": "性別",
    "items": ["男性", "女性", "その他"],
    "direction": "horizontal"
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `items` | Array | 選択肢の文字列配列 |
| `label` | String | グループのラベル |
| `direction` | String | `"vertical"` / `"horizontal"` |

---

#### `dropdown` — ドロップダウン

```json
{
  "id": "category_select",
  "type": "dropdown",
  "bind": "category",
  "props": {
    "items": ["美容院", "クリニック", "ジム", "飲食店"]
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `items` | Array | 選択肢の文字列配列（必須） |

---

#### `slider` — スライダー

```json
{
  "id": "volume_slider",
  "type": "slider",
  "bind": "volume",
  "props": {
    "min": 0,
    "max": 100,
    "divisions": 10
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `min` | num | 最小値（デフォルト 0） |
| `max` | num | 最大値（デフォルト 100） |
| `divisions` | int | 目盛り数（省略可） |

---

#### `date_picker` — 日付選択

タップするとネイティブの日付ピッカーが開き、選択した日付を ISO8601 文字列（`"2024-03-15"`）で bind キーに格納する。

```json
{
  "id": "birth_date",
  "type": "date_picker",
  "bind": "birthDate",
  "props": {
    "label": "生年月日"
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `label` | String | フィールドラベル（デフォルト `"日付を選択"`） |

---

#### `time_picker` — 時刻選択

タップするとネイティブの時刻ピッカーが開き、選択した時刻（`"09:30 AM"` 形式）を bind キーに格納する。

```json
{
  "id": "open_time",
  "type": "time_picker",
  "bind": "openTime",
  "props": {
    "label": "営業開始時刻",
    "placeholder": "時刻を選択",
    "variant": "outline"
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `label` | String | フィールドラベル |
| `placeholder` | String | 未選択時の表示テキスト |
| `variant` | String | `"outline"` / `"filled"` / `"underline"` / `"none"` |

---

#### `file_picker` — ファイル選択

ボタンをタップするとOS標準のファイル選択ダイアログが開き、選択ファイルのパスを bind キーに格納する。

```json
{
  "id": "avatar_picker",
  "type": "file_picker",
  "bind": "avatarPath",
  "props": {
    "label": "画像を選択",
    "accept": ".png,.jpg,.jpeg"
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `label` | String | ボタンラベル（デフォルト `"ファイルを選択"`） |
| `accept` | String | 受け付ける拡張子（例: `".png,.jpg"`） |

---

### 📐 レイアウト系（Layout）

#### `column` — 縦並び

```json
{
  "id": "main_col",
  "type": "column",
  "props": {
    "mainAxisAlignment": "start",
    "crossAxisAlignment": "stretch"
  },
  "children": [...]
}
```

| props | 説明 |
|-------|------|
| `mainAxisAlignment` | `"start"` / `"center"` / `"end"` / `"spaceBetween"` / `"spaceAround"` / `"spaceEvenly"` |
| `crossAxisAlignment` | `"start"` / `"center"` / `"end"` / `"stretch"` |

---

#### `row` — 横並び

```json
{
  "id": "btn_row",
  "type": "row",
  "props": {
    "mainAxisAlignment": "spaceBetween",
    "crossAxisAlignment": "center"
  },
  "children": [...]
}
```

`mainAxisAlignment` / `crossAxisAlignment` は `column` と同じ値（軸が異なる）。

---

#### `stack` — 重ね合わせ

```json
{
  "id": "overlay",
  "type": "stack",
  "props": {
    "alignment": "center"
  },
  "children": [
    { "id": "bg", "type": "container", "props": { "color": "#000000" } },
    {
      "id": "label",
      "type": "text",
      "props": { "value": "オーバーレイ", "left": 16, "top": 24 }
    }
  ]
}
```

子ウィジェットの `props` に `left` / `top` / `right` / `bottom` を指定すると `Positioned` として配置される。

| props | 型 | 説明 |
|-------|----|------|
| `alignment` | String | デフォルト配置（デフォルト `"topLeft"`） |
| `width` | num | スタック幅 |
| `height` | num | スタック高さ |

---

#### `container` — コンテナ

```json
{
  "id": "box",
  "type": "container",
  "props": {
    "width": 200,
    "height": 100,
    "color": "#1A1033",
    "padding": { "left": 16, "right": 16, "top": 12, "bottom": 12 },
    "margin": 8,
    "alignment": "center"
  },
  "children": [...]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `width` | num | 幅 |
| `height` | num | 高さ |
| `color` | String | 背景色 |
| `padding` | num / Object | 内側の余白 |
| `margin` | num / Object | 外側の余白 |
| `alignment` | String | 子ウィジェットの配置（`"center"` / `"topLeft"` / `"bottomRight"` など） |

---

#### `padding` — 余白ラッパー

```json
{
  "id": "padded",
  "type": "padding",
  "props": {
    "padding": { "left": 16, "right": 16, "top": 8, "bottom": 8 }
  },
  "children": [...]
}
```

`"padding": 16` のように数値1つを渡すと全方向に同じ余白が設定される。

---

#### `vspacer` — 縦の余白

```json
{ "id": "sp1", "type": "vspacer", "props": { "height": 24 } }
```

---

#### `hspacer` — 横の余白

```json
{ "id": "sp2", "type": "hspacer", "props": { "width": 16 } }
```

---

#### `expanded` — Row/Column 内でスペースを占有

`row` または `column` の直接の子としてのみ使用可。残りのスペースを `flex` 比率で分配する。

```json
{
  "id": "flex_row",
  "type": "row",
  "children": [
    {
      "id": "left",
      "type": "expanded",
      "props": { "flex": 1 },
      "children": [{ "id": "lbl", "type": "text", "props": { "value": "左" } }]
    },
    {
      "id": "right",
      "type": "expanded",
      "props": { "flex": 2 },
      "children": [{ "id": "val", "type": "text", "props": { "value": "右（2倍幅）" } }]
    }
  ]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `flex` | int | スペースの比率（デフォルト 1） |

---

#### `flexible` — Row/Column 内で柔軟なサイズ

`expanded` と似ているが、子ウィジェットが必要なサイズより小さくなれる（`fit: "loose"`）。

```json
{
  "id": "flex_item",
  "type": "flexible",
  "props": { "flex": 1, "fit": "loose" },
  "children": [...]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `flex` | int | スペースの比率（デフォルト 1） |
| `fit` | String | `"loose"`（必要なサイズまで縮小可） / `"tight"`（`expanded` と同等） |

---

#### `wrap` — 折り返しレイアウト

子が収まらない場合に自動的に折り返す。タグ、チップ、カードなどの配置に使う。

```json
{
  "id": "tags",
  "type": "wrap",
  "props": {
    "spacing": 8,
    "runSpacing": 8,
    "direction": "horizontal"
  },
  "children": [...]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `spacing` | num | 子ウィジェット間の間隔（デフォルト 8） |
| `runSpacing` | num | 行間の間隔（デフォルト 8） |
| `direction` | String | `"horizontal"` / `"vertical"` |

---

#### `grid` — グリッドレイアウト

```json
{
  "id": "product_grid",
  "type": "grid",
  "props": {
    "crossAxisCount": 2,
    "crossAxisSpacing": 8,
    "mainAxisSpacing": 8,
    "childAspectRatio": 1.0
  },
  "children": [...]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `crossAxisCount` | int | 列数（必須、デフォルト 2） |
| `crossAxisSpacing` | num | 列間隔（デフォルト 8） |
| `mainAxisSpacing` | num | 行間隔（デフォルト 8） |
| `childAspectRatio` | num | 各アイテムの縦横比（デフォルト 1.0） |

---

#### `accordion` — アコーディオン

```json
{
  "id": "faq_item",
  "type": "accordion",
  "props": {
    "title": "よくある質問",
    "initiallyExpanded": false,
    "backgroundColor": "#F5F5F5"
  },
  "children": [
    { "id": "answer", "type": "text", "props": { "value": "答えがここに入ります" } }
  ]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `title` | String | ヘッダーテキスト（デフォルト `"アコーディオン"`） |
| `initiallyExpanded` | bool | 初期状態で展開するか（デフォルト `false`） |
| `backgroundColor` | String | 展開時の背景色 |

---

#### `form` — バリデーション付きフォーム

フォームのバリデーションをまとめて行い、`onSubmit` を発火する。

```json
{
  "id": "contact_form",
  "type": "form",
  "props": {
    "submitLabel": "送信する",
    "onSubmit": {
      "type": "functionCall",
      "name": "submitContactForm"
    }
  },
  "children": [
    { "id": "name_field", "type": "text_field", "bind": "name", "props": { "label": "お名前" } },
    { "id": "email_field", "type": "text_field", "bind": "email", "props": { "label": "メール" } }
  ]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `onSubmit` | Object | 送信ボタンタップ時のアクション |
| `submitLabel` | String | 送信ボタンのラベル（デフォルト `"送信"`） |

---

#### `responsive_layout` — レスポンシブレイアウト

画面幅によって表示する DSL ノードを切り替える。

```json
{
  "id": "resp",
  "type": "responsive_layout",
  "props": {
    "sm": { "id": "mobile_view", "type": "column", "children": [...] },
    "md": { "id": "tablet_view", "type": "row",    "children": [...] },
    "lg": { "id": "desktop_view","type": "row",    "children": [...] }
  }
}
```

| props | 型 | 画面幅 | 説明 |
|-------|----|--------|------|
| `sm` | Object | < 600px | スマートフォン向け DSL ノード |
| `md` | Object | 600〜1023px | タブレット向け DSL ノード |
| `lg` | Object | >= 1024px | デスクトップ向け DSL ノード |

---

#### `interval_trigger` — インターバル実行

一定間隔で `on_tick` アクションを発火し続ける非表示ウィジェット。ポーリング処理（在庫確認・チャット更新など）に使う。

```json
{
  "id": "poller",
  "type": "interval_trigger",
  "props": {
    "interval_ms": 5000,
    "fire_immediately": true,
    "on_tick": {
      "type": "apiCall",
      "endpoint": "https://api.example.com/status",
      "method": "GET",
      "storeKey": "status"
    }
  },
  "children": [...]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `interval_ms` | num | 発火間隔（ミリ秒、デフォルト 5000） |
| `on_tick` | Object | 発火するアクション |
| `fire_immediately` | bool | マウント直後に即時発火するか（デフォルト `false`） |

子ウィジェットはそのまま描画される（このウィジェット自体は非表示）。

---

#### `pull_to_refresh` — 引っ張って更新

スクロールビューを引っ張ったときに `on_refresh` アクションを発火する。

```json
{
  "id": "refresh_wrapper",
  "type": "pull_to_refresh",
  "props": {
    "color": "#4A90D9",
    "on_refresh": {
      "type": "apiCall",
      "endpoint": "https://api.example.com/items",
      "method": "GET",
      "storeKey": "items"
    }
  },
  "children": [
    { "id": "item_list", "type": "list_view", "bind": "items", "props": { "item_template": {...} } }
  ]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `on_refresh` | Object | 引っ張り更新時に発火するアクション（必須） |
| `color` | String | インジケーターの色 |

---

#### `realtime_listener` — リアルタイム接続

WebSocket または SSE でサーバーに接続し、受信したデータを `bind_key` に格納する。

```json
{
  "id": "chat_listener",
  "type": "realtime_listener",
  "props": {
    "url": "wss://api.example.com/ws/chat",
    "protocol": "websocket",
    "conn_id": "chat_conn",
    "bind_key": "chatMessages",
    "on_message": {
      "type": "functionCall",
      "name": "onChatMessage"
    }
  },
  "children": [...]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `url` | String | `ws://` または `http://`（SSE）エンドポイント（必須） |
| `protocol` | String | `"websocket"` / `"sse"` |
| `conn_id` | String | 接続ID（`disconnect` アクションで切断に使用） |
| `bind_key` | String | 受信データを格納する BindStore キー |
| `on_message` | Object | メッセージ受信時のアクション |

---

#### `gesture_detector` — ジェスチャー検知

子ウィジェットをジェスチャーで操作できるようにする。スワイプ検知などに使う。

```json
{
  "id": "swipe_area",
  "type": "gesture_detector",
  "props": {
    "on_tap": { "type": "navigate", "to": "detail" },
    "on_long_press": { "type": "setState", "key": "showMenu", "value": true },
    "on_swipe_left":  { "type": "navigate", "to": "next_page" },
    "on_swipe_right": { "type": "navigate.back" },
    "swipe_threshold": 200
  },
  "children": [...]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `on_tap` | Object | タップ時のアクション |
| `on_double_tap` | Object | ダブルタップ時のアクション |
| `on_long_press` | Object | 長押し時のアクション |
| `on_swipe_left` | Object | 左スワイプ時のアクション |
| `on_swipe_right` | Object | 右スワイプ時のアクション |
| `on_swipe_up` | Object | 上スワイプ時のアクション |
| `on_swipe_down` | Object | 下スワイプ時のアクション |
| `swipe_threshold` | num | スワイプ判定速度（px/s、デフォルト 200） |

---

### 📋 リスト系（List）

#### `list_view` — リスト

リストを縦方向に描画する。静的データ（`items`）と動的データ（`bind`）の両方に対応する。

```json
{
  "id": "product_list",
  "type": "list_view",
  "props": {
    "bind": "productList",
    "item_template": {
      "id": "product_item",
      "type": "card",
      "props": { "padding": 12 },
      "children": [
        { "id": "item_name",  "type": "text", "bind": "name" },
        { "id": "item_price", "type": "text", "props": { "value": "¥{{price}}" } }
      ]
    }
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `bind` | String | BindStore の配列キー（動的データ。`items` より優先） |
| `items` | Array | 静的リストデータ（`bind` 未使用時） |
| `item_template` | Object | 各アイテムの DSL ノード。アイテムのフィールドは直接 `bind: "fieldName"` で参照 |
| `separator` | Object | 各アイテム間に表示するセパレータ DSL ノード |
| `emptyWidget` | Object | データが空のときに表示する DSL ノード |
| `scrollDirection` | String | `"vertical"`（デフォルト）/ `"horizontal"` |
| `padding` | num / Object | リスト全体の内側余白 |

#### item_template 内でのフィールド参照

`item_template` の中では `_LoopScope` がアイテムのフィールドをスコープに展開する。  
`bind: "item.name"` ではなく **`bind: "name"`** と書く。

```json
// ✅ 正しい
{ "type": "text", "bind": "name" }
{ "type": "text", "props": { "value": "¥{{price}}" } }

// ❌ 誤り（item. プレフィックスは不要）
{ "type": "text", "bind": "item.name" }
```

#### 行タップ

```json
{
  "id": "product_item",
  "type": "card",
  "props": {
    "onTap": {
      "type": "navigate",
      "to": "product_detail",
      "args": { "productId": "{{id}}" }
    }
  }
}
```

#### 空リスト時のフォールバック

```json
{
  "id": "product_list",
  "type": "list_view",
  "props": {
    "bind": "productList",
    "emptyWidget": {
      "id": "empty",
      "type": "text",
      "props": { "value": "商品がありません", "textAlign": "center" }
    },
    "item_template": { ... }
  }
}
```

#### 動的ロードとの組み合わせ（よくあるパターン）

```json
{
  "id": "loader",
  "type": "async_loader",
  "props": {
    "loadingKey": "isProductLoading",
    "action": {
      "type": "apiCall",
      "url": "/api/products",
      "method": "GET",
      "assignTo": "productList"
    }
  },
  "children": [
    {
      "id": "product_list",
      "type": "list_view",
      "props": {
        "bind": "productList",
        "item_template": { ... }
      }
    }
  ]
}
```

`async_loader` が API を呼び出して `productList` に保存 → `list_view` が再描画される。

#### 無限スクロール（Infinite Scroll）パターン

`pull_to_refresh` + `interval_trigger` の組み合わせでページネーション・無限スクロールを実現する。

```json
{
  "id": "infinite_list_root",
  "type": "column",
  "children": [
    {
      "id": "pull_refresh",
      "type": "pull_to_refresh",
      "props": {
        "onRefresh": {
          "type": "functionCall",
          "name": "reloadProducts",
          "params": { "page": 1 }
        }
      },
      "children": [
        {
          "id": "product_list",
          "type": "list_view",
          "props": {
            "bind": "productList",
            "item_template": { ... }
          }
        }
      ]
    },
    {
      "id": "load_more_btn",
      "type": "visibility",
      "props": { "bind": "hasMoreProducts" },
      "children": [
        {
          "id": "btn_more",
          "type": "button",
          "props": {
            "label": "さらに読み込む",
            "onTap": {
              "type": "functionCall",
              "name": "loadMoreProducts",
              "params": { "page": "{{currentPage}}" }
            }
          }
        }
      ]
    }
  ]
}
```

`loadMoreProducts` は `actions/` 側で `productList` に追記（append）し、`currentPage` をインクリメントする。  
`hasMoreProducts` が `false` になったとき「さらに読み込む」ボタンが消える。

#### ページネーションパターン

```json
{
  "id": "page_controls",
  "type": "row",
  "props": { "mainAxisAlignment": "center" },
  "children": [
    {
      "id": "prev_btn",
      "type": "button",
      "props": {
        "label": "← 前へ",
        "onTap": { "type": "functionCall", "name": "prevPage" }
      }
    },
    {
      "id": "page_indicator",
      "type": "text",
      "props": { "value": "{{currentPage}} / {{totalPages}}" }
    },
    {
      "id": "next_btn",
      "type": "button",
      "props": {
        "label": "次へ →",
        "onTap": { "type": "functionCall", "name": "nextPage" }
      }
    }
  ]
}
```

---

#### `loop` — ループ（bind 版）

`items` prop に bind 式を指定してリストを動的に描画する。

```json
{
  "id": "user_loop",
  "type": "loop",
  "props": {
    "items": "userList",
    "item_template": {
      "id": "user_card",
      "type": "card",
      "children": [
        { "id": "uname", "type": "text", "bind": "name" }
      ]
    }
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `items` | String | BindStore のキー名（必須）。リスト型の state を指す |
| `item_template` | Object | 各アイテムの DSL ノード |

---

#### `data_table` — データテーブル

`bind` キーで渡した配列データをテーブル形式で表示する。

```json
{
  "id": "orders_table",
  "type": "data_table",
  "bind": "orderRows",
  "props": {
    "columns": ["注文ID", "商品名", "金額", "ステータス"]
  }
}
```

`orderRows` は `[["#001", "商品A", "3000", "完了"], ...]` のような二次元配列を渡す。

| props | 型 | 説明 |
|-------|----|------|
| `columns` | Array | 列ヘッダーの文字列配列 |

---

#### `sortable_list` — 並べ替えリスト

ドラッグ&ドロップで並べ替えできるリスト。

```json
{
  "id": "task_list",
  "type": "sortable_list",
  "props": {
    "onReorder": { "type": "functionCall", "name": "onReorder" }
  },
  "children": [
    { "id": "item1", "type": "text", "props": { "value": "タスク1" } },
    { "id": "item2", "type": "text", "props": { "value": "タスク2" } }
  ]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `onReorder` | Object | 並べ替え完了時のアクション |

---

### 🧭 ナビゲーション系（Navigation）

#### `app_bar` — アプリバー

`Scaffold` の `appBar` スロットに配置する。

```json
{
  "id": "my_app_bar",
  "type": "app_bar",
  "props": {
    "title": "ホーム",
    "backgroundColor": "#1A1033",
    "foregroundColor": "#FFFFFF",
    "centerTitle": true,
    "elevation": 0,
    "leadingIcon": "arrow_back",
    "actions": ["search", "more_vert"]
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `title` | String | タイトルテキスト |
| `backgroundColor` | String | 背景色 |
| `foregroundColor` | String | テキスト・アイコン色 |
| `centerTitle` | bool | タイトルを中央揃え（デフォルト `true`） |
| `elevation` | num | 影の高さ（デフォルト 0） |
| `leadingIcon` | String | 左端のアイコン名 |
| `actions` | Array | 右端のアイコン名リスト |

---

#### `bottom_navigation_bar` — ボトムナビゲーション

`Scaffold` の `bottomNavigationBar` スロットに配置する。`bind` キーで選択インデックスを管理できる。

```json
{
  "id": "bottom_nav",
  "type": "bottom_navigation_bar",
  "bind": "selectedTab",
  "props": {
    "backgroundColor": "#1A1033",
    "selectedColor": "#A78BFA",
    "items": [
      { "icon": "home", "label": "ホーム" },
      { "icon": "search", "label": "検索" },
      { "icon": "person", "label": "プロフィール" }
    ]
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `items` | Array | `{ icon: アイコン名, label: ラベル }` の配列（最低2つ必須） |
| `selectedIndex` | num | 初期選択インデックス |
| `backgroundColor` | String | 背景色 |
| `selectedColor` | String | 選択中アイテムの色 |

---

#### `drawer` — ドロワー

サイドメニューとして使う。`column` の子として配置する。

```json
{
  "id": "side_menu",
  "type": "drawer",
  "props": {
    "width": 280,
    "backgroundColor": "#1A1033"
  },
  "children": [
    { "id": "menu_home", "type": "text", "props": { "value": "ホーム" } },
    { "id": "menu_profile", "type": "text", "props": { "value": "プロフィール" } }
  ]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `width` | num | ドロワーの幅（デフォルト 280） |
| `backgroundColor` | String | 背景色 |

---

#### `page_view` — ページビュー

横または縦にスワイプで切り替えるページウィジェット。

```json
{
  "id": "onboarding",
  "type": "page_view",
  "props": {
    "scrollDirection": "horizontal",
    "height": 400
  },
  "children": [
    { "id": "page1", "type": "container", "props": { "color": "#FF5252" } },
    { "id": "page2", "type": "container", "props": { "color": "#448AFF" } }
  ]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `scrollDirection` | String | `"horizontal"` / `"vertical"` |
| `height` | num | ページビューの高さ（デフォルト 200） |

---

#### `tab_bar` — タブバー

タブと TabBarView をまとめて表示する。子ウィジェットが各タブのコンテンツになる。

```json
{
  "id": "my_tabs",
  "type": "tab_bar",
  "props": {
    "backgroundColor": "#1A1033",
    "labelColor": "#A78BFA",
    "indicatorColor": "#A78BFA",
    "tabs": [
      { "label": "概要",     "icon": "info" },
      { "label": "レビュー", "icon": "star" },
      { "label": "関連",     "icon": "link" }
    ]
  },
  "children": [
    { "id": "tab1_content", "type": "text", "props": { "value": "概要の内容" } },
    { "id": "tab2_content", "type": "text", "props": { "value": "レビューの内容" } },
    { "id": "tab3_content", "type": "text", "props": { "value": "関連の内容" } }
  ]
}
```

| props | 型 | 説明 |
|-------|----|------|
| `tabs` | Array | `{ label: ラベル, icon?: アイコン名 }` の配列（必須） |
| `backgroundColor` | String | タブバーの背景色 |
| `labelColor` | String | 選択中タブのテキスト色 |
| `indicatorColor` | String | 選択中タブのインジケーター色 |

---

#### `breadcrumb` — パンくずリスト

```json
{
  "id": "breadcrumb",
  "type": "breadcrumb",
  "props": {
    "items": ["ホーム", "カテゴリ", "商品詳細"],
    "separator": ">",
    "color": "#888888",
    "activeColor": "#4A90D9"
  }
}
```

| props | 型 | 説明 |
|-------|----|------|
| `items` | Array | パンくず項目の文字列配列 |
| `separator` | String | 区切り文字（デフォルト `"/"`） |
| `color` | String | 非アクティブ項目の色 |
| `activeColor` | String | アクティブ（最後の）項目の色 |

---

## Action の型体系

ShellApp の Action は **「UI × Action × State の三位一体」** の中核。  
UIDSL から呼び出せるすべての Action は、以下の6カテゴリに分類される。

| カテゴリ | type 一覧 | 説明 |
|---------|-----------|------|
| **状態管理** | `setState` / `increment` / `decrement` / `toggle` | BindStore を直接操作する |
| **関数呼び出し** | `functionCall` | `actions/` に実装した Dart 関数を呼ぶ |
| **API** | `apiCall` | HTTP リクエストを送り、結果を BindStore に保存する |
| **画面遷移** | `navigate` / `navigate.replace` / `navigate.modal` / `navigate.pop` | 画面スタックを操作する |
| **ストレージ** | `storage.save` / `storage.load` / `storage.remove` / `secure_set` / `secure_get` | 永続化・機密情報の読み書き |
| **UI 更新** | `apply_dsl_patch` / `realtime_connect` / `interval_trigger` | UIDSL の動的変更・リアルタイム通信 |

### Action の共通フィールド

```json
{
  "type": "...",        // 必須：アクション種別
  "params": { ... },   // 任意：パラメータ（functionCall のみ）
  "then": { ... },     // 任意：成功後に実行するアクション（チェーン）
  "catch": { ... }     // 任意：失敗後に実行するアクション
}
```

### Action のトリガー一覧

| トリガー | 場所 | 説明 |
|---------|------|------|
| `onTap` | 全ウィジェット共通 props | タップ時 |
| `onLongPress` | 全ウィジェット共通 props | 長押し時 |
| `onSubmit` | `text_field` / `search_field` | Enter 送信時 |
| `onChanged` | `text_field` / `checkbox` / `switch` / `slider` | 値変更時 |
| `onTick` | `interval_trigger` | インターバル発火時 |
| `onData` | `realtime_listener` | リアルタイムデータ受信時 |
| `onRefresh` | `pull_to_refresh` | プルダウン時 |
| `on_init` | 画面 JSON ルート | 画面初回表示時 |
| `on_resume` | 画面 JSON ルート | 画面復帰時 |
| `on_dispose` | 画面 JSON ルート | 画面破棄時 |
| `action` | `async_loader` | ローダー起動時 |
| `onSubmit` | `form` | バリデーション通過後の送信時 |

---

## アクション一覧

ボタンの `onTap` / `action`、その他イベントハンドラに指定するアクションオブジェクト。

### 🔁 状態管理

#### `setState` — state に値をセット

```json
{ "type": "setState", "key": "isVisible", "value": true }
```

#### `increment` — 数値をインクリメント

```json
{ "type": "increment", "key": "count", "by": 1 }
```

#### `decrement` — 数値をデクリメント

```json
{ "type": "decrement", "key": "count", "by": 1 }
```

#### `toggle` — bool を反転

```json
{ "type": "toggle", "key": "isExpanded" }
```

---

#### `noop` — 何もしない

```json
{ "type": "noop" }
```

アクションが必須なフィールドに「何もしない」を明示的に指定するときに使う。  
`showDialog` のキャンセルボタンなど。

---

### 🌐 API

#### `apiCall` — HTTP API コール

```json
{
  "type": "apiCall",
  "url": "https://api.example.com/products",
  "method": "GET",
  "query": { "keyword": "{{searchQuery}}", "limit": 20 },
  "headers": { "Authorization": "Bearer {{token}}" },
  "body": { "name": "{{inputName}}" },
  "assignTo": "productList",
  "errorKey": "productList_error"
}
```

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `url` / `endpoint` | String | URL（必須。`{{key}}` 展開可） |
| `method` | String | `"GET"` / `"POST"` / `"PUT"` / `"DELETE"` |
| `query` | Object | GET クエリパラメータ（`?keyword=...` として URL に付加） |
| `headers` | Object | リクエストヘッダー（`{{key}}` 展開可） |
| `body` | Object | リクエストボディ（POST/PUT 時。`{{key}}` 展開可） |
| `assignTo` / `storeKey` | String | 成功時のレスポンスを保存する BindStore キー |
| `errorKey` | String | 失敗時のエラーメッセージを保存するキー（省略時は `{assignTo}_error`） |

> `url` と `endpoint` はどちらも同じ意味で使える（後方互換）。  
> `assignTo` と `storeKey` も同じ（後方互換）。

---

### ⚡ 関数呼び出し

#### `functionCall` — Dart 関数を呼び出し

```json
{
  "type": "functionCall",
  "name": "fetchUser",
  "params": { "userId": "{{selectedUserId}}" },
  "storeKey": "userProfile"
}
```

> `params` と `args` はどちらも同じ意味で使える（後方互換）。

`function_actions.dart` に `fetchUser` を実装しておく必要がある。

| パラメータ | 説明 |
|-----------|------|
| `name` | 関数名（必須） |
| `args` | 関数に渡す引数（Object） |
| `storeKey` | 戻り値を格納する state キー |

---

### 💾 ストレージ

#### `storage.save` — SharedPreferences に保存

```json
{ "type": "storage.save", "key": "token", "value": "abc123" }
```

#### `storage.load` — SharedPreferences から読み込み

```json
{ "type": "storage.load", "key": "token", "storeKey": "authToken" }
```

#### `storage.remove` — SharedPreferences から削除

```json
{ "type": "storage.remove", "key": "token" }
```

---

### 🧭 画面遷移

#### `navigate` — 画面遷移（戻れる）

```json
{ "type": "navigate", "to": "profile" }
```

#### `navigate.back` — 前の画面に戻る

```json
{ "type": "navigate.back" }
```

#### `navigate.replace` — 画面遷移（戻れない）

```json
{ "type": "navigate.replace", "to": "home" }
```

ログイン後のホーム遷移など、戻らせたくない場合に使う。

---

### 🌍 外部連携

#### `openUrl` — URL を開く

```json
{ "type": "openUrl", "url": "https://example.com" }
{ "type": "openUrl", "url": "https://example.com", "external": true }
```

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `url` | String | 開く URL（`{{key}}` 展開可） |
| `external` | bool | `true` で外部ブラウザを使用（デフォルト `false`） |

---

#### `clipboard.copy` — クリップボードにコピー

```json
{ "type": "clipboard.copy", "value": "{{inviteCode}}" }
```

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `value` | String | コピーするテキスト（`{{key}}` 展開可） |

---

### 💬 UI フィードバック

#### `showSnackbar` — スナックバー表示

```json
{
  "type": "showSnackbar",
  "message": "保存しました",
  "duration": 3000,
  "action": { "label": "元に戻す", "onTap": { "type": "functionCall", "name": "undoSave" } }
}
```

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `message` | String | 表示テキスト（`{{key}}` 展開可） |
| `duration` | int | 表示時間（ミリ秒、デフォルト 3000） |
| `action` | Object | スナックバー上のボタン（任意） |

---

#### `showDialog` — ダイアログ表示

```json
{
  "type": "showDialog",
  "title": "削除の確認",
  "message": "「{{itemName}}」を削除しますか？",
  "confirm": { "label": "削除", "action": { "type": "functionCall", "name": "deleteItem" } },
  "cancel":  { "label": "キャンセル" }
}
```

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `title` | String | ダイアログタイトル |
| `message` | String | 本文テキスト（`{{key}}` 展開可） |
| `confirm` | Object | 確認ボタン。`label` と `action` を持つ |
| `cancel` | Object | キャンセルボタン。`label` のみでも可 |

---

#### `showBottomSheet` — ボトムシート表示

```json
{
  "type": "showBottomSheet",
  "content": {
    "id": "sheet_body",
    "type": "column",
    "props": { "padding": 16 },
    "children": [
      { "id": "sheet_title", "type": "text", "props": { "value": "アクションを選択" } },
      { "id": "btn_edit",    "type": "button", "props": { "label": "編集する" } },
      { "id": "btn_delete",  "type": "button", "props": { "label": "削除する" } }
    ]
  }
}
```

`content` に任意の UIDSL ノードを渡す。ボトムシートの中身を UIDSL で定義できる。

---

## 画面構造（Screen）

ShellApp の UI はアプリ全体が「画面（Screen）の集合」として構成される。  
各画面は独立した JSON ファイルとして定義され、ShellRouter が動的に読み込んで遷移を制御する。

### アプリ全体の構成

```
app.json              ← アプリ全体の設定（エントリ画面・テーマ等）
screens/
  home.json           ← Home 画面
  profile.json        ← プロフィール画面
  settings.json       ← 設定画面
theme/
  default.json        ← テーマ定義
meta/                 ← ウィジェット定義拡張
plugins/              ← 署名済みプラグイン
```

---

### `app.json` の仕様

アプリのエントリポイント。ShellRouter はここを読んで初期画面を決定し、画面 ID → JSON のマッピングを構築する。

```json
{
  "name": "MyApp",
  "version": "1.0.0",
  "entry": "home",
  "screens": [
    { "id": "home",     "path": "screens/home.json" },
    { "id": "profile",  "path": "screens/profile.json" },
    { "id": "settings", "path": "screens/settings.json" },
    { "id": "login",    "path": "screens/login.json" }
  ],
  "theme": "theme/default.json"
}
```

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `name` | String | アプリ名 |
| `version` | String | バージョン（セマンティックバージョニング推奨） |
| `entry` | String | 起動時に表示する画面 ID（必須） |
| `screens` | Array | 全画面の定義。`id` と `path` のペアのリスト |
| `theme` | String | テーマ定義ファイルのパス |

#### アプリ全体のフロー

```
起動
  ↓
app.json を読み込む
  ↓
entry 画面の JSON をロード
  ↓
ShellPage（画面コンテナ）を生成
  ↓
on_init 発火
  ↓
root Widget ツリーを描画
  ↓
ユーザー操作 → navigate アクション
  ↓
次の画面 JSON をロード → on_init → 描画
```

#### 画面スタック（Navigator）

```
[home] → navigate("profile") → [home, profile]
                                   ↓
                              navigate.pop() → [home]
                                   ↓
[home] → navigate.replace("login") → [login]  ← home は消える
```

---

### 画面 JSON の全体構成

```json
{
  "name": "Home",
  "scrollable": true,
  "on_init":    { "type": "functionCall", "name": "fetchHomeData" },
  "on_resume":  { "type": "functionCall", "name": "refreshHomeData" },
  "on_dispose": { "type": "setState", "key": "homeData", "value": null },
  "root": {
    "id": "root",
    "type": "column",
    "props": {
      "background": "#FFFFFF",
      "mainAxisAlignment": "start",
      "crossAxisAlignment": "stretch"
    },
    "children": [...]
  }
}
```

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `name` | String | 画面名（Studio 表示用） |
| `scrollable` | bool | `true` でスクロール可能（デフォルト `true`） |
| `on_init` | Action | 画面が初めて表示されたとき（`initState`）に一度だけ実行 |
| `on_resume` | Action | 前の画面から戻ってきたとき（フォーカス復帰）に実行 |
| `on_dispose` | Action | 画面が破棄されるとき（`dispose`）に実行 |
| `root` | Object | ルートウィジェット（必須） |

---

### 画面ライフサイクル

```
画面 push
    ↓
  on_init     ← 初回のみ。API取得・BindStore 初期化など
    ↓
  build（描画）
    ↓
    ← 別画面へ遷移 →
    ↓
  on_resume   ← 戻ってきたとき。リスト更新・タイマーリスタートなど
    ↓
  build（再描画）
    ↓
  on_dispose  ← 画面破棄時。タイマー停止・状態クリアなど
```

#### よくある使い方

```json
"on_init": {
  "type": "apiCall",
  "url": "/api/products",
  "method": "GET",
  "assignTo": "productList"
}
```

```json
"on_resume": {
  "type": "functionCall",
  "name": "checkCartUpdates"
}
```

```json
"on_dispose": {
  "type": "setState",
  "key": "searchQuery",
  "value": ""
}
```

---

### 画面遷移とルーティング

ShellRouter が画面 ID をキーに JSON をロードして遷移する。  
遷移タイプは `navigate` アクションの `type` で指定する。

| 遷移タイプ | 説明 | 用途 |
|-----------|------|------|
| `navigate` | スタックに push（戻れる） | 通常の画面遷移 |
| `navigate.replace` | 現在の画面を置換（戻れない） | ログイン完了後のホーム遷移 |
| `navigate.modal` | モーダルで表示 | ダイアログ代わりの全画面モーダル |
| `navigate.pop` | スタックから pop（前の画面に戻る） | 戻るボタン |

```json
{
  "id": "go_profile",
  "type": "button",
  "props": {
    "label": "プロフィールへ",
    "onTap": {
      "type": "navigate",
      "to": "profile",
      "args": { "userId": "{{currentUserId}}" }
    }
  }
}
```

遷移先では `args.userId` として参照できる（BindStore に `args.xxx` で注入される）。

---

## 型エイリアス

| エイリアス | 実際の type | 補足 |
|-----------|------------|------|
| `input` | `text_field` | 後方互換 |
| `list` | `list_view` | 後方互換 |
| `select` | `dropdown` | 後方互換 |
| `spacer` | `vspacer` | 後方互換 |
| `sized_box` | `vspacer` | 後方互換 |

---

## Action リファレンス

Action は `onTap` / `on_init` / `on_resume` などのトリガーから呼び出されるオブジェクト。  
`type` フィールドでアクションの種類を指定する。

### `setState` — 状態を更新

```json
{ "type": "setState", "key": "isLoading", "value": true }
```

| フィールド | 説明 |
|-----------|------|
| `key` | BindStore のキー |
| `value` | セットする値（String / Number / Bool / Object / Array） |

---

### `functionCall` — 関数を呼び出す

```json
{
  "type": "functionCall",
  "name": "fetchUserProfile",
  "params": { "userId": "{{currentUserId}}" },
  "storeKey": "userProfile"
}
```

| フィールド | 説明 |
|-----------|------|
| `name` | 呼び出す関数名（`actions/` に実装） |
| `params` | 関数に渡すパラメータ（`{{key}}` で BindStore 値を展開可） |
| `storeKey` | 関数の戻り値を BindStore に保存するキー |

---

### `apiCall` — API を呼び出す

```json
{
  "type": "apiCall",
  "url": "https://api.example.com/users/{{userId}}",
  "method": "GET",
  "headers": { "Authorization": "Bearer {{token}}" },
  "body": { "name": "{{inputName}}" },
  "assignTo": "userData"
}
```

| フィールド | 説明 |
|-----------|------|
| `url` | エンドポイント（`{{key}}` で BindStore 値を展開可） |
| `method` | `"GET"` / `"POST"` / `"PUT"` / `"DELETE"` |
| `headers` | リクエストヘッダー |
| `body` | リクエストボディ（`{{key}}` 展開可） |
| `assignTo` | レスポンスを保存する BindStore キー |

---

### `navigate` — 画面遷移

```json
{ "type": "navigate", "to": "profile", "args": { "userId": "{{currentUserId}}" } }
```

| type | 説明 |
|------|------|
| `navigate` | 通常遷移（戻れる） |
| `navigate.replace` | 置換遷移（戻れない。ログイン後のホーム遷移などに） |
| `navigate.modal` | モーダル遷移 |
| `navigate.pop` | 前の画面に戻る |

---

### `secure_set` / `secure_get` — セキュアストレージ

```json
{ "type": "secure_set", "key": "auth_token", "value": "{{token}}" }
{ "type": "secure_get", "key": "auth_token", "storeKey": "token" }
```

デバイスのセキュアストレージ（Keychain / Keystore）にアクセスする。  
トークン・パスワードなどの機密情報の保存・取得に使用する。

---

### `apply_dsl_patch` — 差分 UI 更新

```json
{
  "type": "apply_dsl_patch",
  "patch": [
    { "op": "replace", "path": "/root/children/0/props/value", "value": "新しいテキスト" }
  ]
}
```

JSON Patch（RFC 6902）形式で UIDSL を部分更新する。詳細は「差分配信（JSON Patch）」章を参照。

---

### `realtime_connect` — リアルタイム接続

```json
{ "type": "realtime_connect", "channel": "orders/{{orderId}}", "storeKey": "liveOrder" }
```

WebSocket / Server-Sent Events でリアルタイムデータを購読し、BindStore に継続的に反映する。

---

### `interval_trigger` — 定期実行

```json
{ "type": "interval_trigger", "intervalMs": 5000, "action": { "type": "functionCall", "name": "refreshData" } }
```

指定ミリ秒ごとにアクションを繰り返し実行する。ポーリングや定期更新に使う。

---

### `ab` — A/B テスト

```json
{ "type": "ab", "experiment": "new_checkout", "variant": "B" }
```

ユーザーセグメントに応じたバリアントに切り替える。`ab` コンポーネントと組み合わせて使用。

---

### `form.onSubmit` — フォーム送信

`form` コンポーネントの `onSubmit` に指定する。バリデーション通過後に呼び出される。

```json
{
  "id": "login_form",
  "type": "form",
  "props": {
    "onSubmit": { "type": "functionCall", "name": "login" }
  },
  "children": [...]
}
```

---

## bind 仕様

`bind` は UIDSL の心臓部。BindStore（シングルトン状態管理）と Widget を紐付ける仕組み。

### bind の基本

```json
{ "id": "greeting", "type": "text", "props": { "value": "{{userName}}" }, "bind": "userName" }
```

- `bind` に BindStore のキーを指定すると、値が変わったとき Widget が自動再描画される
- `props` の値に `{{key}}` を書くと、その部分が BindStore の値で展開される

---

### bind 演算子の完全仕様

`bind` の値は **単純キーだけでなく式（Expression）として評価される**。  
内部では tokenize → AST 変換 → evaluate のパイプラインで安全に処理される。  
`eval()` は一切使用しない。

#### 許可されている演算子

| カテゴリ | 演算子 | 例 |
|---------|-------|-----|
| **算術** | `+` `-` `*` `/` `%` `()` | `"price * quantity"` |
| **文字列結合** | `+` | `"lastName + ' ' + firstName"` |
| **比較** | `==` `!=` `>` `<` `>=` `<=` | `"stock > 0"` |
| **論理** | `&&` `\|\|` `!` | `"isLoggedIn && isVerified"` |
| **null 安全** | `?.` `??` | `"customer?.name ?? '未設定'"` |
| **現在要素** | `.` | ループの `item_template` 内で現在のアイテムを参照 |

#### 算術式の例

```json
// 合計金額の表示
{ "id": "total", "type": "text", "props": { "value": "{{price * quantity}}" } }

// 税込価格（10%）
{ "id": "with_tax", "type": "text", "props": { "value": "{{price * 1.1}}" } }

// 残り在庫
{ "id": "remaining", "type": "text", "props": { "value": "{{maxStock - usedStock}}" } }
```

#### 文字列結合の例

```json
// 姓名の結合
{ "id": "full_name", "type": "text", "bind": "lastName + ' ' + firstName" }

// 値に単位を付ける
{ "id": "price_text", "type": "text", "bind": "price + '円'" }

// 複数フィールドのテンプレート
{ "id": "address", "type": "text", "bind": "prefecture + city + street" }
```

#### null 安全演算子

```json
// ?.  ← null の場合はアクセスせず null を返す
{ "id": "city", "type": "text", "bind": "user?.address?.city" }

// ??  ← null の場合はデフォルト値を返す
{ "id": "name", "type": "text", "bind": "user?.name ?? '名前未設定'" }

// 組み合わせ
{ "id": "display", "type": "text", "bind": "customer?.name ?? '匿名ユーザー'" }
```

#### ループ内での `.`（現在要素）

`loop` の `item_template` 内で、現在のアイテム**そのもの**（プリミティブ値）を参照するには `.` を使う。

```json
{
  "type": "loop",
  "props": {
    "items": "tagList",
    "item_template": {
      "id": "tag_chip",
      "type": "text",
      "bind": "."
    }
  }
}
```

- アイテムが `Object` の場合は `bind: "fieldName"` でフィールドを参照
- アイテムが `String` / `Number` のプリミティブの場合は `bind: "."` で現在値を参照

#### `visible_when` — 表示条件のショートハンド

`visibility` コンポーネントを使わず、任意のウィジェットに直接表示条件を書ける省略記法。

```json
// 在庫ありのときだけ「購入」ボタンを表示
{ "id": "buy_btn", "type": "button", "props": { "label": "購入する" }, "visible_when": "stock > 0" }

// ログイン済みのときだけプロフィール表示
{ "id": "profile", "type": "card",   "children": [...], "visible_when": "isLoggedIn" }

// 複合条件
{ "id": "admin_area", "type": "column", "children": [...], "visible_when": "role == 'admin' && isActive" }
```

`visible_when` に使える演算子は `conditional` の `when` と同じ（比較・論理演算子）。

---

### キーパス表現と解決ルール

BindStore のキーパスは以下の形式をサポートする。

| 形式 | 例 | 説明 |
|------|----|------|
| **単純キー** | `userName` | BindStore に直接保存された値 |
| **ドット記法（ネスト）** | `user.name` | Object の深いフィールドへのアクセス |
| **2段階まで** | `order.address.city` | 深さ3以上は非推奨（パフォーマンスに影響） |
| **配列インデックス** | `users[0].name` | ⚠️ 非推奨。`loop` / `list_view` 内では item のフィールド名を直接使う |
| **args プレフィックス** | `args.userId` | 画面遷移時に渡された引数（自動注入） |

#### ✅ 推奨パターン

```json
// ① 単純キー
"bind": "isLoading"

// ② ネストアクセス（ドット記法）
"props": { "value": "{{user.name}}" }

// ③ loop / list_view 内でのアイテムフィールド参照
// _LoopScope が item のフィールドを直接スコープに展開するため、
// "item.name" ではなく "name" とだけ書く
{
  "type": "loop",
  "props": {
    "items": "userList",
    "item_template": {
      "id": "user_name",
      "type": "text",
      "bind": "name"
    }
  }
}

// ④ 遷移引数の参照
"props": { "value": "{{args.userId}}" }
```

#### ⚠️ 注意事項

- `users[0].name` のような配列インデックス直接参照は現状非推奨。`loop` の `item_template` 内でフィールド名を直接使うこと
- `conditional` の `when: "status == 'active'"` の `status` は BindStore のキー（ローカル変数ではない）
- キー名の命名規約はスネークケース推奨（`isLoading` ではなく `is_loading`）

---

### bind の型

| 型 | 例 | 説明 |
|----|-----|------|
| `String` | `"bind": "userName"` | テキスト・ラベルの動的表示 |
| `Number` | `"bind": "progress"` | スライダー・プログレス値 |
| `Bool` | `"bind": "isVisible"` | `visibility` / `switch` / `checkbox` の制御 |
| `Object` | `"bind": "userProfile"` | `text` の `value` に `{{userProfile.name}}` でフィールド参照 |
| `Array` | `"bind": "items"` | `list_view` / `loop` の動的リスト |

---

### computed — 算出プロパティ

`computed` に式を書くと、BindStore 上で計算値を定義できる。

```json
{
  "computed": {
    "fullName": "{{firstName}} {{lastName}}",
    "isLoggedIn": "{{token}} != null"
  }
}
```

---

### bind_error — バインドエラー時のフォールバック

```json
{
  "id": "price",
  "type": "text",
  "props": { "value": "{{itemPrice}}" },
  "bind": "itemPrice",
  "bind_error": { "value": "---" }
}
```

`bind_error` を指定すると、BindStore にキーが存在しない / null のときにフォールバック表示できる。

---

### async_loader との連携

```json
{
  "id": "loader",
  "type": "async_loader",
  "props": {
    "loadingKey": "isLoading",
    "action": { "type": "functionCall", "name": "fetchData", "storeKey": "listData" }
  },
  "children": [
    { "id": "list", "type": "list_view", "props": { "bind": "listData" } }
  ]
}
```

`async_loader` が `action` を実行 → `storeKey` に結果を保存 → `list_view` が再描画、という流れ。

---

### storeKey の仕様

`functionCall` / `apiCall` の `storeKey` / `assignTo` に指定したキーに、アクションの戻り値が自動で保存される。

```json
{ "type": "apiCall", "url": "/api/products", "method": "GET", "assignTo": "productList" }
```

→ 実行後、`BindStore["productList"]` にレスポンス JSON が入り、`bind: "productList"` な Widget が再描画される。

---

### `{{keyword}}` テンプレート式の完全仕様

`{{key}}` は props の文字列値の中で BindStore の値に展開される。  
Action の `url` / `body` / `message` / `value` など、文字列フィールドに使える。

#### 展開ルール

| 形式 | 例 | 動作 |
|------|----|------|
| `{{key}}` | `{{userName}}` | BindStore の `userName` の値に置換 |
| `{{key.field}}` | `{{user.name}}` | Object の `name` フィールドに置換 |
| `{{args.key}}` | `{{args.userId}}` | 画面遷移引数に置換 |
| 存在しないキー | `{{unknown}}` | 空文字列に置換（エラーにならない） |
| 文字列中に埋め込み | `"¥{{price}}円"` | `¥1200円` のように前後のテキストを保持 |
| 複数埋め込み | `"{{lastName}} {{firstName}}"` | 複数キーを同時展開 |

#### 使用可能な場所

```json
// URL の動的構築
"url": "https://api.example.com/users/{{userId}}/orders"

// リクエストボディ
"body": { "name": "{{inputName}}", "email": "{{inputEmail}}" }

// 表示テキスト
"props": { "value": "こんにちは、{{user.name}}さん" }

// ダイアログメッセージ
"message": "「{{itemName}}」を削除しますか？"

// navigate の args
"args": { "id": "{{selectedId}}" }
```

#### ⚠️ 制約

- 配列インデックス（`{{users[0].name}}`）は非推奨。`loop` の `item_template` 内でフィールドを直接参照する
- ネストは2段階まで推奨（`{{a.b.c}}` は可能だがパフォーマンスに影響）
- `null` や `undefined` は空文字列になる

---

### `{bind}_error` 命名規約

`async_loader` / `bind_error` などで使われる「エラー状態キー」の命名ルール。

```
{bind キー名} + "_error"
```

| bind キー | エラーキー | 用途 |
|-----------|-----------|------|
| `productList` | `productList_error` | APIフェッチ失敗時のエラーメッセージ |
| `userProfile` | `userProfile_error` | プロフィール取得失敗 |
| `loginState` | `loginState_error` | ログイン失敗エラー |

```json
{
  "id": "product_list",
  "type": "list_view",
  "props": { "bind": "productList" },
  "bind_error": {
    "id": "error_msg",
    "type": "text",
    "props": { "value": "{{productList_error}}", "style": { "color": "#E53935" } }
  }
}
```

`actionCall` / `functionCall` が失敗したとき、`{assignTo}_error` に自動でエラーメッセージが保存される。

---

### `conditional` の `when` 式評価ルール

`conditional` コンポーネントの `when` に書く条件式の仕様。

```json
{
  "id": "admin_section",
  "type": "conditional",
  "props": { "when": "role == 'admin'" },
  "children": [...]
}
```

#### 使用できる演算子

| 演算子 | 例 | 説明 |
|-------|----|------|
| `==` | `status == 'active'` | 等値比較 |
| `!=` | `role != 'guest'` | 不等値比較 |
| `>` / `<` | `count > 0` | 数値比較 |
| `>=` / `<=` | `age >= 18` | 数値比較（以上・以下） |
| `&&` | `isLoggedIn && isVerified` | AND |
| `\|\|` | `isAdmin \|\| isMod` | OR |
| `!` | `!isLoading` | NOT |
| 単独キー | `isVisible` | bool キーをそのまま評価（`== true` 省略可） |

#### 評価ルール

- `when` の識別子（`status`, `role` など）はすべて **BindStore のキー** として解決される（ローカル変数ではない）
- 文字列リテラルはシングルクォートで囲む（`'active'`）
- 数値リテラルはそのまま書く（`0`, `18`）
- ネストキー（`user.role == 'admin'`）も使用可

---

## 差分配信（JSON Patch）

ShellApp の最大の強みのひとつ。UIDSL 全体を再配信せず、変更箇所だけを差分で送ることができる。

### JSON Patch とは

RFC 6902 で定義された JSON の部分更新フォーマット。`op` / `path` / `value` の3フィールドで構成される。

### 操作タイプ

| op | 説明 | 例 |
|----|------|----|
| `replace` | 値を置換 | テキスト変更・色変更 |
| `add` | 値を追加 | 新しい子 Widget を追加 |
| `remove` | 値を削除 | Widget の削除 |

### 例：テキストだけ変更

```json
{
  "type": "apply_dsl_patch",
  "patch": [
    { "op": "replace", "path": "/root/children/0/props/value", "value": "キャンペーン開催中！" }
  ]
}
```

### 例：バナーを追加

```json
{
  "type": "apply_dsl_patch",
  "patch": [
    {
      "op": "add",
      "path": "/root/children/0",
      "value": {
        "id": "campaign_banner",
        "type": "image",
        "props": { "src": "https://cdn.example.com/banner.png", "width": 390, "height": 80 }
      }
    }
  ]
}
```

### 例：ウィジェットを削除

```json
{
  "type": "apply_dsl_patch",
  "patch": [
    { "op": "remove", "path": "/root/children/2" }
  ]
}
```

### 大規模アプリでの運用例

- **緊急メンテナンス告知**: サーバーから patch を push → 全ユーザーの画面に即時バナー表示
- **A/B テスト**: バリアント B のユーザーだけ特定 Widget を差し替え
- **運用キャンペーン**: 期間中だけボタンの色とテキストを変更
- **多言語対応**: ロケールに応じたテキストだけ patch で差し替え

> JSON Patch は「ビルドなし・審査なし・即時反映」を実現する ShellApp の核心機能。

---

## StateMachine の実践例

`state_machine` は複雑な非同期フローをシンプルに表現できるコンポーネント。  
各 `state` に対応するウィジェットを定義し、`setState` で遷移する。

### 基本構造

```json
{
  "id": "flow",
  "type": "state_machine",
  "props": { "bind": "flowState", "initial": "idle" },
  "children": [
    { "id": "state_idle",    "type": "...", "props": { "state": "idle" } },
    { "id": "state_loading", "type": "...", "props": { "state": "loading" } },
    { "id": "state_done",    "type": "...", "props": { "state": "done" } },
    { "id": "state_error",   "type": "...", "props": { "state": "error" } }
  ]
}
```

---

### 実践例①：ログインフロー

```
idle（入力中）→ loading（認証中）→ done（完了）/ error（失敗）
```

```json
{
  "id": "login_flow",
  "type": "state_machine",
  "props": { "bind": "loginState", "initial": "idle" },
  "children": [
    {
      "id": "state_idle",
      "type": "column",
      "props": { "state": "idle" },
      "children": [
        { "id": "email",    "type": "text_field", "props": { "label": "メールアドレス", "bind": "email" } },
        { "id": "password", "type": "text_field", "props": { "label": "パスワード", "bind": "password", "obscure": true } },
        {
          "id": "login_btn",
          "type": "button",
          "props": {
            "label": "ログイン",
            "onTap": { "type": "functionCall", "name": "login", "params": { "email": "{{email}}", "password": "{{password}}" } }
          }
        }
      ]
    },
    {
      "id": "state_loading",
      "type": "column",
      "props": { "state": "loading", "mainAxisAlignment": "center" },
      "children": [
        { "id": "spinner", "type": "icon", "props": { "name": "hourglass_empty", "size": 48 } },
        { "id": "msg",     "type": "text", "props": { "value": "認証中...", "textAlign": "center" } }
      ]
    },
    {
      "id": "state_done",
      "type": "column",
      "props": { "state": "done", "mainAxisAlignment": "center" },
      "children": [
        { "id": "ok_icon", "type": "icon", "props": { "name": "check_circle", "size": 64, "color": "#4CAF50" } },
        { "id": "ok_msg",  "type": "text", "props": { "value": "ログイン完了", "textAlign": "center" } }
      ]
    },
    {
      "id": "state_error",
      "type": "column",
      "props": { "state": "error", "mainAxisAlignment": "center" },
      "children": [
        { "id": "err_msg", "type": "text", "props": { "value": "{{loginError}}", "style": { "color": "#E53935" } } },
        {
          "id": "retry_btn",
          "type": "button",
          "props": { "label": "再試行", "onTap": { "type": "setState", "key": "loginState", "value": "idle" } }
        }
      ]
    }
  ]
}
```

---

### 実践例②：注文フロー

```
idle → confirming（確認中）→ processing（処理中）→ done（完了）/ error
```

```json
{
  "id": "order_flow",
  "type": "state_machine",
  "props": { "bind": "orderState", "initial": "idle" },
  "children": [
    { "id": "state_idle",        "type": "text", "props": { "state": "idle",        "value": "注文内容を確認してください" } },
    { "id": "state_confirming",  "type": "text", "props": { "state": "confirming",  "value": "注文を確定しますか？" } },
    { "id": "state_processing",  "type": "text", "props": { "state": "processing",  "value": "処理中..." } },
    { "id": "state_done",        "type": "text", "props": { "state": "done",        "value": "ご注文ありがとうございます！" } },
    { "id": "state_error",       "type": "text", "props": { "state": "error",       "value": "エラーが発生しました: {{orderError}}" } }
  ]
}
```

---

### 実践例③：フォームバリデーションフロー

```
input（入力中）→ validating（検証中）→ submitting（送信中）→ done / error
```

```json
{
  "id": "form_flow",
  "type": "state_machine",
  "props": { "bind": "formState", "initial": "input" },
  "children": [
    {
      "id": "state_input",
      "type": "form",
      "props": {
        "state": "input",
        "onSubmit": { "type": "setState", "key": "formState", "value": "validating" }
      },
      "children": [
        { "id": "name_field",  "type": "text_field", "props": { "label": "名前",  "bind": "formName",  "required": true } },
        { "id": "email_field", "type": "text_field", "props": { "label": "メール", "bind": "formEmail", "required": true } },
        { "id": "submit_btn",  "type": "button",     "props": { "label": "送信", "isSubmit": true } }
      ]
    },
    { "id": "state_validating",  "type": "text", "props": { "state": "validating",  "value": "入力内容を検証中..." } },
    { "id": "state_submitting",  "type": "text", "props": { "state": "submitting",  "value": "送信中..." } },
    { "id": "state_done",        "type": "text", "props": { "state": "done",        "value": "送信完了しました！" } },
    { "id": "state_error",       "type": "text", "props": { "state": "error",       "value": "{{formError}}" } }
  ]
}
```

---

## UIDSL ベストプラクティス

### 命名・構造

| ルール | 理由 |
|--------|------|
| `id` はスネークケース（`login_btn`、`user_name_text`） | JSON / BindStore のキーと統一感が出る |
| `id` は画面内で一意にする | BindStore・デバッグ・Studio の選択で混乱しない |
| `props` は必要最低限に | 不要な props はランタイムのオーバーヘッドになる |
| `children` は 20 個以上にしない | 深すぎるネストは `column` / `card` で分割して整理する |
| 大規模 UI は `loop` / `list_view` でコンポーネント化する | 同構造の繰り返しは `item_template` に切り出す |

### データフロー

| ルール | 理由 |
|--------|------|
| `functionCall` には `storeKey` を必ず指定する | 戻り値が捨てられると再描画が起きない |
| `apiCall` のレスポンスは `Map` か `List` に統一する | BindStore のアクセスパスが予測しやすくなる |
| `{{key}}` 展開は深さ 2 まで（`{{user.name}}`）にとどめる | それ以上のネストはパーサーの負荷と可読性に影響する |
| 機密情報は `secure_set` / `secure_get` で扱う | BindStore はインメモリのため再起動で消える |
| `bind_error` で常にフォールバックを定義する | データ遅延・null によるブランク表示を防げる |

### アクション設計

| ルール | 理由 |
|--------|------|
| アクションのロジックは `actions/` に実装し、UIDSL 側には名前だけ書く | UI と処理の分離を徹底する |
| `on_init` で初期データを取得する | 画面表示直後に必要なデータを揃える |
| `state_machine` で非同期フローを管理する | `isLoading` / `isError` フラグを乱立させない |
| `navigate.replace` はログイン完了・チュートリアル完了のみに使う | 戻れなくなる副作用に注意 |
