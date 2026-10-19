import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class StoryOrderGamePage extends ConsumerStatefulWidget {
  const StoryOrderGamePage({required this.game, super.key});
  final GameModel game;
  @override
  ConsumerState<StoryOrderGamePage> createState() => _StoryOrderGamePageState();
}

class _StoryOrderGamePageState extends ConsumerState<StoryOrderGamePage> {
  int _round = 1; final int _max = 5; int _score = 0;
  late List<_StoryStep> _current;
  late List<String> _order;
  static final _stories = [
    _StoryData(title: 'کاشت گل', steps: [
      _StoryStep('🌱', 'بذر کاشتیم'),
      _StoryStep('💧', 'آب دادیم'),
      _StoryStep('☀️', 'آفتاب تابید'),
      _StoryStep('🌷', 'گل رویید'),
    ]),
    _StoryData(title: 'صبحانه', steps: [
      _StoryStep('🥚', 'تخم‌مرغ شکستیم'),
      _StoryStep('🍳', 'نیمرو پختیم'),
      _StoryStep('🍞', 'نان آوردیم'),
      _StoryStep('😋', 'صبحانه خوردیم'),
    ]),
    _StoryData(title: 'سفر', steps: [
      _StoryStep('🎒', 'کوله بستیم'),
      _StoryStep('🚌', 'سوار شدیم'),
      _StoryStep('🏞️', 'به طبیعت رسیدیم'),
      _StoryStep('⛺', 'چادر زدیم'),
    ]),
    _StoryData(title: 'باران', steps: [
      _StoryStep('☁️', 'ابر آمد'),
      _StoryStep('🌧️', 'باران بارید'),
      _StoryStep('🌱', 'زمین سبز شد'),
      _StoryStep('🌈', 'رنگین‌کمان آمد'),
    ]),
    _StoryData(title: 'کتاب', steps: [
      _StoryStep('📚', 'کتاب برداشتیم'),
      _StoryStep('👀', 'خواندیم'),
      _StoryStep('💡', 'یاد گرفتیم'),
      _StoryStep('😊', 'خوشحال شدیم'),
    ]),
  ];
  late _StoryData _story;

  @override
  void initState() { super.initState(); _loadRound(); }

  void _loadRound() {
    _story = _stories[(_round - 1) % _stories.length];
    _current = [..._story.steps]..shuffle();
    _order = _current.map((e) => e.label).toList();
  }

  void _check() {
    final correct = _order.join(',') == _story.steps.map((e) => e.label).join(',');
    if (correct) _score += 10;
    if (_round >= _max) { _showEnd(); return; }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(correct ? 'آفرین! ترتیب درست بود' : 'اشتباه! دوباره امتحان کن'), backgroundColor: correct ? Colors.green : Colors.orange, duration: const Duration(milliseconds: 700)));
    setState(() { _round++; _loadRound(); });
  }

  void _showEnd() {
    if (!mounted) return;
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    showDialog(context: context, barrierDismissible: false, builder: (_) => GameResultDialog(title: _score >= 30 ? 'داستان‌سرا!' : 'پایان', message: 'امتیاز $_score از ${_max*10}', score: _score, isWin: _score >= 30, onRestart: () { Navigator.of(context).pop(); setState(() { _score=0; _round=1; _loadRound(); }); }, onExit: () { Navigator.of(context).pop(); Navigator.of(context).maybePop(); }));
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      game: widget.game, score: _score, maxScore: _max*10,
      onRestart: () => setState(() { _score=0; _round=1; _loadRound(); }),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Text('مرحله $_round از $_max — ${_story.title}: به ترتیب بچین', style: Theme.of(context).textTheme.titleMedium)),
          const SizedBox(height: 8),
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onReorder: (oldIdx, newIdx) { setState(() { if (newIdx > oldIdx) newIdx--; final item = _order.removeAt(oldIdx); _order.insert(newIdx, item); }); },
              children: _order.asMap().entries.map((entry) {
                final label = entry.value;
                final idx = entry.key;
                final step = _current.firstWhere((s) => s.label == label, orElse: () => _story.steps.firstWhere((s) => s.label == label));
                return Container(
                  key: ValueKey('${label}_${_round}_$idx'),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: widget.game.accentColor.withOpacity(.10), borderRadius: BorderRadius.circular(14), border: Border.all(color: widget.game.accentColor.withOpacity(.25))),
                  child: ListTile(
                    leading: Text(step.emoji, style: const TextStyle(fontSize: 28)),
                    title: Text(step.label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
                    trailing: const Icon(Icons.drag_handle_rounded),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: double.infinity, child: FilledButton(onPressed: _check, style: FilledButton.styleFrom(backgroundColor: widget.game.accentColor), child: const Text('بررسی'))),
          ),
        ],
      ),
    );
  }
}

class _StoryStep { const _StoryStep(this.emoji, this.label); final String emoji; final String label; }
class _StoryData { const _StoryData({required this.title, required this.steps}); final String title; final List<_StoryStep> steps; }
