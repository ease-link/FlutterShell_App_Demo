# クイックスタートガイド

ShellApp + FlutterShell Studio のフルフローを体験するガイド。  
**非エンジニア（PM・デザイナー）** と **Flutter 開発者** のどちらも対象にしている。

---

## このガイドで体験できること

```
Studio で画面を作る
  ↓
Flutter テンプレートをダウンロード
  ↓
実機・シミュレータで確認する
```

---

## Part 1：非エンジニア向け — Studio で画面を作る

### 1-1. Studio を起動する

FlutterShell Studio（Windows デスクトップアプリ）を起動する。

### 1-2. 新規プロジェクトを作成する

1. 画面左上の **[New Project]** をクリック
2. プロジェクト名を入力して **[Create]** をクリック
3. `home` 画面が自動作成された状態でエディタが開く

### 1-3. コンポーネントを追加する

左パネルの **コンポーネントパレット** からウィジェットをドラッグ＆ドロップする。

例：ログイン画面を作る場合

1. `text_field` を2つドロップ（メールアドレス・パスワード）
2. `button` を1つドロップ（ログインボタン）
3. 右パネルの **プロパティ** でラベル・色・サイズを調整する

### 1-4. アクションを設定する

ボタンをクリックして選択し、右パネルの **Action** タブを開く。

```
onTap → apiCall
  method: POST
  url: https://api.example.com/login
  body:
    email: {{email}}
    password: {{password}}
  assignTo: loginResult
```

### 1-5. プレビューで確認する

右上の **[Preview]** ボタンをクリックしてプレビューモードに切り替える。  
実際のウィジェットが描画され、ボタンのタップ動作も確認できる。

### 1-6. UIDSL をエクスポートする

メニューの **[File] → [Export UIDSL]** でプロジェクトを保存する。  
画面ごとに JSON ファイルが生成される。

---

## Part 2：Flutter 開発者向け — テンプレートをダウンロードして実機確認

### 2-1. テンプレートをダウンロードする

Studio の **[Project] → [Download Template]** をクリックする。  
ShellApp が組み込み済みの Flutter プロジェクトが ZIP でダウンロードされる。

ZIP の構成：

```
my_app/
├── lib/
│   ├── main.dart
│   ├── shellapp/          ← ShellApp コアエンジン（編集不要）
│   └── screens/           ← Studio が生成した UIDSL JSON
│       ├── home.json
│       └── login.json
├── assets/
│   ├── app.json           ← アプリ設定
│   └── theme/
│       └── default.json   ← テーマ定義
└── pubspec.yaml
```

### 2-2. 依存パッケージをインストールする

```bash
cd my_app
flutter pub get
```

### 2-3. 実機・シミュレータで起動する

```bash
# iOS シミュレータ
flutter run -d ios

# Android エミュレータ
flutter run -d android

# Windows デスクトップ
flutter run -d windows
```

### 2-4. API と接続する

`screens/login.json` の `apiCall` の `url` を実際のエンドポイントに変更する。

```json
{
  "type": "apiCall",
  "method": "POST",
  "url": "https://your-api.example.com/login",
  "body": {
    "email": "{{email}}",
    "password": "{{password}}"
  },
  "assignTo": "loginResult"
}
```

エンジニアが担当するのはこの **Action（API I/F）** の実装だけ。  
画面の構成・デザインは Studio で PM・デザイナーが変更できる。

### 2-5. Action を追加実装する（オプション）

標準の Action（apiCall / navigate / setState など）以外のロジックが必要な場合、  
`lib/shellapp/` の `ActionDispatcher` に Action を追加実装する。

```dart
// lib/shellapp/actions/custom_actions.dart
ActionDispatcher.register('sendPushNotification', (args) async {
  final token = args['token'] as String;
  await PushService.send(token);
});
```

UIDSL 側からは通常の Action と同じように呼べる：

```json
{
  "type": "sendPushNotification",
  "token": "{{deviceToken}}"
}
```

---

## Part 3：チームでの分業フロー

```
PM・デザイナー                     エンジニア
─────────────────────────────────────────────────
Studio で画面を作る
↓
Action の I/F 名を決める    ───→   API を実装する
（例: type: "fetchOrders"）         （並列作業 OK）
↓
UIDSL で apiCall を繋ぐ    ←───   API エンドポイントが確定
↓
テンプレートをダウンロード
↓
                            ←───   エンジニアが pubspec / main.dart 調整
↓
実機で動作確認
```

UIDSL が「チーム間の契約（コントラクト）」として機能するため、  
**Action の I/F 名が決まれば画面とAPIを並列開発できる。**

---

## よくある質問

### Q: UIDSL を直接編集してもいい？
A: 問題ない。Studio はビジュアルエディタだが、JSON を直接編集して Studio に読み込ませることもできる。

### Q: ShellApp コアエンジン（`lib/shellapp/`）を編集してもいい？
A: 基本的に編集不要。API 接続・カスタムアクションは `ActionDispatcher.register()` で拡張できる。

### Q: プラグインを追加したい
A: `app.json` の `plugins` フィールドにプラグインを追加し、Runtime が起動時にロードする。  
詳細は [プラグイン仕様書](../draft/ShellAppPlugin仕様書(draft).md) を参照。

### Q: 画面を増やしたい
A: `screens/` に JSON ファイルを追加し、`app.json` の `screens` と `screenOrder` に登録する。  
詳細は [app.json スキーマ仕様書](../draft/13_app.jsonスキーマ_プラグインロード仕様書(draft).md) を参照。
