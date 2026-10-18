# Kartoniya Phase 5 image assets

Created for this repository on 2026-10-18. These are original AI-generated
illustrations made specifically for Kartoniya; no external image, stock pack,
character, or third-party model is included.

| Asset | Content | Pipeline | Runtime classification |
| --- | --- | --- | --- |
| `flak_3d.webp` | Felak, Kartoniya's cloud mascot | Original 3D-style render, isolated from its generated checkerboard backdrop, alpha-matted, then converted to WebP | Pre-rendered 3D still (not a rigged model) |
| `flak_reading_scene.webp` | Felak reading a picture book | Original 3D-style scene rendered with the mascot as an identity reference, resized and compressed to WebP | Pre-rendered 3D still (alternate scene/pose) |
| `cloudworld_hero.webp` | Floating sky-island environment | Original 3D-style storybook diorama render, resized and compressed to WebP | Pre-rendered 3D still |
| `storybook_garden.webp` | Storybook garden environment | Original 3D-style felt-and-clay diorama render, resized and compressed to WebP | Pre-rendered 3D still |
| `twilight_library.webp` | Moonlit floating story library | Original 3D-style night diorama render, resized and compressed to WebP | Pre-rendered 3D still |

The images are shipped at mobile-appropriate dimensions and are loaded as local
Flutter assets. A transparent matte is used only for the isolated mascot; the reading scene and
the three environment illustrations are opaque images. There is no GLB/GLTF mesh,
skeleton, runtime 3D renderer, external asset download, or live 3D camera.
