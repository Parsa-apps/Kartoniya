// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class GuessGamePage extends ConsumerStatefulWidget {
  const GuessGamePage({required this.game, super.key});
  final GameModel game;
  @override
  ConsumerState<GuessGamePage> createState() => _GuessGamePageState();
}

class _GuessGamePageState extends ConsumerState<GuessGamePage> {
  int _round = 1;
  final int _max = 6;
  int _score = 0;
  late _GuessItem _current;
  late List<_GuessItem> _pool;

  static const _items = [
    _GuessItem(hint: '🦁', answer: 'شیر', options: ['پلنگ', 'شیر', 'روباه', 'خرس'], clue: 'شاه جنگل، یال دارد'),
    _GuessItem(hint: '🚀', answer: 'موشک', options: ['هواپیما', 'موشک', 'بالن', 'هلیکوپتر'], clue: 'به فضا می‌رود'),
    _GuessItem(hint: '🍎', answer: 'سیب', options: ['گلابی', 'هلو', 'سیب', 'پرتقال'], clue: 'قرمز و گرد'),
    _GuessItem(hint: '🚗', answer: 'ماشین', options: ['دوچرخه', 'ماشین', 'قطار', 'کشتی'], clue: 'چهار چرخ دارد'),
    _GuessItem(hint: '🌳', answer: 'درخت', options: ['گل', 'بوته', 'درخت', 'چمن'], clue: 'بلند و پربرگ'),
    _GuessItem(hint: '🐠', answer: 'ماهی', options: ['نهنگ', 'کوسه', 'ماهی', 'دلفین'], clue: 'در آب شنا می‌کند'),
    _GuessItem(hint: '⚽', answer: 'توپ', options: ['توپ', 'راکت', 'چوب', 'تور'], clue: 'گرد و برای بازی'),
    _GuessItem(hint: '🏠', answer: 'خانه', options: ['کلبه', 'خانه', 'برج', 'پل'], clue: 'در آن زندگی می‌کنیم'),
    _GuessItem(hint: '🌙', answer: 'ماه', options: ['خورشید', 'ستاره', 'ماه', 'ابر'], clue: 'شب در آسمان'),
    _GuessItem(hint: '🔤', answer: 'الف', options: ['ب', 'الف', 'ج', 'د'], clue: 'اولین حرف فارسی'),
  ];

  @override
  void initState() {
    super.initState();
    _pool = [..._items]..shuffle(math.Random());
    _current = _pool.first;
  }

  void _pick(String ans) {
    final correct = ans == _current.answer;
    if (correct) _score += 10;
    if (_round >= _max) {
      _showEnd();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(correct ? 'آفرین!' : 'جواب ${_current.answer} بود'), backgroundColor: correct ? Colors.green : Colors.red, duration: const Duration(milliseconds: 700)),
      );
      setState(() {
        _round++;
        _current = _pool[_round % _pool.length];
      });
    }
  }

  void _showEnd() {
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => GameResultDialog(
        title: _score >= 40 ? 'حدس عالی!' : 'پایان',
        message: 'امتیاز حدس شما $_score از ${_max*10}',
        score: _score, isWin: _score >= 30,
        onRestart: () { Navigator.of(context).pop(); setState(() { _score=0; _round=1; _pool.shuffle(math.Random()); _current=_pool.first; }); },
        onExit: () { Navigator.of(context).pop(); Navigator.of(context).maybePop(); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      game: widget.game,
      score: _score, maxScore: _max*10,
      onRestart: () => setState(() { _score=0; _round=1; _pool.shuffle(math.Random()); _current=_pool.first; }),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Text('مرحله $_round از $_max — حدس بزن', style: Theme.of(context).textTheme.titleMedium)),
          const SizedBox(height: 8),
          Container(
            width: 140, height: 140,
            decoration: BoxDecoration(color: widget.game.accentColor.withOpacity(.10), shape: BoxShape.circle, border: Border.all(color: widget.game.accentColor.withOpacity(.25), width: 2)),
            child: Center(child: Text(_current.hint, style: const TextStyle(fontSize: 64))),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(.25))),
            child: Text(_current.clue, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
              children: (_current.options..shuffle(math.Random(_round*13))).map((o) => SizedBox(
                width: 150, height: 48,
                child: FilledButton(
                  onPressed: () => _pick(o),
                  style: FilledButton.styleFrom(backgroundColor: widget.game.accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(o, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              )).toList(),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _GuessItem {
  const _GuessItem({required this.hint, required this.answer, required this.options, required this.clue});
  final String hint;
  final String answer;
  final List<String> options;
  final String clue;
}
