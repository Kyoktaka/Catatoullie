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

The model checks cover all 50 required ingredients in Level 1's five recipes, sequential mission unlocking, LIFO pickup, rejection of duplicate and stale items, two-minute timeouts, preparation time, retries, star ratings, replay progress, and save-mask restoration. The sequence based collection and ingredient staging change is newer than these checks, so this suite does not yet verify that behavior.

For full sketch compilation, event-handler checks and offscreen screenshots:

```powershell
.\test-sketch.ps1
```

This requires Processing 4 and its Video library. Use `-ProcessingHome` and `-VideoLibrary` for custom installation locations. Compiled files go into a new `tmp/sketch-check-*` folder and screenshots go into `tmp/qa`. The smoke-test sketch overrides saving so it does not modify player progress. These checks do not automate a desktop window or verify audible playback.

For manual interface verification, run `Catatoullie.pde` in Processing and check these interactions:

- Drag the menu cat and customization preview left and right. Rotation should blend smoothly and settle on a complete view when released, without rotation buttons.
- Try every coat, hat and accessory. Hats follow the selected view; headphones, tag collars and eyewear appear only from the front.
- Open both papers before searching. Check that both headings and the longest recipe fit below the paper's top edge.
- Drag either paw by its hand. Its base should stay fixed as the forearm stretches; clicking the forearm alone should not start a drag.
- Grab only the top object of the overlapping pile. Collect the next unchecked FIND item in order; set later ingredients aside and retrieve them when they become next. Junk goes to either interior side of the can. Wrong bag drops should retain the object for another try.
- Pause or open help while holding an item, then resume and finish the drop. The timer should stop during either overlay.
- Finish a can, retry after timeout, and proceed through all five cans. Cooking and arranging remain outside this Level 1 prototype.

Sprite silhouette masks are reused across coats, and the paw pieces are cached after their initial preparation. Startup and interactive performance should be checked on the target computer; no frame-rate target is asserted by the model tests.
