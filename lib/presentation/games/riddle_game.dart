// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class RiddleGamePage extends ConsumerStatefulWidget {
  const RiddleGamePage({required this.game, super.key});
  final GameModel game;
  @override
  ConsumerState<RiddleGamePage> createState() => _RiddleGamePageState();
}

class _RiddleGamePageState extends ConsumerState<RiddleGamePage> {
  int _round = 1; final int _max = 5; int _score = 0;
  late _Riddle _current; late List<_Riddle> _pool;

  static const _riddles = [
    _Riddle(q: 'کدام حیوان یال دارد؟', options: ['شیر', 'گربه', 'سگ', 'خرگوش'], answer: 'شیر', emoji: '🦁'),
    _Riddle(q: 'چه چیزی همیشه می‌آید ولی نمی‌رسد؟', options: ['فردا', 'دیروز', 'امروز', 'ساعت'], answer: 'فردا', emoji: '⏰'),
    _Riddle(q: 'پله دارد اما بالا نمی‌رود؟', options: ['نردبان', 'در', 'پنجره', 'پله برقی'], answer: 'نردبان', emoji: '🪜'),
    _Riddle(q: 'در آسمان است، در شب می‌درخشد؟', options: ['ماه', 'خورشید', 'ابر', 'کوه'], answer: 'ماه', emoji: '🌙'),
    _Riddle(q: 'صدای مه دریا چیست؟', options: ['ققا', 'میو', 'عوعو', 'بع بع'], answer: 'ققا', emoji: '🦆'),
    _Riddle(q: 'کدام شکل سه ضلع دارد؟', options: ['مثلث', 'مربع', 'دایره', 'مستطیل'], answer: 'مثلث', emoji: '🔺'),
    _Riddle(q: '۲ + ۳ = ؟', options: ['۴', '۵', '۶', '۷'], answer: '۵', emoji: '➕'),
    _Riddle(q: 'کدام میوه قرمز است؟', options: ['موز', 'سیب', 'لیمو', 'پرتقال'], answer: 'سیب', emoji: '🍎'),
  ];

  @override
  void initState() { super.initState(); _pool=[..._riddles]..shuffle(math.Random()); _current=_pool.first; }

  void _pick(String a) {
    final correct = a == _current.answer;
    if (correct) _score += 10;
    if (_round >= _max) { _showEnd(); return; }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(correct ? 'آفرین!' : 'جواب ${_current.answer} بود'), backgroundColor: correct?Colors.green:Colors.red, duration: const Duration(milliseconds: 700)));
    setState((){ _round++; _current=_pool[_round % _pool.length]; });
  }

  void _showEnd() {
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    showDialog(context: context, barrierDismissible: false, builder: (_) => GameResultDialog(title: _score>=30?'معماگر!':'پایان', message: 'امتیاز $_score از ${_max*10}', score: _score, isWin: _score>=30, onRestart: (){ Navigator.of(context).pop(); setState((){ _score=0; _round=1; _pool.shuffle(math.Random()); _current=_pool.first;});}, onExit: (){ Navigator.of(context).pop(); Navigator.of(context).maybePop();}));
  }

  @override
  Widget build(BuildContext context) {
    final opts = [..._current.options]..shuffle(math.Random(_round*23));
    return GameScaffold(
      game: widget.game, score: _score, maxScore: _max*10,
      onRestart: () => setState((){ _score=0; _round=1; _pool.shuffle(math.Random()); _current=_pool.first;}),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Text('معمای $_round از $_max', style: Theme.of(context).textTheme.titleMedium)),
          Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: widget.game.accentColor.withOpacity(.08), borderRadius: BorderRadius.circular(16)), child: Column(children: [Text(_current.emoji, style: const TextStyle(fontSize: 48)), const SizedBox(height: 8), Text(_current.q, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)])),
          ...opts.map((o)=> Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: ()=>_pick(o), style: FilledButton.styleFrom(backgroundColor: widget.game.accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(o))))),
          const Spacer(),
        ],
      ),
    );
  }
}

class _Riddle {
  const _Riddle({required this.q, required this.options, required this.answer, required this.emoji});
  final String q; final List<String> options; final String answer; final String emoji;
}
