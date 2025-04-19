import 'package:flutter/material.dart';
import 'package:persistent_random_word_generator/models/words.dart';
import 'package:provider/provider.dart';
import 'package:persistent_random_word_generator/providers/app_state.dart';

class HistoryListView extends StatefulWidget {
  const HistoryListView({super.key});

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey<AnimatedListState>();
  List<Word> _previousHistory = [];

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: StreamBuilder<List<Word>>(
        stream: appState.history,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data!;

          // Check if we need to animate a new item
          if (history.length > _previousHistory.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _key.currentState?.insertItem(0);
            });
          }
          _previousHistory = List.from(history);

          return AnimatedList(
            key: _key,
            reverse: true,
            padding: const EdgeInsets.only(top: 100),
            initialItemCount: history.length,
            itemBuilder: (context, index, animation) {
              if (index >= history.length) {
                return const SizedBox();
              }

              final word = history[index];

              return SizeTransition(
                sizeFactor: animation,
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      appState.toggleFavorite(word);
                    },
                    icon: StreamBuilder<List<Word>>(
                      stream: appState.favorites,
                      builder: (context, snapshot) {
                        final isFavorite =
                            snapshot.data?.contains(word) ?? false;
                        return isFavorite
                            ? const Icon(Icons.favorite, size: 12)
                            : const SizedBox();
                      },
                    ),
                    label: Text(
                      word.asLowerCase,
                      semanticsLabel: word.asPascalCase,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
