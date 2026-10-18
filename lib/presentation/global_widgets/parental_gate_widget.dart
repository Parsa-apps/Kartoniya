import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/app_haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';

/// قفل والدین مبتنی بر پرسش تصادفی؛ هیچ PIN ثابت یا دادهٔ حساسی ذخیره نمی‌شود.
///
/// ضد‌دورزدن:
/// - پس از سه پاسخ نادرست، قفل برای ۳۰ ثانیه وارد حالت انتظار می‌شود
///   (تلاس آفلاین در حافظهٔ همان نشست؛ بدون هیچ ذخیره‌ای روی دستگاه).
/// - با هر پاسخ غلط، مسئلهٔ تازه‌ای ساخته می‌شود تا حدس‌زدن معنادار نباشد.
/// - دیالوگ با barrierDismissible باز نمی‌ماند و با back هم رد نمی‌شود مگر
///   دکمهٔ «انصراف».
Future<bool> showParentalGate(BuildContext context) async {
  return (await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _ParentalGateDialog(),
      )) ??
      false;
}

class _ParentalGateDialog extends StatefulWidget {
  const _ParentalGateDialog();

  @override
  State<_ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<_ParentalGateDialog>
    with SingleTickerProviderStateMixin {
  static const _maxFailedAttempts = 3;
  static const _cooldown = Duration(seconds: 30);

  final _answerController = TextEditingController();
  final _random = Random();
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  late int _first;
  late int _second;
  late int _answer;
  late String _operator;
  String? _error;
  int _failedAttempts = 0;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;
  bool _accepted = false;

  bool get _lockedOut => _cooldownSeconds > 0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -9), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -9, end: 9), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 9, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
    _newChallenge();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _answerController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _newChallenge() {
    switch (_random.nextInt(3)) {
      case 0:
        _first = _random.nextInt(14) + 6;
        _second = _random.nextInt(14) + 4;
        _answer = _first + _second;
        _operator = '+';
      case 1:
        _first = _random.nextInt(15) + 15;
        _second = _random.nextInt(_first - 3) + 2;
        _answer = _first - _second;
        _operator = '−';
      default:
        _first = _random.nextInt(7) + 3;
        _second = _random.nextInt(6) + 3;
        _answer = _first * _second;
        _operator = '×';
    }
  }

  void _submit() {
    if (_lockedOut || _accepted) return;
    final submitted = _normalizeDigits(_answerController.text.trim());
    final parsed = int.tryParse(submitted);
    if (parsed == _answer) {
      AppHaptics.light();
      setState(() => _accepted = true);
      // مکث کوتاه برای دیدن حالت موفقیت، سپس خروج.
      Timer(const Duration(milliseconds: 260), () {
        if (mounted) Navigator.of(context).pop(true);
      });
      return;
    }

    AppHaptics.heavy();
    _failedAttempts++;
    if (_failedAttempts >= _maxFailedAttempts) {
      _startCooldown();
    }
    setState(() {
      _error = submitted.isEmpty
          ? 'لطفاً پاسخ را وارد کنید.'
          : 'پاسخ درست نیست؛ یک مسئلهٔ تازه امتحان کن.';
      _answerController.clear();
      _newChallenge();
    });
    _shakeController.forward(from: 0);
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = _cooldown.inSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) {
          _failedAttempts = 0;
          _error = null;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnimation.value, 0),
        child: child,
      ),
      child: AlertDialog(
        icon: AnimatedContainer(
          duration: context.motion.dur(AppMotion.quick),
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: _accepted
                ? const LinearGradient(
                    colors: [AppColors.green, AppColors.greenDeep])
                : AppColors.sunsetGradient,
            shape: BoxShape.circle,
            boxShadow: AppTheme.glow(
              _accepted ? AppColors.green : AppColors.coral,
              opacity: .35,
            ),
          ),
          child: Icon(
            _accepted ? Icons.lock_open_rounded : Icons.family_restroom_rounded,
            color: Colors.white,
          ),
        ),
        title: Text(_accepted ? 'ورود مجاز شد' : 'ورود والدین'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_accepted) ...[
              Text(
                'برای باز کردن تنظیمات، مسئلهٔ زیر را حل کنید.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Semantics(
                label: 'مسئله ریاضی: $_first $_operator $_second',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _lockedOut
                        ? AppColors.red.withOpacity(.08)
                        : AppColors.skySoft.withOpacity(
                            Theme.of(context).brightness == Brightness.dark
                                ? .12
                                : 1,
                          ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: _lockedOut
                          ? AppColors.red.withOpacity(.4)
                          : AppColors.sky.withOpacity(.25),
                    ),
                  ),
                  child: _lockedOut
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.hourglass_top_rounded,
                                color: AppColors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'چند پاسخ نادرست؛ '
                                  '${toFaDigits('$_cooldownSeconds')} ثانیه صبر کن.',
                                  style: const TextStyle(
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          '$_first  $_operator  $_second  =  ؟',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppColors.skyDeep,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _answerController,
                autofocus: !_lockedOut,
                enabled: !_lockedOut,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹]')),
                ],
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'پاسخ',
                  errorText: _error,
                  prefixIcon: const Icon(Icons.calculate_outlined),
                ),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'آفرین! حالا می‌توانید تنظیمات را باز کنید.',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          if (!_accepted)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('انصراف'),
            ),
          FilledButton(
            onPressed: (_lockedOut || _accepted) ? null : _submit,
            child: Text(_accepted ? 'ورود' : 'تأیید'),
          ),
        ],
      ),
    );
  }
}

String _normalizeDigits(String input) {
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  final buffer = StringBuffer();
  for (final character in input.runes) {
    final value = String.fromCharCode(character);
    final persianIndex = persian.indexOf(value);
    final arabicIndex = arabic.indexOf(value);
    if (persianIndex >= 0) {
      buffer.write(persianIndex);
    } else if (arabicIndex >= 0) {
      buffer.write(arabicIndex);
    } else {
      buffer.write(value);
    }
  }
  return buffer.toString();
}
