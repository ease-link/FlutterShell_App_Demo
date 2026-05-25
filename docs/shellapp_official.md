# 1. はじめに（Introduction）

## 1.1 ShellAppとは
ShellApp は「アプリのUIをコードではなくデータ（UIDSL）で定義し、ランタイムが描画する」新しいアプリケーションOSです。従来のアプリ開発では、UI・画面遷移・フォーム・テーマなどをすべてコードとして実装する必要がありました。ShellApp はこの常識を根本から変えます。

- UI = コード  
ではなく  
- **UI = UIDSL（JSON）**

という構造により、アプリの UI をデータとして定義し、ランタイムが描画するという新しいアプローチを実現します。

## 1.2 ShellAppが生まれた背景
アプリ開発には次のような課題があります。

- UI変更のたびにビルドが必要  
- ストア更新が遅い  
- 多店舗・多言語対応が難しい  
- 業務アプリの現場要望に即応できない  
- コードが肥大化し保守が困難  
- ノーコード/ローコードでは限界がある  

これらは「UIがコードである」ことが原因です。ShellApp は UI をデータ化することで、これらの問題をすべて解決します。

## 1.3 ShellAppのアーキテクチャ概要
ShellApp は以下の3層で構成されます。

### 1. UIDSL（UI Definition DSL）
アプリの UI を JSON で定義するための DSL。画面、レイアウト、コンポーネント、フォーム、リスト、テーマなどをすべて JSON で表現します。

### 2. ShellApp Runtime（Flutter製）
UIDSL を読み込み、実際の UI を描画するランタイム。Web / iOS / Android / Desktop に対応。

### 3. ShellApp Cloud（任意）
UIDSL をホスティングし、アプリに配信する軽量クラウド。GCP / AWS / 自前サーバーなど、どこでも動作可能。

## 1.4 UIDSLの例
以下は最もシンプルな画面の UIDSL 例です。

```json
{
  "screen": {
    "id": "home",
    "title": "ホーム",
    "layout": "column",
    "children": [
      {
        "type": "text",
        "value": "ShellAppへようこそ！"
      },
      {
        "type": "button",
        "label": "次へ",
        "action": {
          "type": "navigate",
          "to": "next_screen"
        }
      }
    ]
  }
}
```

この JSON を ShellApp Runtime に読み込ませるだけで、Flutter コードを書かずに UI が生成されます。

## 1.5 ShellAppの主な特徴
- UIをJSONで定義（UIDSL）
- ランタイムがUIを描画
- ビルド不要のUI更新
- Cloud配信に対応
- 多文化・多業種対応
- Marketplaceによる拡張

## 1.6 ShellAppは誰のためのものか
- 業務アプリを高速に作りたい企業  
- 多店舗・多言語アプリを運用したい企業  
- UIを頻繁に更新したいサービス  
- Flutterのコードを書きたくない開発者  
- ノーコード/ローコードの限界を超えたい人  
- SaaSを構築したいスタートアップ  

## 1.7 ShellAppの思想
> アプリのUIはコードではなくデータであるべき

この思想により、アプリ開発はより速く、より柔軟で、より安全になります。

## 1.8 ShellAppが“しないこと”
- ノーコードツールではない  
- FlutterFlow の代替ではない  
- 単なる UI ライブラリではない  
- 単なる JSON 形式ではない  

ShellApp はアプリケーションOSです。

## 1.9 次のステップ
次の章では、ShellApp の中核である UIDSL の仕様を解説します。

# 2. クイックスタート（Quick Start）

## 2.1 必要なもの
ShellApp を始めるために必要なものは次の3つだけです。

- ShellApp Runtime（アプリ本体）
- UIDSL（UI定義JSON）
- 任意：ShellApp Cloud（UIDSL配信サーバー）

ローカル環境だけでも動作します。

## 2.2 最小のUIDSLを作成する
まずは最もシンプルな UIDSL を作成します。  
`home.json` という名前で保存してください。

```json
{
  "screen": {
    "id": "home",
    "title": "ホーム",
    "layout": "column",
    "children": [
      {
        "type": "text",
        "value": "ShellAppへようこそ！"
      }
    ]
  }
}
```

これだけで1画面のアプリが動作します。

## 2.3 ShellApp RuntimeでUIDSLを読み込む
ShellApp Runtime は UIDSL を読み込み、UI を描画します。  
Runtime の設定で UIDSL のパスを指定します。

例：ローカルファイルを読み込む場合

```
/assets/uidsl/home.json
```

例：クラウドから読み込む場合

```
https://example.com/uidsl/home.json
```

Runtime は起動時に UIDSL を取得し、即座に画面を生成します。

## 2.4 アプリを起動する
UIDSL のパスを設定したら、ShellApp Runtime を起動します。

- Web版 → ブラウザでアクセス  
- モバイル版 → アプリを起動  
- デスクトップ版 → 実行ファイルを起動  

起動すると、先ほどの UIDSL に基づいた画面が表示されます。

## 2.5 UIを変更してみる
UIDSL を編集して保存すると、アプリの UI が即時に変わります。

例：ボタンを追加してみる

```json
{
  "screen": {
    "id": "home",
    "title": "ホーム",
    "layout": "column",
    "children": [
      {
        "type": "text",
        "value": "ShellAppへようこそ！"
      },
      {
        "type": "button",
        "label": "次へ",
        "action": {
          "type": "navigate",
          "to": "next_screen"
        }
      }
    ]
  }
}
```

保存 → アプリを再読み込み  
これだけで UI が更新されます。

## 2.6 Cloud配信を使う場合
ShellApp Cloud を使うと、UIDSL をサーバーに置くだけでアプリの UI を動的に変更できます。

例：Cloud上のUIDSLを指定

```
https://your-cloud.com/app/123/home.json
```

UIDSL を更新すると、アプリ側は自動で最新の UI を取得します。

## 2.7 これでShellAppの基本が理解できます
ここまでで理解できること：

- ShellApp は UIDSL（JSON）で UI を定義する  
- Runtime が UI を描画する  
- ビルド不要で UI を更新できる  
- Cloud を使えば即時反映できる  

次の章では、UIDSL の構造をより詳しく解説します。

# 3. DSL リファレンス（DSL Reference）

ShellApp の UI はすべて UIDSL（UI Definition DSL）によって定義されます。  
UIDSL は JSON 形式で記述され、画面・レイアウト・コンポーネント・アクション・データバインドなど、アプリの UI を構成するすべての要素を表現します。

この章では、UIDSL の基本構造と主要フィールドを説明します。

---

## 3.1 UIDSLの基本構造

UIDSL は大きく次の構造で構成されます。

- `screen`（画面定義）
- `layout`（レイアウト）
- `children`（子コンポーネント）
- `type`（コンポーネント種別）
- `action`（アクション）
- `bind`（データバインド）
- `theme`（テーマ設定）

最小構造は以下の通りです。

```json
{
  "screen": {
    "id": "screen_id",
    "title": "タイトル",
    "layout": "column",
    "children": []
  }
}
```

---

## 3.2 screen（画面定義）

画面を定義する最上位要素です。

| フィールド | 型 | 説明 |
|-----------|----|------|
| id | string | 画面ID（ユニーク） |
| title | string | 画面タイトル |
| layout | string | レイアウト方式（column / row / stack など） |
| children | array | 子コンポーネントの配列 |
| theme | object | 画面固有のテーマ設定（任意） |

例：

```json
{
  "screen": {
    "id": "home",
    "title": "ホーム",
    "layout": "column",
    "children": []
  }
}
```

---

## 3.3 layout（レイアウト）

画面やコンテナのレイアウト方式を指定します。

| 値 | 説明 |
|----|------|
| column | 縦方向に並べる |
| row | 横方向に並べる |
| stack | 重ねる |
| list | スクロール可能なリスト |
| grid | グリッド配置 |

例：

```json
{
  "layout": "column"
}
```

---

## 3.4 children（子コンポーネント）

画面やコンテナ内に配置する UI コンポーネントの配列です。

例：

```json
{
  "children": [
    { "type": "text", "value": "Hello" },
    { "type": "button", "label": "OK" }
  ]
}
```

---

## 3.5 type（コンポーネント種別）

コンポーネントの種類を指定します。

代表的な type：

| type | 説明 |
|------|------|
| text | テキスト表示 |
| button | ボタン |
| input | 入力フィールド |
| list | リスト表示 |
| image | 画像 |
| container | コンテナ（子要素を持つ） |
| card | カードUI |
| spacer | 余白 |

例：

```json
{
  "type": "text",
  "value": "ShellAppへようこそ！"
}
```

---

## 3.6 action（アクション）

ユーザー操作に応じて実行される動作を定義します。

代表的な action：

| type | 説明 |
|------|------|
| navigate | 画面遷移 |
| open_url | 外部URLを開く |
| submit | フォーム送信 |
| dialog | ダイアログ表示 |
| update_state | 状態更新 |

例：画面遷移

```json
{
  "type": "button",
  "label": "次へ",
  "action": {
    "type": "navigate",
    "to": "next_screen"
  }
}
```

---

## 3.7 bind（データバインド）

コンポーネントにデータを紐づけるための仕組みです。

| フィールド | 説明 |
|-----------|------|
| value | 単一値のバインド |
| list | リストデータのバインド |
| if | 条件表示 |
| default | デフォルト値 |

例：単一値バインド

```json
{
  "type": "text",
  "bind": {
    "value": "user.name"
  }
}
```

例：リストバインド

```json
{
  "type": "list",
  "bind": {
    "list": "items"
  }
}
```

---

## 3.8 theme（テーマ設定）

画面やコンポーネントのスタイルを指定します。

| フィールド | 説明 |
|-----------|------|
| color | 文字色 |
| background | 背景色 |
| padding | 余白 |
| margin | 外側余白 |
| font_size | フォントサイズ |

例：

```json
{
  "theme": {
    "color": "#333333",
    "background": "#FFFFFF",
    "padding": 16
  }
}
```

---

## 3.9 UIDSLの完全サンプル

以下は、画面・テキスト・ボタン・アクションを含む UIDSL の完全例です。

```json
{
  "screen": {
    "id": "home",
    "title": "ホーム",
    "layout": "column",
    "children": [
      {
        "type": "text",
        "value": "ShellAppへようこそ！"
      },
      {
        "type": "button",
        "label": "次へ",
        "action": {
          "type": "navigate",
          "to": "next_screen"
        }
      }
    ]
  }
}
```

---

## 3.10 次のステップ
次の章では、各コンポーネントの詳細仕様を説明します。

# 4. Meta Components（メタコンポーネント）

Meta Components（メタコンポーネント）は、ShellApp の UIDSL を構成する上で最も重要な概念のひとつです。  
通常のコンポーネント（text, button, input など）とは異なり、Meta Components は **「UIを生成するための抽象的な構造」** を表します。

Meta Components を使うことで、複雑な UI を **少ない記述量で再利用可能な形** にまとめることができます。

---

## 4.1 Meta Componentsとは

Meta Components は、複数の UI コンポーネントをまとめた **再利用可能なUIブロック** です。

- 共通レイアウト  
- 共通フォーム  
- 共通カードUI  
- 共通リストアイテム  
- 共通ヘッダー/フッター  

などをひとつの「メタコンポーネント」として定義し、  
複数画面で使い回すことができます。

---

## 4.2 Meta Componentsの基本構造

Meta Component は `meta` キーで定義します。

```json
{
  "meta": {
    "id": "user_card",
    "description": "ユーザー情報カード",
    "template": {
      "type": "container",
      "layout": "row",
      "children": [
        { "type": "image", "bind": { "value": "user.avatar" } },
        { "type": "text", "bind": { "value": "user.name" } }
      ]
    }
  }
}
```

| フィールド | 説明 |
|-----------|------|
| id | メタコンポーネントの識別子 |
| description | 説明（任意） |
| template | 実際の UI を構成するテンプレート |

---

## 4.3 Meta Componentsの利用方法

定義したメタコンポーネントは、通常のコンポーネントと同じように `type: "meta"` で呼び出します。

```json
{
  "type": "meta",
  "ref": "user_card",
  "bind": {
    "user": "current_user"
  }
}
```

| フィールド | 説明 |
|-----------|------|
| type | `"meta"` 固定 |
| ref | 使用するメタコンポーネントID |
| bind | テンプレート内で使用するデータのバインド |

---

## 4.4 パラメータ付きMeta Components

Meta Components はパラメータを受け取ることができます。

### 定義側

```json
{
  "meta": {
    "id": "title_bar",
    "params": ["title"],
    "template": {
      "type": "container",
      "layout": "row",
      "children": [
        { "type": "text", "bind": { "value": "params.title" } }
      ]
    }
  }
}
```

### 呼び出し側

```json
{
  "type": "meta",
  "ref": "title_bar",
  "params": {
    "title": "設定画面"
  }
}
```

---

## 4.5 Meta Componentsの用途

### 1. 共通UIの再利用
- ヘッダー
- フッター
- カードUI
- リストアイテム

### 2. 業務アプリの共通フォーム
- 顧客情報フォーム
- 商品情報フォーム
- 住所入力フォーム

### 3. テンプレート化された画面構造
- 一覧画面
- 詳細画面
- 編集画面

### 4. Marketplaceでの配布
Meta Components は Marketplace で配布可能で、  
他のプロジェクトでも再利用できます。

---

## 4.6 Meta Componentsの完全サンプル

以下は、ユーザー情報カードを定義し、画面で利用する完全例です。

```json
{
  "meta": {
    "id": "user_card",
    "description": "ユーザー情報カード",
    "template": {
      "type": "container",
      "layout": "row",
      "children": [
        {
          "type": "image",
          "bind": { "value": "user.avatar" },
          "theme": { "size": 48 }
        },
        {
          "type": "text",
          "bind": { "value": "user.name" },
          "theme": { "font_size": 18 }
        }
      ]
    }
  },
  "screen": {
    "id": "home",
    "title": "ホーム",
    "layout": "column",
    "children": [
      {
        "type": "meta",
        "ref": "user_card",
        "bind": {
          "user": "current_user"
        }
      }
    ]
  }
}
```

---

## 4.7 次のステップ
次の章では、各コンポーネントの詳細仕様を説明します。

# 5. Action Engine（アクションエンジン）

Action Engine は、ShellApp の UI に「動作」を与える仕組みです。  
ボタンを押す、画面を遷移する、フォームを送信する、ダイアログを表示するなど、  
アプリ内のすべてのアクションは Action Engine によって処理されます。

UIDSL 内では `action` キーで定義します。

---

## 5.1 Action Engineの役割

Action Engine は次のような役割を持ちます。

- ユーザー操作に応じたアクションの実行
- 画面遷移の制御
- 外部APIの呼び出し
- 状態管理（State）の更新
- ダイアログや通知の表示
- 条件分岐（if）や複数アクションの連続実行

Action Engine は **宣言的に書かれた JSON を解釈して動作する** ため、  
コードを書かずにアプリの動作を定義できます。

---

## 5.2 Actionの基本構造

アクションは以下のように定義します。

```json
{
  "action": {
    "type": "navigate",
    "to": "next_screen"
  }
}
```

| フィールド | 説明 |
|-----------|------|
| type | アクションの種類 |
| ... | アクションごとの追加パラメータ |

---

## 5.3 代表的なAction一覧

| type | 説明 |
|------|------|
| navigate | 画面遷移 |
| open_url | 外部URLを開く |
| submit | フォーム送信 |
| dialog | ダイアログ表示 |
| update_state | 状態更新 |
| sequence | 複数アクションの連続実行 |
| if | 条件付きアクション |
| back | 前の画面に戻る |
| refresh | 画面の再読み込み |

---

## 5.4 navigate（画面遷移）

画面を別の screen に遷移します。

```json
{
  "action": {
    "type": "navigate",
    "to": "detail_screen"
  }
}
```

---

## 5.5 open_url（外部URLを開く）

ブラウザまたはアプリ内WebViewでURLを開きます。

```json
{
  "action": {
    "type": "open_url",
    "url": "https://example.com"
  }
}
```

---

## 5.6 submit（フォーム送信）

フォームデータを API に送信します。

```json
{
  "action": {
    "type": "submit",
    "endpoint": "/api/user/update",
    "method": "POST"
  }
}
```

---

## 5.7 dialog（ダイアログ表示）

メッセージダイアログを表示します。

```json
{
  "action": {
    "type": "dialog",
    "title": "確認",
    "message": "保存しますか？"
  }
}
```

---

## 5.8 update_state（状態更新）

アプリ内の状態（State）を更新します。

```json
{
  "action": {
    "type": "update_state",
    "set": {
      "user.name": "新しい名前"
    }
  }
}
```

---

## 5.9 sequence（複数アクションの連続実行）

複数のアクションを順番に実行します。

```json
{
  "action": {
    "type": "sequence",
    "actions": [
      { "type": "update_state", "set": { "loading": true } },
      { "type": "submit", "endpoint": "/api/save" },
      { "type": "dialog", "title": "完了", "message": "保存しました" }
    ]
  }
}
```

---

## 5.10 if（条件付きアクション）

条件に応じてアクションを切り替えます。

```json
{
  "action": {
    "type": "if",
    "condition": "user.logged_in == true",
    "then": {
      "type": "navigate",
      "to": "dashboard"
    },
    "else": {
      "type": "navigate",
      "to": "login"
    }
  }
}
```

---

## 5.11 back（戻る）

前の画面に戻ります。

```json
{
  "action": {
    "type": "back"
  }
}
```

---

## 5.12 refresh（画面再読み込み）

現在の画面を再読み込みします。

```json
{
  "action": {
    "type": "refresh"
  }
}
```

---

## 5.13 Actionの完全サンプル

以下は、ボタン押下 → 状態更新 → API送信 → ダイアログ表示  
という一連の流れを sequence で実現した例です。

```json
{
  "type": "button",
  "label": "保存",
  "action": {
    "type": "sequence",
    "actions": [
      {
        "type": "update_state",
        "set": { "saving": true }
      },
      {
        "type": "submit",
        "endpoint": "/api/save",
        "method": "POST"
      },
      {
        "type": "dialog",
        "title": "完了",
        "message": "保存しました"
      }
    ]
  }
}
```

---

## 5.14 次のステップ
次の章では、データバインド（bind）の仕様を説明します。

# 6. BindStore（状態管理）

BindStore は ShellApp の状態管理システムです。  
画面間で共有されるデータ、フォーム入力値、APIレスポンス、UIの表示制御など、  
アプリ内のあらゆる状態を BindStore が一元管理します。

BindStore は UIDSL の `bind` と連携し、  
**「データ → UI」**  
**「UI → データ」**  
の双方向バインディングを実現します。

---

## 6.1 BindStoreの役割

BindStore は次のような役割を持ちます。

- グローバル状態の保持
- 画面ローカル状態の保持
- APIレスポンスの保存
- フォーム入力値の保存
- UIコンポーネントへのデータバインド
- アクションによる状態更新（update_state）
- 条件分岐（if）での利用

BindStore は ShellApp Runtime 内に存在し、  
UIDSL のどこからでも参照できます。

---

## 6.2 BindStoreの基本構造

BindStore は JSON の階層構造で管理されます。

例：

```json
{
  "user": {
    "name": "大輔",
    "logged_in": true
  },
  "ui": {
    "loading": false
  }
}
```

---

## 6.3 bind（データバインド）との関係

コンポーネントは `bind` を使って BindStore の値を参照します。

例：単一値バインド

```json
{
  "type": "text",
  "bind": {
    "value": "user.name"
  }
}
```

例：リストバインド

```json
{
  "type": "list",
  "bind": {
    "list": "items"
  }
}
```

---

## 6.4 BindStoreの更新（update_state）

Action Engine の `update_state` を使って BindStore を更新できます。

```json
{
  "action": {
    "type": "update_state",
    "set": {
      "ui.loading": true
    }
  }
}
```

複数の値を同時に更新することも可能です。

```json
{
  "action": {
    "type": "update_state",
    "set": {
      "user.name": "新しい名前",
      "ui.loading": false
    }
  }
}
```

---

## 6.5 APIレスポンスの保存

`submit` アクションで API を呼び出した場合、  
レスポンスは自動的に BindStore に保存されます。

```json
{
  "action": {
    "type": "submit",
    "endpoint": "/api/user",
    "save_to": "user"
  }
}
```

これにより、次のように UI に反映できます。

```json
{
  "type": "text",
  "bind": {
    "value": "user.name"
  }
}
```

---

## 6.6 フォーム入力値の保存

input コンポーネントは自動的に BindStore に値を保存します。

```json
{
  "type": "input",
  "bind": {
    "value": "form.email"
  }
}
```

ユーザーが入力すると、BindStore は次のように更新されます。

```json
{
  "form": {
    "email": "example@example.com"
  }
}
```

---

## 6.7 条件分岐（if）での利用

BindStore の値は条件分岐にも利用できます。

```json
{
  "action": {
    "type": "if",
    "condition": "user.logged_in == true",
    "then": { "type": "navigate", "to": "dashboard" },
    "else": { "type": "navigate", "to": "login" }
  }
}
```

---

## 6.8 BindStoreの初期値（initial_state）

画面ごとに初期状態を設定できます。

```json
{
  "screen": {
    "id": "home",
    "initial_state": {
      "ui": {
        "loading": false
      }
    }
  }
}
```

---

## 6.9 BindStoreのスコープ

BindStore には2種類のスコープがあります。

### 1. グローバルスコープ
アプリ全体で共有される状態。

例：ログイン情報、設定、テーマなど。

### 2. ローカルスコープ
画面ごとに存在する状態。

例：フォーム入力値、画面内の一時的なフラグなど。

---

## 6.10 BindStoreの完全サンプル

以下は、BindStore を使って  
「ロード中 → API呼び出し → 結果表示」  
を実現する完全例です。

```json
{
  "screen": {
    "id": "home",
    "title": "ホーム",
    "initial_state": {
      "ui": { "loading": false }
    },
    "layout": "column",
    "children": [
      {
        "type": "button",
        "label": "読み込み",
        "action": {
          "type": "sequence",
          "actions": [
            { "type": "update_state", "set": { "ui.loading": true } },
            {
              "type": "submit",
              "endpoint": "/api/user",
              "save_to": "user"
            },
            { "type": "update_state", "set": { "ui.loading": false } }
          ]
        }
      },
      {
        "type": "text",
        "bind": { "value": "user.name" }
      },
      {
        "type": "text",
        "bind": { "value": "ui.loading" }
      }
    ]
  }
}
```

---

## 6.11 次のステップ
次の章では、Theme Engine（テーマエンジン）について説明します。

# 7. Router（画面遷移）

Router は ShellApp の画面遷移を管理する仕組みです。  
ShellApp の画面遷移は UIDSL と Action Engine によって宣言的に定義され、  
コードを書くことなく画面の移動を実現できます。

Router は以下の機能を提供します。

- 画面IDによる遷移
- パラメータ付き遷移
- 戻る（back）
- 画面スタック管理
- 初期画面（initial_route）の設定

---

## 7.1 Routerの基本概念

ShellApp の Router は **画面ID（screen.id）** をキーとして動作します。

例：

```json
{
  "screen": {
    "id": "home"
  }
}
```

画面遷移は Action Engine の `navigate` アクションで行います。

```json
{
  "action": {
    "type": "navigate",
    "to": "home"
  }
}
```

---

## 7.2 navigate（画面遷移）

最も基本的な画面遷移です。

```json
{
  "action": {
    "type": "navigate",
    "to": "detail_screen"
  }
}
```

| フィールド | 説明 |
|-----------|------|
| type | `"navigate"` 固定 |
| to | 遷移先の screen.id |

---

## 7.3 パラメータ付き遷移

画面遷移時にパラメータを渡すことができます。

### 呼び出し側

```json
{
  "action": {
    "type": "navigate",
    "to": "detail",
    "params": {
      "item_id": 123
    }
  }
}
```

### 受け取り側（BindStoreに自動格納）

```json
{
  "screen": {
    "id": "detail",
    "bind": {
      "value": "params.item_id"
    }
  }
}
```

Router は `params` を BindStore の `params` に自動で格納します。

---

## 7.4 back（戻る）

前の画面に戻ります。

```json
{
  "action": {
    "type": "back"
  }
}
```

---

## 7.5 initial_route（初期画面）

アプリ起動時に最初に表示する画面を指定できます。

```json
{
  "app": {
    "initial_route": "home"
  }
}
```

---

## 7.6 Routerの画面スタック

ShellApp の Router は **スタック方式** で画面を管理します。

例：

1. home  
2. → list  
3. → detail  
4. back → list  
5. back → home  

`navigate` はスタックに push  
`back` はスタックから pop

---

## 7.7 条件付き遷移（if）

Action Engine の `if` と組み合わせることで、  
ログイン状態などに応じた遷移が可能です。

```json
{
  "action": {
    "type": "if",
    "condition": "user.logged_in == true",
    "then": {
      "type": "navigate",
      "to": "dashboard"
    },
    "else": {
      "type": "navigate",
      "to": "login"
    }
  }
}
```

---

## 7.8 RouterとBindStoreの連携

遷移時に渡したパラメータは BindStore に保存されます。

例：遷移時

```json
{
  "action": {
    "type": "navigate",
    "to": "profile",
    "params": {
      "user_id": 42
    }
  }
}
```

BindStore に自動で以下が入る：

```json
{
  "params": {
    "user_id": 42
  }
}
```

画面側で利用：

```json
{
  "type": "text",
  "bind": {
    "value": "params.user_id"
  }
}
```

---

## 7.9 Routerの完全サンプル

以下は、一覧画面 → 詳細画面 の遷移を実現する完全例です。

```json
{
  "screen": {
    "id": "list",
    "title": "一覧",
    "layout": "column",
    "children": [
      {
        "type": "button",
        "label": "詳細へ",
        "action": {
          "type": "navigate",
          "to": "detail",
          "params": {
            "item_id": 1001
          }
        }
      }
    ]
  }
}
```

```json
{
  "screen": {
    "id": "detail",
    "title": "詳細",
    "layout": "column",
    "children": [
      {
        "type": "text",
        "bind": {
          "value": "params.item_id"
        }
      },
      {
        "type": "button",
        "label": "戻る",
        "action": {
          "type": "back"
        }
      }
    ]
  }
}
```

---

## 7.10 次のステップ
次の章では、Theme Engine（テーマエンジン）について説明します。

# 8. Theme Engine（テーマ）

Theme Engine は、ShellApp の UI の見た目（色・余白・フォント・サイズなど）を  
UIDSL で宣言的に定義するための仕組みです。

ShellApp のテーマは以下の3階層で構成されます。

1. **グローバルテーマ（アプリ全体）**
2. **画面テーマ（screen単位）**
3. **コンポーネントテーマ（個別UI）**

下位のテーマは上位テーマを上書きする仕組みになっています。

---

## 8.1 Theme Engineの役割

Theme Engine は次のような役割を持ちます。

- アプリ全体の統一感を保つ
- UI の見た目を JSON で制御する
- 画面ごとのテーマ変更
- コンポーネント単位の細かいスタイル調整
- ダークモード / シーズンテーマの切り替え
- 多店舗・多ブランド対応

ShellApp のテーマは **Flutter の ThemeData を抽象化したもの** で、  
UIDSL だけで UI の見た目を完全にコントロールできます。

---

## 8.2 テーマの基本構造

テーマは `theme` キーで定義します。

```json
{
  "theme": {
    "color": "#333333",
    "background": "#FFFFFF",
    "padding": 16,
    "margin": 8,
    "font_size": 14,
    "radius": 8
  }
}
```

---

## 8.3 グローバルテーマ（アプリ全体）

アプリ全体のテーマは `app.theme` に定義します。

```json
{
  "app": {
    "theme": {
      "color": "#222222",
      "background": "#FAFAFA",
      "font_size": 16
    }
  }
}
```

---

## 8.4 画面テーマ（screen単位）

画面ごとにテーマを上書きできます。

```json
{
  "screen": {
    "id": "home",
    "title": "ホーム",
    "theme": {
      "background": "#FFFFFF",
      "padding": 24
    }
  }
}
```

---

## 8.5 コンポーネントテーマ（個別UI）

個別コンポーネントにもテーマを設定できます。

```json
{
  "type": "text",
  "value": "Hello",
  "theme": {
    "color": "#FF0000",
    "font_size": 20
  }
}
```

---

## 8.6 テーマの継承ルール

テーマは以下の順で上書きされます。

1. **グローバルテーマ（最も弱い）**
2. **画面テーマ**
3. **コンポーネントテーマ（最も強い）**

例：

- グローバル：文字色 = 黒  
- 画面テーマ：文字色 = 青  
- コンポーネントテーマ：文字色 = 赤  

→ 実際の文字色は **赤** になります。

---

## 8.7 よく使うテーマプロパティ一覧

| プロパティ | 説明 |
|-----------|------|
| color | 文字色 |
| background | 背景色 |
| padding | 内側余白 |
| margin | 外側余白 |
| font_size | フォントサイズ |
| radius | 角丸 |
| width | 幅 |
| height | 高さ |
| align | 配置（left / center / right） |
| weight | フォント太さ |

---

## 8.8 ダークモード対応

ShellApp はダークモードテーマを切り替えることができます。

```json
{
  "app": {
    "theme": {
      "light": {
        "background": "#FFFFFF",
        "color": "#000000"
      },
      "dark": {
        "background": "#000000",
        "color": "#FFFFFF"
      }
    }
  }
}
```

Runtime が OS のダークモードに応じて自動切り替えします。

---

## 8.9 シーズンテーマ（季節テーマ）

ShellApp はテーマを外部から差し替えることで  
「春テーマ」「夏テーマ」「秋テーマ」「冬テーマ」などを実現できます。

例：春テーマ

```json
{
  "app": {
    "theme": {
      "background": "#FFF5F7",
      "color": "#D6336C",
      "accent": "#FFB3C1"
    }
  }
}
```

テーマを Cloud から配信すれば、  
アプリをビルドし直さずに季節テーマを切り替えられます。

---

## 8.10 テーマの完全サンプル

以下は、グローバルテーマ → 画面テーマ → コンポーネントテーマ  
の3階層を使った完全例です。

```json
{
  "app": {
    "theme": {
      "background": "#F0F0F0",
      "color": "#222222",
      "font_size": 16
    }
  },
  "screen": {
    "id": "home",
    "title": "ホーム",
    "theme": {
      "background": "#FFFFFF",
      "padding": 20
    },
    "layout": "column",
    "children": [
      {
        "type": "text",
        "value": "ShellAppへようこそ！",
        "theme": {
          "color": "#FF0000",
          "font_size": 24
        }
      }
    ]
  }
}
```

---

## 8.11 次のステップ
次の章では、Component Reference（コンポーネントリファレンス）を説明します。

# 9. Plugin System（プラグイン）

Plugin System は、ShellApp の機能を拡張するための仕組みです。  
ShellApp のプラグインは、UI・アクション・データ処理・外部サービス連携などを追加できる  
「拡張モジュール」として動作します。

プラグインは UIDSL から呼び出すことができ、  
ShellApp Runtime によって安全に実行されます。

---

## 9.1 Plugin Systemの目的

Plugin System は次のような目的で設計されています。

- ShellApp の機能を外部モジュールで拡張する
- 特定業務向けの UI / ロジックを追加する
- 外部サービス（Stripe / Firebase / Maps など）と連携する
- Marketplace で配布可能な拡張パッケージを作る
- コアを汚さずに機能追加できる

ShellApp は「アプリケーションOS」であり、  
プラグインはその上で動く **アプリケーション拡張** です。

---

## 9.2 プラグインの種類

ShellApp のプラグインは大きく3種類に分類されます。

### 1. UI Plugin（UIプラグイン）
独自の UI コンポーネントを追加する。

例：  
- QRコード表示  
- 地図コンポーネント  
- カレンダーUI  
- チャート（グラフ）

### 2. Action Plugin（アクションプラグイン）
独自のアクションを追加する。

例：  
- Bluetooth操作  
- NFC読み取り  
- 位置情報取得  
- カメラ撮影

### 3. Service Plugin（サービスプラグイン）
外部サービスと連携する。

例：  
- Stripe 決済  
- Firebase Auth  
- Supabase  
- OpenAI API

---

## 9.3 プラグインの基本構造

プラグインは `plugin` キーで呼び出します。

```json
{
  "type": "plugin",
  "name": "qr_viewer",
  "props": {
    "value": "https://example.com"
  }
}
```

| フィールド | 説明 |
|-----------|------|
| type | `"plugin"` 固定 |
| name | プラグイン名 |
| props | プラグインに渡すパラメータ |

---

## 9.4 UI Pluginの例

QRコード表示プラグインの例：

```json
{
  "type": "plugin",
  "name": "qr_viewer",
  "props": {
    "value": "user.id"
  }
}
```

Runtime は `qr_viewer` プラグインをロードし、  
QRコードを描画します。

---

## 9.5 Action Pluginの例

NFC読み取りプラグインの例：

```json
{
  "action": {
    "type": "plugin",
    "name": "nfc_read",
    "save_to": "nfc.data"
  }
}
```

| フィールド | 説明 |
|-----------|------|
| name | プラグイン名 |
| save_to | 結果を BindStore に保存 |

---

## 9.6 Service Pluginの例

Stripe 決済プラグインの例：

```json
{
  "action": {
    "type": "plugin",
    "name": "stripe_payment",
    "params": {
      "amount": 1200,
      "currency": "JPY"
    }
  }
}
```

---

## 9.7 プラグインのロード方法

プラグインはアプリ起動時にロードされます。

```json
{
  "app": {
    "plugins": [
      "qr_viewer",
      "nfc_read",
      "stripe_payment"
    ]
  }
}
```

Runtime は指定されたプラグインを読み込み、  
UIDSL から利用可能になります。

---

## 9.8 プラグインの安全性

ShellApp のプラグインは以下の安全設計を採用しています。

- サンドボックス実行  
- 権限の明示的要求  
- 外部通信の制限  
- UIDSL からの安全な呼び出し  
- Marketplace での署名検証  

これにより、企業向けアプリでも安全に利用できます。

---

## 9.9 プラグインの開発（概要）

プラグインは Flutter / Dart で開発します。

構成例：

```
plugin/
 ├─ lib/
 │   ├─ plugin.dart
 │   ├─ ui/
 │   └─ actions/
 ├─ plugin.json
 └─ README.md
```

`plugin.json` でプラグインのメタ情報を定義します。

```json
{
  "name": "qr_viewer",
  "type": "ui",
  "version": "1.0.0"
}
```

---

## 9.10 Marketplaceとの連携

プラグインは Marketplace に公開できます。

- UIコンポーネント  
- アクション  
- サービス連携  
- テンプレート  
- Meta Components  

企業や開発者は Marketplace からプラグインを追加し、  
ShellApp を自由に拡張できます。

---

## 9.11 プラグインの完全サンプル

以下は、QRコード表示プラグインを利用した完全例です。

```json
{
  "app": {
    "plugins": ["qr_viewer"]
  },
  "screen": {
    "id": "qr",
    "title": "QRコード",
    "layout": "column",
    "children": [
      {
        "type": "plugin",
        "name": "qr_viewer",
        "props": {
          "value": "https://example.com"
        }
      }
    ]
  }
}
```

---

## 9.12 次のステップ
次の章では、Layout System（レイアウトシステム）について説明します。

# 10. Fault Tolerance（エラー耐性）

ShellApp は「壊れない UI」を最優先に設計されています。  
UIDSL が不完全でも、データが欠損していても、ネットワークが落ちても、  
アプリがクラッシュせず動作し続けることを目的としています。

Fault Tolerance（エラー耐性）は以下の3つの柱で構成されます。

1. **UIDSL Validation（DSLバリデーション）**
2. **Runtime Safety（ランタイム安全性）**
3. **Graceful Degradation（段階的劣化）**

---

## 10.1 UIDSL Validation（DSLバリデーション）

ShellApp Runtime は UIDSL を読み込む際、  
以下のチェックを自動で行います。

- 必須フィールドの存在チェック  
- 不正な type の検出  
- 不正な action の検出  
- 不正な bind の検出  
- JSON 構造の破損チェック  

エラーがあってもアプリは停止せず、  
**可能な範囲で UI を描画** します。

例：必須フィールドが欠けている場合

```json
{
  "screen": {
    "id": "home",
    "children": [
      { "type": "text", "value": "Hello" }
    ]
  }
}
```

`title` がなくても、画面は描画されます。

---

## 10.2 Runtime Safety（ランタイム安全性）

ShellApp Runtime は、実行時エラーを防ぐために  
以下の安全機構を備えています。

### 1. Null Safety（ヌル安全）
- bind が null → 空文字やデフォルト値に置き換え
- list が null → 空リストとして扱う

### 2. Action Safety（アクション安全性）
- navigate の遷移先が存在しない → 無視して警告ログ
- submit の API が失敗 → エラーを BindStore に保存
- plugin が未ロード → 無視して警告ログ

### 3. UI Safety（UI安全性）
- 不正なコンポーネント → 空のコンテナに置き換え
- 不正なテーマ → デフォルトテーマにフォールバック

---

## 10.3 Graceful Degradation（段階的劣化）

ShellApp は「壊れる」のではなく「劣化して動き続ける」設計です。

### 例1：ネットワークが落ちた場合

```json
{
  "action": {
    "type": "submit",
    "endpoint": "/api/user"
  }
}
```

→ ネットワークエラー  
→ アプリはクラッシュせず  
→ BindStore に `error.network = true` を保存  
→ UI は動作し続ける

### 例2：不正な JSON を読み込んだ場合

- 破損した部分をスキップ  
- 残りの UI を描画  
- エラーログを出力

### 例3：プラグインが読み込めない場合

- plugin コンポーネント → 空のプレースホルダーに置き換え  
- アプリは動作継続

---

## 10.4 エラー表示（Error UI）

ShellApp はエラーを UI に表示する仕組みを持っています。

例：APIエラーを表示

```json
{
  "type": "text",
  "bind": {
    "value": "error.message"
  }
}
```

例：ネットワークエラー時の条件表示

```json
{
  "type": "text",
  "bind": {
    "if": "error.network == true",
    "value": "ネットワークに接続できません"
  }
}
```

---

## 10.5 BindStoreへのエラー格納

Action Engine はエラーを BindStore に自動保存します。

例：submit のエラー

```json
{
  "error": {
    "submit": {
      "code": 500,
      "message": "サーバーエラー"
    }
  }
}
```

例：plugin のエラー

```json
{
  "error": {
    "plugin": {
      "name": "nfc_read",
      "message": "NFCが利用できません"
    }
  }
}
```

---

## 10.6 エラーの種類

ShellApp が扱うエラーは以下の通りです。

| 種類 | 説明 |
|------|------|
| network | ネットワークエラー |
| api | APIレスポンスエラー |
| plugin | プラグイン実行エラー |
| dsl | UIDSL構造エラー |
| runtime | ランタイム内部エラー |

---

## 10.7 エラーのログ出力

ShellApp Runtime は以下のログを出力します。

- DSLパースエラー  
- 不正な type / action / bind  
- プラグイン読み込みエラー  
- APIエラー  
- 画面遷移エラー  

ログは開発モードでのみ詳細表示されます。

---

## 10.8 完全サンプル：エラー耐性のある画面

```json
{
  "screen": {
    "id": "home",
    "title": "ホーム",
    "layout": "column",
    "children": [
      {
        "type": "button",
        "label": "読み込み",
        "action": {
          "type": "submit",
          "endpoint": "/api/user",
          "save_to": "user"
        }
      },
      {
        "type": "text",
        "bind": {
          "value": "user.name"
        }
      },
      {
        "type": "text",
        "bind": {
          "if": "error.submit != null",
          "value": "error.submit.message"
        }
      }
    ]
  }
}
```

---

## 10.9 次のステップ
次の章では、Layout System（レイアウトシステム）について説明します。

# 11. Diff Render（差分描画）

Diff Render（差分描画）は、ShellApp Runtime が UIDSL の変更を検知し、  
**変更された部分だけを再描画する仕組み** です。

これにより、ShellApp は以下を実現します。

- 高速な UI 更新  
- 最小限の再描画  
- 大規模画面でも滑らかな動作  
- Cloud 配信時のリアルタイム UI 更新  
- ビルド不要の UI 差分反映  

ShellApp の Diff Render は Flutter の Widget Diff を抽象化し、  
UIDSL ベースで動作するように最適化されています。

---

## 11.1 Diff Renderの目的

Diff Render の目的は次の通りです。

- UIDSL の変更を最小コストで UI に反映する
- 不必要な再描画を避ける
- 大規模アプリでも高速に動作させる
- Cloud 配信時の UI 更新をリアルタイムにする
- 状態（BindStore）と UI の同期を最適化する

---

## 11.2 Diff Renderの仕組み

Diff Render は以下の3ステップで動作します。

### 1. UIDSL のハッシュ化
各コンポーネントは内部的にハッシュ化されます。

例：

```
text("Hello") → hash: A1B2C3
button("OK") → hash: D4E5F6
```

### 2. 前回の UIDSL と比較
前回のハッシュと比較し、変更された部分を特定します。

### 3. 変更された部分だけ再描画
差分があるコンポーネントのみ再描画し、  
他の部分はそのまま保持します。

---

## 11.3 Diff Renderが行う最適化

Diff Render は以下の最適化を行います。

### ✔ コンポーネント単位の差分検知  
text → text（内容変更なし） → 再描画しない  
text → text（内容変更あり） → 再描画する

### ✔ レイアウトの差分検知  
layout が変わらない限り、子要素の再配置を行わない

### ✔ BindStore の差分検知  
bind の値が変わった場合のみ再描画

### ✔ Plugin の差分検知  
plugin の props が変わった場合のみ再実行

---

## 11.4 Diff Renderの例

### 変更前

```json
{
  "type": "text",
  "value": "Hello"
}
```

### 変更後

```json
{
  "type": "text",
  "value": "Hello World"
}
```

Diff Render は以下を判断します。

- type は同じ（text）  
- theme も同じ  
- value が変更された  

→ **value の変更のみ再描画**

---

## 11.5 リストの差分描画（List Diff）

リストは差分描画の恩恵が最も大きい部分です。

例：

```json
{
  "type": "list",
  "bind": {
    "list": "items"
  }
}
```

BindStore の `items` が以下のように変化した場合：

```
[1,2,3] → [1,2,3,4]
```

Diff Render は以下を行います。

- 既存の 1,2,3 は再描画しない  
- 追加された 4 のみ描画  

---

## 11.6 Meta Components と Diff Render

Meta Components も内部的にはハッシュ化されるため、  
テンプレートの一部が変わった場合のみ再描画されます。

例：

```
user_card の theme が変わった → 全 user_card を再描画  
user_card の内部テキストが変わった → 該当部分のみ再描画  
```

---

## 11.7 Cloud 配信と Diff Render

Cloud から UIDSL を取得した場合でも、  
Diff Render により **差分のみ反映** されます。

例：

- Cloud でボタンのラベルだけ変更  
- アプリ側はボタン部分だけ再描画  
- 画面全体は再描画しない  

これにより、  
**リアルタイム UI 更新が高速で安全に実現** されます。

---

## 11.8 Diff Renderの制限

以下の場合はフル再描画が発生します。

- layout が変更された場合  
- コンポーネントの type が変更された場合  
- plugin が別の plugin に変わった場合  
- screen.id が変わった場合（画面遷移扱い）  

---

## 11.9 Diff Renderの完全サンプル

以下は、Cloud から UIDSL を更新し、  
Diff Render が差分だけを反映する例です。

### 更新前

```json
{
  "type": "button",
  "label": "送信"
}
```

### 更新後

```json
{
  "type": "button",
  "label": "保存"
}
```

Diff Render の判断：

- type: button → 変更なし  
- theme: 変更なし  
- label: 変更あり  

→ **label のみ再描画**

---

## 11.10 次のステップ
次の章では、Marketplace（マーケットプレイス）について説明します。

# 12. Logging（ログ）

Logging（ログ）は、ShellApp Runtime がアプリの動作状況を記録する仕組みです。  
ShellApp のログは、開発・デバッグ・運用において重要な役割を果たします。

Logging は以下の目的で設計されています。

- UIDSL の解析状況を把握する
- Action の実行状況を追跡する
- BindStore の更新を確認する
- API 通信の成功/失敗を記録する
- Plugin の動作を監視する
- エラーの原因を特定する

ShellApp のログは「開発モードで詳細」「本番モードで最小限」という方針で動作します。

---

## 12.1 ログの種類

ShellApp のログは以下のカテゴリに分類されます。

| カテゴリ | 説明 |
|----------|------|
| system | Runtime の内部動作 |
| dsl | UIDSL の解析・構文チェック |
| action | Action Engine の実行ログ |
| bind | BindStore の更新ログ |
| api | API 通信ログ |
| plugin | プラグインの実行ログ |
| error | エラー情報 |

---

## 12.2 ログレベル

ログには以下のレベルがあります。

| レベル | 説明 |
|--------|------|
| debug | 詳細なデバッグ情報（開発モードのみ） |
| info | 通常の動作ログ |
| warn | 注意が必要な動作 |
| error | 実行エラー |
| fatal | 致命的エラー（ShellApp は極力発生させない） |

---

## 12.3 UIDSL ログ（dsl）

UIDSL の解析時に以下のログが出力されます。

- JSON パース成功/失敗
- 不正な type の検出
- 不正な action の検出
- 不正な bind の検出
- 必須フィールドの欠落

例：

```
[dsl][warn] Missing field: screen.title
[dsl][error] Unknown component type: "textbox"
```

---

## 12.4 Action ログ（action）

Action Engine の実行ログです。

例：navigate

```
[action][info] navigate → detail_screen
```

例：submit

```
[action][info] submit POST /api/user
```

例：if 条件

```
[action][debug] condition user.logged_in == true → true
```

---

## 12.5 BindStore ログ（bind）

BindStore の更新ログです。

```
[bind][info] set ui.loading = true
[bind][debug] set user.name = "大輔"
```

---

## 12.6 API ログ（api）

API 通信の成功/失敗を記録します。

成功：

```
[api][info] 200 OK /api/user
```

失敗：

```
[api][error] 500 Server Error /api/user
```

タイムアウト：

```
[api][warn] Timeout /api/user
```

---

## 12.7 Plugin ログ（plugin）

プラグインの実行ログです。

```
[plugin][info] execute qr_viewer
[plugin][error] plugin nfc_read not available
```

---

## 12.8 エラーログ（error）

ShellApp のエラーはすべて error カテゴリに記録されます。

例：DSL エラー

```
[error][dsl] Invalid JSON at line 12
```

例：Action エラー

```
[error][action] navigate target not found: "unknown_screen"
```

例：Plugin エラー

```
[error][plugin] stripe_payment failed: invalid API key
```

---

## 12.9 ログの出力先

ShellApp のログは以下に出力されます。

### 1. 開発モード（debug）
- コンソール（Flutter DevTools）
- ShellApp Debug Overlay（オーバーレイ表示）

### 2. 本番モード（release）
- 最小限の info / warn / error のみ
- オプションで外部ログサービスに送信可能

---

## 12.10 ログフィルタリング

ログはカテゴリごとにフィルタリングできます。

例：action と api のみ表示

```json
{
  "app": {
    "logging": {
      "enabled": true,
      "filter": ["action", "api"]
    }
  }
}
```

---

## 12.11 ログの完全サンプル

以下は、画面遷移 → API 呼び出し → BindStore 更新  
の一連のログ例です。

```
[action][info] navigate → user_detail
[api][info] POST /api/user
[api][info] 200 OK
[bind][info] set user.name = "大輔"
[action][info] dialog "保存しました"
```

---

## 12.12 次のステップ
次の章では、Marketplace（マーケットプレイス）について説明します。

# 13. Utilities（ユーティリティ）

Utilities（ユーティリティ）は、ShellApp Runtime が提供する  
**共通処理・便利関数・補助ロジック** の集合です。

Utilities は UIDSL 内で利用でき、  
Action Engine や BindStore と組み合わせることで  
より柔軟な UI ロジックを実現します。

Utilities は以下のカテゴリで構成されます。

1. **Formatter（フォーマッタ）**
2. **Validator（バリデータ）**
3. **Converter（変換）**
4. **Helper Functions（ヘルパー関数）**

---

## 13.1 Formatter（フォーマッタ）

Formatter は値を整形するためのユーティリティです。

### 代表的なフォーマッタ

| 名前 | 説明 |
|------|------|
| format.date | 日付フォーマット |
| format.number | 数値フォーマット |
| format.currency | 通貨フォーマット |
| format.percent | パーセント表示 |
| format.upper | 大文字化 |
| format.lower | 小文字化 |

### 使用例

```json
{
  "type": "text",
  "bind": {
    "value": "format.date(user.created_at, 'YYYY/MM/DD')"
  }
}
```

---

## 13.2 Validator（バリデータ）

Validator は入力値の検証に使用します。

### 代表的なバリデータ

| 名前 | 説明 |
|------|------|
| validate.required | 必須チェック |
| validate.email | メール形式 |
| validate.number | 数値チェック |
| validate.min | 最小値 |
| validate.max | 最大値 |

### 使用例

```json
{
  "type": "input",
  "bind": {
    "value": "form.email"
  },
  "validate": [
    "validate.required",
    "validate.email"
  ]
}
```

---

## 13.3 Converter（変換）

Converter は値を別の形式に変換します。

### 代表的なコンバータ

| 名前 | 説明 |
|------|------|
| convert.bool | 真偽値変換 |
| convert.int | 整数変換 |
| convert.float | 小数変換 |
| convert.string | 文字列変換 |
| convert.json | JSON 文字列 → オブジェクト |

### 使用例

```json
{
  "type": "text",
  "bind": {
    "value": "convert.string(user.age)"
  }
}
```

---

## 13.4 Helper Functions（ヘルパー関数）

Helper Functions は UI ロジックを簡潔に記述するための関数です。

### 代表的なヘルパー

| 名前 | 説明 |
|------|------|
| util.is_empty | 空判定 |
| util.not | 否定 |
| util.eq | 等価比較 |
| util.gt | 大なり |
| util.lt | 小なり |
| util.len | 長さ取得 |

### 使用例：条件表示

```json
{
  "type": "text",
  "bind": {
    "if": "util.is_empty(user.name)",
    "value": "名前が未設定です"
  }
}
```

---

## 13.5 Utilities と BindStore の連携

Utilities は BindStore の値を直接扱えます。

例：数値をフォーマットして表示

```json
{
  "type": "text",
  "bind": {
    "value": "format.number(stats.count)"
  }
}
```

例：条件分岐に利用

```json
{
  "action": {
    "type": "if",
    "condition": "util.gt(cart.total, 0)",
    "then": { "type": "navigate", "to": "checkout" },
    "else": { "type": "dialog", "message": "カートが空です" }
  }
}
```

---

## 13.6 Utilities の拡張（カスタムユーティリティ）

ShellApp はカスタムユーティリティを追加できます。

### 定義例（plugin 側）

```json
{
  "utility": {
    "name": "util.is_adult",
    "params": ["age"],
    "script": "return age >= 20;"
  }
}
```

### 呼び出し例（UIDSL）

```json
{
  "bind": {
    "if": "util.is_adult(user.age)",
    "value": "成人ユーザーです"
  }
}
```

---

## 13.7 Utilities の安全性

Utilities は以下の安全設計を採用しています。

- サンドボックス実行  
- 外部アクセス不可  
- プラグインユーティリティは署名検証  
- 無限ループ防止  
- 型安全な実行環境  

---

## 13.8 Utilities の完全サンプル

以下は、Formatter + Validator + Helper を組み合わせた例です。

```json
{
  "screen": {
    "id": "profile",
    "title": "プロフィール",
    "layout": "column",
    "children": [
      {
        "type": "input",
        "label": "メールアドレス",
        "bind": { "value": "form.email" },
        "validate": ["validate.required", "validate.email"]
      },
      {
        "type": "text",
        "bind": {
          "value": "format.lower(form.email)"
        }
      },
      {
        "type": "text",
        "bind": {
          "if": "util.is_empty(form.email)",
          "value": "メールが未入力です"
        }
      }
    ]
  }
}
```

---

## 13.9 次のステップ
次の章では、Layout System（レイアウトシステム）について説明します。

# 14. Best Practices（ベストプラクティス）

この章では、ShellApp を最大限に活用するための  
**設計・運用・パフォーマンス・保守性** に関するベストプラクティスをまとめます。

ShellApp は「UI = データ」という思想で動作するため、  
従来のアプリ開発とは異なる最適化ポイントがあります。

---

## 14.1 UIDSL 設計のベストプラクティス

### ✔ 画面は「小さく・シンプル」に保つ
1画面に大量の UI を詰め込むと、可読性と保守性が低下します。

- 1画面 = 1目的  
- 大きな画面は Meta Components に分割  
- 再利用できる UI は必ずメタ化する  

### ✔ ID は一貫した命名規則を使う
例：

```
home
home.list
home.detail
user.profile
user.settings
```

階層構造を意識すると管理が楽になります。

### ✔ JSON の構造は「浅く」保つ
ネストが深いと可読性が落ちるため、  
container を乱用しないようにする。

---

## 14.2 BindStore のベストプラクティス

### ✔ BindStore は「状態の最小集合」を保持する
状態は必要最小限にする。

悪い例：

```
user.name_copy
user.name_backup
user.name_temp
```

良い例：

```
user.name
```

### ✔ フォームは form.* に統一する

```
form.email
form.password
form.address
```

### ✔ API レスポンスは save_to で直接 BindStore に保存する

```
save_to: "user"
```

---

## 14.3 Action Engine のベストプラクティス

### ✔ sequence は 3〜5 アクション以内に収める
長すぎる sequence はデバッグが困難。

### ✔ 条件分岐は if を使い、複雑なロジックは Utilities へ
複雑な条件式は util.* に切り出す。

### ✔ navigate は screen.id を必ず固定文字列で指定する
動的に screen.id を生成しない。

---

## 14.4 Theme のベストプラクティス

### ✔ グローバルテーマ → 画面テーマ → コンポーネントテーマ の順で上書き
テーマは階層構造で管理する。

### ✔ 色・余白・フォントサイズは変数化する
例：

```
theme.primary_color
theme.spacing_m
theme.font_l
```

### ✔ ダークモードは必ず light/dark の両方を定義する

---

## 14.5 Meta Components のベストプラクティス

### ✔ 再利用できる UI は必ずメタ化する
- カード  
- リストアイテム  
- ヘッダー  
- フォーム  

### ✔ params を使って柔軟性を持たせる

```
params: ["title", "icon"]
```

### ✔ Meta Components は 1ファイル1定義が理想
大規模化を防ぐ。

---

## 14.6 Plugin のベストプラクティス

### ✔ プラグイン名は一意で短く
```
qr_viewer
nfc_read
stripe_payment
```

### ✔ props は最小限にする
複雑なロジックは plugin 側で処理する。

### ✔ plugin のエラーは BindStore に保存して UI で表示する

---

## 14.7 Diff Render のベストプラクティス

### ✔ UIDSL の変更は最小限にする
差分描画が効率的に動作する。

### ✔ リストには一意の key を持たせる（推奨）
```
bind.list: "items"
key: "id"
```

### ✔ layout を頻繁に変更しない
layout が変わるとフル再描画になる。

---

## 14.8 Logging のベストプラクティス

### ✔ 開発モードでは logging.filter を活用する

```
filter: ["action", "api"]
```

### ✔ 本番では error / warn のみを残す

### ✔ API エラーは UI に表示する

---

## 14.9 UIDSL のファイル構成ベストプラクティス

### ✔ 画面ごとにファイルを分割する

```
screens/
  home.json
  user_detail.json
  settings.json
```

### ✔ Meta Components は meta/ にまとめる

```
meta/
  user_card.json
  list_item.json
```

### ✔ Plugin 設定は app.json にまとめる

---

## 14.10 完全サンプル：ベストプラクティスを適用した構成

```
app.json
screens/
  home.json
  user/
    profile.json
    settings.json
meta/
  card/
    user_card.json
  layout/
    section_header.json
theme/
  light.json
  dark.json
```

---

## 14.11 次のステップ
次の章では、Layout System（レイアウトシステム）について説明します。

# 15. Examples（サンプル）

この章では、ShellApp の主要機能を理解するための  
**実践的な UIDSL サンプル** を紹介します。

- 基本画面  
- フォーム  
- リスト  
- 画面遷移  
- API 連携  
- Meta Components  
- Plugin  
- Diff Render  
- BindStore  
- 条件分岐  
- テーマ適用  

など、ShellApp の実用的な構成をまとめています。

---

## 15.1 基本画面（Hello World）

```json
{
  "screen": {
    "id": "hello",
    "title": "Hello",
    "layout": "column",
    "children": [
      { "type": "text", "value": "Hello ShellApp!" }
    ]
  }
}
```

---

## 15.2 ボタン + 画面遷移

```json
{
  "screen": {
    "id": "home",
    "title": "ホーム",
    "layout": "column",
    "children": [
      {
        "type": "button",
        "label": "次へ",
        "action": {
          "type": "navigate",
          "to": "next"
        }
      }
    ]
  }
}
```

---

## 15.3 フォーム入力 + BindStore

```json
{
  "screen": {
    "id": "form",
    "title": "フォーム",
    "layout": "column",
    "children": [
      {
        "type": "input",
        "label": "名前",
        "bind": { "value": "form.name" }
      },
      {
        "type": "text",
        "bind": { "value": "form.name" }
      }
    ]
  }
}
```

---

## 15.4 リスト表示（BindStore 連携）

```json
{
  "screen": {
    "id": "list",
    "title": "一覧",
    "layout": "list",
    "children": [],
    "bind": {
      "list": "items"
    }
  }
}
```

BindStore:

```json
{
  "items": [
    { "name": "りんご" },
    { "name": "バナナ" },
    { "name": "みかん" }
  ]
}
```

---

## 15.5 API 連携（submit + save_to）

```json
{
  "screen": {
    "id": "user",
    "title": "ユーザー情報",
    "layout": "column",
    "children": [
      {
        "type": "button",
        "label": "読み込み",
        "action": {
          "type": "submit",
          "endpoint": "/api/user",
          "save_to": "user"
        }
      },
      {
        "type": "text",
        "bind": { "value": "user.name" }
      }
    ]
  }
}
```

---

## 15.6 条件分岐（if）

```json
{
  "type": "text",
  "bind": {
    "if": "user.logged_in == true",
    "value": "ログイン済み"
  }
}
```

---

## 15.7 Meta Components（ユーザーカード）

### 定義

```json
{
  "meta": {
    "id": "user_card",
    "template": {
      "type": "container",
      "layout": "row",
      "children": [
        { "type": "image", "bind": { "value": "user.avatar" } },
        { "type": "text", "bind": { "value": "user.name" } }
      ]
    }
  }
}
```

### 利用

```json
{
  "type": "meta",
  "ref": "user_card",
  "bind": { "user": "current_user" }
}
```

---

## 15.8 Plugin（QRコード表示）

```json
{
  "type": "plugin",
  "name": "qr_viewer",
  "props": {
    "value": "https://example.com"
  }
}
```

---

## 15.9 Diff Render（差分描画）

### 更新前

```json
{
  "type": "text",
  "value": "送信"
}
```

### 更新後

```json
{
  "type": "text",
  "value": "保存"
}
```

→ Diff Render は **value のみ再描画**。

---

## 15.10 テーマ適用（Theme Engine）

```json
{
  "type": "text",
  "value": "タイトル",
  "theme": {
    "color": "#FF0000",
    "font_size": 24
  }
}
```

---

## 15.11 完全サンプル：ログイン画面

```json
{
  "screen": {
    "id": "login",
    "title": "ログイン",
    "layout": "column",
    "children": [
      {
        "type": "input",
        "label": "メール",
        "bind": { "value": "form.email" }
      },
      {
        "type": "input",
        "label": "パスワード",
        "bind": { "value": "form.password" }
      },
      {
        "type": "button",
        "label": "ログイン",
        "action": {
          "type": "submit",
          "endpoint": "/api/login",
          "save_to": "user"
        }
      },
      {
        "type": "text",
        "bind": {
          "if": "error.submit != null",
          "value": "error.submit.message"
        }
      }
    ]
  }
}
```

---

## 15.12 次のステップ
次の章では、Marketplace（マーケットプレイス）について説明します。

# 16. ShellApp Studio（GUI エディタ）

ShellApp Studio は、ShellApp の UIDSL を GUI で編集するための  
**公式ビジュアルエディタ（GUI Editor）** です。

Studio を使うことで、開発者はコードを書かずに  
画面構築・テーマ設定・アクション定義・プレビュー・デプロイを  
すべて GUI 上で行うことができます。

ShellApp Studio は以下の特徴を持ちます。

- ノーコードで UIDSL を生成  
- リアルタイムプレビュー  
- Diff Render による高速反映  
- BindStore の状態確認  
- Action の動作テスト  
- Meta Components の管理  
- Plugin の設定  
- Cloud へのデプロイ  

---

## 16.1 ShellApp Studio の目的

ShellApp Studio は次の目的で設計されています。

- UIDSL を GUI で編集できるようにする  
- 開発者の学習コストを下げる  
- デザイナーとエンジニアの共同作業を容易にする  
- Cloud 配信と連携し、即時 UI 更新を可能にする  
- ShellApp の全機能を視覚的に操作できるようにする  

---

## 16.2 Studio の主な機能

ShellApp Studio は以下の機能を提供します。

### ✔ 1. 画面エディタ（Screen Editor）
- ドラッグ＆ドロップで UI を配置  
- レイアウト（column / row / list / grid）を GUI で設定  
- コンポーネントの追加・削除・並び替え  

### ✔ 2. プロパティパネル（Properties Panel）
選択したコンポーネントの設定を GUI で編集。

- type  
- label / value  
- bind  
- action  
- theme  
- plugin props  

### ✔ 3. アクションエディタ（Action Editor）
Action Engine の設定を GUI で編集。

- navigate  
- submit  
- dialog  
- update_state  
- if  
- sequence  

### ✔ 4. BindStore Viewer（状態ビューア）
BindStore の現在値をリアルタイムで確認。

- form 値  
- API レスポンス  
- params  
- error  
- ui 状態  

### ✔ 5. プレビュー（Preview）
- 画面を即時プレビュー  
- Diff Render による高速反映  
- モバイル / タブレット / デスクトップ切り替え  

### ✔ 6. Meta Components Manager
- メタコンポーネントの作成  
- params の設定  
- テンプレート編集  
- 再利用 UI の管理  

### ✔ 7. Plugin Manager
- プラグインの追加 / 削除  
- props の設定  
- plugin の動作テスト  

### ✔ 8. Cloud Sync（クラウド同期）
- UIDSL を Cloud にアップロード  
- アプリ側が即時反映  
- バージョン管理  

---

## 16.3 Studio の画面構成

Studio は以下の 4 ペイン構成です。

1. **左：コンポーネントパレット**  
2. **中央：画面エディタ（Canvas）**  
3. **右：プロパティパネル**  
4. **下：BindStore / Log / Preview 切り替え**

---

## 16.4 Studio が生成する UIDSL

Studio は GUI 操作を UIDSL に変換します。

例：ボタンを追加すると…

```json
{
  "type": "button",
  "label": "送信"
}
```

例：bind を設定すると…

```json
{
  "type": "text",
  "bind": { "value": "user.name" }
}
```

例：action を設定すると…

```json
{
  "action": {
    "type": "navigate",
    "to": "detail"
  }
}
```

Studio は UIDSL を自動生成するため、  
開発者は JSON を手書きする必要がありません。

---

## 16.5 Studio と Diff Render の連携

Studio のプレビューは Diff Render と連携しており、

- コンポーネントの変更  
- テーマの変更  
- bind の変更  
- action の変更  

などが **差分だけ即時反映** されます。

---

## 16.6 Studio と Cloud の連携

Studio から Cloud に UIDSL をアップロードすると、  
アプリ側は自動で最新 UI を取得します。

例：Studio → Cloud → アプリ（リアルタイム更新）

```
Studio でボタンのラベル変更  
→ Cloud に保存  
→ アプリ側が差分だけ再描画  
```

---

## 16.7 Studio のエラー検知（Lint）

Studio は UIDSL のエラーを GUI 上で警告します。

- 不正な type  
- 不正な action  
- bind の参照ミス  
- 必須フィールド不足  
- plugin 未ロード  

例：

```
[warning] bind: user.name が存在しません
```

---

## 16.8 Studio のベストプラクティス

- 画面は小さく分割する  
- Meta Components を積極的に使う  
- bind は form.* / user.* などで整理  
- theme はグローバル → 画面 → 個別の順で設定  
- plugin は必要最小限にする  

---

## 16.9 完全サンプル：Studio で作成した画面

```json
{
  "screen": {
    "id": "profile",
    "title": "プロフィール",
    "layout": "column",
    "children": [
      {
        "type": "input",
        "label": "名前",
        "bind": { "value": "form.name" }
      },
      {
        "type": "button",
        "label": "保存",
        "action": {
          "type": "submit",
          "endpoint": "/api/profile",
          "save_to": "user"
        }
      },
      {
        "type": "text",
        "bind": {
          "if": "error.submit != null",
          "value": "error.submit.message"
        }
      }
    ]
  }
}
```

Studio ではこれを GUI で作成できる。

---

## 16.10 次のステップ
次の章では、Marketplace（マーケットプレイス）について説明します。

# 17. ShellApp CLI（開発ツール）

ShellApp CLI は、ShellApp アプリの開発・ビルド・デプロイ・検証を  
コマンドラインから効率的に行うための公式ツールです。

CLI は以下の用途に最適化されています。

- プロジェクト作成  
- UIDSL の検証  
- ローカルサーバーでのプレビュー  
- Cloud へのデプロイ  
- プラグイン管理  
- Studio との連携  
- ログ・状態の確認  

ShellApp Studio（GUI）と対になる **開発者向けの高速ツールチェーン** です。

---

## 17.1 インストール

（※実際のコマンドは環境に応じて変わる想定）

```
npm install -g shellapp-cli
```

または

```
shellapp upgrade
```

---

## 17.2 CLI の基本コマンド一覧

| コマンド | 説明 |
|---------|------|
| shellapp init | プロジェクト作成 |
| shellapp dev | ローカル開発サーバー起動 |
| shellapp validate | UIDSL の構文チェック |
| shellapp build | 本番ビルド |
| shellapp deploy | Cloud へデプロイ |
| shellapp plugin add | プラグイン追加 |
| shellapp plugin list | プラグイン一覧 |
| shellapp logs | ログ確認 |
| shellapp state | BindStore の状態確認 |

---

## 17.3 プロジェクト作成（init）

```
shellapp init my-app
```

生成される構成例：

```
my-app/
  app.json
  screens/
  meta/
  theme/
  plugins/
```

---

## 17.4 ローカル開発サーバー（dev）

```
shellapp dev
```

機能：

- ローカルで UIDSL を読み込み  
- Diff Render による高速プレビュー  
- BindStore の状態確認  
- Logging のリアルタイム表示  

ブラウザで以下が開く：

```
http://localhost:3000
```

---

## 17.5 UIDSL 構文チェック（validate）

```
shellapp validate
```

チェック内容：

- JSON 構造  
- type / action / bind の整合性  
- 必須フィールド  
- plugin の存在確認  

例：

```
[dsl][warn] Missing field: screen.title
[dsl][error] Unknown component type: "textbox"
```

---

## 17.6 本番ビルド（build）

```
shellapp build
```

出力：

- 最適化された UIDSL  
- 圧縮されたテーマ  
- プラグインバンドル  
- Cloud 配信用パッケージ  

---

## 17.7 Cloud デプロイ（deploy）

```
shellapp deploy
```

機能：

- UIDSL を Cloud にアップロード  
- バージョン管理  
- アプリ側が自動で最新 UI を取得  
- 差分のみ反映（Diff Render）  

---

## 17.8 プラグイン管理（plugin）

### プラグイン追加

```
shellapp plugin add qr_viewer
```

### プラグイン一覧

```
shellapp plugin list
```

### プラグイン削除

```
shellapp plugin remove qr_viewer
```

---

## 17.9 ログ確認（logs）

```
shellapp logs
```

表示されるログ：

- dsl  
- action  
- api  
- plugin  
- error  

例：

```
[action][info] navigate → detail
[api][error] 500 /api/user
```

---

## 17.10 BindStore の状態確認（state）

```
shellapp state
```

例：

```
user.name = "大輔"
ui.loading = false
form.email = "example@example.com"
```

---

## 17.11 Studio との連携

Studio と CLI は相互連携できます。

### Studio を CLI から起動

```
shellapp studio
```

### Studio の変更を CLI dev に反映

Studio → Cloud → dev が自動同期。

---

## 17.12 CI/CD での利用

CLI は CI/CD での自動デプロイに最適です。

例：GitHub Actions

```
shellapp validate
shellapp build
shellapp deploy
```

---

## 17.13 完全サンプル：開発フロー

```
shellapp init my-app
cd my-app
shellapp dev
（開発）
shellapp validate
shellapp build
shellapp deploy
```

---

## 17.14 次のステップ
次の章では、Marketplace（マーケットプレイス）について説明します。

# 18. Marketplace（マーケットプレイス）

Marketplace は、ShellApp の拡張機能を配布・共有・管理するための  
**公式エコシステムプラットフォーム** です。

開発者・デザイナー・企業は Marketplace を通じて以下を利用できます。

- プラグイン（Plugin）
- メタコンポーネント（Meta Components）
- テーマ（Theme）
- テンプレート（Template）
- サンプルアプリ（Example Apps）
- ユーティリティ（Utilities）
- レイアウトパック（Layout Packs）

Marketplace は ShellApp Studio / CLI と連携し、  
**1クリックでインストール → 即時反映** を実現します。

---

## 18.1 Marketplace の目的

Marketplace は以下の目的で設計されています。

- ShellApp のエコシステムを拡張する
- 再利用可能な UI / ロジックを共有する
- プラグインの安全な配布と署名管理
- 企業向けのカスタムパッケージ配布
- Studio / CLI との統合による高速開発

---

## 18.2 Marketplace のカテゴリ

Marketplace は以下のカテゴリで構成されます。

### ✔ 1. Plugins（プラグイン）
- UI プラグイン  
- Action プラグイン  
- Service プラグイン（Stripe / Firebase など）

### ✔ 2. Meta Components（メタコンポーネント）
- カード UI  
- リストアイテム  
- フォームテンプレート  
- 汎用レイアウト  

### ✔ 3. Themes（テーマ）
- ライト / ダークテーマ  
- ブランドテーマ  
- シーズンテーマ（春・夏・秋・冬）  

### ✔ 4. Templates（テンプレート）
- ログイン画面  
- CRUD アプリ  
- 店舗予約アプリ  
- POS UI  
- ダッシュボード  

### ✔ 5. Example Apps（サンプルアプリ）
- 完成済みアプリの UIDSL  
- 学習用プロジェクト  

### ✔ 6. Utilities（ユーティリティ）
- バリデーションセット  
- フォーマッタセット  
- カスタム関数  

---

## 18.3 インストール方法

Marketplace のアイテムは以下の方法でインストールできます。

### ✔ ShellApp Studio からインストール

Studio の「Marketplace」タブから：

- 検索  
- プレビュー  
- インストール  
- バージョン切り替え  

### ✔ ShellApp CLI からインストール

```
shellapp plugin add qr_viewer
shellapp meta add user_card
shellapp theme add dark_theme
```

### ✔ UIDSL から直接指定（自動取得）

```json
{
  "app": {
    "plugins": ["qr_viewer"]
  }
}
```

→ Runtime が Marketplace から自動取得

---

## 18.4 バージョン管理

Marketplace のアイテムはすべて **セマンティックバージョニング** を採用。

例：

```
1.0.0
1.1.0
2.0.0
```

Studio / CLI でバージョンを指定可能。

```
shellapp plugin add qr_viewer@1.2.0
```

---

## 18.5 セキュリティと署名

Marketplace のアイテムはすべて署名され、  
ShellApp Runtime は以下を検証します。

- 署名の正当性  
- 改ざんチェック  
- プラグインの権限  
- 外部通信の制限  

企業向けには **プライベート Marketplace** も提供可能。

---

## 18.6 プラグインの公開フロー

1. plugin.json を作成  
2. プラグインをビルド  
3. Marketplace にアップロード  
4. 自動テスト  
5. 署名  
6. 公開  

Studio から GUI で公開することも可能。

---

## 18.7 Meta Components の公開

Meta Components は Marketplace で共有できます。

例：user_card

```json
{
  "meta": {
    "id": "user_card",
    "params": ["user"],
    "template": {
      "type": "container",
      "layout": "row",
      "children": [
        { "type": "image", "bind": { "value": "user.avatar" } },
        { "type": "text", "bind": { "value": "user.name" } }
      ]
    }
  }
}
```

→ Marketplace に公開  
→ 他のプロジェクトで再利用可能

---

## 18.8 テーマの公開

ブランドテーマや季節テーマを配布できます。

例：spring_theme

```json
{
  "theme": {
    "background": "#FFF5F7",
    "color": "#D6336C",
    "accent": "#FFB3C1"
  }
}
```

---

## 18.9 テンプレートの公開

アプリの骨組みをテンプレートとして公開できます。

例：ログインテンプレート  
例：予約アプリテンプレート  
例：ダッシュボードテンプレート  

Studio で「テンプレートから作成」が可能。

---

## 18.10 Marketplace の完全サンプル

### app.json

```json
{
  "app": {
    "plugins": ["qr_viewer"],
    "themes": ["dark_theme"],
    "meta": ["user_card"]
  }
}
```

### screen.json

```json
{
  "screen": {
    "id": "qr",
    "title": "QRコード",
    "layout": "column",
    "children": [
      {
        "type": "plugin",
        "name": "qr_viewer",
        "props": {
          "value": "https://example.com"
        }
      },
      {
        "type": "meta",
        "ref": "user_card",
        "bind": { "user": "current_user" }
      }
    ]
  }
}
```

---

## 18.11 次のステップ
次の章では、Component Reference（コンポーネントリファレンス）について説明します。

# 19. Component Reference（コンポーネントリファレンス）

この章では、ShellApp のすべての UI コンポーネントの  
**プロパティ・bind・action・theme・使用例** を体系的にまとめます。

ShellApp のコンポーネントはすべて UIDSL で宣言的に定義され、  
Theme Engine / BindStore / Action Engine と連携して動作します。

---

# 19.1 コンポーネント一覧

| コンポーネント | 説明 |
|----------------|------|
| text | テキスト表示 |
| button | ボタン |
| input | 入力フィールド |
| image | 画像表示 |
| container | コンテナ（レイアウト用） |
| list | リスト表示 |
| grid | グリッド表示 |
| spacer | 余白 |
| divider | 区切り線 |
| card | カードUI |
| meta | メタコンポーネント |
| plugin | プラグインコンポーネント |
| form | フォームコンテナ |
| icon | アイコン表示 |
| switch | ON/OFF スイッチ |
| checkbox | チェックボックス |
| select | セレクトボックス |

---

# 19.2 text（テキスト）

### 基本構造

```json
{
  "type": "text",
  "value": "Hello"
}
```

### プロパティ

| プロパティ | 説明 |
|------------|------|
| value | 表示する文字列 |
| theme | 色・フォントサイズなど |

### bind

```json
{
  "type": "text",
  "bind": { "value": "user.name" }
}
```

---

# 19.3 button（ボタン）

### 基本構造

```json
{
  "type": "button",
  "label": "送信"
}
```

### プロパティ

| プロパティ | 説明 |
|------------|------|
| label | ボタンの文字 |
| action | ボタン押下時の動作 |

### action 例

```json
{
  "type": "button",
  "label": "次へ",
  "action": { "type": "navigate", "to": "next" }
}
```

---

# 19.4 input（入力フィールド）

### 基本構造

```json
{
  "type": "input",
  "label": "名前",
  "bind": { "value": "form.name" }
}
```

### プロパティ

| プロパティ | 説明 |
|------------|------|
| label | ラベル |
| placeholder | プレースホルダ |
| bind.value | 入力値の保存先 |
| validate | バリデーション |

---

# 19.5 image（画像）

```json
{
  "type": "image",
  "bind": { "value": "user.avatar" }
}
```

### プロパティ

| プロパティ | 説明 |
|------------|------|
| value | URL または base64 |
| width / height | サイズ |
| radius | 角丸 |

---

# 19.6 container（コンテナ）

レイアウトの基本要素。

```json
{
  "type": "container",
  "layout": "row",
  "children": [...]
}
```

### プロパティ

| プロパティ | 説明 |
|------------|------|
| layout | row / column / stack |
| children | 子要素 |
| theme | padding / margin など |

---

# 19.7 list（リスト）

```json
{
  "type": "list",
  "bind": { "list": "items" }
}
```

### プロパティ

| プロパティ | 説明 |
|------------|------|
| bind.list | リストデータ |
| item | アイテムテンプレート（省略時は children を繰り返す） |

---

# 19.8 grid（グリッド）

```json
{
  "type": "grid",
  "columns": 2,
  "bind": { "list": "products" }
}
```

### プロパティ

| プロパティ | 説明 |
|------------|------|
| columns | 列数 |
| bind.list | データ |
| item | アイテムテンプレート |

---

# 19.9 spacer（余白）

```json
{
  "type": "spacer",
  "size": 16
}
```

---

# 19.10 divider（区切り線）

```json
{
  "type": "divider"
}
```

---

# 19.11 card（カードUI）

```json
{
  "type": "card",
  "children": [...]
}
```

### プロパティ

| プロパティ | 説明 |
|------------|------|
| elevation | 影 |
| radius | 角丸 |
| theme | 背景色など |

---

# 19.12 meta（メタコンポーネント）

```json
{
  "type": "meta",
  "ref": "user_card",
  "bind": { "user": "current_user" }
}
```

---

# 19.13 plugin（プラグインコンポーネント）

```json
{
  "type": "plugin",
  "name": "qr_viewer",
  "props": { "value": "https://example.com" }
}
```

---

# 19.14 form（フォームコンテナ）

```json
{
  "type": "form",
  "children": [...]
}
```

---

# 19.15 icon（アイコン）

```json
{
  "type": "icon",
  "name": "home",
  "size": 24
}
```

---

# 19.16 switch（スイッチ）

```json
{
  "type": "switch",
  "bind": { "value": "form.enabled" }
}
```

---

# 19.17 checkbox（チェックボックス）

```json
{
  "type": "checkbox",
  "label": "同意する",
  "bind": { "value": "form.agree" }
}
```

---

# 19.18 select（セレクトボックス）

```json
{
  "type": "select",
  "bind": { "value": "form.country" },
  "options": [
    { "label": "日本", "value": "jp" },
    { "label": "アメリカ", "value": "us" }
  ]
}
```

---

# 19.19 コンポーネント共通プロパティ

すべてのコンポーネントは以下を共通で持つ。

| プロパティ | 説明 |
|------------|------|
| theme | 色・余白・フォントなど |
| bind | データバインド |
| action | イベントアクション（button など） |
| visible | 表示/非表示 |
| key | Diff Render 用の一意キー |

---

# 19.20 完全サンプル：複合 UI

```json
{
  "screen": {
    "id": "profile",
    "title": "プロフィール",
    "layout": "column",
    "children": [
      {
        "type": "image",
        "bind": { "value": "user.avatar" },
        "theme": { "radius": 50, "width": 100, "height": 100 }
      },
      {
        "type": "text",
        "bind": { "value": "user.name" },
        "theme": { "font_size": 20 }
      },
      {
        "type": "button",
        "label": "編集",
        "action": { "type": "navigate", "to": "edit_profile" }
      }
    ]
  }
}
```

---

# 19.21 次のステップ
次の章では、Layout System（レイアウトシステム）について説明します。

# 20. Layout System（レイアウトシステム）

Layout System は、ShellApp の UI の構造・配置・並びを定義する仕組みです。  
ShellApp のレイアウトは **宣言的（Declarative）** に記述され、  
Flutter のレイアウトモデルを抽象化した形で動作します。

ShellApp のレイアウトは以下の要素で構成されます。

1. **レイアウトタイプ（layout）**
2. **コンテナ（container）**
3. **リスト / グリッド**
4. **アラインメント（align）**
5. **スペーシング（spacing / padding / margin）**
6. **レスポンシブ（responsive）**
7. **Meta Layout（メタレイアウト）**

---

# 20.1 レイアウトタイプ一覧

| layout | 説明 |
|--------|------|
| column | 縦方向に並べる |
| row | 横方向に並べる |
| stack | 重ねる |
| list | 縦スクロールリスト |
| grid | グリッド表示 |
| form | フォーム用レイアウト |

---

# 20.2 column（縦並び）

```json
{
  "type": "container",
  "layout": "column",
  "children": [
    { "type": "text", "value": "上" },
    { "type": "text", "value": "下" }
  ]
}
```

---

# 20.3 row（横並び）

```json
{
  "type": "container",
  "layout": "row",
  "children": [
    { "type": "text", "value": "左" },
    { "type": "text", "value": "右" }
  ]
}
```

---

# 20.4 stack（重ねる）

```json
{
  "type": "container",
  "layout": "stack",
  "children": [
    { "type": "image", "value": "bg.png" },
    { "type": "text", "value": "前面テキスト" }
  ]
}
```

---

# 20.5 list（リスト）

```json
{
  "type": "list",
  "bind": { "list": "items" }
}
```

BindStore の items を縦スクロールで表示。

---

# 20.6 grid（グリッド）

```json
{
  "type": "grid",
  "columns": 2,
  "bind": { "list": "products" }
}
```

---

# 20.7 アラインメント（align）

コンポーネントの配置を指定。

| 値 | 説明 |
|-----|------|
| left | 左寄せ |
| center | 中央 |
| right | 右寄せ |
| space_between | 均等配置 |
| space_around | 均等余白 |

例：

```json
{
  "type": "container",
  "layout": "row",
  "align": "space_between",
  "children": [...]
}
```

---

# 20.8 スペーシング（spacing / padding / margin）

### padding（内側余白）

```json
{
  "theme": { "padding": 16 }
}
```

### margin（外側余白）

```json
{
  "theme": { "margin": 8 }
}
```

### spacing（子要素間の余白）

```json
{
  "type": "container",
  "layout": "column",
  "spacing": 12,
  "children": [...]
}
```

---

# 20.9 サイズ（width / height）

```json
{
  "theme": {
    "width": 200,
    "height": 50
  }
}
```

---

# 20.10 レスポンシブ（responsive）

ShellApp は画面幅に応じてレイアウトを切り替えられる。

```json
{
  "responsive": {
    "mobile": { "layout": "column" },
    "tablet": { "layout": "row" },
    "desktop": { "layout": "row" }
  }
}
```

---

# 20.11 Auto Layout（自動レイアウト）

子要素のサイズに応じて自動調整される。

例：row の子要素が自動で横幅にフィット。

```json
{
  "type": "container",
  "layout": "row",
  "children": [
    { "type": "text", "value": "A" },
    { "type": "text", "value": "B" }
  ]
}
```

---

# 20.12 Meta Layout（メタレイアウト）

Meta Components と同様に、レイアウトもテンプレート化できる。

### 定義

```json
{
  "meta": {
    "id": "section_layout",
    "params": ["title", "content"],
    "template": {
      "type": "container",
      "layout": "column",
      "children": [
        { "type": "text", "bind": { "value": "title" } },
        { "type": "container", "bind": { "value": "content" } }
      ]
    }
  }
}
```

### 利用

```json
{
  "type": "meta",
  "ref": "section_layout",
  "bind": {
    "title": "ユーザー情報",
    "content": "user_card"
  }
}
```

---

# 20.13 Layout System のベストプラクティス

### ✔ レイアウトは浅く保つ  
ネストが深いと可読性が落ちる。

### ✔ spacing を積極的に使う  
spacer の乱用を避ける。

### ✔ responsive を使ってデバイス対応  
mobile / tablet / desktop の切り替え。

### ✔ Meta Layout で再利用性を高める  
セクション・カード・フォームなど。

---

# 20.14 完全サンプル：複合レイアウト

```json
{
  "screen": {
    "id": "dashboard",
    "title": "ダッシュボード",
    "layout": "column",
    "spacing": 16,
    "children": [
      {
        "type": "container",
        "layout": "row",
        "spacing": 12,
        "children": [
          { "type": "card", "children": [{ "type": "text", "value": "売上" }] },
          { "type": "card", "children": [{ "type": "text", "value": "顧客数" }] }
        ]
      },
      {
        "type": "list",
        "bind": { "list": "recent_orders" }
      }
    ]
  }
}
```

---

# 20.15 次のステップ
これで ShellApp のコアドキュメント（1〜20章）がすべて揃いました。

# 21. Glossary（用語集）

この章では、ShellApp を理解する上で重要となる用語を  
**簡潔かつ正確に** まとめています。

ShellApp は「UI = データ」という思想で構築されているため、  
一般的なアプリ開発とは異なる概念が多く存在します。

---

# A

### **Action（アクション）**
ユーザー操作やイベントに応じて実行される処理。  
navigate / submit / dialog / update_state / if / sequence など。

### **Action Engine（アクションエンジン）**
UIDSL 内の action を解釈し、実行するランタイムの仕組み。

---

# B

### **Bind（バインド）**
UI と BindStore の値を紐づける仕組み。  
例：`"bind": { "value": "user.name" }`

### **BindStore（バインドストア）**
ShellApp の状態管理システム。  
UI の状態・フォーム値・API レスポンスなどを保持する。

---

# C

### **CLI（Command Line Interface）**
ShellApp の開発ツール。  
init / dev / validate / build / deploy などを提供。

### **Cloud（クラウド）**
UIDSL をホスティングし、アプリにリアルタイム配信する仕組み。

### **Component（コンポーネント）**
UI を構成する最小単位。  
text / button / input / list / plugin など。

### **Container（コンテナ）**
レイアウト用の UI コンポーネント。  
row / column / stack などを構成する。

---

# D

### **Diff Render（差分描画）**
UIDSL の変更を検知し、変更部分だけを再描画する仕組み。

### **DSL（Domain Specific Language）**
ShellApp の UI を定義する JSON ベースの宣言的言語。

---

# E

### **Error Handling（エラー処理）**
ShellApp の Fault Tolerance に基づく安全なエラー処理。

---

# F

### **Fault Tolerance（エラー耐性）**
ShellApp がクラッシュせず動作し続けるための設計思想。

### **Form（フォーム）**
入力値を BindStore に保存する UI コンポーネント群。

---

# G

### **Grid（グリッド）**
複数列のレイアウトを構成する UI コンポーネント。

---

# H

### **Hash（ハッシュ）**
Diff Render が UIDSL の差分を検知するために内部で生成する識別値。

---

# I

### **Input（入力フィールド）**
ユーザーが値を入力する UI コンポーネント。

---

# L

### **Layout（レイアウト）**
UI の配置方法。  
column / row / stack / list / grid など。

### **Logging（ログ）**
ShellApp Runtime の動作を記録する仕組み。

---

# M

### **Marketplace（マーケットプレイス）**
プラグイン・メタコンポーネント・テーマなどを配布する公式ストア。

### **Meta Components（メタコンポーネント）**
再利用可能な UI テンプレート。  
params を持ち、柔軟にカスタマイズ可能。

---

# N

### **Navigate（画面遷移）**
画面を切り替えるアクション。

---

# P

### **Plugin（プラグイン）**
ShellApp の機能を拡張するモジュール。  
UI / Action / Service の 3 種類がある。

### **Props（プロパティ）**
プラグインに渡すパラメータ。

---

# R

### **Router（ルーター）**
画面遷移を管理する仕組み。

### **Runtime（ランタイム）**
UIDSL を解釈し、UI を描画する ShellApp の実行エンジン。

---

# S

### **Screen（画面）**
アプリの 1 画面を構成する UIDSL の単位。

### **ShellApp Studio（GUI エディタ）**
ShellApp の GUI 開発環境。  
ドラッグ＆ドロップで UIDSL を生成できる。

### **State（状態）**
BindStore に保存されるアプリのデータ。

---

# T

### **Template（テンプレート）**
画面や UI のひな形。  
Marketplace で配布される。

### **Theme（テーマ）**
色・余白・フォントなどのスタイル設定。

### **Theme Engine（テーマエンジン）**
テーマを適用・上書きする仕組み。

---

# U

### **UIDSL（UI DSL）**
ShellApp の UI を定義する JSON ベースの DSL。

### **Utilities（ユーティリティ）**
フォーマッタ・バリデータ・変換関数などの補助機能。

---

# V

### **Validator（バリデータ）**
入力値の検証を行うユーティリティ。

---

# W

### **Widget（ウィジェット）**
Flutter の UI 要素。  
ShellApp では直接扱わず、Runtime が自動生成する。

---

# Z

### **Zero-Config（ゼロコンフィグ）**
ShellApp の設計思想のひとつ。  
設定なしで動作することを重視。

---

# 21.1 Glossary の目的

- ShellApp の概念を統一する  
- 開発者間の認識を揃える  
- ドキュメント全体の理解を補助する  
- Studio / CLI / Marketplace の用語を整理する  

---

# 21.2 次のステップ
Glossary により ShellApp の全体像が整理されました。  
次は必要に応じて **Architecture（アーキテクチャ）** や  
**Runtime Internals（内部実装）** を追加できます。

# 22. Architecture（アーキテクチャ）

ShellApp は「UI = データ」という思想に基づき、  
アプリケーションを **UIDSL（JSON）で完全に定義し、  
Runtime がそれを解釈して UI を生成する** アーキテクチャを採用しています。

ShellApp のアーキテクチャは以下の 5 層で構成されます。

1. **UIDSL Layer（宣言的 UI 層）**  
2. **Runtime Layer（実行エンジン）**  
3. **State Layer（BindStore）**  
4. **Rendering Layer（描画エンジン）**  
5. **Platform Layer（Flutter / OS）**

---

# 22.1 全体構造（Overview）

```
+-----------------------------+
|        UIDSL Layer         |
|     (JSON-based UI DSL)    |
+-----------------------------+
              ↓
+-----------------------------+
|       Runtime Layer         |
|  - DSL Parser               |
|  - Action Engine            |
|  - Plugin Engine            |
|  - Theme Engine             |
+-----------------------------+
              ↓
+-----------------------------+
|        State Layer          |
|         BindStore           |
+-----------------------------+
              ↓
+-----------------------------+
|     Rendering Layer         |
|       Diff Renderer         |
|   (Generates Flutter UI)    |
+-----------------------------+
              ↓
+-----------------------------+
|      Platform Layer         |
|   Flutter / iOS / Android   |
+-----------------------------+
```

---

# 22.2 UIDSL Layer（宣言的 UI 層）

ShellApp の UI はすべて JSON で定義される。

例：

```json
{
  "screen": {
    "id": "home",
    "title": "ホーム",
    "layout": "column",
    "children": [
      { "type": "text", "value": "Hello" }
    ]
  }
}
```

UIDSL は以下を含む：

- screen  
- component  
- bind  
- action  
- theme  
- plugin  
- meta  

**アプリの UI とロジックのすべてが UIDSL に集約される。**

---

# 22.3 Runtime Layer（実行エンジン）

Runtime は UIDSL を解釈し、UI を構築する ShellApp の中核。

構成：

### ✔ DSL Parser  
UIDSL を解析し、内部モデルに変換。

### ✔ Action Engine  
navigate / submit / dialog / update_state / if / sequence を実行。

### ✔ Plugin Engine  
プラグインのロード・実行・props の受け渡し。

### ✔ Theme Engine  
テーマの適用・上書き・継承。

### ✔ Error Handler  
Fault Tolerance に基づく安全なエラー処理。

---

# 22.4 State Layer（BindStore）

BindStore は ShellApp の **唯一の状態管理システム**。

保持するデータ：

- form.*  
- user.*  
- api レスポンス  
- ui.*  
- params  
- error.*  

BindStore が更新されると、  
Diff Render が UI の必要部分だけを再描画する。

---

# 22.5 Rendering Layer（描画エンジン）

Rendering Layer は UIDSL を Flutter の Widget に変換する。

構成：

### ✔ Component Renderer  
text / button / input / list / plugin などを Flutter UI に変換。

### ✔ Diff Renderer  
UIDSL の差分を検知し、変更部分だけ再描画。

### ✔ Layout Engine  
column / row / stack / grid を Flutter のレイアウトに変換。

### ✔ Theme Applier  
テーマを Flutter のスタイルに適用。

---

# 22.6 Platform Layer（Flutter / OS）

最終的に ShellApp は Flutter 上で動作する。

- iOS  
- Android  
- Web  
- Desktop（将来的に）  

ShellApp は Flutter の Widget Tree を直接操作せず、  
**Runtime → Renderer → Flutter** の順で UI を生成する。

---

# 22.7 データフロー（Data Flow）

```
ユーザー操作
      ↓
Action Engine
      ↓
BindStore 更新
      ↓
Diff Renderer
      ↓
UI 再描画（必要部分のみ）
```

例：ボタン押下 → API → user.name 更新 → text 再描画

---

# 22.8 画面遷移フロー（Routing Flow）

```
navigate(to: "detail")
      ↓
Router が screen.id を解決
      ↓
UIDSL をロード
      ↓
Runtime が解析
      ↓
Diff Render で画面切り替え
```

---

# 22.9 Plugin Architecture（プラグイン構造）

```
+------------------------+
|     Plugin Engine      |
+------------------------+
        ↓ props
+------------------------+
|     Plugin Module      |
|  (UI / Action / API)   |
+------------------------+
        ↓ result
+------------------------+
|       BindStore        |
+------------------------+
```

プラグインは Sandbox 内で動作し、  
BindStore に結果を返す。

---

# 22.10 Cloud Architecture（クラウド構造）

```
Studio → Cloud → App（Runtime）
```

- Studio で UIDSL を編集  
- Cloud にアップロード  
- アプリが自動で取得  
- Diff Render で差分だけ反映  

**ビルド不要の UI 更新** を実現。

---

# 22.11 ShellApp のアーキテクチャ思想

### ✔ UI = データ  
UI をコードではなく JSON で定義。

### ✔ Runtime-Driven UI  
アプリは「実行時に UI を生成」する。

### ✔ Zero-Config  
設定なしで動作する。

### ✔ Declarative  
UI は宣言的に記述。

### ✔ Diff-Based Rendering  
差分だけ描画して高速化。

### ✔ Plugin-First  
機能拡張はすべてプラグインで行う。

---

# 22.12 完全サンプル：アーキテクチャ全体図

```
UIDSL (JSON)
      ↓
DSL Parser
      ↓
Runtime
  ├ Action Engine
  ├ Plugin Engine
  ├ Theme Engine
  └ Error Handler
      ↓
BindStore（状態）
      ↓
Diff Renderer
      ↓
Flutter Widgets
      ↓
iOS / Android / Web
```

---

# 22.13 次のステップ
アーキテクチャの理解により、ShellApp の内部構造が明確になりました。  
必要に応じて次の章を追加できます。

- **23. Runtime Internals（内部実装）**  
- **24. Security Model（セキュリティモデル）**  
- **25. ShellApp Cloud（クラウド配信）**

# 24. Security Model（セキュリティモデル）

ShellApp は「UI = データ」という構造を採用しているため、  
従来のアプリとは異なるセキュリティ要件を持ちます。

本章では、ShellApp Runtime・Plugin・Cloud・UIDSL の  
**安全性を保証するためのセキュリティモデル** を解説します。

---

# 24.1 セキュリティモデルの基本思想

ShellApp のセキュリティは以下の 5 原則に基づいて設計されています。

1. **Sandbox Execution（サンドボックス実行）**  
2. **Signed Distribution（署名付き配布）**  
3. **Zero Trust Runtime（ゼロトラスト実行）**  
4. **Immutable UI（不変 UI）**  
5. **Fail-Safe Architecture（安全側に倒れる設計）**

---

# 24.2 UIDSL の安全性

UIDSL（JSON）はアプリの UI とロジックを定義するが、  
**任意コード実行は一切できない**。

### UIDSL の制限

- JavaScript / Dart / Python などのコードは書けない  
- 外部 URL を実行できない  
- OS API を直接呼べない  
- 動的コード生成は禁止  

### UIDSL の安全性の理由

- すべての動作は Runtime が制御  
- 許可された action のみ実行可能  
- bind は BindStore の値しか参照できない  
- plugin は署名されたもののみ使用可能  

---

# 24.3 Runtime のセキュリティ

ShellApp Runtime は **ゼロトラストモデル** を採用。

### Runtime の防御機構

- UIDSL の構文検証  
- 不正な type / action の拒否  
- plugin の署名検証  
- BindStore の型安全性  
- Action Engine の安全実行  
- Diff Render の安全描画  

### Runtime の sandbox

Runtime は Flutter の Widget Tree を直接操作せず、  
**安全な中間レイヤー（Renderer）を介して UI を生成**する。

---

# 24.4 Plugin のセキュリティ

プラグインは ShellApp の拡張機能だが、  
**最も厳しいセキュリティ制約**が課される。

---

## 24.4.1 Plugin の署名（Signature）

Marketplace / Cloud / ローカルのいずれでも、  
プラグインは必ず **署名付きで配布**される。

Runtime は以下を検証する：

- 署名の正当性  
- 改ざんチェック  
- バージョン整合性  
- 権限（permissions）  

---

## 24.4.2 Plugin Sandbox（隔離環境）

プラグインは以下の制限下で実行される：

- メモリ隔離  
- 外部ネットワーク制限（許可された API のみ）  
- OS API への直接アクセス禁止  
- ファイルシステムアクセス禁止  
- UI への直接描画禁止（Renderer 経由のみ）  

---

## 24.4.3 Plugin Permissions（権限モデル）

プラグインは明示的に権限を宣言する必要がある。

例：

```json
{
  "plugin": {
    "name": "qr_viewer",
    "permissions": ["camera"]
  }
}
```

Runtime は権限がない操作を拒否する。

---

# 24.5 BindStore のセキュリティ

BindStore は ShellApp の状態管理の中心であり、  
**安全性と整合性が最重要**。

### BindStore の防御機構

- 型安全（type-safe）  
- 不正キーの拒否  
- plugin からの直接書き換え禁止  
- Action Engine 経由でのみ更新可能  
- エラー状態は error.* に隔離  

### BindStore の更新フロー

```
Action / Plugin
      ↓
Validation
      ↓
BindStore.update()
      ↓
Diff Render
```

---

# 24.6 Cloud のセキュリティ

ShellApp Cloud は UIDSL を配信するが、  
**配信されるデータはすべて署名付き**。

### Cloud の防御機構

- UIDSL の署名検証  
- 改ざん検知  
- HTTPS 通信  
- バージョン固定（pinning）  
- ロールバック機能  

### Cloud → App の流れ

```
Cloud
  ↓（署名付き UIDSL）
Runtime
  ↓（検証）
Diff Render
```

---

# 24.7 Action Engine のセキュリティ

Action Engine はユーザー操作を処理するが、  
**危険な操作は一切許可されない**。

### 許可される操作

- navigate  
- submit（許可された API のみ）  
- update_state  
- dialog  
- if  
- sequence  

### 禁止される操作

- 任意コード実行  
- OS API 呼び出し  
- ファイル操作  
- 外部 URL の実行  

---

# 24.8 API 通信のセキュリティ

submit アクションは API を呼び出すが、  
以下の制約がある。

### API 制限

- HTTPS のみ  
- 許可されたドメインのみ  
- CORS 制御  
- save_to の型チェック  
- エラーは error.submit に隔離  

---

# 24.9 エラー耐性（Fault Tolerance）

ShellApp は **クラッシュしないアプリ** を前提に設計。

### エラー処理の原則

- 例外はすべてキャッチ  
- UI は常に描画され続ける  
- エラーは BindStore.error に保存  
- ユーザーに安全に通知  
- Runtime は停止しない  

---

# 24.10 セキュリティモデルのまとめ

| 領域 | セキュリティ機構 |
|------|------------------|
| UIDSL | コード実行不可・構文検証 |
| Runtime | ゼロトラスト・安全実行 |
| Plugin | 署名・Sandbox・権限 |
| BindStore | 型安全・検証付き更新 |
| Cloud | 署名・改ざん検知 |
| Action | 許可制・安全な実行 |
| API | HTTPS・ドメイン制限 |

---

# 24.11 次のステップ
次は **25. ShellApp Cloud（クラウド配信）** を追加できます。

# 25. ShellApp Cloud（クラウド配信）

ShellApp Cloud は、UIDSL（JSON）をクラウド上で管理し、  
アプリに **リアルタイムで UI を配信するための公式プラットフォーム** です。

Cloud を利用することで、アプリの UI・テーマ・メタコンポーネント・プラグイン設定を  
**ビルド不要で即時更新**できます。

---

# 25.1 ShellApp Cloud の目的

ShellApp Cloud は以下の目的で設計されています。

- アプリの UI をクラウドから配信  
- ビルドなしで UI を更新  
- バージョン管理とロールバック  
- Studio / CLI との統合  
- Marketplace との連携  
- 安全な署名付き配信  

---

# 25.2 Cloud 配信の仕組み

ShellApp Cloud は以下の流れで UI を配信します。

```
Studio / CLI
      ↓
Cloud（UIDSL 保存）
      ↓
App（Runtime が取得）
      ↓
Diff Render（差分だけ更新）
```

### 特徴

- アプリの再インストール不要  
- ストア審査不要  
- UI の変更が即時反映  
- 差分のみ更新で高速  

---

# 25.3 Cloud に保存されるデータ

Cloud には以下のデータが保存されます。

| 種類 | 説明 |
|------|------|
| UIDSL（画面定義） | screen.json / meta.json |
| Theme | light.json / dark.json |
| Plugin 設定 | plugin.json |
| Layout | レイアウト定義 |
| Marketplace アイテム | プラグイン・テーマ・メタ |
| バージョン情報 | version.json |

---

# 25.4 Cloud 配信のフロー

### 1. Studio / CLI で UIDSL を編集

```
shellapp deploy
```

または Studio の「Publish」ボタン。

### 2. Cloud にアップロード

- 署名  
- バージョン付与  
- 整合性チェック  

### 3. アプリが Cloud をポーリング or プッシュ受信

- 起動時  
- バックグラウンド復帰時  
- 手動更新時  

### 4. Runtime が UIDSL を検証

- 署名チェック  
- 構文チェック  
- プラグイン依存関係チェック  

### 5. Diff Render が差分だけ更新

- UI の変更部分のみ再描画  
- 状態（BindStore）は保持  

---

# 25.5 バージョン管理

Cloud は UIDSL を **セマンティックバージョニング** で管理。

例：

```
1.0.0
1.1.0
1.2.0
2.0.0
```

### バージョン固定（Pinning）

アプリ側でバージョンを固定することも可能。

```json
{
  "app": {
    "version": "1.2.0"
  }
}
```

---

# 25.6 ロールバック（Rollback）

Cloud は任意のバージョンにロールバック可能。

例：

```
shellapp deploy --rollback 1.1.0
```

アプリは次回起動時にそのバージョンを取得。

---

# 25.7 差分配信（Delta Delivery）

Cloud は UIDSL の差分のみを配信する。

### メリット

- 軽量  
- 高速  
- 通信量削減  
- UI の瞬時更新  

---

# 25.8 セキュリティ（Security）

Cloud 配信は以下の安全機構を持つ。

- 署名付き UIDSL  
- 改ざん検知  
- HTTPS 通信  
- プラグイン署名検証  
- バージョン整合性チェック  
- Zero Trust Runtime  

---

# 25.9 Cloud と Marketplace の統合

Cloud は Marketplace と連携し、  
以下を自動取得できる。

- プラグイン  
- メタコンポーネント  
- テーマ  
- テンプレート  

例：

```json
{
  "app": {
    "plugins": ["qr_viewer"],
    "meta": ["user_card"],
    "themes": ["dark_theme"]
  }
}
```

→ Cloud が自動で依存関係を解決して配信。

---

# 25.10 Cloud と Studio の統合

Studio は Cloud と完全統合されている。

### Studio の機能

- Publish（クラウドへ公開）  
- Preview（クラウド版のプレビュー）  
- Versioning（バージョン管理）  
- Rollback（ロールバック）  
- Marketplace インストール  

---

# 25.11 Cloud と CLI の統合

CLI からも Cloud を操作できる。

### デプロイ

```
shellapp deploy
```

### バージョン一覧

```
shellapp cloud versions
```

### ロールバック

```
shellapp cloud rollback 1.1.0
```

---

# 25.12 完全サンプル：Cloud 配信を利用したアプリ

### app.json

```json
{
  "app": {
    "version": "1.2.0",
    "plugins": ["qr_viewer"],
    "themes": ["dark_theme"]
  }
}
```

### screen.json（Cloud 配信）

```json
{
  "screen": {
    "id": "home",
    "title": "ホーム",
    "layout": "column",
    "children": [
      { "type": "text", "value": "Hello from Cloud!" },
      {
        "type": "plugin",
        "name": "qr_viewer",
        "props": { "value": "https://example.com" }
      }
    ]
  }
}
```

Cloud で更新すると、アプリは即時反映される。

---

# 25.13 ShellApp Cloud のメリットまとめ

| 機能 | メリット |
|------|----------|
| UI のクラウド配信 | ビルド不要・即時反映 |
| バージョン管理 | 安定運用 |
| ロールバック | 障害時の迅速復旧 |
| Marketplace 連携 | 拡張性 |
| Studio 連携 | ノーコード更新 |
| Diff Render | 高速更新 |
| 署名検証 | 安全性 |

---

# 25.14 次のステップ
ShellApp Cloud により、アプリの UI をクラウドで管理できるようになりました。  
次は必要に応じて以下の章を追加できます。

- **26. Deployment Guide（デプロイガイド）**  
- **27. Performance Tuning（パフォーマンス最適化）**  
- **28. Plugin Development Guide（プラグイン開発ガイド）**
