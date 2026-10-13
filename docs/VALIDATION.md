# Validation — v1.0.0

Executed on 2026-09-11 with **Godot 4.7.2.stable.official.ed1daf0bf**, Windows, Compatibility/OpenGL 3.3, NVIDIA RTX 5080.

## Checks actually performed

| Check | Result |
| --- | --- |
| Headless editor import | Completed, exit 0; no project script or dependency errors |
| Core suite | 29 checks, zero failures |
| Actual rendered demo suite | 18 behavior checks, zero failures; plus successful initial and populated viewport PNG captures in the screenshot run |
| Main scene launch | Normal project launch rendered and ran for 90 frames, exit 0 |
| Clean ZIP extraction | CRC and every file's SHA-256 verified; imported and ran suites independently of the working project |
| Standalone integration | Copied only the picker into a new minimal Godot project; 1,000 valid draws and correct normalized odds |
| Dependency inspection | All literal `res://` project dependencies present; no absolute computer paths in project code or configuration |
| Asset provenance | Five PNGs byte-matched against official Kenney downloads; two original CC0 license files included |
| Packaging | Explicit source allowlist; no `.godot`, `.git`, executable, credentials, or unrelated workspace files |
| Visual review | Inspected initial and populated 1440×960 viewports after integrating Kenney CC0 sprites and the tile-based room; controls, item reveal, statistics, instructions, exercise, and credits are visible without scrolling at the default size |

Core tests cover defaults, proportional scaling, interval boundaries, zero exclusion, one active entry, empty/mismatched/duplicate/blank IDs, negative/non-finite weights, extreme finite magnitudes, invalid draw inputs, null RNG, deterministic replay, reset, count conservation, and a seeded distribution sanity check.

For seed 42 and 100,000 default draws, the counts were **59,761 Coin; 25,164 Potion; 10,097 Gem; 4,978 Relic**. Each observed proportion is within one percentage point of its configured probability. This is a deterministic regression/sanity check, not proof of arbitrary statistical properties or a promise about other seeds.

The graphical suite loads the real scene and sends synthetic mouse events through Godot's GUI system for roll buttons, presets, auto-roll, and pause, plus key events for Space, R, and Enter. It also exercises weight/seed `value_changed` connections, fractional values, all-zero disabling, and restart behavior. The typed-value check assigns the LineEdit text and dispatches Enter. These are **automated engine interactions**, not a claim of manual human playtesting or OS-level keyboard typing.

## Environment warnings and untested areas

The Windows sandbox reported `Failed to read the root certificate store` during engine startup. This is an engine environment warning; this resource uses no network API. Earlier runs also lacked writable editor/user cache directories; final tests redirected process-local APPDATA/LOCALAPPDATA to the test scratch directory and used Godot's portable editor mode, resolving those cache warnings. No certificate validation was disabled.

Cross-platform behavior, other Godot versions, exported executables/web builds, screen-reader accessibility, gamepad control, and human playtesting were not verified. The CodingQuests credit link's URL was reviewed and the destination retrieved separately; the automated suite intentionally did not launch a browser.

## Reproduce

Use the three commands in the README. Optional actual screenshot capture:

```text
godot --path . --script res://tests/test_demo.gd -- --capture=/absolute/writable/path/demo.png
```

Use a Windows absolute path on Windows. Omit `--headless` when capturing. The capture run finishes with the default weights, seed 42, and 10,000 rolls.
