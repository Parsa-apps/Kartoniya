// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class OddOneOutGamePage extends ConsumerStatefulWidget {
  const OddOneOutGamePage({required this.game, super.key});
  final GameModel game;

  @override
  ConsumerState<OddOneOutGamePage> createState() => _OddOneOutGamePageState();
}

class _OddOneOutGamePageState extends ConsumerState<OddOneOutGamePage> {
  late List<String> _items;
  late int _oddIndex;
  int _score = 0;
  int _round = 1;
  final int _max = 5;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    final rand = math.Random();
    const pool = ['⭐', '🌟', '💫'];
    // most are ⭐, one is 🌟
    final base = pool[rand.nextInt(2)];
    final odd = pool.firstWhere((e) => e != base);
    _items = List.generate(9, (_) => base);
    _oddIndex = rand.nextInt(9);
    _items[_oddIndex] = odd;
  }

  void _tap(int i) {
    final correct = i == _oddIndex;
    if (correct) {
      setState(() => _score += 10);
      if (_round >= _max) {
        _showEnd(true);
      } else {
        setState(() {
          _round++;
          _newRound();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اشتباه! دوباره نگاه کن.'), duration: Duration(milliseconds: 500)),
      );
      setState(() => _score = (_score - 2).clamp(0, 999).toInt());
    }
  }

  void _showEnd([bool win = true]) {
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameResultDialog(
        title: win ? 'چشم عقابی!' : 'پایان',
        message: 'امتیازت $_score شد.',
        score: _score,
        isWin: _score >= 30,
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
      maxScore: 50,
      onRestart: () => setState(() {
        _score = 0;
        _round = 1;
        _newRound();
      }),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('مرحله $_round از $_max — متفاوت را پیدا کن',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 9,
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => _tap(i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.game.accentColor.withOpacity(.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: widget.game.accentColor.withOpacity(.25)),
                    ),
                    child: Center(child: Text(_items[i], style: const TextStyle(fontSize: 36))),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
