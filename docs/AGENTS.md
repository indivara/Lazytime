# Lazytime

- Garmin Connect IQ / Monkey C watch face; target `fr57042mm` (Forerunner 570 42mm), API 6.0.2.
- Owner builds, runs, tests and commits manually. Do not build, run, or commit unless asked. Never commit or print `../developer_key`.
- `source/LazytimeApp.mc`: entry point. `source/LazytimeView.mc`: rendering and sleep handling. `manifest.xml`: target and app ID.
- Hour: 12-hour Roman numerals, `XII` at midnight/noon, silver `#929E9E` on black `#000000`.
- Quarter arcs, clockwise from 12: white `#FFFFFF`, yellow `#FBC93D`, blue `#6CC0E5`, red `#FB4F4F`. Cumulative: `:00` first filled, `:15` first two, `:30` first three, `:45` all four; remaining arcs outlined.
- Arcs have 4px black gaps and 4px inset borders. Each band is one 62-point polygon (Garmin limit: 64); do not reintroduce adjacent polygon segments, which produced dark seams. Keep borders inside their own quadrant.
- Violet `#8C66DE` seconds marker: radial line with translucent layered glow inside the arc; hidden in low-power mode. Updates are once per second awake and once per minute asleep.
- Hour font: M PLUS U Regular, SIL OFL 1.1. Original TTF, license, `IVX` glyph bitmap and resource declaration are in `resources/fonts/`. Bitmap size 130px; widest hour `VIII` must fit the center circle.
- Bitmap generator: `../Counterclock/tools/make_bitmap_font.py`, requires Pillow. Regenerate using `--size 130 --chars IVX` when changing the font.
- Monkey C local variable types are inferred; don't annotate them. Polygon points must be `[Numeric, Numeric]` pairs.
- Visual correctness needs simulator and watch checks; simulator alone can hide display artifacts. Keep the existing design and avoid unrelated features or permissions.