# Kartoniya image assets

All images in this folder are original AI-generated illustrations created for
this repository on 2026-10-18. No external image, stock pack, character, or
third-party model is included. Every file is committed with the app and loaded
as a local Flutter asset; nothing is fetched at runtime.

## Phase 5 — brand scenes and mascot

| Asset | Content | Pipeline | Runtime classification |
| --- | --- | --- | --- |
| `flak_3d.webp` | Felak, Kartoniya's cloud mascot | Original 3D-style render, isolated from its generated checkerboard backdrop, alpha-matted, then converted to WebP | Pre-rendered 3D still (not a rigged model) |
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
