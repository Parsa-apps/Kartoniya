// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class DifferenceGamePage extends ConsumerStatefulWidget {
  const DifferenceGamePage({required this.game, super.key});
  final GameModel game;

  @override
  ConsumerState<DifferenceGamePage> createState() => _DifferenceGamePageState();
}

class _DifferenceGamePageState extends ConsumerState<DifferenceGamePage> {
  late List<bool> _found;
  late List<Offset> _positions;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    _found = List.filled(5, false);
    _positions = List.generate(5, (i) {
      final rand = math.Random(i * 99);
      return Offset(0.15 + rand.nextDouble() * 0.7, 0.2 + rand.nextDouble() * 0.6);
    });
    _score = 0;
  }

  void _tap(int i) {
    if (_found[i]) return;
    setState(() {
      _found[i] = true;
      _score += 10;
      if (_found.every((e) => e)) _showWin();
    });
  }

  void _showWin() {
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameResultDialog(
        title: 'پیدا کردی!',
        message: 'هر ۵ تفاوت را یافتی.',
        score: _score,
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
      score: _score,
      maxScore: 50,
      onRestart: () => setState(_init),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('۵ تفاوت را لمس کن',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.game.accentColor.withOpacity(.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: widget.game.accentColor.withOpacity(.2)),
                      ),
                      child: Center(
                        child: Text('تصویر ۱  •  تفاوت‌ها با نقطه نشان داده شده',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ),
                    ..._positions.asMap().entries.map((e) {
                      final idx = e.key;
                      final pos = e.value;
                      return Positioned(
                        left: pos.dx * constraints.maxWidth,
                        top: pos.dy * constraints.maxHeight,
                        child: GestureDetector(
                          onTap: () => _tap(idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _found[idx] ? Colors.green : Colors.red.withOpacity(.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: _found[idx] ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('پیدا شده: ${_found.where((e) => e).length} / 5',
                style: Theme.of(context).textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}
