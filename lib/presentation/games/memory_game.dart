// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class MemoryGamePage extends ConsumerStatefulWidget {
  const MemoryGamePage({required this.game, super.key});
  final GameModel game;

  @override
  ConsumerState<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends ConsumerState<MemoryGamePage> {
  late List<String> _cards;
  late List<bool> _revealed;
  late List<bool> _matched;
  int _firstIndex = -1;
  int _moves = 0;
  int _pairsFound = 0;
  bool _busy = false;
  int _elapsed = 0;
  Timer? _timer;
  bool _won = false;

  static const _emojisByGame = {
    'memory_classic': ['🍎', '🚀', '🌈', '🐶', '🍓', '⭐', '🎈', '🚗'],
    'memory_animals': ['🐶', '🐱', '🦁', '🐰', '🐼', '🐨', '🦊', '🐻'],
    'memory_shapes': ['🔷', '🔶', '⭕', '⭐', '💙', '💚', '💜', '🧡'],
    'memory_numbers': ['1️⃣', '2️⃣', '3️⃣', '4️⃣', '5️⃣', '6️⃣', '7️⃣', '8️⃣'],
    'memory_fruits': ['🍎', '🍌', '🍇', '🍊', '🍓', '🍉', '🍒', '🥝'],
    'memory_emoji': ['😊', '😂', '😍', '🥳', '🤩', '😎', '🤗', '😇'],
    'memory_toddler': ['🌟', '❤️', '🌈', '🎈'],
  };

  @override
  void initState() {
    super.initState();
    _initBoard();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_won && mounted) setState(() => _elapsed++);
    });
  }

  void _initBoard() {
    final emojis = _emojisByGame[widget.game.id] ?? _emojisByGame['memory_classic']!;
    final pairs = widget.game.id == 'memory_toddler' ? 2 : 6;
    final chosen = (emojis.take(pairs).toList(growable: false));
    final deck = [...chosen, ...chosen];
    deck.shuffle(math.Random());
    _cards = deck;
    _revealed = List.filled(deck.length, false);
    _matched = List.filled(deck.length, false);
    _firstIndex = -1;
    _moves = 0;
    _pairsFound = 0;
    _busy = false;
    _won = false;
    _elapsed = 0;
  }

  void _onTap(int index) {
    if (_busy || _matched[index] || _revealed[index] || _won) return;
    setState(() {
      _revealed[index] = true;
      if (_firstIndex == -1) {
        _firstIndex = index;
      } else {
        _moves++;
        final first = _firstIndex;
        final second = index;
        _firstIndex = -1;
        if (_cards[first] == _cards[second]) {
          _matched[first] = true;
          _matched[second] = true;
          _pairsFound++;
          if (_pairsFound == _cards.length ~/ 2) {
            _won = true;
            Future.delayed(const Duration(milliseconds: 300), _showWin);
          }
        } else {
          _busy = true;
          Future.delayed(const Duration(milliseconds: 700), () {
            if (!mounted) return;
            setState(() {
              _revealed[first] = false;
              _revealed[second] = false;
              _busy = false;
            });
          });
        }
      }
    });
  }

  void _showWin() {
    if (!mounted) return;
    final computed = (100 - _moves * 2 - _elapsed).clamp(10, 100).toInt();
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, computed);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameResultDialog(
        title: 'آفرین!',
        message: 'همهٔ جفت‌ها را در $_moves حرکت و $_elapsed ثانیه پیدا کردی.',
        score: computed,
        isWin: true,
        onRestart: () {
          Navigator.of(context).pop();
          setState(_initBoard);
        },
        onExit: () {
          Navigator.of(context).pop();
          Navigator.of(context).maybePop();
        },
      ),
    );
  }

  void _restart() => setState(_initBoard);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cols = widget.game.id == 'memory_toddler' ? 2 : 4;
    return GameScaffold(
      game: widget.game,
      score: _pairsFound * 10,
      maxScore: _cards.length ~/ 2 * 10,
      showTimer: true,
      elapsedSeconds: _elapsed,
      onRestart: _restart,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('حرکت: $_moves  •  جفت: $_pairsFound/${_cards.length ~/ 2}',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, i) {
                  final isUp = _revealed[i] || _matched[i];
                  return GestureDetector(
                    onTap: () => _onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: _matched[i]
                            ? AppColors.success.withOpacity(.18)
                            : isUp
                                ? Colors.white
                                : widget.game.accentColor.withOpacity(.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _matched[i]
                              ? AppColors.success
                              : widget.game.accentColor.withOpacity(.3),
                          width: _matched[i] ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: isUp
                            ? Text(_cards[i], style: const TextStyle(fontSize: 32))
                            : Icon(Icons.question_mark_rounded,
                                color: widget.game.accentColor, size: 28),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
