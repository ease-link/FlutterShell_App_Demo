// 画面遷移系。
// app_actions.dart の onNavigate コールバック経由で呼ばれる。
// 遷移ロジックをここに集約することで、画面ファイルに遷移コードが散らばらない。

class NavigationActions {
  // 遷移前に認証チェックや前処理を挟みたい場合はここに追加する
  static String? guard(String to, Map<String, dynamic> state) {
    // 例: 未ログインなら login にリダイレクト
    // if (to != 'login' && state['isLoggedIn'] != true) return 'login';
    return to;
  }
}
