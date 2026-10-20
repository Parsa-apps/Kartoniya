import '../../data/models/game_model.dart';

abstract class GameRepository {
  Future<List<GameModel>> fetchGames();
  Future<List<GameCategory>> fetchGameCategories();
  Future<GameModel?> fetchGameById(String id);
}
