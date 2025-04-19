import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_random_word_generator/providers/app_state.dart';
import 'package:persistent_random_word_generator/models/words.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    return StreamBuilder<List<Word>>(
      stream: appState.favorites,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final favorites = snapshot.data!;

        if (favorites.isEmpty) {
          return const Center(child: Text('No favorites yet.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Text('You have ${favorites.length} favorites:'),
            ),
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 400 / 80,
                ),
                children: [
                  for (var word in favorites)
                    ListTile(
                      leading: IconButton(
                        onPressed: () {
                          appState.toggleFavorite(word);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          semanticLabel: 'Delete',
                        ),
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        word.asLowerCase,
                        semanticsLabel: word.asPascalCase,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
