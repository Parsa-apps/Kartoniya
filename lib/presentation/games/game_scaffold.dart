import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';

/// Scaffold مشترک هر بازی: هدر، امتیاز/زمان، دکمه‌های کنترل، مدیریت چرخهٔ حیات.
///
/// هر بازی مستقل است؛ تایمر و کنترلرها در dispose آزاد می‌شوند.
class GameScaffold extends ConsumerStatefulWidget {
  const GameScaffold({
    required this.game,
    required this.child,
    this.score = 0,
    this.maxScore,
    this.showTimer = false,
    this.elapsedSeconds,
    this.onRestart,
    this.onExit,
    super.key,
  });

  final GameModel game;
  final Widget child;
  final int score;
  final int? maxScore;
  final bool showTimer;
  final int? elapsedSeconds;
  final VoidCallback? onRestart;
  final VoidCallback? onExit;

  @override
  ConsumerState<GameScaffold> createState() => _GameScaffoldState();
}

class _GameScaffoldState extends ConsumerState<GameScaffold> {
  @override
  Widget build(BuildContext context) {
    final best = ref.watch(gameScoresProvider)[widget.game.id] ?? 0;
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: Text(widget.game.title),
        centerTitle: true,
        backgroundColor: widget.game.accentColor.withOpacity(.08),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: widget.onExit ?? () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (widget.onRestart != null)
            IconButton(
              tooltip: 'شروع دوباره',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: widget.onRestart,
            ),
        ],
      ),
      body: Column(
        children: [
          _GameStatusBar(
            score: widget.score,
            best: best,
            maxScore: widget.maxScore,
            elapsed: widget.elapsedSeconds,
            showTimer: widget.showTimer,
            category: widget.game.category,
          ),
          Expanded(child: widget.child),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onExit ?? () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('خروج'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: widget.onRestart,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('دوباره'),
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.game.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameStatusBar extends StatelessWidget {
  const _GameStatusBar({
    required this.score,
    required this.best,
    this.maxScore,
    this.elapsed,
    required this.showTimer,
    required this.category,
  });

  final int score;
  final int best;
  final int? maxScore;
  final int? elapsed;
  final bool showTimer;
  final GameCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: category.color.withOpacity(.08),
        border: Border(bottom: BorderSide(color: category.color.withOpacity(.18))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: category.color.withOpacity(.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(category.labelFa, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
          const Spacer(),
          if (showTimer && elapsed != null) ...[
            Icon(Icons.timer_outlined, size: 16, color: AppColors.coral),
            const SizedBox(width: 4),
            Text('$elapsed ثانیه', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('امتیاز: $score${maxScore != null ? ' / $maxScore' : ''}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
              if (best > 0)
                Text('بهترین: $best', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }
}

/// دیالوگ پایان بازی — برد/باخت با امتیاز و دکمه‌ها
class GameResultDialog extends StatelessWidget {
  const GameResultDialog({
    required this.title,
    required this.message,
    required this.score,
    required this.isWin,
    required this.onRestart,
    required this.onExit,
    super.key,
  });

  final String title;
  final String message;
  final int score;
  final bool isWin;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(isWin ? Icons.celebration_rounded : Icons.sentiment_dissatisfied_rounded,
              color: isWin ? AppColors.gold : AppColors.coral),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.skySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('امتیاز شما: $score', textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onExit, child: const Text('خروج')),
        FilledButton(onPressed: onRestart, child: const Text('دوباره بازی کن')),
      ],
    );
  }
}
