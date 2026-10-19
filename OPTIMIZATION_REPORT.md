# Catatoullie optimization report

19 October 2026. Processing 4 / Java mode. This pass preserves the existing
working tree, all supplied media, gameplay rules, timers, typography and layouts.
All three levels are implemented in this checkout. Earlier documentation calling
Level 3 a coming-soon screen describes an older revision.

## Baseline and audit

Before source edits, `tmp/optimization-baseline/source.zip` captured the existing
source, tests, scripts and documentation, including uncommitted files. The folder
also contains the pre-existing Git diff/status, SHA-256 media/save inventory,
original test logs and screenshots. No commit, reset, publication or asset edit
was performed. The original compiled game remains in
`tmp/sketch-check-055c1df7` for the comparison runs.

Inspected every sketch/model module, assets and manifests, initialization,
scene routing, timing/rendering, input/drop geometry, animations, audio/video,
the three data structures, progress/rewards, settings, tutorials and tests.
Reviewed all 40 PLAY-FLOW and 16 GAMEPLAY-WIREFRAME pages as rendered contact
sheets, including the detailed Level 1 gameplay and victory pages. Existing
rendered kitchen and dining screens provide the additional level references.

| Classification | Findings and disposition |
| --- | --- |
| Critical bugs | One malformed save value aborted all later restoration. Save writes replaced the live file directly. Decoder failure could retain a playing Movie. Fixed with field-level fallbacks, temporary-file replacement, and independent stop/dispose cleanup. |
| Performance bottlenecks | Full-size backgrounds were scaled and shaded every frame; kitchen name tables and target/tray rectangles allocated repeatedly. Added an eight-layer backdrop cache, persistent label tables and reusable coordinates. Missing-art sentinels now prevent disk retries from drawing. |
| Responsiveness | Mouse pause/help retained paw capture; resume could charge paused wall time; storage/recipe overlays accepted underlying controls; fast releases depended on drag-event delivery; right release could complete a left drag. Fixed and regression-tested. |
| Visual polish | Pickup recentered/resized kitchen objects and dishes. Preserved their source sizes and grab offsets; added a 180 ms, VFX-scaled dish settle and eased feeding. Paw return now uses elapsed time. |
| Optional quality of life | Focus loss queues safe pause/capture cleanup on the sketch thread. The existing VFX slider remains the way to reduce optional effects; no additional settings panel was added. |

## Implementation

- `BackdropCache.pde`, `DrawingHelpers.pde`, `KitchenAssets.pde`: cache static
  backdrop composition at the current viewport/smoothing. Eight layers cap pixel
  storage at approximately 28 MiB at 1280 x 720, excluding renderer copies.
  Dynamic sprites, controls, checklists and effects retain their original layers.
- `PreparedLayout.java`, `KitchenScreens.pde`: reuse stable tray/target rectangles
  and kitchen labels; keep pointer and drawing coordinates aligned. Dragged items
  retain their pickup position and size. Release displacement is checked even if
  the OS did not deliver a drag event.
- `InputTiming.pde`, `Catatoullie.pde`, `ScavengeScreens.pde`,
  `ProgressScreens.pde`: settle active time before input transitions, exclude
  pause/help time, reject key auto-repeat/right release, clear stale capture and
  tutorial state, isolate kitchen overlays, queue focus-loss handling, and retain
  the ingredient's position when a paw grabs it off-center.
- `SaveSafety.pde`, `Catatoullie.pde`: preserve valid version-2 through version-6
  progress, rewards and settings when another field is malformed. Clamp finite
  preferences. Write a temporary JSON, then replace the destination atomically
  where supported; retain the old save when writing fails.
- `Effects.pde`, `MealScreens.pde`: particles expire by actual elapsed time,
  offscreen particles are not drawn, and the existing 180-particle/eight-pop caps
  remain. Square pixels avoid the measured rounded-path overhead. Dish settling
  is cosmetic; feeding still pops only once and retains
  the model's animation lock. No new sprite or procedural replacement was added.
- `KitchenNavigation.pde`, `IngredientArt.pde`, `Localization.pde`: tolerate
  missing optional assets/manifests without repeated frame-loop disk access.
- `EndingMedia.pde`, `RuntimeMedia.pde`, `KitchenAudio.pde`: stop failed/stalled
  endings, ignore late callbacks from disposed Movies, dispose even if stop
  throws, close audio streams/failed clips, and avoid unchanged gain writes.
  Synthesized MIDI frequencies are computed once instead of per audio sample.
- Added `tests/OptimizationTest.java`, `tests/PerformanceProbe.java`,
  `tests/FramePacingProbe.java`, `test-performance.ps1`; expanded
  `tests/EndingPlaybackTest.java`, `test-video.ps1`, `test-sketch.ps1`, and the
  relevant README instructions. `.gitignore` also excludes save-write temporary
  files left behind if the process is interrupted.

The Level 1 `Stack` top-item restriction, Level 2 `Queue.offer/peek/poll`, and
Level 3 push/peek/pop on the same `Stack` remain intact. No recipe, time limit,
heart penalty, unlock requirement, reward rule, or difficulty threshold changed.
The frontend-design skill's replacement palettes/anchors conflict with the
explicit preservation brief, so the game's established art direction takes
precedence. Feedback uses its existing artwork and colors.

## Measurements and verification

Environment: Windows 11, Java 17.0.20.1, four reported processors, Java2D,
1280 x 720, `noSmooth()`, 60 FPS target. Runs use 40 warmup frames and 180
measured frames per scene. Baseline and changed builds run serially. There are
no audio devices or video playback in the rendering probes. FPS comes from the
real animation thread in a hidden window, with intentional focus-loss behavior
disabled by the probe and tested separately by the regression suite.

| Scene | Unpaced mean render ms, before / after | Hidden-window FPS, before / after | p95 frame interval ms, before / after |
| --- | --- | --- | --- |
| Menu | 12.68 / 6.87 | 55.21 / 59.57 | 25.25 / 18.43 |
| Level 1 search | 19.96 / 15.07 | 41.67 / 51.74 | 33.22 / 26.65 |
| Kitchen | 14.30 / 8.96 | 53.19 / 59.04 | 26.54 / 18.73 |
| Ingredient storage | 23.57 / 11.26 | 34.48 / 57.46 | 34.52 / 21.08 |
| Dining | 8.85 / 12.35 | 59.76 / 58.37 | 18.47 / 20.34 |

Dining's unpaced result was slower in the full sequence. A focused recheck was
10.06 / 10.17 ms; no dining performance improvement is claimed. The first hidden
probe also exposed its own focus-loss pause interference; final FPS numbers above
come from a corrected probe that asserts every scenario remains unpaused.
The 60 FPS target is not sustained across all scenes: search still has spikes,
and the final hidden run's worst frame was 33.77 ms. The measured improvements
apply to this host and these scenarios, not all hardware or visible presentation.

The isolated 180-live-particle stress test fell from 4.40 to 2.30 ms mean total
render time (p95 8.81 to 3.75 ms). Its empty-render control was 0.98 / 1.04 ms;
estimated incremental effect cost was 3.42 / 1.26 ms. Main-thread allocation in
that stress test fell from approximately 474 to 310 KB/frame. This measures the
renderer as well as the effects, not just particle-object construction.

Warm scenes performed zero `loadImage()` calls in both revisions. Main-thread
allocation per frame changed from approximately 103 to 97 KB in the menu, 186 to
180 KB in search, 121 to 113 KB in the kitchen, and 198 to 179 KB in storage.
Startup assets took 2.79 / 2.94 s. Cold entry including asset preparation and the
first draw was 1.19 / 1.55 s for search and 0.20 / 0.23 s for the kitchen; no cold
loading improvement is claimed. Heap snapshots ranged approximately 185-329 MiB
before and 200-349 MiB after, with no forced collection. The cache trades memory
and first-entry work for lower warm rendering cost.

Evidence: `tmp/optimization-baseline/final-performance/` and
`tmp/optimization-after/` contain render CSVs, environment notes and images.
`pacing-final/` contains the corrected FPS CSVs; `meal-recheck/` contains the
focused dining results. Particle-only results are under baseline `effects/` and
changed `effects-final/`. Preliminary antialiased measurements do not represent
the game's renderer and are excluded from the comparison above.

Validation:

- `test-model.ps1`: 12,439 Level 1, 3,142 cooking/layout/reward, and 1,841 meal
  model checks passed. Every cooking dish completes through its real FIFO queue;
  Level 3 covers all 120 placement permutations and one-pop feeding locks.
- `test-sketch.ps1`: existing suites passed 2,114 Level 1, 1,609 kitchen, 62 meal,
  63 subtitle and 112 audio-sample checks. They exercise actual handlers, every
  implemented dish, transitions, retries, pause/help, rewards, isolated saves and
  seven languages. The final optimization suite separately verifies the new
  interrupted-input, corrupted-save, missing-art and caching regressions:
  29/29 passed, for 21,411 model/sketch checks total. The initial targeted
  baseline reproduced 15 failures in 18 cases before fixes.
- `test-video.ps1`: actual game Movie callbacks decoded 238 and 240 frames of
  the two 10.006-second endings. Automatic destination routing, duplicate-start
  rejection, replay, skip, disposal and ignored late callbacks passed. Playback
  was muted; speaker output and perceived A/V synchronization are not verified.
- Five deterministic menu/search/kitchen/storage/dining screenshots have zero
  changed pixels against the baseline. Reviewed the side-by-side composition
  in `tmp/optimization-after/comparison.png`. Animated pickups, feeding and
  settling are intentional changes and are covered by the handler/render suites.
- All 347 inventoried data files, including the original player save and videos,
  retain their baseline SHA-256 hashes. No art, audio, cutscene or manifest bytes
  were changed. The version-control diff is kept separate from pre-existing work
  in `tmp/optimization-changes.patch`.

## Remaining limits

- Hidden-window cadence and offscreen rendering do not establish visible-screen
  performance on every student computer. Cold asset preparation and native
  decoder initialization can still stall; no asynchronous loading rewrite or
  renderer replacement was introduced.
- Heap snapshots include pending garbage and renderer caches; they are not a
  retained-memory/leak proof. Cache/effect caps and repeated replay handlers are
  tested, but an extended desktop soak remains useful.
- Automated handlers complete all implemented dishes/levels. Human play feel,
  audible speaker output, perceived A/V synchronization and hardware-specific
  decoder behavior still need a hands-on session. No unperformed manual test is
  claimed.
- Missing gameplay artwork is reported rather than replaced. Restore the
  supplied files to recover its appearance. Syntactically damaged JSON cannot
  reconstruct lost data; field-level recovery applies to readable save objects.
- Existing art gaps remain: no dedicated kitchen bowl sprite, neutral/error cat
  animation frames, or exact original editable Level 3 font. Existing fallbacks
  were preserved. Saved attempts still restore completion/preferences rather
  than resuming an unfinished level.
