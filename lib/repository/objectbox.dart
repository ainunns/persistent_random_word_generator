import 'package:english_words/english_words.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/words.dart';
import 'objectbox.g.dart'; // created by `dart run build_runner build`

/// Provides access to the ObjectBox Store throughout the app.
///
/// Create this in the apps main function.
class ObjectBox {
  /// The Store of this app.
  late final Store _store;

  /// A Box of words.
  late final Box<Word> _wordBox;

  ObjectBox._create(this._store) {
    _wordBox = Box<Word>(_store);
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    // Note: setting a unique directory is recommended if running on desktop
    // platforms. If none is specified, the default directory is created in the
    // users documents directory, which will not be unique between apps.
    // On mobile this is typically fine, as each app has its own directory
    // structure.

    // Note: set macosApplicationGroup for sandboxed macOS applications, see the
    // info boxes at https://docs.objectbox.io/getting-started for details.

    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(
      directory: p.join(
        (await getApplicationDocumentsDirectory()).path,
        "obx-word-generator",
      ),
      macosApplicationGroup: "objectbox.demo",
    );

    return ObjectBox._create(store);
  }

  /// Generate a new word and add it to the database.
  Word getCurrent() {
    final allWords = _wordBox.getAll();
    if (allWords.isEmpty) {
      final newWord = Word(
        word: WordPair.random().asString,
        createdAt: DateTime.now(),
      );
      _wordBox.put(newWord);
      return newWord;
    }
    return allWords[0];
  }

  /// Add a word to the database.
  void addToHistory(Word word) {
    _wordBox.put(word);
  }

  /// Get all words from the database.
  Stream<List<Word>> getHistoryStream() {
    return _wordBox
        .query(Word_.deletedAt.equals(DateTime(0).millisecondsSinceEpoch))
        .order(Word_.createdAt, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  /// Get all favorite words from the database.
  Stream<List<Word>> getFavoritesStream() {
    return _wordBox
        .query(
          Word_.isFavorite.equals(true) &
              Word_.deletedAt.equals(DateTime(0).millisecondsSinceEpoch),
        )
        .order(Word_.createdAt, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  /// Update a word in the database.
  void toggleFavorite(Word word) {
    word.isFavorite = !word.isFavorite;
    word.updatedAt = DateTime.now();
    _wordBox.put(word);
  }

  /// Delete a favorite word from the database.
  void removeFavorite(Word word) {
    word.isFavorite = false;
    word.updatedAt = DateTime.now();
    _wordBox.put(word);
  }
}
