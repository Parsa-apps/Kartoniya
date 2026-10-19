import 'package:flutter/material.dart';

import '../../data/models/game_model.dart';
import 'game_scaffold.dart';

class MazeGamePage extends StatefulWidget {
  const MazeGamePage({required this.game, super.key});
  final GameModel game;

  @override
  State<MazeGamePage> createState() => _MazeGamePageState();
}

class _MazeGamePageState extends State<MazeGamePage> {
  // 5x5 maze: 0 empty, 1 wall, 2 start, 3 end
  final List<List<int>> _maze = [
    [2, 0, 1, 0, 0],
    [0, 0, 1, 0, 1],
    [1, 0, 0, 0, 0],
    [0, 1, 1, 1, 0],
    [0, 0, 0, 0, 3],
  ];
  int _r = 0, _c = 0;
  int _moves = 0;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _r = 0;
    _c = 0;
  }

  void _move(int dr, int dc) {
    if (_won) return;
    final nr = _r + dr;
    final nc = _c + dc;
    if (nr < 0 || nr >= 5 || nc < 0 || nc >= 5) return;
    if (_maze[nr][nc] == 1) return;
    setState(() {
      _r = nr;
      _c = nc;
      _moves++;
      if (_maze[nr][nc] == 3) {
        _won = true;
        Future.delayed(const Duration(milliseconds: 200), _showWin);
      }
    });
  }

  void _showWin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameResultDialog(
        title: 'رسیدی!',
        message: 'ماز را در $_moves حرکت حل کردی.',
        score: (80 - _moves).clamp(10, 80).toInt(),
        isWin: true,
        onRestart: () {
          Navigator.of(context).pop();
          setState(() {
            _r = 0;
            _c = 0;
            _moves = 0;
            _won = false;
          });
        },
        onExit: () {
          Navigator.of(context).pop();
          Navigator.of(context).maybePop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      game: widget.game,
      score: _moves,
      onRestart: () => setState(() {
        _r = 0;
        _c = 0;
        _moves = 0;
        _won = false;
      }),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('با دکمه‌ها شخصیت را به 🏁 برسان', style: Theme.of(context).textTheme.titleSmall),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 4, mainAxisSpacing: 4),
                    itemCount: 25,
                    itemBuilder: (context, i) {
                      final r = i ~/ 5;
                      final c = i % 5;
                      final cell = _maze[r][c];
                      final isPlayer = r == _r && c == _c;
                      Color col;
                      String emoji = '';
                      if (isPlayer) {
                        col = widget.game.accentColor;
                        emoji = '🧒';
                      } else if (cell == 1) {
                        col = Colors.black87;
                      } else if (cell == 2) {
                        col = Colors.green.withOpacity(.2);
                        emoji = '🏠';
                      } else if (cell == 3) {
                        col = Colors.orange.withOpacity(.3);
                        emoji = '🏁';
                      } else {
                        col = Colors.white;
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: col,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                IconButton(onPressed: () => _move(-1, 0), icon: const Icon(Icons.arrow_upward_rounded), style: IconButton.styleFrom(backgroundColor: widget.game.accentColor.withOpacity(.15))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: () => _move(0, -1), icon: const Icon(Icons.arrow_back_rounded), style: IconButton.styleFrom(backgroundColor: widget.game.accentColor.withOpacity(.15))),
                    const SizedBox(width: 40),
                    IconButton(onPressed: () => _move(0, 1), icon: const Icon(Icons.arrow_forward_rounded), style: IconButton.styleFrom(backgroundColor: widget.game.accentColor.withOpacity(.15))),
                  ],
                ),
                IconButton(onPressed: () => _move(1, 0), icon: const Icon(Icons.arrow_downward_rounded), style: IconButton.styleFrom(backgroundColor: widget.game.accentColor.withOpacity(.15))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
