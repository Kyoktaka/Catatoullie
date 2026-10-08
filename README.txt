CATATOULLIE - LEVEL 1: SCAVENGE, DON'T COOK
Processing 4 / Java mode / 1280 x 720

RUN
Open Catatoullie.pde in Processing 4 and click Run. Keep every .pde tab,
GameModel.java, and data/ together. Install the Video library through
Sketch > Import Library > Manage Libraries if needed.

CUSTOMIZATION
Five coats: Ginger, Blue, White, Black, and Silver Vox.
Click and drag the cat horizontally in the menu or wardrobe preview to turn
clockwise or counterclockwise. Release to settle smoothly on the nearest view.
Rotation blends the supplied front/right/back/left artwork; there are no
rotation buttons or keyboard rotation controls.
Every angle loads the corresponding supplied cat image, including the new
cat-menu-front.-black.jpg and the blue right image named blue9.
Choose one hat and one accessory together. Hats use fitted anchors for each
view. Headphones, tag collars and eyewear appear only on the front-facing cat,
using the available front artwork rather than covering its side or back.
Original source files are preserved. White sprite backgrounds and grey cat
backdrops are removed when loaded into the game, with alpha compositing.
The shared registered cat silhouettes preserve the pale Silver Vox coat.
Silhouette masks are cached per view and reused across coats. Sprite loading
uses reusable pixel queues, and the paw cap/forearm images are prepared once.

LEVEL 1 FLOW
Menu > cutscene > trash cans > loading > recipe folder > opened-file transition
> two closed papers > click BOTH papers > start the timed search.
The five trash cans sit under the five background lamps. Hover for sparkles.
Only the first is unlocked initially. Completing one unlocks the next.
Every can, including Next Trash and Retry, passes through a loading screen.

HOW TO SEARCH
1. Grab either paw near its hand, then drag it onto the TOP object of the pile.
2. Follow the FIND list from the top down. Only the next unchecked item can go in COLLECT.
3. Set later ingredients aside to reach the item currently marked NEXT. Collect them when their turn comes.
4. Drag a paw to a staged ingredient to pick it up, then drop it in COLLECT when it is NEXT.
5. Set junk beside the pile, inside the left or right side of the trash can.
The larger arms stay attached at their bases; their forearms stretch while
their hands follow the mouse. Empty paws ease back to their resting positions.
Objects overlap as a pile without item-name labels or individual cards.
Only the top object can be removed: this is STACK / LIFO behavior.
The first item pushed into the stack is the last one available to remove.
Ingredients must be collected in FIND order. Later ingredients can be staged
beside the pile and collected when they become next. Junk cannot go in the bag.
Junk placed aside stays visible inside the can and is never collected.
A wrong drop keeps the item in the same paw, ready for another try.
The rest of the stack stays unchanged until a valid deposit succeeds.

TIMER, STARS, AND PROGRESSION
Each trash can gives TWO MINUTES. Loading, reading papers, pause and help
screens do not consume that time. The supplied health bar shows the countdown.
When time expires, choose Retry Trash for a fresh pile and two minutes.
Complete a can with 80+ seconds left for 3 stars, 40+ for 2, otherwise 1.
Best stars are preserved when replaying a completed can.
Congratulations > Next Trash repeats the flow through the fifth can.
The final screen ends Level 1. No Level 2, cooking, serving, or arranging flow
is implemented. All finds remain uncooked and unarranged for the future level.

CONTROLS
Mouse: menus, colors, accessories, papers, and paw dragging.
Drag directly on either cat preview to rotate it left or right.
SPACE / ENTER: skip cutscene; it also advances when playback ends.
ESC during the search: pause/resume. H or ?: help (also pauses countdown).
ESC on preparation screens: return to trash selection.
Options: music volume, visual-effect intensity, and paw pickup reach.

SAVING
Completed cans, best star ratings, selected cat/view, wardrobe and options
save to data/savegame.json. Unfinished searches are not persisted.
Settings from the earlier prototype are retained; its FIFO cooking progress
is not carried into the revised LIFO collection mode.

MEDIA AND ART
Original cutscene: data/cutscene1.mp4. Decoder failures fall back to supplied
PLAY-FLOW story frames in data/INTRO. Video remains a compile-time dependency.
Synthesized background music needs no separate Sound library.
Recipe ingredient icons use native drawing; supplied junk, paws, paper,
folder, sparkle, timer, congratulations and star artwork are reused.

CHECKS
./test-model.ps1   - independent Java tests for LIFO, wrong targets, stale items,
                    collection/set-aside state, all five collections, timeout,
                    retries, stars and progress.
./test-sketch.ps1  - compile the full Processing sketch; render screenshots and
                    test menu rotation, papers, both paws, every can and retry.
                    Output: tmp/qa. No desktop UI automation or save mutation.
Pass -ProcessingHome or -VideoLibrary to test-sketch.ps1 for custom installs.

FILES
Catatoullie.pde     - app state, assets, countdown and persistence
MenuScreens.pde    - menu, wardrobe, options and achievements
AvatarPreview.pde  - mouse rotation, eased view blending and wardrobe fitting
ScavengeScreens.pde - trash selection, transitions, papers and paw gameplay
SpriteAssets.pde   - in-game sprite transparency and cached cat silhouettes
DrawingHelpers.pde - shared drawing and hit-testing
IngredientArt.pde  - native ingredient icons
RuntimeMedia.pde   - movie, fallback story and audio
GameModel.java     - independently tested Level 1 collection rules
