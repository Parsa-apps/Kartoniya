import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';
import '../../core/theme/app_colors.dart';

class CountingGamePage extends ConsumerStatefulWidget {
  const CountingGamePage({required this.game, super.key});
  final GameModel game;

  @override
  ConsumerState<CountingGamePage> createState() => _CountingGamePageState();
}

class _CountingGamePageState extends ConsumerState<CountingGamePage> {
  int _target = 0;
  late List<String> _display;
  int _score = 0;
  int _round = 1;
  final int _maxRound = 6;

  static const _iconOptions = ['🍎', '⭐', '🐶', '🎈', '🍓', '🚀', '🌈', '🐱'];

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    final rand = math.Random();
    _target = 3 + rand.nextInt(6); // 3..8
    final icon = _iconOptions[rand.nextInt(_iconOptions.length)];
    _display = List.generate(_target, (_) => icon);
    _display.shuffle(rand);
  }

  void _answer(int value) {
    final correct = value == _target;
    if (correct) _score += 10;
    if (_round >= _maxRound) {
      _showEnd();
    } else {
      setState(() {
        _round++;
        if (correct) _score += 5;
        _newRound();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(correct ? 'آفرین! درست بود.' : 'اشتباه بود. جواب $_target بود.'),
          backgroundColor: correct ? AppColors.success : AppColors.error,
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _showEnd() {
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameResultDialog(
        title: _score >= 40 ? 'عالی!' : 'پایان!',
        message: 'در $_maxRound مرحله، امتیازت $_score شد.',
        score: _score,
        isWin: _score >= 40,
        onRestart: () {
          Navigator.of(context).pop();
          setState(() {
            _score = 0;
            _round = 1;
            _newRound();
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
      score: _score,
      maxScore: 60,
      onRestart: () => setState(() {
        _score = 0;
        _round = 1;
        _newRound();
      }),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('مرحله $_round از $_maxRound — چند تا می‌بینی؟',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _display
                    .map((e) => Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: widget.game.accentColor.withOpacity(.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: widget.game.accentColor.withOpacity(.3)),
                          ),
                          child: Center(child: Text(e, style: const TextStyle(fontSize: 36))),
                        ))
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(7, (i) {
                final n = 2 + i; // 2..8
                return SizedBox(
                  width: 72,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => _answer(n),
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.game.accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('$n', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
