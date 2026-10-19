import 'package:flutter/material.dart';

import '../../data/models/game_model.dart';
import 'game_scaffold.dart';

class ColoringGamePage extends StatefulWidget {
  const ColoringGamePage({required this.game, super.key});
  final GameModel game;

  @override
  State<ColoringGamePage> createState() => _ColoringGamePageState();
}

class _ColoringGamePageState extends State<ColoringGamePage> {
  final List<Color> _palette = const [
    Color(0xFFFF5D6C),
    Color(0xFFFFC53D),
    Color(0xFF53B86A),
    Color(0xFF2E9BEB),
    Color(0xFF8F7AED),
    Color(0xFFFF8A50),
    Color(0xFF1B2436),
    Color(0xFFFFFFFF),
  ];
  late List<Color?> _cells;
  late Color _selected;
  int _filled = 0;

  @override
  void initState() {
    super.initState();
    _cells = List.filled(16, null);
    _selected = _palette.first;
  }

  void _fill(int index) {
    setState(() {
      if (_cells[index] == null) _filled++;
      _cells[index] = _selected;
      if (_filled == _cells.length) _showDone();
    });
  }

  void _showDone() {
    showDialog(
      context: context,
      builder: (_) => GameResultDialog(
        title: 'آفرین هنرمند!',
        message: 'نقاشی‌ات تکمیل شد.',
        score: 50,
        isWin: true,
        onRestart: () {
          Navigator.of(context).pop();
          setState(() {
            _cells = List.filled(16, null);
            _filled = 0;
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
      score: _filled,
      maxScore: 16,
      onRestart: () => setState(() {
        _cells = List.filled(16, null);
        _filled = 0;
      }),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: _palette
                  .map((c) => GestureDetector(
                        onTap: () => setState(() => _selected = c),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selected == c ? Colors.black : Colors.black12,
                              width: _selected == c ? 3 : 1,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => _fill(i),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _cells[i] ?? Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: _cells[i] == null
                            ? const Icon(Icons.brush_rounded, size: 16, color: Colors.black26)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('رنگ را انتخاب کن و خانه‌ها را پر کن',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
