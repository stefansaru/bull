# Icon set — image-generation prompt

Owner rulings (2026-10-26):
- **Style:** flat glyph.
- **Colour:** a single colour, black on white. The app tints the icons, so they follow light/dark and the colour-vision modes.
- **Scope:** the pictorial symbols of glossary Table 1, the chapter markers, and left/right arrows.
- **Gum states:** drawn in the philatelic convention (`(*)`, `*`, `**`), not the book's ✳ ✾ ✼ marks.
- **Typographic marks stay text:** ” § ~ ? £.

## The grid (40 icons, 8 columns × 5 rows)

| # | Row 1 | # | Row 2 | # | Row 3 | # | Row 4 | # | Row 5 |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Aurochs 🐃 | 9 | Unused, no gum `(*)` ✳ | 17 | Calendar date 📅 | 25 | Up ⬆ | 33 | Envelope ✉ |
| 2 | Bison / wisent 🦬 | 10 | Unused, partial gum ✾ | 18 | Place (globe) 🌍 | 26 | Down ⬇ | 34 | Newspaper 📰 |
| 3 | Ox (post-captain seals) 🐂 | 11 | Unused, hinged `*` ✼ | 19 | Map (compass) 🧭 | 27 | Left | 35 | Catalogue 📖 |
| 4 | Bird of prey 🦅 | 12 | Mint, never hinged `**` ✼✼ | 20 | Currency (coin) 💰 | 28 | Right | 36 | Certificate 📜 |
| 5 | Lily / fleur-de-lis 🌸 | 13 | Hinge | 21 | Colour (palette) 🎨 | 29 | Reference ⏭ | 37 | Signature ✍ |
| 6 | Star ⭐ | 14 | Cancellation ⨀ | 22 | Paper 🧻 | 30 | Enlarged image 🔍 | 38 | Quill (seals before the stamp) 🖋 |
| 7 | Crescent moon 🌙 | 15 | Fragment △ | 23 | Diameter ∅ | 31 | Warning / caveat ⚠ | 39 | Sanitary seal (quarantine) 🩺 |
| 8 | Postal horn 📯 | 16 | Cutout ✂ | 24 | Replica 🆁 | 32 | Open question ⚑ | 40 | Six-pointed postmark star ✶ |

## Prompt — the whole grid

> A professional icon set: 40 flat glyph icons arranged in a precise grid of 8 columns and 5 rows, every icon centred in an identical square cell with generous equal spacing, on a plain pure-white background. Every icon is solid black, one single colour, flat filled shapes with no gradients, no shading, no outlines of a different weight, no texture, no 3D, no drop shadows. Consistent visual weight, consistent corner rounding, consistent stroke thickness wherever a line is needed, designed on a 24×24 pixel grid with 2-pixel padding so each icon stays legible at 16 pixels. Style comparable to Google Material Symbols (filled): simple, geometric, instantly recognisable silhouettes. The theme is 19th-century philately (the first stamps of Moldavia, 1858) and the history of the aurochs. No text, no letters, no numbers, no labels anywhere in the image, except where an icon below explicitly calls for a glyph.
>
> Row 1, left to right:
> 1. Aurochs head seen from the front, with long horns curving forward and upward like a lyre.
> 2. European bison (wisent) in side profile, with a high shoulder hump, a short beard and short curved horns.
> 3. Domestic ox head from the front, with short horns and a broad muzzle.
> 4. An eagle with spread wings, seen from the front, in a heraldic pose.
> 5. A heraldic fleur-de-lis (lily).
> 6. A five-pointed star.
> 7. A crescent moon.
> 8. A coiled post horn with a mouthpiece and a flared bell, in the classic postal emblem shape.
>
> Row 2, left to right (postage-stamp condition marks):
> 9. A postage stamp with perforated edges and a single asterisk in round brackets inside it, `(*)`.
> 10. The same perforated stamp containing one asterisk whose lower half is outlined and upper half is solid.
> 11. The same perforated stamp containing one solid asterisk `*`.
> 12. The same perforated stamp containing two solid asterisks side by side `**`.
> 13. A stamp hinge: a small rectangular strip of paper folded in half, with a visible fold line.
> 14. A cancellation postmark: a circle with a solid dot in its centre, with two short wavy lines beside it.
> 15. A fragment: a perforated stamp on an irregular torn piece of paper.
> 16. Scissors cutting along a dashed line.
>
> Row 3, left to right:
> 17. A tear-off calendar page with two rings at the top.
> 18. A globe showing Europe and Africa.
> 19. A compass rose with a pointed north needle.
> 20. A single coin seen at a slight angle, with a milled edge.
> 21. A painter's palette with a thumb hole and three paint dabs.
> 22. A sheet of paper with one corner curled.
> 23. The diameter symbol: a circle crossed by a diagonal line from the lower left to the upper right.
> 24. A perforated postage stamp with the capital letter R inside a small square in its centre (replica).
>
> Row 4, left to right:
> 25. A bold arrow pointing up.
> 26. A bold arrow pointing down.
> 27. A bold arrow pointing left.
> 28. A bold arrow pointing right.
> 29. The skip-to-next symbol, a right-pointing double triangle with a vertical bar (used here as a cross-reference).
> 30. A magnifying glass with a small plus sign inside the lens.
> 31. A warning triangle with an exclamation mark.
> 32. A small flag on a pole.
>
> Row 5, left to right:
> 33. A closed envelope seen from the back, with its flap.
> 34. A folded newspaper.
> 35. An open book.
> 36. A rolled certificate scroll with a round wax seal and a ribbon.
> 37. A hand holding a pen, writing a signature line.
> 38. A quill feather pen with an ink drop.
> 39. A round wax sanitary seal with a small cross in the middle.
> 40. A six-pointed star.
>
> All 40 icons must look like one family drawn by the same designer: the same line weight, the same level of detail, the same proportions within their cells. Output a square, high-resolution image, 4096×2560 or the closest available.

## If the generator struggles with 40 at once

Most image generators lose consistency past about 12 items. Generate the grid **one row at a time**: 8 icons in 1 row (or 4 × 2).
1. Paste the style paragraph (the first paragraph above) unchanged.
2. Add that row's numbered items.
3. Attach the first good row as a style reference image for the later rows.

## Next steps after generation

1. Cut the grid into separate icons.
2. Vectorise each icon to SVG (trace, then clean up by hand).
3. Check each icon at 16, 24 and 48 dp, in both light and dark themes.
4. Bundle them in the app as SVGs, or as an icon font, under `assets/icons/`, mapped to the glossary symbols. The bundle step then replaces the emoji markers in headings with the icons, keeping the emoji as the accessible text.
