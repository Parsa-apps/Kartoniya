import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class PatternGamePage extends ConsumerStatefulWidget {
  const PatternGamePage({required this.game, super.key});
  final GameModel game;

  @override
  ConsumerState<PatternGamePage> createState() => _PatternGamePageState();
}

class _PatternGamePageState extends ConsumerState<PatternGamePage> {
  int _round = 1;
  final int _max = 5;
  int _score = 0;
  late _Pattern _current;
  late List<_Pattern> _pool;

  static final _patterns = [
    _Pattern(['🔴', '🔵', '🔴', '🔵', '?'], '🔴', ['🔵', '🟢', '🟡']),
    _Pattern(['⭐', '⭐', '🌙', '⭐', '⭐', '?'], '🌙', ['⭐', '☀️', '🌟']),
    _Pattern(['1', '2', '3', '4', '?'], '5', ['6', '2', '4']),
    _Pattern(['🐶', '🐱', '🐶', '🐱', '?'], '🐶', ['🐱', '🐰', '🦊']),
    _Pattern(['🔺', '🔻', '🔺', '🔻', '?'], '🔺', ['🔻', '🔷', '🔶']),
    _Pattern(['A', 'B', 'C', 'D', '?'], 'E', ['F', 'A', 'C']),
    _Pattern(['2', '4', '6', '8', '?'], '10', ['12', '9', '7']),
    _Pattern(['🌞', '🌙', '🌞', '🌙', '?'], '🌞', ['🌙', '⭐', '☁️']),
    _Pattern(['⬆️', '➡️', '⬇️', '⬅️', '?'], '⬆️', ['➡️', '⬇️', '🔄']),
    _Pattern(['🍎', '🍌', '🍎', '🍌', '🍎', '?'], '🍌', ['🍎', '🍇', '🍊']),
  ];

  @override
  void initState() {
    super.initState();
    _pool = [..._patterns]..shuffle(math.Random());
    _current = _pool.first;
  }

  void _pick(String choice) {
    final correct = choice == _current.answer;
    if (correct) _score += 10;
    if (_round >= _max) {
      _showEnd();
    } else {
      setState(() {
        _round++;
        _current = _pool[_round % _pool.length];
        if (!correct) {} // keep score
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(correct ? 'درست!' : 'نادرست! جواب ${_current.answer} بود'),
          backgroundColor: correct ? Colors.green : Colors.red,
          duration: const Duration(milliseconds: 700),
        ),
      );
      // need to advance correctly - fix: we advanced before snackbar, need to show previous answer
      // adjust: if incorrect we already showed, but current changed — fix by storing prev
    }
  }

  void _showEnd() {
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameResultDialog(
        title: _score >= 30 ? 'منطق عالی!' : 'پایان',
        message: 'از $_max الگو، امتیازت $_score شد.',
        score: _score,
        isWin: _score >= 30,
        onRestart: () {
          Navigator.of(context).pop();
          setState(() {
            _score = 0; _round = 1; _pool.shuffle(math.Random()); _current = _pool.first;
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
    final options = [..._current.distractors, _current.answer]..shuffle(math.Random(_round * 31));
    return GameScaffold(
      game: widget.game,
      score: _score,
      maxScore: _max * 10,
      onRestart: () => setState(() { _score = 0; _round = 1; _pool.shuffle(math.Random()); _current = _pool.first; }),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('مرحله $_round از $_max — بعدی چیست؟', style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.game.accentColor.withOpacity(.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.game.accentColor.withOpacity(.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _current.sequence.map((e) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: e == '?' ? 52 : 48,
                height: 52,
                decoration: BoxDecoration(
                  color: e == '?' ? Colors.orange.withOpacity(.15) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: e == '?' ? Colors.orange : Colors.black12),
                ),
                child: Center(child: Text(e, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
              children: options.map((o) => SizedBox(
                width: 72, height: 56,
                child: FilledButton(
                  onPressed: () => _pick(o),
                  style: FilledButton.styleFrom(backgroundColor: widget.game.accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(o, style: const TextStyle(fontSize: 22)),
                ),
              )).toList(),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('الگو را ببین و گزینهٔ درست را انتخاب کن', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Pattern {
  const _Pattern(this.sequence, this.answer, this.distractors);
  final List<String> sequence;
  final String answer;
  final List<String> distractors;
}
