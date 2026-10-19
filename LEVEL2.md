# Level 2: Cooking Time

Open `Catatoullie.pde` in Processing 4, install the **Video** library, and run.
Keep every `.pde`, `.java`, and the complete `data/` folder together.

## Reach the kitchen

Finish all five Level 1 trash cans. The existing final congratulations screen
now has **NEXT LEVEL**. It plays `data/LEVEL2/level1-cutscene-after.mp4`, then
opens the dish selector. Individual trash cans do not trigger this video.

Existing saves with all five cans completed already unlock Level 2. Press
**PLAY** on the main menu to watch or skip the opening cutscene and choose a level, or open the Level 2 card
under Customization / Maps. Entering Level 1 plays its opening; entering Level 2 plays the Level 1 ending before dish selection. Both have SKIP controls. Spaghetti is the first available dish.

Complete Spaghetti, Fried Chicken, Lumpia, Peach Mango Pie, and Burger in that
order to unlock each next dish. Completed dishes remain replayable.

## Cooking controls

- The recipe panel lists five major stages. Only its active stage accepts work.
- The upper instruction gives the current action. The storage picker highlights
  its source item and opens the appropriate Equipment, Ingredients, or Prepared tab.
- Click and hold an item card, drag it to the gold outline, and release. The item
  follows the mouse. An invalid drop returns it to storage without progress.
- Pick up a placed utensil directly from the counter or cookware; it does not need to be fetched again. Drag a knife, spoon, brush, or fork to its highlighted work surface once and release. A short animation completes the action automatically: stirring, brushing, chopping, whisking, or sealing. Wait for the progress bar to finish before the next action.
- Place cookware on the stove, add its ingredients, then press **HEAT** when
  instructed. Cooking takes 2.5 seconds and displays progress and steam.
- Prepared food stays in fixed, separate trays behind the chopping board. Pick it up directly from its highlighted tray; the right panel does not duplicate those items.
  Temporary cookware and work surfaces reset after each major stage.
- The work area and serving area sit on the foreground counter. Sink actions
  temporarily hide the recipe panel so the sink and drop target remain visible.
- Each dish has **05:00 total**, across all its stages. The introduction is untimed.
- Click **II** or press **Esc** to pause. Retry resets the attempt, queue, and
  five-minute timer while preserving completed dishes.
- Click **?** or press **H** to replay the tutorial without losing the attempt.
- Press **F3** to show or hide the FIFO demonstration overlay.

The first tutorial introduces the kitchen, requires a sandbox board drag unless
skipped, explains recipe order and the clock, and saves that it was seen.
Tutorial actions never modify real cooking actions. Replaying it pauses the clock.

Stars: finish with at least 180 seconds remaining for three stars, at least 60
for two, otherwise one. A replay never lowers an earned best rating.

## The real FIFO implementation

`CookingModel.java` owns:

```java
Queue<CookingStep> cookingQueue = new ArrayDeque<CookingStep>();
```

`startDish()` creates fresh recipe stages and calls `offer()` on each in order.
`front()` returns `peek()`. Interactions validate against the action belonging
to that front stage; later-stage actions cannot advance the recipe. Once every
action of the front stage is complete, `finishAction()` calls `poll()` once,
records the removed stage, and resets temporary equipment. The five stages
must all leave the queue before the dish can complete.

The checklist is a read-only view of that queue. Clicking its boxes does nothing.
Each stage contains validated sub-actions and repetition counters; those are
separate from the queue that controls major cooking order. Raw pantry stock,
prepared/cooked food states, equipment locations, and work placements have
separate representations. Processed food required by later steps survives reset.

## Storyboard requirements and completed gaps

All 44 pages of the supplied `level-2-flow.pdf` were inspected visually and as text.
The supplied updated background is shown with proportional cover scaling, so
it fills 1280 x 720 without stretching. The same window coordinates define art
placement, drag targets, tutorial practice, and hitboxes.

The storyboard establishes the dish selector, locked progression, kitchen tools,
ingredient selection, chopping, stove/cookware interactions, checklists, timer,
and dish victory screens. Those are implemented with the supplied artwork.

The detailed brief supplies these five-stage completions where the pictures do
not fully specify a recipe:

| Dish | Five queued stages |
| --- | --- |
| Spaghetti | Prepare aromatics/meats; prepare sauce; cook pasta; combine; serve |
| Fried Chicken | Marinate; bread; heat oil; fry; drain and serve |
| Lumpia | Chop vegetables; mix filling; wrap/seal 3 rolls; fry; drain and serve |
| Peach Mango Pie | Prepare fruit filling; prepare pastry/egg wash; assemble/seal; fry; drain and serve |
| Burger | Prepare vegetables; mix/shape patty; cook patty; toast buns/mix sauce; assemble/serve |

Spaghetti follows the brief's sauce-before-pasta stage order; the optional text
inside the archive describes an alternate pasta-first order. The storyboard
does not fully settle those later stages. Pie uses frying because matching
frying and finished-pie sprites are supplied. Burger sauce and vegetables use
the supplied recipe ingredients. The assembly does not introduce a new cheese
ingredient absent from the collected Burger recipe.

Cooking times, animated utensil actions, task-level dependencies, star thresholds,
and the recipe gaps above are implementation choices. They are simplified game
interactions, not real cooking-time instructions. The lumpia frying action
represents the prepared batch; the 3 wrapping cycles are individually required.

## Artwork, sound, and documented fallbacks

`data/LEVEL2/asset-map.json` maps stable game identifiers to real filenames.
Source files retain their filenames, including spaces and the supplied spelling.
The inventory is in `LEVEL2_ASSETS.md`. Sprite alpha is retained. Connected gray
or white sprite mattes are removed at runtime without editing the originals.

Missing dedicated sprites are handled as follows:

- Bowl: a small neutral bowl drawing; the archive has bowls inside food artwork
  but no standalone bowl image.
- Coated chicken: the supplied chicken/buttermilk bowl image represents the
  prepared chicken; the gameplay has a separate validated breading state.
- Raw patty: the supplied patty-mixture image represents the formed uncooked
  patty. Cooked patty uses its dedicated sprite.
- Drained food: the matching cooked food image is reused.
- Water pouring and egg preparation: drag actions and resulting food sprites
  represent the transformation; no dedicated animation frames were supplied.

The supplied background music is used in the kitchen. `BgMusic.wav` is a mono
22,050 Hz PCM copy of the original MP3 for Java Sound compatibility. The Music
slider controls it; leaving the kitchen stops it. If audio output is unavailable,
the existing synthesized audio remains the fallback. The combined chopping,
water, frying, and boiling MP3 is retained as supplied, but has no timing manifest
for separate cues and is not assigned to individual actions. Existing click
feedback and slider-scaled visual bursts provide action feedback.

The new cooking text, item names, instructions, and tutorial support the existing
seven languages. Supplied ending videos retain their original embedded text
and audio. They are not automatically translated.

## Ending transitions

Completing Burger shows the Level 2 victory screen first. **NEXT LEVEL** plays
`data/LEVEL2/level2-cutscene-after.mp4`. Completion or **SKIP / Space / Enter**
opens the Level 3 coming-soon screen. No playable Level 3 is included.

`EndingMedia.pde` provides one reusable playback controller for both endings.
It preserves aspect ratio, native playback speed and audio, blocks overlapping
starts, detects completion, and stops/disposes the movie before changing scene.
On decoding failure, a visible message and SKIP allow progression; no replacement
cutscene is generated. The previous localized opening cutscene remains separate.

## Saves

Version 4 preserves existing Level 1 progress, wardrobe rewards, coat, angle,
language, and settings. It adds `cookingCompleted`, `cookingStars`, and
`cookingTutorial`. Level 2 unlock is derived from the five completed Level 1 cans;
available dishes and Level 2 completion are derived from cooking progress.
Unfinished dish attempts are not restored after quitting. Old version-2/3 saves
load without inventing cooking progress. Player data stays in the ignored
`data/savegame.json` file.

## Checks and limits

```powershell
.\test-model.ps1
.\test-sketch.ps1
.\test-video.ps1
```

The model tests cover LIFO regression plus all five FIFO recipes, wrong actions,
dependency preservation, exact stage removal order, repetition requirements,
equipment reset, cooking waits, pause, timeout, retries, and progression.

The sketch tests compile the full game and exercise actual mouse/key handlers,
all five dishes, the sandbox tutorial and replay, both level transitions, skip,
failure/retry, persistence, asset loading, and translated rendering. Screenshots
are in `tmp/qa/` and `tmp/qa-kitchen/`. Saves are redirected to those folders.

The video check uses Processing's real `Movie` API to decode both supplied MP4s
through their approximately 10.006-second duration at native speed. It needs
PowerShell 7 and the Video library's Windows native GStreamer folder. The test
sets native paths only for its child process. If GStreamer's DLL shutdown stalls
in this surface-free harness after the success marker, it terminates only that
owned test process. This is not used by the game.

These are offscreen rendering, event-handler, model, and decoder checks. Audible
speaker output, extended manual play, and frame-rate performance need a listening
and play session on the target computer; no FPS target is claimed.

Executed validation on 18 October 2026: 12,439 Level 1 model checks, 2,225 cooking
model checks, 2,114 existing sketch checks, and 1,869 kitchen sketch checks passed.
Both real ending videos decoded more than 230 frames and reached their native
10.006-second endpoint. Original video/background bytes and the player's save
were verified unchanged.

## Files added and changed for Level 2

Added: `CookingModel.java`, `CookingRecipes.java`, `KitchenAssets.pde`,
`KitchenScreens.pde`, `KitchenAudio.pde`, `EndingMedia.pde`, `data/LEVEL2/`,
`tests/CookingModelTest.java`, `tests/KitchenSmokeTest.java`,
`tests/EndingPlaybackTest.java`, `test-video.ps1`, this guide, and the asset inventory.

Changed: `Catatoullie.pde`, `MenuScreens.pde`, `ScavengeScreens.pde`,
`RuntimeMedia.pde`, `Effects.pde`, `data/languages.json`, the model/sketch test
scripts, `tests/SketchSmokeTest.java`, and project documentation. Existing Level 1
collection rules in `GameModel.java` were not changed by this implementation.

## Interface and interaction revisions, 18 October 2026

- World and map cards show each playable level's cumulative best stars out of 15 and completion status.
- Options / RESET PROGRESS has a confirmation screen. It clears both levels, stars, attempts and tutorial completion, while preserving wardrobe rewards, equipped cosmetics, languages and preferences. Reward records stay claimed to avoid duplicate awards.
- Maps no longer displays the obsolete demo sentence in any language.
- Neckwear uses a front section fitted beneath the chin; rear rims are hidden. Accessories remain front-only when the avatar turns because no matching side/back art was supplied.
- Level 1 food and junk use a 174-pixel size throughout the pile, dragging and staging. Placement uses the paw center across a wider interior ellipse, excluding the collection bag.
- Lumpia requires three wrapping cycles. Reusable utensils have direct hitboxes and the active utensil wins when cookware overlaps it.
- Ingredients added to vessels become contained mixture visuals. Bottles and cans disappear after a brief drop animation. Prepared food has separate positions and shadows on the foreground worktop; obsolete intermediate outputs are removed at stage boundaries.
- Egg matte removal handles partial alpha, including its supplied alpha-200 gray background, while retaining the source file.
- The selected cat watches from behind the foreground counter. Perspective worktop edges, layered sprites and shadows provide 2.5D depth; these are not a true 3D camera or meshes.
- Paper text uses Georgia with a Chinese font fallback. Achievements use sand, clay and moss cards with real progress for both levels.
- Added synthesized meow, chopping and drop cues through the existing bounded audio buffer. Drop particles and animation intensity follow VFX; audio follows Music. Speaker output and target-machine frame rate still require manual checking.

Revision validation: 12,439 Level 1 model checks, 1,683 cooking model checks,
2,114 Level 1 sketch checks, and 1,303 kitchen handler checks passed. Kitchen
checks include placed-tool reuse, partial-alpha egg cleanup, cutscene entry routes,
reset cancellation, and wardrobe persistence after resetting and reloading an
isolated save. The real player save is not used by these tests. Cutscene decoding
was validated during the prior implementation; this revision rechecks routing
with a deterministic video fixture, not a new audio/video playback session.

## Storage, tray and reward fixes

Placed raw ingredients leave the storage list immediately. The list scans only
unfinished recipe actions, so repeat portions such as lumpia wrappers remain
available when required. Prepared food is picked up from the counter rather than
being duplicated in the right panel. Invalid drops leave the original item in its
slot. Tools already placed on the work surface also leave storage and remain
available directly where they were placed.

`PreparedLayout.java` assigns up to eight disjoint tray slots shared by drawing
and pointer selection. Consuming one item does not move the others. The trays sit
above the chopping board and serving surfaces, avoiding the Burger overlap that
blocked ingredient pickup. The pantry uses sand, clay and sage colors, rounded
cards and subtle grain; its empty state explains where to pick up prepared food.

Each of the five completed Level 2 dishes grants one random unowned hat and one
random unowned accessory. Rewards are shared with the existing wardrobe and avoid
Level 1 rewards. The success screen displays both items. Each dish awards once;
replay and progress reset preserve the claim and the wearable rewards. Older saves
can earn these rewards by completing each dish again. Save version 5 adds the
`cookingRewards` array and continues reading older saves.

The LEVELS button and Escape return from the Level 1 selector, Level 2 selector,
and Level 3 entry to the world selector. MAIN MENU remains the explicit menu action.
Level entry still uses the appropriate cutscene and Skip control.

Latest validation: 12,439 Level 1 model checks, 3,041 cooking/layout/reward checks,
2,114 Level 1 sketch checks, and 1,302 kitchen input checks passed (18,896 total).
The kitchen checks complete every dish using actual prepared-tray hitboxes, reject
duplicate raw pickup, check button/Escape navigation, and reload Level 2 wardrobe
rewards after resetting an isolated save. Screenshots include the Burger trays
and per-dish reward screen. This validation uses offscreen Processing graphics;
live frame rate and speaker output were not measured.

## Animated utensil actions

One valid utensil drag starts a model-timed action across all five recipes.
Spoon stirring takes 1.25 seconds, knife chopping 0.9 seconds, and brush/fork
work 1 second. Outputs appear only when the action finishes. During this time,
additional item pickup, repeated drops and heat starts cannot advance the recipe.
The five-minute dish clock continues; pause and tutorial help freeze the action.
Timeout cancels it without producing ingredients, and retry clears its state.

`KitchenActions.pde` draws each tool on its actual target. Stirring follows the
bowl or pan opening, brushing sweeps over the rolled wrapper or filled pastry,
and forks whisk or press pastry edges. The current wrapper/pastry is shown on the
work surface rather than duplicated in its prepared tray. The action progress bar
and tool motion stay visible with VFX at zero; optional ripples and brush sheen
follow the VFX slider. Instructions and action labels support all seven languages.

Utensil validation: 12,439 Level 1 model checks, 3,142 cooking/layout/reward
checks, 2,114 Level 1 sketch checks, and 1,276 kitchen handler checks passed.
All five dishes complete with one drag per utensil action. Screenshots cover
Lumpia stirring and brushing, pie brushing and sealing, and the matching actions
in other recipes. These are offscreen Processing input/render checks; live
speaker output and frame rate remain manual checks.

## Perfect-level borders and stage loading

Maps and world selection use the same perfect-level rule. A playable level earns
its gold border only when all five stages are completed and all five best ratings
are three stars (15/15). Completing the level with fewer stars keeps a neutral
border. The unimplemented Level 3 has no perfect rating.

Level 1 retains its loading screen before every trash can. Level 2 now shows a
1.2-second loading transition when starting or retrying a dish, selecting the next
dish, and moving between its five major recipe stages. The loading screen shows
the selected cat, dish and upcoming stage. Cooking input and the countdown are
suspended until the destination opens. LEVELS cancels back to world selection;
Escape returns to dish selection. Tutorial replay does not add a loading break.

Border/loading validation: the Processing sketch builds; 2,114 Level 1 input/render checks and 1,450 kitchen checks passed. Rendered perfect/partial borders and loading screens were visually inspected.

## October 19 storyboard revision

Compared all 49 PNG screens in the supplied `level-2.zip`. The cooking interface now opens equipment from the drawer/cupboard hotspots and ingredients from the fridge. Picking an item closes storage so it can be dragged onto the existing work surfaces. The paper button opens the FIFO checklist; Escape closes an open overlay before pausing gameplay. Clicking the stove during a heat action opens the supplied stove closeup. All five dishes retain their recipe actions, timed utensil animations, stage loading, rewards, and save compatibility.

Dish selection uses the supplied green image Play control over uncompleted/hovered dishes, without rectangular dish cards. Completed dishes display their earned stars. Pause choices are larger text controls without a panel or button boxes. Level 1 victory uses the original yellow CONGRATS art over the faded live bin scene, three earned/unearned stars, and rounded next/menu controls. Its dynamic stage number, rewards, and final NEXT LEVEL action remain functional.

Level 1 has a separate original synthesized minor-key plucked melody and bass line. The Music slider scales the music signal before button/action/meow effects are mixed, so Music 0% does not mute click feedback. No additional audio library or network connection is required.

Verification uses isolated saves and real input handlers. The suite covers all five dishes through spatial storage, checklist isolation, stove closeups, stage loading, rewards, pause/retry, and translated screens. It also renders the production synthesizer offline and checks silence at Music 0%, audible clicks, and distinct Level 1 music. Speaker playback has not been manually assessed. Screenshot references guide the composition; dynamic progress, localization, and rewards are rendered rather than baked into static screenshots.

## Kitchen hand, options, and tutorial revision

Options now includes an independent Sound Effects slider for button, paw, meow, and cooking feedback. Its saved `sfx` value defaults to 70% for older saves. Music and effects can each be muted without muting the other; Restore Defaults restores the effects setting as well.

The neighborhood level selector uses floating level artwork with ratings and play controls. Its surrounding card fills and borders were removed. The separate Maps screen retains its perfect-star border rule.

Every cooking victory places the rewards panel below the three stars, with a gap before navigation. The kitchen, storage views, tutorial, and loading screen use one anchored, stretching right arm instead of a full cat avatar. Storage scenes expose the drawer, cupboard shelves, and fridge shelves behind selectable items. Shared station and slot bounds are cached rather than allocated on each draw/hit test.

The five-page tutorial now introduces storage, practices opening the cupboard and dragging a board onto the counter, shows the recipe note and FIFO order, then explains the countdown. Its board is a tutorial-only source: practicing or replaying help does not consume ingredients or advance the recipe queue. The countdown begins after the tutorial and remains paused during a help replay.

## Kitchen hotspot and Options alignment

Storage polygons are traced on the supplied 2012 x 1258 kitchen background. The backdrop, hover outlines, click regions, sink, and stove share one cached cover transform. The fridge polygon follows its visible door and excludes the foreground counter; the cupboard follows its sloping top edge. The preparation rack takes pointer priority over storage behind it, and heating takes priority over picking up a pan. This geometry applies to every dish and tutorial view.

Options uses four evenly spaced rows with shared drawing/input positions. The seven language buttons are replaced by one dropdown displaying native language names. The dropdown supports mouse selection, arrow-key navigation, Enter selection, Escape dismissal, and outside-click dismissal without changing underlying sliders. Existing saved language and audio settings remain compatible.
