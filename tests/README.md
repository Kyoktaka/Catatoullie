# Game model checks

From the project folder in PowerShell:

```powershell
.\test-model.ps1
```

The script uses Processing 4's bundled JDK when available, then `JAVA_HOME`, then `javac` and `java` on `PATH`. To choose a JDK explicitly:

```powershell
.\test-model.ps1 -JavaHome 'C:\path\to\jdk-17'
```

Compilation writes only to `tmp/model-tests`. The tests run without opening the game and do not change saved progress.

The model checks cover all 50 required ingredients in Level 1's five recipes, sequential mission unlocking, LIFO pickup, ordered collection from both pile and staging, rejection of duplicate and stale items, two-minute timeouts, preparation time, retries, star ratings, replay progress, and save-mask restoration. Wardrobe checks cover successful-clear rewards, unique unlocks, replay protection, and restored ownership. `CookingModelTest` additionally completes all five cooking recipes and checks real FIFO queue order, invalid actions, dependencies, gestures, heating, reset, pause, timeout, retry, and unlock persistence.

For full sketch compilation, event-handler checks and offscreen screenshots:

```powershell
.\test-sketch.ps1
```

This requires Processing 4 and its Video library. Use `-ProcessingHome` and `-VideoLibrary` for custom installation locations. Compiled files go into a new `tmp/sketch-check-*` folder and screenshots go into `tmp/qa`. The smoke-test sketch redirects persistence to `tmp/qa/test-save.json` and checks both new saves and older version-2 saves without modifying player progress. These checks do not automate a desktop window or verify audible playback.

The sketch checks also cover all seven language selectors, dynamic translated feedback, ingredient/button assets, missing-video English fallback, proportional VFX counts, reward screens, free placement coordinates, and front-only visibility of every accessory. Fit screenshots cover every hat and accessory. Language screenshots cover menus, options, wardrobe, and the longest recipe papers.

For manual interface verification, run `Catatoullie.pde` in Processing and check these interactions:

- Drag the menu cat and customization preview left and right. Rotation should blend smoothly and settle on a complete view when released, without rotation buttons.
- Try every coat, hat and accessory. Hats follow the selected view; headphones, tag collars and eyewear appear only from the front.
- Open both papers before searching. Check that both headings and the longest recipe fit below the paper's top edge.
- Drag either paw by its hand. Its base should stay fixed as the forearm stretches; clicking the forearm alone should not start a drag.
- Grab only the top object of the overlapping pile. Collect the next unchecked FIND item in order; set later ingredients aside and retrieve them when they become next. Junk goes to either interior side of the can. Wrong bag drops should retain the object for another try.
- Pause or open help while holding an item, then resume and finish the drop. The timer should stop during either overlay.
- Finish a can, retry after timeout, and proceed through all five cans. NEXT LEVEL on the final victory screen starts the ending video and opens Level 2.
- Set VFX to 0%, 50%, and 100%; check ambient motes, pickup particles, hover sparkles, and the last-30-seconds border pulse.
- Add translated videos as described in `LANGUAGES.md`, then check playback, sound, and skipping in each language.

Sprite silhouette masks are reused across coats, and the paw pieces are cached after their initial preparation. Startup and interactive performance should be checked on the target computer; no frame-rate target is asserted by the model tests.

`OptimizationTest` additionally covers interrupted paw capture, pause/help timing,
modal click isolation, release without an intermediate drag event, right-button
release, tutorial cleanup, queued focus loss, preserved grab offsets, stalled-frame
particle expiry, missing artwork/manifests, malformed save fields/JSON, failed
temporary save writes, bounded backdrop caching, and exact backdrop pixels.
Its save is isolated under `tmp/qa-optimization`.

Run `./test-performance.ps1 -Pacing` separately from other tests and busy workloads.
`PerformanceProbe` uses the game's Java2D renderer and `noSmooth()` at 1280 x 720,
40 warmup frames and 180 measured frames per scene. It records render-time
percentiles, main-thread allocation, image-load counts, cold entry cost, heap
snapshots, and deterministic screenshots. The particle scenario keeps 180 live
particles on screen throughout sampling. These unpaced render times are not FPS.
`FramePacingProbe` measures 180 animation-thread intervals per scene in an owned
hidden Processing window targeting 60 FPS. Audio, video, display presentation,
and human interaction are excluded. Results go to `tmp/performance` by default;
use `-OutputDirectory` to keep another run.

`KitchenSmokeTest` also runs as part of `test-sketch.ps1`. It uses an isolated
`tmp/qa-kitchen/save.json`, drives real kitchen mouse/key handlers through every
dish, and captures tutorial, FIFO debug, stages, failures, successes, and seven
language screens. Ending transitions use a deterministic decoder-unavailable
fixture in these UI checks; playback itself is tested separately.

Run `./test-video.ps1` in PowerShell 7 for both real ending MP4s through Processing
Video. It asserts frame decoding, native duration, and full timeline progression.
See `LEVEL2.md` for native GStreamer path handling and the offscreen shutdown
limitation. Audible output remains a manual check.

The revision regression cases also cover exactly three lumpia wrappers, disappearance of ingredient packaging inside cookware, direct reuse of placed utensils, gray egg matte removal, intro/ending entry routing, and reset cancellation plus wardrobe-preserving save/reload. Screenshots include the revised achievements, accessories, counter, cookware and reset options.

The storage/tray revision removes prepared-item shortcuts from the UI tests:
every prepared ingredient is picked from its real, stable counter slot. Pure Java
checks cover slot separation and stability for all five recipes, repeat wrapper
availability, reward uniqueness across levels, and one claim per completed dish.
Kitchen checks cover selector Back/Escape navigation and cooking reward
persistence across reset and reload. `test-model.ps1` includes PreparedLayout.java.

Animated utensil checks use one direct drag, then advance the model clock through
the action. They assert delayed output, rejection of duplicate starts, pause,
timeout cancellation and retry cleanup. UI tests complete all five recipes and
capture stirring, brushing, chopping, whisking and sealing on their actual work
surfaces. The animation uses model time, so pause does not leave a visual loop
running independently of recipe progress.

Perfect-border and loading checks render both Maps cards at 15/15 and 14/15 and
assert the actual border colors. Kitchen checks verify dish entry/retry loading,
all four stage boundaries per dish, input blocking and preservation of countdown
time. `test-sketch.ps1` passed 2,114 Level 1 checks and 1,450 kitchen checks for
this revision; screenshots include maps-perfect, maps-partial and stage loading.

Storyboard revision checks additionally open the cupboard, drawer and fridge through mouse input, drag source items out of their paper cards, close overlays with Escape, open the FIFO recipe note, and use the stove closeup for heat actions. Audio checks invoke the same PCM renderer as live playback; the generated `tmp/qa-kitchen/level1-music-preview.wav` is a ten-second preview, not a speaker-listening test.

Additional regressions cover independent effects mute/volume, saved effects preferences, the cupboard-driven tutorial practice, and removal of neighborhood card backgrounds. Full recipe input tests continue through all five dish successes with rewards and stage loading.

Hotspot regressions include physical cupboard/drawer/fridge landmarks, excluded counter/wall regions, and cover mapping at 1280 x 720, 1600 x 900, and 1280 x 900. Options checks exercise the language dropdown by mouse and keyboard, Escape/outside dismissal, all seven localized layouts, and slider behavior at the revised row positions.

### Level 3

`test-model.ps1` includes `MealModelTest`: all placement permutations, actual LIFO removal, hearts, countdown, pause, animation locks, and retry. `test-sketch.ps1` includes `MealSmokeTest`: actual input handlers, isolated save/load, cutscene routing, all five placements/feeds, exposed lower-plate rejection, and seven-language renders. Generated images and isolated save: `tmp/qa-meal/`.
