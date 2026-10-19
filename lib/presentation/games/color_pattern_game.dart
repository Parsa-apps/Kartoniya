import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class ColorPatternGamePage extends ConsumerStatefulWidget {
  const ColorPatternGamePage({required this.game, super.key});
  final GameModel game;
  @override
  ConsumerState<ColorPatternGamePage> createState() => _ColorPatternGamePageState();
}

class _ColorPatternGamePageState extends ConsumerState<ColorPatternGamePage> {
  int _round=1; final int _max=5; int _score=0;
  late List<Color> _target; late List<Color?> _answer;
  final _palette = const [Color(0xFFFF5D6C), Color(0xFF2E9BEB), Color(0xFF53B86A), Color(0xFFFFC53D)];
  // patterns: each is correct sequence length 6 with 3 blanks
  static final _patterns = [
    [0,1,0,1,0,1], // red blue alternation
    [0,0,1,1,0,0],
    [0,1,2,0,1,2],
    [1,2,1,2,1,2],
    [0,2,0,2,0,2],
  ];

  @override
  void initState() { super.initState(); _load(); }

  void _load() {
    final pat = _patterns[(_round-1)%_patterns.length];
    _target = pat.map((i)=> _palette[i]).toList();
    _answer = List.filled(6, null);
    // prefill first 3 as clue
    for (var i=0;i<3;i++) _answer[i]=_target[i];
  }

  void _tapPalette(Color c) {
    final idx = _answer.indexWhere((e)=> e==null);
    if (idx==-1) return;
    setState(()=> _answer[idx]=c);
  }

  void _clear(int i) { if (i>=3) setState(()=> _answer[i]=null); }

  void _check() {
    if (_answer.any((e)=> e==null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('همه خانه‌ها را پر کن'), duration: Duration(milliseconds: 600)));
      return;
    }
    bool ok = true;
    for (var i=0;i<6;i++) if (_answer[i]!=_target[i]) ok=false;
    if (ok) _score+=10;
    if (_round >= _max) { _showEnd(); return; }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok?'درست!':'نادرست! پاسخ صحیح را ببین'), backgroundColor: ok?Colors.green:Colors.red, duration: const Duration(milliseconds: 600)));
    setState((){ _round++; _load(); });
  }

  void _showEnd() {
    if (!mounted) return;
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    showDialog(context: context, barrierDismissible: false, builder: (_)=> GameResultDialog(title: _score>=30?'الگوساز!':'پایان', message: 'امتیاز $_score از ${_max*10}', score: _score, isWin: _score>=30, onRestart: (){ Navigator.of(context).pop(); setState((){ _score=0; _round=1; _load();});}, onExit: (){ Navigator.of(context).pop(); Navigator.of(context).maybePop();}));
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      game: widget.game, score: _score, maxScore: _max*10,
      onRestart: ()=> setState((){ _score=0; _round=1; _load();}),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Text('مرحله $_round از $_max — الگو را کامل کن', style: Theme.of(context).textTheme.titleMedium)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: List.generate(6, (i){
              final isClue = i<3;
              return Expanded(child: GestureDetector(
                onTap: ()=> _clear(i),
                child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), height: 52, decoration: BoxDecoration(color: _answer[i] ?? (isClue? Colors.grey.withOpacity(.15): Colors.white), borderRadius: BorderRadius.circular(12), border: Border.all(color: isClue? Colors.black26 : widget.game.accentColor.withOpacity(.25))),
                  child: _answer[i]!=null ? null : Center(child: Text(isClue? '🔒':'?', style: TextStyle(color: Colors.black26))),
                ),
              ));
            })),
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: _palette.map((c)=> GestureDetector(onTap: ()=> setState(()=> _tapPalette(c)), child: Container(width: 56, height: 56, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)])))).toList()),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: double.infinity, child: FilledButton(onPressed: _check, style: FilledButton.styleFrom(backgroundColor: widget.game.accentColor), child: const Text('بررسی')))),
          const Spacer(),
        ],
      ),
    );
  }
}
