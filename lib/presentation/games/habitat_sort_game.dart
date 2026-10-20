// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import 'game_scaffold.dart';

class HabitatSortGamePage extends ConsumerStatefulWidget {
  const HabitatSortGamePage({required this.game, super.key});
  final GameModel game;
  @override
  ConsumerState<HabitatSortGamePage> createState() => _HabitatSortGamePageState();
}

class _HabitatSortGamePageState extends ConsumerState<HabitatSortGamePage> {
  late List<_Animal> _animals;
  int _score=0;
  final _habitats = const [
    ('جنگل','🌲', Color(0xFF53B86A)),
    ('دریا','🌊', Color(0xFF2E9BEB)),
    ('مزرعه','🌾', Color(0xFFFFC53D)),
  ];
  static const _all = [
    _Animal('🦁','شیر','جنگل'),
    _Animal('🐻','خرس','جنگل'),
    _Animal('🐠','ماهی','دریا'),
    _Animal('🐙','هشت‌پا','دریا'),
    _Animal('🐄','گاو','مزرعه'),
    _Animal('🐓','مرغ','مزرعه'),
    _Animal('🐯','ببر','جنگل'),
    _Animal('🐬','دلفین','دریا'),
    _Animal('🐑','گوسفند','مزرعه'),
  ];

  @override
  void initState() { super.initState(); _init(); }

  void _init() {
    _animals = [..._all]..shuffle(); _animals = _animals.take(6).toList(); _score=0;
  }

  void _onAccept(String habitat, _Animal a) {
    final correct = a.habitat == habitat;
    if (correct) {
      setState((){ _animals.remove(a); _score+=10; if (_animals.isEmpty) _showEnd(); });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('درست!'), backgroundColor: Colors.green, duration: Duration(milliseconds: 500)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${a.label} در $habitat نیست!'), backgroundColor: Colors.red, duration: const Duration(milliseconds: 600)));
      setState(()=> _score = (_score-2).clamp(0, 999));
    }
  }

  void _showEnd() {
    if (!mounted) return;
    ref.read(gameScoresProvider.notifier).saveScore(widget.game.id, _score);
    showDialog(context: context, barrierDismissible: false, builder: (_) => GameResultDialog(title: 'آفرین مربی!', message: 'هر 6 حیوان را به خانه بردی', score: _score, isWin: true, onRestart: (){ Navigator.of(context).pop(); setState(_init);}, onExit: (){ Navigator.of(context).pop(); Navigator.of(context).maybePop();}));
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      game: widget.game, score: _score, maxScore: 60,
      onRestart: ()=> setState(_init),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Text('حیوان را به خانه‌اش بکش', style: Theme.of(context).textTheme.titleMedium)),
          Expanded(
            child: Row(
              children: _habitats.map((h){
                final name = h.$1; final emoji = h.$2; final col = h.$3;
                return Expanded(child: DragTarget<_Animal>(
                  onAccept: (a)=> _onAccept(name, a),
                  builder: (context,cand,rej){
                    final over = cand.isNotEmpty;
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: over ? col.withOpacity(.25) : col.withOpacity(.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: col.withOpacity(.4), width: over?2:1)),
                      child: Column(children: [
                        const SizedBox(height: 8),
                        Text(emoji, style: const TextStyle(fontSize: 28)),
                        Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                        const Divider(),
                        Expanded(child: Center(child: Text('بکش اینجا', style: TextStyle(color: Colors.black38, fontSize: 10)))),
                      ]),
                    );
                  },
                ));
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Wrap(
              spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
              children: _animals.map((a)=> Draggable<_Animal>(
                data: a,
                feedback: Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black26)]), child: Center(child: Text(a.emoji, style: const TextStyle(fontSize: 30)))),
                childWhenDragging: Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.grey.withOpacity(.2), borderRadius: BorderRadius.circular(12))),
                child: Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)), child: Center(child: Text(a.emoji, style: const TextStyle(fontSize: 30)))),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Animal { const _Animal(this.emoji, this.label, this.habitat); final String emoji; final String label; final String habitat; }
