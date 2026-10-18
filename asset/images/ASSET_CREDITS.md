# Kartoniya image assets

All images in this folder are original AI-generated illustrations created for
this repository on 2026-10-18. No external image, stock pack, character, or
third-party model is included. Every file is committed with the app and loaded
as a local Flutter asset; nothing is fetched at runtime.

## Phase 5 — brand scenes and mascot

| Asset | Content | Pipeline | Runtime classification |
| --- | --- | --- | --- |
| `flak_3d.webp` | Felak, Kartoniya's cloud mascot | Original 3D-style render. Phase 6 re-matte: the generated grey checkerboard was flood-filled out, the silhouette was closed with a 5 px dilate/erode pass so no checkerboard bites the scarf or hands, and the alpha edge was softened 0.6 px before WebP encoding (alpha quality 100). | Pre-rendered 3D still (not a rigged model) |
| `flak_reading_scene.webp` | Felak reading a picture book | Original 3D-style scene rendered with the mascot as an identity reference, resized and compressed to WebP | Pre-rendered 3D still (alternate scene/pose) |
| `cloudworld_hero.webp` | Floating sky-island environment | Original 3D-style storybook diorama render, resized and compressed to WebP | Pre-rendered 3D still |
| `storybook_garden.webp` | Storybook garden environment | Original 3D-style felt-and-clay diorama render, resized and compressed to WebP | Pre-rendered 3D still |
| `twilight_library.webp` | Moonlit floating story library | Original 3D-style night diorama render, resized and compressed to WebP | Pre-rendered 3D still |

## Phase 6 — splash and catalogue posters

The nine Phase 6 images share one art direction: soft clay/felt diorama lighting,
pastel sky-blue, cream, coral, teal, violet and gold, no baked-in text, and a
centred 4:3 composition for posters. They were generated from the Phase 5
mascot and scene images as identity references, then center-cropped with
ImageMagick, resized and compressed to WebP.

| Asset | Used by | Content | Runtime classification |
| --- | --- | --- | --- |
| `cloud_night_splash.webp` | `SplashPage` background | Felak flying through a moonlit cloud world with hanging stars | Pre-rendered 3D still (splash backdrop) |
| `posters/oscar.webp` | «ماجراهای اسکار» | Coral lizard hero in a cloud garden | Pre-rendered 3D still (poster) |
| `posters/alphabet.webp` | «الفبای جادویی» | Letter blocks and a smiling sun | Pre-rendered 3D still (poster) |
| `posters/counting.webp` | «شمارش شاد» | Number friends on a pastel hill | Pre-rendered 3D still (poster) |
| `posters/bedtime.webp` | «قصه‌های شب» | Cozy moonlit bedroom with a storybook | Pre-rendered 3D still (poster) |
| `posters/cooking.webp` | «آشپزخانهٔ کوچک» | Child-sized kitchen with a cake and fruit | Pre-rendered 3D still (poster) |
| `posters/animals.webp` | «دوستان حیوانات» | Farm and jungle animals together | Pre-rendered 3D still (poster) |
| `posters/science.webp` | «آزمایشگاه کوچک» | Bubbling flasks and a friendly robot arm | Pre-rendered 3D still (poster) |
| `posters/music.webp` | «آهنگ جنگل» | Forest music band with glowing notes | Pre-rendered 3D still (poster) |

Posters are 1080×810 WebP at quality 80 (35–86 KiB each, ~500 KiB total) and are
decoded with `cacheWidth` capped at the logical size × device pixel ratio so
large screens do not allocate full-resolution bitmaps. `cloud_night_splash.webp`
is 900×1611 at quality 82 (87 KiB). `test/brand_visual_assets_test.dart` enforces
these budgets and checks that every catalogue entry resolves to a bundled file.

## Honesty notes

There is no GLB/GLTF mesh, skeleton, runtime 3D renderer, external asset
download, or live 3D camera. All "3D" imagery above is pre-rendered; the vector
`KartoniyaMascot` used for empty/error states is a hand-drawn 2D fallback that
imitates the same character design. A transparent matte is used only for the
isolated mascot; all scene, splash and poster images are opaque.

## فندوقی — شخصیت اصلی (فاز ۶)

- **تصویر مرجع:** توسط مالک پروژه (Parsa Apps) ارائه شده است؛ پس‌زمینه در
  همان پروژه حذف و لبهٔ آلفا تمیز شده است.
- **لایه‌های ریگ‌شده** (`asset/images/fandaq/`): بدن، دست راست (سلام)، دست
  چپ، دو پا، برگ، دو حالت چشم (بسته/درشت) و دهان خندان. این لایه‌ها با
  برش ماسک روی همان تصویر ساخته شده‌اند تا در Flutter واقعاً حرکت کنند.
- **حالت‌های چهره** با ویرایش هوش مصنوعی روی همان شخصیت ساخته و سپس فقط
  ناحیهٔ چشم/دهان آن‌ها روی بدن اصلی جای‌گذاری شده است.
- **صحنه‌های تازه:** `fandaq_splash_night.webp` (پس‌زمینهٔ بدون شخصیت برای
  اسپلش)، `fandaq_scene_reading.webp` و `fandaq_scene_night.webp`؛ هر سه با
  همان زبان بصری نمدی/خمیری ساخته شده‌اند.
- **ادعای سه‌بعدی:** این‌ها رندرهای از پیش ساخته‌شده‌اند (نه مدل زنده). حرکت
  دست/پا/برگ/چشم در Flutter با تبدیل لایه‌ها انجام می‌شود.
