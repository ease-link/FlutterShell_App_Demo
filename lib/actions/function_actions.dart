import 'dart:math';

class FunctionActions {
  static final _rng = Random();

  static const _adjectives = [
    'nonce', 'shunter', 'larder', 'wadder', 'blender',
    'funky', 'quirky', 'snappy', 'fizzy', 'bumpy',
    'cozy', 'zany', 'jolly', 'peppy', 'witty',
  ];
  static const _nouns = [
    'hibachi', 'noodle', 'castle', 'rocket', 'panda',
    'muffin', 'cactus', 'pickle', 'goblin', 'wizard',
    'taco', 'llama', 'waffle', 'penguin', 'burrito',
  ];

  static String _randomPair() {
    final adj  = _adjectives[_rng.nextInt(_adjectives.length)];
    final noun = _nouns[_rng.nextInt(_nouns.length)];
    return '$adj $noun';
  }

  static Map<String, dynamic> initialState() => {
    'currentWord':      _randomPair(),
    'favorites':        <String>[],
    'favoritesCount':   0,
    'selectedNavIndex': 0,
  };

  static Future<dynamic> call(
    String name,
    Map<String, dynamic> args, {
    Map<String, dynamic> state = const {},
  }) async {
    switch (name) {
      case 'getNext':
        return _randomPair();

      case 'toggleFavorite':
        final current = state['currentWord']?.toString() ?? '';
        if (current.isEmpty) return null;
        final favorites = List<String>.from(
            (state['favorites'] as List?)?.map((e) => e.toString()) ?? []);
        if (favorites.contains(current)) {
          favorites.remove(current);
        } else {
          favorites.add(current);
        }
        return {'favorites': favorites, 'favoritesCount': favorites.length};

      default:
        return null;
    }
  }
}
