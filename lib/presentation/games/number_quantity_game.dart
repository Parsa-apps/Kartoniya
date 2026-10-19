import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class NumberQuantityGamePage extends ConsumerStatefulWidget {
  const NumberQuantityGamePage({required this.game, super.key});
  final GameModel game;
  @override
  ConsumerState<NumberQuantityGamePage> createState() => _NumberQuantityGamePageState();
}

class _NumberQuantityGamePageState extends ConsumerState<NumberQuantityGamePage> {
  int _round=1; final int _max=6; int _score=0;
  late List<int> _numbers; // 4 numbers
  late List<List<String>> _groups; // 4 groups of emojis
  int? _selectedNumIdx;

  final _emojiPool = const ['🍎','⭐','🐶','🎈','🍓','🚀'];

  @override
  void initState() { super.initState(); _load(); }

  void _load() {
    _numbers = [2,3,5,4]..shuffle();
    // create groups with quantities matching numbers but shuffled
    final numsShuffled = [..._numbers]..shuffle();
    _groups = numsShuffled.map((n){
      final e = _emojiPool[n % _emojiPool.length];
      return List.generate(n, (_)=> e);
    }).toList();
    _selectedNumIdx = null;
  }

  void _pickNumber(int i) => setState(()=> _selectedNumIdx = i);

  void _pickGroup(int j) {
    if (_selectedNumIdx==null) return;
    final numVal = _numbers[_selectedNumIdx!];
    final groupSize = _groups[j].length;
    final correct = numVal == groupSize;
    if (correct) {
      setState((){ _score+=10; _numbers.removeAt(_selectedNumIdx!); _groups.removeAt(j); _selectedNumIdx=null; if (_numbers.isEmpty) { if (_round>=_max) _showEnd(); else { _round++; _load(); } } });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آفرین!'), backgroundColor: Colors.green, duration: Duration(milliseconds: 500)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اشتباه، دوباره سعی کن'), backgroundColor: Colors.red, duration: Duration(milliseconds: 600)));
      setState(()=> _selectedNumIdx=null);
      setState(()=> _score = (_score-2).clamp(0, 999));
    }
  }

  void _showEnd() {
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    showDialog(context: context, barrierDismissible: false, builder: (_) => GameResultDialog(title: _score>=30?'اعداد را بلدی!':'پایان', message: 'امتیاز $_score', score: _score, isWin: _score>=30, onRestart: (){ Navigator.of(context).pop(); setState((){ _score=0; _round=1; _load();});}, onExit: (){ Navigator.of(context).pop(); Navigator.of(context).maybePop();}));
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      game: widget.game, score: _score, maxScore: _max*40,
      onRestart: ()=> setState((){ _score=0; _round=1; _load();}),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Text('مرحله $_round از $_max — عدد را به تعداد وصل کن', style: Theme.of(context).textTheme.titleMedium)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: _numbers.asMap().entries.map((e)=> Expanded(child: GestureDetector(
              onTap: ()=> _pickNumber(e.key),
              child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), height: 56, decoration: BoxDecoration(color: _selectedNumIdx==e.key ? widget.game.accentColor : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: widget.game.accentColor, width: _selectedNumIdx==e.key?2:1)), child: Center(child: Text('${e.value}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _selectedNumIdx==e.key?Colors.white:widget.game.accentColor)))),
            ))).toList()),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
              itemCount: _groups.length,
              itemBuilder: (context,i){
                final g = _groups[i];
                return GestureDetector(
                  onTap: ()=> _pickGroup(i),
                  child: Container(
                    decoration: BoxDecoration(color: widget.game.accentColor.withOpacity(.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: widget.game.accentColor.withOpacity(.25))),
                    padding: const EdgeInsets.all(8),
                    child: Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: g.map((e)=> Text(e, style: const TextStyle(fontSize: 22))).toList()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
