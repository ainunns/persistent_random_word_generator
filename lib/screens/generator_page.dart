import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_random_word_generator/models/words.dart';
import 'package:persistent_random_word_generator/providers/app_state.dart';
import 'package:persistent_random_word_generator/widgets/big_card.dart';
import 'package:persistent_random_word_generator/widgets/history_list_view.dart';

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: HistoryListView()),
          SizedBox(height: 10),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<List<Word>>(
                stream: appState.favorites,
                builder: (context, snapshot) {
                  final isFavorite = snapshot.data?.contains(pair) ?? false;

                  return ElevatedButton.icon(
                    onPressed: () {
                      appState.toggleFavorite();
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    label: Text('Like'),
                  );
                },
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
