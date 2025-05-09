# Persistent Random Word Generator App

| Name                     | NRP        | Class                              |
| ------------------------ | ---------- | ---------------------------------- |
| Ainun Nadhifah Syamsiyah | 5025221053 | Pemrograman Perangkat Bergerak (C) |

## Overview

This is a Flutter application that generates random word pairs and store the objects using offline database [ObjectBox](https://docs.objectbox.io/getting-started), allows users to favorite them and provides a simple, interactive user interface with multiple widgets and state management.

You can view the local state version [here](https://github.com/ainunns/random_word_generator).

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- An IDE (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository

```bash
git clone https://github.com/ainunns/persistent_random_word_generator.git
cd persistent_random_word_generator
```

2. Install dependencies

```bash
flutter pub get
```

3. Run the app

```bash
flutter run
```

## Development Steps

> [!NOTE]
> This project is an improved version. Before getting started, clone the [previous project](https://github.com/ainunns/random_word_generator.git) first and follow the setup instructions in the repository.

### 1. ObjectBox Installation

Run these commands to add ObjectBox on this Flutter project.

```bash
flutter pub add objectbox objectbox_flutter_libs:any
flutter pub add --dev build_runner objectbox_generator:any
```

### 2. Define Entity Class

The `Word` class contains the following properties:

| Property     | Type       | Description                                       |
| ------------ | ---------- | ------------------------------------------------- |
| `id`         | `int`      | Unique identifier for the Word entity             |
| `word`       | `String`   | The actual word text                              |
| `isFavorite` | `bool`     | Flag indicating if the word is marked as favorite |
| `createdAt`  | `DateTime` | Timestamp when the word was created               |
| `updatedAt`  | `DateTime` | Timestamp when the word was last updated          |
| `deletedAt`  | `DateTime` | Timestamp for soft deletion (if applicable)       |

Create a new file `lib/models/words.dart` and define the entity class `Word` with the following code:

```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class Word {
  int id;
  String word;
  bool isFavorite;

  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;

  Word({
    this.id = 0,
    required this.word,
    this.isFavorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       deletedAt = deletedAt ?? DateTime(0);
}
```

### 3. Generate ObjectBox Code

We will use custom directories for the files generated by the ObjectBox in the `lib/repository` directory. The generated files will include the ObjectBox model and the ObjectBox database access code.

Add the following code to the `pubspec.yaml`:

```yaml
objectbox:
  # Writes objectbox-model.json and objectbox.g.dart to lib/custom (and test/custom).
  output_dir: repository
  # Or optionally specify the lib and test output folder separately.
  # output_dir:
  #   lib: custom
  #   test: other
```

Create a new directory `lib/repository` and run the following command to generate the ObjectBox code:

```bash
dart run build_runner build
```

> [!TIP]
> You can add `--delete-conflicting-outputs` to the command to automatically delete conflicting files.

ObjectBox generator will look for all `@Entity` annotations in your `lib` folder and create

- a single database definition `lib/repository/objectbox-model.json` and
- supporting code in `lib/repository/objectbox.g.dart`.

### 4. Create ObjectBox Store

Create a new file `lib/repository/objectbox.dart` and add the following code to create an ObjectBox store:

```dart
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
    // Other comments...

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
}
```

Initialize the ObjectBox store in the `lib/main.dart` file:

```dart
// Other imports...

Future<void> main() async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  final objectBox = await ObjectBox.create();

  runApp(MyApp());
}

// Other code...
```

To isolate the ObjectBox store from the rest of the app, we will use a singleton pattern. This allows us to create a single instance of the ObjectBox store and share it across the app. This is done by creating a private constructor and a static method to create the instance on the `MyApp` and `MyAppState` class.

`lib/main.dart`

```dart
// Other imports...

Future<void> main() async {
  // Other code...
  final objectBox = await ObjectBox.create();

  runApp(MyApp(objectBox: objectBox));
}

class MyApp extends StatelessWidget {
  final ObjectBox objectBox;

  const MyApp({super.key, required this.objectBox});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(objectBox),
      // Other code...
    );
  }
}
```

`lib/providers/app_state.dart`:

```dart
// Other imports...

class MyAppState extends ChangeNotifier {
  late final ObjectBox _objectBox;
  Word? _current;
  GlobalKey? historyListKey;

  MyAppState(this._objectBox) {
    _current = _objectBox.getCurrent();
  }

  // Other code...
}
```

### 5. Create CRUD Operations

#### Get Current Word

Returns the first word in the database or creates a new random word if none exists.

```dart
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
```

#### Add to History

Adds or updates a word in the database.

```dart
void addToHistory(Word word) {
  _wordBox.put(word);
}
```

#### Get History Stream

Returns a reactive stream of all non-deleted words, ordered by creation date (newest first).

```dart
Stream<List<Word>> getHistoryStream() {
  return _wordBox
      .query(Word_.deletedAt.equals(DateTime(0).millisecondsSinceEpoch))
      .order(Word_.createdAt, flags: Order.descending)
      .watch(triggerImmediately: true)
      .map((query) => query.find());
}
```

#### Get Favorites Stream

Returns a reactive stream of favorite words that haven't been deleted, ordered by creation date.

```dart
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
```

#### Toggle Favorite

Toggles the favorite status of a word and updates the database.

```dart
void toggleFavorite(Word word) {
  word.isFavorite = !word.isFavorite;
  word.updatedAt = DateTime.now();
  _wordBox.put(word);
}
```

#### Remove Favorite

Removes the favorite status from a word and updates the database.

```dart
void removeFavorite(Word word) {
  word.isFavorite = false;
  word.updatedAt = DateTime.now();
  _wordBox.put(word);
}
```

### 6. Update App State Provider

Create some useful getters in the `MyAppState` class to manage the current word and the history of words.

```dart
Word get current => _current ?? Word(word: WordPair.random().asString);

Stream<List<Word>> get history => _objectBox.getHistoryStream();
Stream<List<Word>> get favorites => _objectBox.getFavoritesStream();
```

- `current`: Returns the current word or generates a new one if none exists
- `history`: Returns a stream of all words in the history
- `favorites`: Returns a stream of only favorited words

Create some useful methods in the `MyAppState` class to manage the current word and the history of words.

#### Get Next Word

This method checks if a current word exists and, if so, adds it to the history. It then generates a new random word using the current timestamp, updates the `_current` property with this new word, and notifies all listeners about the change in state. Additionally, it includes error handling with logging to ensure robust operation.

```dart
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
```

#### Toggle Favorite

This method accepts an optional `Word` parameter, defaulting to the current word if none is provided. It uses the `ObjectBox` service to toggle the favorite status of the specified word and notifies listeners about the resulting state change.

```dart
void toggleFavorite([Word? word]) {
  word = word ?? current;

  _objectBox.toggleFavorite(word);
  notifyListeners();
}
```

#### Remove Favorite

This method removes favorite status from the specified word and notifies listeners about the state change

```dart
void removeFavorite(Word word) async {
  _objectBox.removeFavorite(word);
  notifyListeners();
}
```

### 7. Update UI

Update the UI to use the new ObjectBox store and the app state provider. This includes updating the `History` and `Favorites` screens to display the words from the ObjectBox store.

## References

- [ObjectBox Documentation](https://docs.objectbox.io/getting-started)
- [Flutter Documentation](https://flutter.dev/docs)
