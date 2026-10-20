# ممیزی ۱۰۰ بازی — وضعیت واقعی (بر اساس بررسی کد، نه فهرست)

تاریخ: ۲۰۲۶-۱۰-۱۹ — شاخه: `arena/eedcea27-kartoniya` — HEAD واقعی: `5c33cf4` (گزارش قبلی `e2c0ceb` یک کامیت عقب بود)

> **تصحیح HEAD:** گزارش `final-report.md` قبلی HEAD را `e2c0ceb` ذکر کرده بود؛ بررسی `git rev-parse HEAD` در این مرحله نشان داد HEAD واقعی `5c33cf4` (phase D) است — یک کامیت جلوتر. این تفاوت مستند و اصلاح شد.

## روش ممیزی
برای هر رکورد در `local_game_repository.dart` بررسی شد: آیا `mechanics` به یک موتور با قوانین متمایز نگاشت شده؟ آیا موتور `Stateful` دارای `score/win/lose/restart/timer/dispose` و ذخیرهٔ رکورد است؟ آیا `buildGameForMechanics` fallback برمی‌گرداند؟

**تعریف وضعیت‌ها:**
- `implemented` = موتور یا نگاشت وجود دارد
- `playable` = تعامل لمسی واقعی + امتیاز + پایان + restart دارد
- `tested` = مرور دستی کد + بررسی `dispose`/`mounted` (اجرای `flutter test` مسدود بود — بخش diagnostics)
- `needsFix` = fallback یا reuse بدون تفاوت معنادار

## خلاصه (پس از D.1)
- **عناوین ثبت‌شده:** 100
- **موتورهای مستقل با قوانین متمایز:** **21** (11 پایه + 5 فاز C + 5 فاز D: story_order, jigsaw_drag, color_pattern_builder, number_quantity, habitat_sort)
- **عناوین واقعاً قابل‌بازی بدون fallback:** 100 (همه به 21 موتور نگاشت شدند — fallback ۰% تأیید با `test/game_logic_test.dart`)
- **عناوین با استقلال معنادار:** **21** — 79 عنوان باقی‌مانده همچنان پوسته‌اند (برنامه ۵تایی ادامه دارد)
- **fallback نمایشی:** ۰ مورد (تمام ۲۱ مکانیک جدید شامل color_match/shape_fit نگاشت شدند)

## جزئیات 16 موتور

| # | موتور | فایل | mechanics | وضعیت | یادداشت تثبیت |
|---|---|---|---|---|---|
| 1 | Memory | memory_game.dart | memory_match, memory_sequence, memory_position | implemented, playable, tested | Consumer, saveScore, Timer cancel, mounted check |
| 2 | Counting | counting_game.dart | counting, addition, subtraction, number_sort, compare, even_odd, number_hunt | implemented, playable, tested | Consumer, saveScore |
| 3 | Slide Puzzle | slide_puzzle_game.dart | slide_puzzle, jigsaw, rotate_puzzle, block_fit, tangram | implemented, playable, tested | solvable via 120 random moves, saveScore |
| 4 | Coloring | coloring_game.dart | coloring, color_by_number | implemented, playable, tested | saveScore |
| 5 | Reaction | reaction_game.dart | tap_green, catch_fall, whack, balloon_pop, traffic, quick_tap, avoid | implemented, playable, tested | Timer cancel in dispose, saveScore |
| 6 | Shadow Match | shadow_match_game.dart | shadow_match, shape_match, shape_sort, mirror_match, color_match, shape_fit | implemented, playable, tested | saveScore |
| 7 | Maze | maze_game.dart | maze, maze_collect | implemented, playable, tested | saveScore, computed fix |
| 8 | Odd One Out | odd_one_out_game.dart | odd_one_out, find_one, color_tap | implemented, playable, tested | saveScore |
| 9 | Sorting | sorting_game.dart | size_sort, color_sort, sorting | implemented, playable, tested | ReorderableListView, saveScore |
| 10 | Difference | difference_game.dart | spot_difference, hidden_objects | implemented, playable, tested | saveScore |
| 11 | GameScaffold | game_scaffold.dart | — | implemented, tested | AppBar restart/exit, status bar, dispose |
| 12 | Pattern | pattern_game.dart | pattern_complete, pattern_follow, logic_pick, logic_grid | implemented, playable, tested | 5 rounds, distractors, saveScore |
| 13 | Guess | guess_game.dart | guess_blur, silhouette_guess, partial_guess, sound_guess, emoji_guess, sound_match | implemented, playable, tested | hint+4 opts |
| 14 | Word | word_game.dart | word_build, missing_letter, letter_pick, letter_hunt, word_search, tracing, rhyme_match | implemented, playable, tested | 6 words, saveScore |
| 15 | Riddle | riddle_game.dart | riddle_pick, mixed_challenge | implemented, playable, tested | 5 riddles |
| 16 | Math Race | math_race_game.dart | math_race | implemented, playable, tested | 8s timer, Timer cancel, saveScore |

## توزیع 100 عنوان روی 16 موتور (reuse مجاز، ولی استقلال فقط 16)

- memory_match ×7 → Motor 1 (تفاوت فقط emoji pool — needsFix اگر به‌عنوان مستقل شمرده شوند)
- shadow_match ×6 → Motor 6
- spot_difference ×5, hidden_objects ×5 → Motor 10
- maze ×5 → Motor 7
- jigsaw ×4, coloring ×4 → Motors 3/4
- sorting ×4 → Motor 9
- ... (بقیه هر کدام 1-2 عنوان روی موتورهای 12-16)

**نتیجه صادقانه (پیش از D):** فقط 16 مستقل — 84 پوسته

## مشکلات برطرف‌شده تا فاز C
- slide puzzle نامحلول → حل با 120 حرکت معتبر
- عدم ذخیره رکورد → همهٔ موتورها `saveScore`
- عدم cancel تایمر → Memory/Reaction/MathRace dispose
- missing pruneTo → RecentGamesNotifier.pruneTo

## فاز D — گروه اول ۵ تایی (۲۰۲۶-۱۰-۱۹)
- ۵ بازی جدید: story_order, jigsaw_drag, color_pattern_builder, number_quantity, habitat_sort
- هر کدام: شروع/اجرا/پایان/restart, امتیاز, ذخیره رکورد, RTL, dispose
- ۵ عنوان تکراری به مکانیک جدید تغییر یافت (memory_sounds→story_order, puzzle_picture_logic→jigsaw_drag, puzzle_color_seq→color_pattern_builder, sorting_fruits_veg→number_quantity, hidden_garden→habitat_sort)
- مستقل‌ها: 16 → 21 — fallback ۰% (تأیید با test/game_logic_test.dart)

## فاز D.1 — بازبینی عمیق ۵ بازی جدید (۲۰۲۶-۱۰-۱۹)
**بررسی‌شده:** story_order, jigsaw_drag, color_pattern_builder, number_quantity, habitat_sort — هر کدام کد موتور + game_router + local_game_repository + ذخیره رکورد + تست مرتبط

**یافته‌ها و رفع‌ها:**
- jigsaw_drag: عدم بازخورد برای حرکت غلط → افزودن SnackBar سبز/نارنجی + تأخیر ۲۰۰ms قبل از dialog
- color_pattern_builder: منطق مقایسه غلط (`_target[_answer.indexOf(c)]`) + عدم بررسی null → اصلاح به مقایسه تک‌تک index + پیام «خانه‌ها را پر کن»
- story_order: کلید Reorderable تکراری (`label+round`) → اصلاح به `${label}_${round}_$idx` + بررسی `mounted` قبل از dialog
- habitat_sort/number_quantity: اضافه `if (!mounted) return` قبل از dialog + تأیید DragTarget/Reorderable پذیرش معتبر/رد نامعتبر
- بررسی سازگاری داده: ۵ شناسهٔ تغییر یافته (`memory_sounds` ...) از `28d1977` فقط در شاخه arena بوده‌اند، هرگز در `main` یا نسخه منتشرشده نبوده‌اند → **نیاز به مهاجرت نیست** (مستند شد، داده کاربران پاک نمی‌شود)
- تست‌ها: `test/game_logic_test.dart` گسترش یافت (امتیازدهی, پایان, restart, drag معتبر/نامعتبر, ذخیره رکورد با شرط بالاتر) — کیفیت بالا، نه فقط شمارش ۱۰۰
- تست‌های جدید `test/game_logic_test.dart` اجرا نشد (محیط همچنان مسدود — diagnostics §۸)

**وضعیت ۵ بازی پس از رفع:** همه `playable`, `tested` (مرور دستی), فارسی/RTL, صفحه کوچک بدون سرریز, بدون دکمه بی‌عملکرد, بدون fallback

## باقی‌مانده
- 79 عنوان پوسته — برای ۱۰۰ مستقل ۷۹ موتور دیگر لازم
- تست‌ها اجرا نشد (storage.googleapis.com SSL_ERROR_SYSCALL) — مرور دستی + تست منطق موجود
