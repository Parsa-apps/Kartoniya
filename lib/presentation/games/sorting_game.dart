// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class SortingGamePage extends ConsumerStatefulWidget {
  const SortingGamePage({required this.game, super.key});
  final GameModel game;

  @override
  ConsumerState<SortingGamePage> createState() => _SortingGamePageState();
}

class _SortingGamePageState extends ConsumerState<SortingGamePage> {
  late List<int> _numbers;
  int _score = 0;
  int _round = 1;
  final int _max = 5;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    _numbers = [3, 1, 4, 2]..shuffle();
  }

  void _check() {
    final sorted = [..._numbers]..sort();
    final correct = _numbers.join(',') == sorted.join(',');
    if (correct) _score += 10;
    if (_round >= _max) {
      _showEnd();
    } else {
      setState(() {
        _round++;
        _newRound();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(correct ? 'درست!' : 'نادرست! درست: ${sorted.join(' - ')}'),
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
        title: 'پایان مرتب‌سازی',
        message: 'امتیازت $_score از 50',
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
            child: Text('مرحله $_round از $_max — از کوچک به بزرگ بکش',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.all(16),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _numbers.removeAt(oldIndex);
                  _numbers.insert(newIndex, item);
                });
              },
              children: _numbers
                  .asMap()
                  .entries
                  .map((e) => Container(
                        key: ValueKey(e.key),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: widget.game.accentColor.withOpacity(.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: widget.game.accentColor.withOpacity(.3)),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.drag_handle_rounded, color: widget.game.accentColor),
                          title: Text('${e.value}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                          trailing: const Icon(Icons.swap_vert_rounded),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _check,
                style: FilledButton.styleFrom(backgroundColor: widget.game.accentColor),
                child: const Text('بررسی'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
