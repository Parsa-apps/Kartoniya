import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_model.dart';
import '../repositories/local_game_repository.dart';
import '../../domain/repositories/game_repository.dart';
import '../../core/services/app_preferences.dart';
import 'cartoons_provider.dart'; // برای sharedPreferencesProvider

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return LocalGameRepository();
});

final gamesProvider = FutureProvider<List<GameModel>>((ref) {
  return ref.watch(gameRepositoryProvider).fetchGames();
});

final playableGamesProvider = FutureProvider<List<GameModel>>((ref) async {
  final games = await ref.watch(gamesProvider.future);
  return games.where((g) => g.isPlayable).toList(growable: false);
});

final gamesByCategoryProvider =
    FutureProvider.family<List<GameModel>, String>((ref, categoryId) async {
  final games = await ref.watch(playableGamesProvider.future);
  if (categoryId == 'all') return games;
  return games.where((g) => g.category.id == categoryId).toList(growable: false);
});

final favoriteGamesProvider =
    StateNotifierProvider<FavoriteGamesNotifier, Set<String>>((ref) {
  return FavoriteGamesNotifier(ref.watch(appPreferencesProvider));
});

class FavoriteGamesNotifier extends StateNotifier<Set<String>> {
  FavoriteGamesNotifier(this._prefs) : super(_prefs.favoriteGameIds);
  final AppPreferences _prefs;
  void toggle(String id) {
    final next = {...state};
    if (!next.add(id)) next.remove(id);
    state = Set.unmodifiable(next);
    unawaited(_prefs.saveFavoriteGameIds(next));
  }

  void pruneTo(Set<String> valid) {
    if (state.every(valid.contains)) return;
    final next = state.where(valid.contains).toSet();
    state = Set.unmodifiable(next);
    unawaited(_prefs.saveFavoriteGameIds(next));
  }
}

final gameSearchQueryProvider = StateProvider<String>((ref) => '');

final gameSearchResultsProvider = FutureProvider<List<GameModel>>((ref) async {
  final query = ref.watch(gameSearchQueryProvider).trim();
  if (query.isEmpty) return const <GameModel>[];
  final games = await ref.watch(playableGamesProvider.future);
  final lower = query.toLowerCase();
  return games
      .where((g) =>
          g.title.contains(query) ||
          g.description.contains(query) ||
          g.category.labelFa.contains(query) ||
          g.tags.any((t) => t.contains(query)))
      .toList(growable: false);
});

final recentGamesProvider =
    StateNotifierProvider<RecentGamesNotifier, List<String>>((ref) {
  return RecentGamesNotifier(ref.watch(appPreferencesProvider));
});

class RecentGamesNotifier extends StateNotifier<List<String>> {
  RecentGamesNotifier(this._prefs) : super(_prefs.recentGameIds);
  final AppPreferences _prefs;
  void add(String id) {
    final next = [id, ...state.where((e) => e != id)].take(10).toList();
    state = List.unmodifiable(next);
    unawaited(_prefs.saveRecentGameIds(next));
  }
}

final gameScoresProvider =
    StateNotifierProvider<GameScoresNotifier, Map<String, int>>((ref) {
  return GameScoresNotifier(ref.watch(appPreferencesProvider));
});

class GameScoresNotifier extends StateNotifier<Map<String, int>> {
  GameScoresNotifier(this._prefs) : super(Map.unmodifiable(_prefs.gameScores));
  final AppPreferences _prefs;
  void saveScore(String gameId, int score) {
    if (score <= (state[gameId] ?? 0)) return;
    final next = {...state, gameId: score};
    state = Map.unmodifiable(next);
    unawaited(_prefs.saveGameScore(gameId, score));
  }

  void clear() {
    state = const {};
    unawaited(_prefs.clearGameScores());
  }
}
