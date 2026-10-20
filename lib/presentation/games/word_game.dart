// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class WordGamePage extends ConsumerStatefulWidget {
  const WordGamePage({required this.game, super.key});
  final GameModel game;
  @override
  ConsumerState<WordGamePage> createState() => _WordGamePageState();
}

class _WordGamePageState extends ConsumerState<WordGamePage> {
  int _round = 1;
  final int _max = 6;
  int _score = 0;
  late _WordItem _current;
  late List<_WordItem> _pool;

  static const _words = [
    _WordItem(display: 'س_ب', answer: 'ی', options: ['ا', 'ی', 'و', 'ه'], full: 'سیب', hint: 'میوهٔ قرمز'),
    _WordItem(display: 'م_رسه', answer: 'د', options: ['د', 'ب', 'ن', 'ر'], full: 'مدرسه', hint: 'جای درس'),
    _WordItem(display: 'پ_نجره', answer: 'ن', options: ['م', 'ن', 'ر', 'ل'], full: 'پنجره', hint: 'نور از آن می‌آید'),
    _WordItem(display: 'کتا_', answer: 'ب', options: ['ب', 'پ', 'ت', 'ن'], full: 'کتاب', hint: 'می‌خوانیم'),
    _WordItem(display: 'دو_ت', answer: 'س', options: ['س', 'ش', 'ص', 'ض'], full: 'دوست', hint: 'رفیق مهربان'),
    _WordItem(display: 'خر_وش', answer: 'گ', options: ['گ', 'ک', 'غ', 'ق'], full: 'خرگوش', hint: 'گوش‌دراز'),
    _WordItem(display: 'ماها_', answer: 'ن', options: ['ن', 'م', 'ت', 'ب'], full: 'ماهان', hint: 'نام'),
    _WordItem(display: 'آ_مان', answer: 'س', options: ['س', 'ش', 'ص', 'ز'], full: 'آسمان', hint: 'بالای سر'),
  ];

  @override
  void initState() { super.initState(); _pool=[..._words]..shuffle(math.Random()); _current=_pool.first; }

  void _pick(String l) {
    final correct = l == _current.answer;
    if (correct) _score += 10;
    if (_round >= _max) { _showEnd(); return; }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(correct ? 'درست! ${_current.full}' : 'جواب ${_current.answer} بود → ${_current.full}'), backgroundColor: correct?Colors.green:Colors.red, duration: const Duration(milliseconds: 700)));
    setState(() { _round++; _current=_pool[_round % _pool.length]; });
  }

  void _showEnd() {
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    showDialog(context: context, barrierDismissible: false, builder: (_) => GameResultDialog(title: _score>=40?'واژه‌شناس!':'پایان', message: 'امتیاز $_score از ${_max*10}', score: _score, isWin: _score>=30, onRestart: (){ Navigator.of(context).pop(); setState((){ _score=0; _round=1; _pool.shuffle(math.Random()); _current=_pool.first;});}, onExit: (){ Navigator.of(context).pop(); Navigator.of(context).maybePop();}));
  }

  @override
  Widget build(BuildContext context) {
    final opts = [..._current.options]..shuffle(math.Random(_round*17));
    return GameScaffold(
      game: widget.game, score: _score, maxScore: _max*10,
      onRestart: () => setState((){ _score=0; _round=1; _pool.shuffle(math.Random()); _current=_pool.first;}),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Text('مرحله $_round از $_max — حرف گمشده', style: Theme.of(context).textTheme.titleMedium)),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: widget.game.accentColor.withOpacity(.25))),
            child: Column(
              children: [
                Text(_current.display, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 6)),
                const SizedBox(height: 8),
                Text(_current.hint, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: opts.map((o)=> SizedBox(width: 64, height: 56, child: FilledButton(onPressed: ()=>_pick(o), style: FilledButton.styleFrom(backgroundColor: widget.game.accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text(o, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))))).toList())),
          const Spacer(),
        ],
      ),
    );
  }
}

class _WordItem {
  const _WordItem({required this.display, required this.answer, required this.options, required this.full, required this.hint});
  final String display; final String answer; final List<String> options; final String full; final String hint;
}
