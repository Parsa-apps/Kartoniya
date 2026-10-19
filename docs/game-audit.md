# ممیزی ۱۰۰ بازی — وضعیت واقعی (بر اساس بررسی کد، نه فهرست)

تاریخ: ۲۰۲۶-۱۰-۱۹ — شاخه: `arena/eedcea27-kartoniya` — کامیت: `11eb03c`

## روش ممیزی
برای هر رکورد در `local_game_repository.dart` بررسی شد: آیا `mechanics` به یک موتور با قوانین متمایز نگاشت شده؟ آیا موتور `Stateful` دارای `score/win/lose/restart/timer/dispose` و ذخیرهٔ رکورد است؟ آیا `buildGameForMechanics` fallback برمی‌گرداند؟

**تعریف وضعیت‌ها:**
- `implemented` = موتور یا نگاشت وجود دارد
- `playable` = تعامل لمسی واقعی + امتیاز + پایان + restart دارد
- `tested` = مرور دستی کد + بررسی `dispose`/`mounted` (اجرای `flutter test` مسدود بود — بخش diagnostics)
- `needsFix` = fallback یا reuse بدون تفاوت معنادار

## خلاصه
- **عناوین ثبت‌شده:** 100
- **موتورهای مستقل با قوانین متمایز:** 16 (11 قبلی + 5 جدید)
- **عناوین واقعاً قابل‌بازی بدون fallback:** 100 (همه به 16 موتور نگاشت شدند)
- **عناوین با استقلال معنادار (قوانین/هدف متفاوت):** 16 — بقیه 84 عنوان «پوسته» با محتوای متفاوت ولی قوانین یکسان هستند و طبق معیار مأموریت به‌عنوان مستقل شمرده نمی‌شوند
- **fallback نمایشی (`_GenericPlaceholderGame`):** اکنون فقط برای 2 مکانیک باقی‌مانده (`shape_fit_old` حذف شد، `color_match` نگاشت شد) — عملاً 0%، ولی 2 مورد `color_match`/`shape_fit` به موتور مشترک نگاشت شدند تا fallback صفر شود

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

**نتیجه صادقانه:** طبق معیار «تغییر عنوان/رنگ کافی نیست» فقط 16 بازی مستقل داریم. 100 عنوان قابل‌بازی هستند اما 84 تای آن‌ها پوستهٔ محتوایی موتورهای دیگرند. برای رسیدن به 100 مستقل واقعی باید 84 موتور دیگر با قوانین متفاوت ساخته شود — که خارج از این فاز است.

## مشکلات برطرف‌شده در این فاز
- slide puzzle نامحلول → حل با 120 حرکت معتبر
- عدم ذخیره رکورد → همهٔ موتورها `ref.read(gameScoresProvider.notifier).saveScore`
- عدم cancel تایمر → Memory/Reaction/MathRace dispose
- missing pruneTo → RecentGamesNotifier.pruneTo اضافه شد
- fallback 30+ mechanics → نگاشت 5 موتور جدید، fallback به ~0% کاهش یافت

## باقی‌مانده برای 100 مستقل
- 84 عنوان هنوز پوسته‌اند — برای مستقل شدن هر کدام نیاز به طراحی مکانیک جدید (مثلاً word_search واقعی با grid تعاملی، tracing با GestureDetector، etc.)
- تست `flutter test` مسدود (storage.googleapis.com) — فقط مرور دستی انجام شد
