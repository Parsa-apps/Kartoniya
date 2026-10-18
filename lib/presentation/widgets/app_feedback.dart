import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// بازخورد یکپارچهٔ عملیات (علاقه‌مندی، تنظیمات، پاک‌سازی داده…).
/// snackBar کارتونیا: شناور، تیره/روشن با آیکن رنگی.
void showKartoniyaFeedback(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_circle_rounded,
  Color iconColor = AppColors.green,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2300),
        content: Row(
          children: [
            Icon(icon, color: isDark ? iconColor : AppColors.goldLight, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

/// دیالوگ تأیید عملیات حساس والدین (پاک‌سازی داده و…).
Future<bool> confirmParentAction(
  BuildContext context, {
  required String title,
  required String body,
  String confirmLabel = 'انجام بده',
  bool destructive = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(
        destructive
            ? Icons.warning_amber_rounded
            : Icons.info_outline_rounded,
        color: destructive ? AppColors.warning : AppColors.sky,
        size: 34,
      ),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(body, textAlign: TextAlign.center),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('انصراف'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: destructive ? AppColors.error : AppColors.sky,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
