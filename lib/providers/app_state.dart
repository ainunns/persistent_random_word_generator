import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:persistent_random_word_generator/models/words.dart';
import 'package:persistent_random_word_generator/repository/objectbox.dart';

class MyAppState extends ChangeNotifier {
  late final ObjectBox _objectBox;
  Word? _current;
  GlobalKey? historyListKey;

  MyAppState(this._objectBox) {
    _current = _objectBox.getCurrent();
  }

  Word get current => _current ?? Word(word: WordPair.random().asString);

  Stream<List<Word>> get history => _objectBox.getHistoryStream();
  Stream<List<Word>> get favorites => _objectBox.getFavoritesStream();

  Future<void> getNext() async {
    try {
      if (_current != null) {
        // Add current word to history first and wait for completion
        _objectBox.addToHistory(_current!);
      }

      // Generate new word only after history is updated
      _current = Word(
        word: WordPair.random().asString,
        createdAt: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      print('Error in getNext: $e');
    }
  }

  void toggleFavorite([Word? word]) {
    word = word ?? current;

    _objectBox.toggleFavorite(word);
    notifyListeners();
  }

  void removeFavorite(Word word) async {
    _objectBox.removeFavorite(word);
    notifyListeners();
  }
}
