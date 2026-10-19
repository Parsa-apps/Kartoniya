import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class JigsawDragGamePage extends ConsumerStatefulWidget {
  const JigsawDragGamePage({required this.game, super.key});
  final GameModel game;
  @override
  ConsumerState<JigsawDragGamePage> createState() => _JigsawDragGamePageState();
}

class _JigsawDragGamePageState extends ConsumerState<JigsawDragGamePage> {
  late List<int> _pieces; // shuffled ids 0..3
  late List<int?> _slots; // 4 slots, null or piece id
  int _correct = 0;

  @override
  void initState() { super.initState(); _init(); }

  void _init() {
    _pieces = [0,1,2,3]..shuffle();
    _slots = List.filled(4, null);
    _correct = 0;
  }

  void _onAccept(int slot, int piece) {
    if (_slots[slot] != null) return;
    setState(() {
      _slots[slot] = piece;
      _pieces.remove(piece);
      if (piece == slot) _correct++;
      if (_slots.every((e) => e != null)) _showEnd();
    });
  }

  void _showEnd() {
    final score = _correct * 10;
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, score);
    showDialog(context: context, barrierDismissible: false, builder: (_) => GameResultDialog(title: _correct==4 ? 'کامل شد!' : 'پایان', message: '$_correct از 4 تکه درست', score: score, isWin: _correct>=3, onRestart: () { Navigator.of(context).pop(); setState(_init); }, onExit: () { Navigator.of(context).pop(); Navigator.of(context).maybePop(); }));
  }

  @override
  Widget build(BuildContext context) {
    final colors = [const Color(0xFFFF5D6C), const Color(0xFF53B86A), const Color(0xFF2E9BEB), const Color(0xFFFFC53D)];
    final emojis = ['🐶','🐱','🦁','🐰'];
    return GameScaffold(
      game: widget.game, score: _correct*10, maxScore: 40,
      onRestart: () => setState(_init),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Text('تکه‌ها را به جای درست بکش', style: Theme.of(context).textTheme.titleMedium)),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: 4,
                    itemBuilder: (context, i) {
                      final placed = _slots[i];
                      return DragTarget<int>(
                        onAccept: (data) => _onAccept(i, data),
                        builder: (context, cand, rej) {
                          final isOver = cand.isNotEmpty;
                          return Container(
                            decoration: BoxDecoration(
                              color: placed != null ? colors[placed].withOpacity(.25) : isOver ? widget.game.accentColor.withOpacity(.15) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: placed != null ? (placed==i ? Colors.green : Colors.red) : widget.game.accentColor.withOpacity(.25), width: placed != null ? 2 : 1),
                            ),
                            child: placed != null ? Center(child: Text(emojis[placed], style: const TextStyle(fontSize: 36))) : Center(child: Text('${i+1}', style: TextStyle(color: Colors.black26, fontSize: 20))),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Wrap(
              spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
              children: _pieces.map((p) => Draggable<int>(
                data: p,
                feedback: Container(width: 64, height: 64, decoration: BoxDecoration(color: colors[p], borderRadius: BorderRadius.circular(12)), child: Center(child: Text(emojis[p], style: const TextStyle(fontSize: 30)))),
                childWhenDragging: Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.grey.withOpacity(.3), borderRadius: BorderRadius.circular(12))),
                child: Container(width: 64, height: 64, decoration: BoxDecoration(color: colors[p], borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: Center(child: Text(emojis[p], style: const TextStyle(fontSize: 30)))),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
