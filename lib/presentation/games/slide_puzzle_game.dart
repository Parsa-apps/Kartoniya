// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';
import '../../core/theme/app_colors.dart';

class SlidePuzzleGamePage extends ConsumerStatefulWidget {
  const SlidePuzzleGamePage({required this.game, super.key});
  final GameModel game;

  @override
  ConsumerState<SlidePuzzleGamePage> createState() => _SlidePuzzleGamePageState();
}

class _SlidePuzzleGamePageState extends ConsumerState<SlidePuzzleGamePage> {
  late List<int> _board; // 0 = empty
  int _moves = 0;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    // Start from solved: [1..8,0] then apply 100 random valid moves — guarantees solvability
    _board = [1, 2, 3, 4, 5, 6, 7, 8, 0];
    final rand = DateTime.now().microsecondsSinceEpoch % 91138233;
    var r = rand;
    int empty = 8;
    for (var k = 0; k < 120; k++) {
      r = (r * 1664525 + 1013904223) & 0x7fffffff;
      final dir = r % 4;
      int nr = empty ~/ 3, nc = empty % 3;
      if (dir == 0) nr--;
      if (dir == 1) nr++;
      if (dir == 2) nc--;
      if (dir == 3) nc++;
      if (nr < 0 || nr >= 3 || nc < 0 || nc >= 3) continue;
      final nxt = nr * 3 + nc;
      _board[empty] = _board[nxt];
      _board[nxt] = 0;
      empty = nxt;
    }
    // ensure not solved (extremely rare after shuffle)
    if (_isSolved) {
      _board[0] = 2; _board[1] = 1;
    }
    _moves = 0;
    _won = false;
  }

  bool get _isSolved {
    for (var i = 0; i < 8; i++) {
      if (_board[i] != i + 1) return false;
    }
    return _board[8] == 0;
  }

  void _tap(int index) {
    if (_won) return;
    final empty = _board.indexOf(0);
    final row = index ~/ 3;
    final col = index % 3;
    final eRow = empty ~/ 3;
    final eCol = empty % 3;
    if ((row == eRow && (col - eCol).abs() == 1) ||
        (col == eCol && (row - eRow).abs() == 1)) {
      setState(() {
        _board[empty] = _board[index];
        _board[index] = 0;
        _moves++;
        if (_isSolved) {
          _won = true;
          Future.delayed(const Duration(milliseconds: 200), _showWin);
        }
      });
    }
  }

  void _showWin() {
    if (!mounted) return;
    final computed = (100 - _moves).clamp(20, 100).toInt();
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, computed);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameResultDialog(
        title: 'تبریک!',
        message: 'پازل را در $_moves حرکت حل کردی!',
        score: computed,
        isWin: true,
        onRestart: () {
          Navigator.of(context).pop();
          setState(_init);
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
      onRestart: () => setState(_init),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('حرکت: $_moves',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, i) {
                      final v = _board[i];
                      if (v == 0) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: () => _tap(i),
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.game.accentColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 6)],
                          ),
                          child: Center(
                            child: Text('$v',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('کاشی را به خانهٔ خالی بکشان',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
