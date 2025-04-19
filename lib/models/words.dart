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

  String get asLowerCase => word.toLowerCase();
  String get asPascalCase => word;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Word &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          word == other.word;

  @override
  int get hashCode => id.hashCode ^ word.hashCode ^ isFavorite.hashCode;
}
