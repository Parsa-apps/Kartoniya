import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/game_model.dart';
import 'game_scaffold.dart';

class ShadowMatchGamePage extends StatefulWidget {
  const ShadowMatchGamePage({required this.game, super.key});
  final GameModel game;

  @override
  State<ShadowMatchGamePage> createState() => _ShadowMatchGamePageState();
}

class _ShadowMatchGamePageState extends State<ShadowMatchGamePage> {
  late List<String> _items;
  late List<String> _shadows;
  int _score = 0;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    final pools = {
      'shadow_animals': ['🐶', '🐱', '🦁', '🐰'],
      'shadow_fruits': ['🍎', '🍌', '🍇', '🍊'],
      'shadow_vehicles': ['🚗', '✈️', '🚀', '🚁'],
    };
    final list = pools[widget.game.id] ?? ['⭐', '❤️', '🌈', '🎈'];
    _items = List.from(list)..shuffle(math.Random());
    _shadows = List.from(list)..shuffle(math.Random());
    _score = 0;
    _selected = null;
  }

  void _pickItem(int i) => setState(() => _selected = i);

  void _dropShadow(int j) {
    if (_selected == null) return;
    final correct = _items[_selected!] == _shadows[j];
    if (correct) {
      setState(() {
        _score += 10;
        _items.removeAt(_selected!);
        _shadows.removeAt(j);
        _selected = null;
        if (_items.isEmpty) _showWin();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اشتباه بود، دوباره امتحان کن!'), duration: Duration(milliseconds: 600)),
      );
      setState(() => _selected = null);
    }
  }

  void _showWin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameResultDialog(
        title: 'آفرین!',
        message: 'همهٔ سایه‌ها را درست جفت کردی.',
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
      onRestart: () => setState(_init),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('یک آیتم را انتخاب کن، سپس سایه‌اش را بزن',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _items.asMap().entries.map((e) {
                final sel = _selected == e.key;
                return GestureDetector(
                  onTap: () => _pickItem(e.key),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: sel ? widget.game.accentColor : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: widget.game.accentColor, width: sel ? 3 : 1),
                    ),
                    child: Center(child: Text(e.value, style: const TextStyle(fontSize: 32))),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          Text('سایه‌ها', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _shadows.asMap().entries.map((e) {
              return GestureDetector(
                onTap: () => _dropShadow(e.key),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Center(
                    child: Text(e.value, style: TextStyle(fontSize: 32, color: Colors.black.withOpacity(.45))),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
