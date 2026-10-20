// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class MathRaceGamePage extends ConsumerStatefulWidget {
  const MathRaceGamePage({required this.game, super.key});
  final GameModel game;
  @override
  ConsumerState<MathRaceGamePage> createState() => _MathRaceGamePageState();
}

class _MathRaceGamePageState extends ConsumerState<MathRaceGamePage> {
  int _score = 0; int _round = 1; final int _max = 8;
  late int _a; late int _b; late String _op; late int _answer;
  late List<int> _options;
  int _timeLeft = 8; Timer? _timer;

  @override
  void initState() { super.initState(); _newQuestion(); _startTimer(); }

  void _startTimer() {
    _timeLeft = 8;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t){
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <=0) { _timer?.cancel(); _pick(-999); }
    });
  }

  void _newQuestion() {
    final r = math.Random();
    final ops = ['+', '-'];
    _op = ops[r.nextInt(ops.length)];
    if (_op == '+') { _a = 1 + r.nextInt(9); _b = 1 + r.nextInt(9); _answer = _a + _b; }
    else { _a = 5 + r.nextInt(6); _b = 1 + r.nextInt(4); _answer = _a - _b; }
    final set = {_answer};
    while (set.length < 4) set.add(_answer + r.nextInt(7) - 3);
    set.removeWhere((e)=> e<0 || e>20);
    while (set.length <4) set.add(r.nextInt(15));
    _options = set.toList()..shuffle(r);
  }

  void _pick(int v) {
    _timer?.cancel();
    final correct = v == _answer;
    if (correct) _score += 10 + _timeLeft; else _score = (_score - 2).clamp(0, 999).toInt();
    if (_round >= _max) { _showEnd(); return; }
    setState((){ _round++; _newQuestion(); });
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(correct ? 'درست! +${10+_timeLeft}' : 'نادرست! جواب $_answer بود'), backgroundColor: correct?Colors.green:Colors.red, duration: const Duration(milliseconds: 600)));
  }

  void _showEnd() {
    _timer?.cancel();
    final totalMax = _max * 18;
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    if (!mounted) return;
    showDialog(context: context, barrierDismissible: false, builder: (_) => GameResultDialog(title: _score >= totalMax*0.6 ? 'سریع و دقیق!' : 'پایان مسابقه', message: 'امتیاز $_score از $totalMax', score: _score, isWin: _score >= totalMax*0.5, onRestart: (){ Navigator.of(context).pop(); setState((){ _score=0; _round=1; _newQuestion(); _startTimer();});}, onExit: (){ Navigator.of(context).pop(); Navigator.of(context).maybePop();}));
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      game: widget.game, score: _score, maxScore: _max*18, showTimer: true, elapsedSeconds: _timeLeft,
      onRestart: (){ _timer?.cancel(); setState((){ _score=0; _round=1; _newQuestion(); _startTimer();});},
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Text('مسابقه $_round از $_max — سریع جواب بده!', style: Theme.of(context).textTheme.titleMedium)),
          const SizedBox(height: 12),
          Container(margin: const EdgeInsets.symmetric(horizontal: 24), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: widget.game.accentColor.withOpacity(.25))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('$_a', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(_op, style: TextStyle(fontSize: 30, color: widget.game.accentColor))),
            Text('$_b', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('=', style: TextStyle(fontSize: 30))),
            Container(width: 48, height: 48, decoration: BoxDecoration(color: widget.game.accentColor.withOpacity(.12), borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('?', style: TextStyle(fontSize: 24)))),
          ])),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: _timeLeft/8, color: _timeLeft>3?widget.game.accentColor:Colors.red, backgroundColor: Colors.black12, minHeight: 6),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: _options.map((o)=> SizedBox(width: 72, height: 56, child: FilledButton(onPressed: ()=>_pick(o), style: FilledButton.styleFrom(backgroundColor: widget.game.accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text('$o', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))))).toList())),
          const Spacer(),
        ],
      ),
    );
  }
}
