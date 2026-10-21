// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';
import '../../core/theme/app_colors.dart';

class ReactionGamePage extends ConsumerStatefulWidget {
  const ReactionGamePage({required this.game, super.key});
  final GameModel game;

  @override
  ConsumerState<ReactionGamePage> createState() => _ReactionGamePageState();
}

class _ReactionGamePageState extends ConsumerState<ReactionGamePage> {
  bool _isGreen = false;
  int _score = 0;
  int _round = 0;
  final int _maxRounds = 8;
  Timer? _timer;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    if (_round >= _maxRounds) {
      _showEnd();
      return;
    }
    setState(() {
      _round++;
      _isGreen = false;
    });
    final delay = 500 + math.Random().nextInt(2000);
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() => _isGreen = true);
      _timer = Timer(const Duration(milliseconds: 1100), () {
        if (!mounted || !_isGreen) return;
        // too slow
        setState(() => _isGreen = false);
        Future.delayed(const Duration(milliseconds: 400), _nextRound);
      });
    });
  }

  void _tap() {
    if (_isGreen) {
      setState(() {
        _score += 10;
        _isGreen = false;
      });
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 300), _nextRound);
    } else {
      // premature tap
      setState(() => _score = (_score - 5).clamp(0, 999).toInt());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عجله نکن! صبر کن سبز شود.'), duration: Duration(milliseconds: 600)),
      );
    }
  }

  void _showEnd() {
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameResultDialog(
        title: _score >= 50 ? 'واکنش عالی!' : 'پایان!',
        message: 'امتیاز واکنش شما $_score از ${_maxRounds * 10}',
        score: _score,
        isWin: _score >= 40,
        onRestart: () {
          Navigator.of(context).pop();
          setState(() {
            _score = 0;
            _round = 0;
          });
          _nextRound();
        },
        onExit: () {
          Navigator.of(context).pop();
          Navigator.of(context).maybePop();
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      game: widget.game,
      score: _score,
      maxScore: _maxRounds * 10,
      onRestart: () {
        _timer?.cancel();
        setState(() {
          _score = 0;
          _round = 0;
        });
        _nextRound();
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('مرحله $_round از $_maxRounds', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _tap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: _isGreen ? AppColors.success : AppColors.error.withOpacity(.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: (_isGreen ? AppColors.success : AppColors.error).withOpacity(.4), blurRadius: 20)
                  ],
                ),
                child: Center(
                  child: Text(_isGreen ? 'بزن!' : 'صبر...',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('فقط وقتی سبز شد بزن — اگر زود بزنی امتیاز کم می‌شود',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }
}
