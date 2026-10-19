# Level 3: Full Course Meal

Open `Catatoullie.pde` in Processing 4, Java mode, with the Processing Video library installed. Run the sketch. Complete all five dishes in Level 2, then choose NEXT LEVEL. The existing Level 2 ending plays once for that entry; finishing or skipping it opens the Level 3 quest. Level 3 is also available through Levels and Maps after Level 2 completion. A retry never replays the cutscene.

## Controls and rules

Click GAME! to start the 30-second stacking countdown. Drag Burger, Peach Mango Pie, Lumpia, Fried Chicken, then Spaghetti onto the central table stack. Each accepted drop performs one `Stack.push()`. Dropping elsewhere cancels freely; a wrong dish dropped onto the stack costs one heart. Already placed food cannot be duplicated.

Once all five dishes are stacked, drag the top dish to the cat on the right. Eating uses `peek()` and `pop()` on that same stack, in reverse order. Lower plates cannot be removed. Clicking an exposed lower plate costs one heart. Each feed locks input during its animation. There is no eating timer.

The task button toggles both papers. PAUSE or Escape suspends gameplay and the countdown. At zero hearts or timeout, TRY AGAIN resets only the attempt. The final feeding fades into the supplied fat-cat scene, then LEVELS returns to selection. Completion and best stars (remaining hearts, maximum three) persist through the existing save system. Reset Progress clears all three levels while preserving wardrobe rewards.

## Reference and artwork

The 19 pages of `Copy of PLAY (Animated).pdf` were rendered and reviewed. Their gameplay screenshots are landscape, despite the brief describing square screenshots. The supplied background is 1994 x 1122, effectively matching the game's 16:9 canvas. The room, two papers, task button, hearts, food positions, central physical stack, reaction banners, and ending image retain that composition.

All 18 original PNGs from the supplied archive are copied unchanged to `data/LEVEL3`. `asset-map.json` documents every role. Images load once on entry. The existing runtime matte-removal helper exposes the waiting cat and buttons without modifying source files. The eating/final cat's connected near-black matte is removed once during loading, preserving enclosed facial and fur details. No font, separate neutral/error cat, animation frames, or sound file was included. The provided drooling/eating/fat images supply the available reactions; motion/fade are code-driven. Impact is the closest installed condensed font used for editable checklist text; Chinese uses the existing language font. Thus the layout follows the storyboard, but unavailable font and neutral/error frames are not claimed as exact reproductions.

English preserves the original baked lettering. Other languages overlay translations inside the same controls and papers. Existing volume-controlled click and meow sounds are reused. Level 3 now has its own original café soundtrack.

## Files

Added: `MealModel.java`, `MealScreens.pde`, `data/LEVEL3/*`, `tests/MealModelTest.java`, `tests/MealSmokeTest.java`, this document.

Integration edits: `Catatoullie.pde` (tick/save version 6), `EndingMedia.pde` (entry), `KitchenScreens.pde` (selection and handler routing), `ScavengeScreens.pde` (release/key routing), `MenuScreens.pde` (Maps), `ProgressScreens.pde` (rating/reset), `data/languages.json`, both test scripts, the existing KitchenSmokeTest entry assertions. No Level 1 or Level 2 gameplay model was changed for this feature.

## Validation

Run `./test-model.ps1` and `./test-sketch.ps1` from PowerShell. The new model suite covers all 120 placement permutations, duplicate prevention, LIFO feeding, animation locks, pause, timer, failure, and retry. The sketch suite uses real Processing handlers and offscreen rendering, with isolated saves under `tmp/qa-meal`. It exercises all five drag/drop and feeding actions, navigation, cutscene completion routing, heart penalties, save/load, and global reset. Screenshots include intro, every push/pop, error, completed stack, final scene, timeout, and all seven languages.

These are automated interactions and rendered-image inspections. Native video playback and speaker output were not re-tested for this change; the existing video/audio controllers are reused.

## Campaign ending

After the final feeding transition, completing all three levels opens a meal-table celebration with the transparent full cat, all five dishes, earned star totals, and Main Menu / Levels navigation. Text follows the selected language. Cached grain and sprites avoid repeated image processing; decoration uses a fixed, slider-scaled loop capped at 44 pieces, with no particle-list growth. Zero VFX disables confetti and breathing motion. Level 3 uses the burger thumbnail in both selection screens.

## Original soundtrack

`data/LEVEL3/full-course-cafe.wav` is an original 20-second loop at 96 BPM, with soft plucked melody, warm bass, syncopated chords, and light percussion. It plays during the Level 3 introduction, gameplay, and campaign ending. Music volume controls it independently of clicks/meows. Pause freezes playback; leaving Level 3 restores the other scene music. The PCM buffer loads once and shares the existing audio thread, with no extra mixer/device or per-frame decoding.

Regenerate using `scripts/compose_level3.py` (Python + NumPy). The game needs neither Python nor NumPy. `MealAudioTest` checks duration, wraparound, seam, headroom, volume/mute, pause/resume, scene exit/reentry, and buffer reuse without opening a speaker device.
