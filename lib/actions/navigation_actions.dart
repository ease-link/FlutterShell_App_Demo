class NavigationActions {
  // Add auth checks or pre-processing here if needed.
  static String? guard(String to, Map<String, dynamic> state) {
    // e.g. if (to != 'login' && state['isLoggedIn'] != true) return 'login';
    return to;
  }
}
