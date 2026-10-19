# Catatoullie

A Processing 4 game about a hungry cat collecting ingredients and cooking five dishes. Level 1 demonstrates LIFO retrieval from a trash pile; Level 2 processes cooking stages through a real FIFO queue.

## Run the game

1. Clone this repository:
   ```sh
   git clone https://github.com/Kyoktaka/Catatoullie.git
   ```
2. Install Processing 4 and select Java mode.
3. Install the **Video** library using **Sketch > Import Library > Manage Libraries**.
4. Open `Catatoullie.pde` from the `Catatoullie` folder and click **Run**.

Keep all `.pde` and `.java` files and the `data` folder together. If downloading a ZIP, rename the extracted folder to `Catatoullie` before opening the sketch. The game uses a 1280 x 720 window.

## Play

- Customize five cat coats with hats and accessories. Drag the cat preview left or right to turn it.
- Choose a trash can, open the recipe folder, and read both papers.
- Drag a cat paw to the top object in the central pile. Objects are removed in LIFO order.
- Follow the **FIND** list from top to bottom. Only the ingredient marked **NEXT** can enter **COLLECT**.
- Set later ingredients aside to reach the current ingredient, then pick them up when their turn comes. Leave junk beside the pile.
- Finish each search within two minutes, earn stars, and unlock the next can.
- First completion of each can unlocks a random hat and accessory. Replays keep the same rewards.
- Options include seven languages and a VFX slider controlling ambient particles, pickup effects, and countdown urgency.

After the fifth can, choose **NEXT LEVEL** to watch the supplied ending and enter Level 2. Complete five cooking dishes with click-and-drag actions, a five-minute timer, and sequential unlocks. The final victory screen plays the supplied Level 2 ending and opens Level 3: stack five dishes, then feed them to the cat in reverse order.

## Controls

| Control | Action |
| --- | --- |
| Mouse | Menus, wardrobe, papers, and paw dragging |
| Drag cat preview | Rotate the cat |
| Space / Enter | Skip the cutscene |
| Esc during a search | Pause or resume |
| H / ? during a search | Show help and pause the countdown |
| Drag a kitchen item | Place equipment, prepare food, or assemble a dish |
| II / Esc in the kitchen | Pause or resume |
| H / ? in the kitchen | Replay the tutorial without losing the attempt |
| F3 in the kitchen | Toggle the FIFO debug overlay |

Progress and preferences save locally to `data/savegame.json`. This file, temporary output, and local builds are excluded from Git.

## Project notes

- [Detailed game guide](README.txt)
- [Languages, cutscene paths, and new assets](LANGUAGES.md)
- [Level 2 controls, architecture, recipes, and verification](LEVEL2.md)
- [Original play flow](data/PLAY-FLOW.pdf)
- [Checks and manual verification notes](tests/README.md)

Run `./test-model.ps1` and `./test-sketch.ps1` to check all three levels, reward rules, input handlers, persistence, translations, and offscreen rendering. Test saves stay under `tmp/`. Run `./test-video.ps1` for actual Movie decoding/playback, replay, skip, and disposal of both ending MP4s. `./test-performance.ps1 -Pacing` records rendering costs and hidden-window frame pacing. See [the optimization report](OPTIMIZATION_REPORT.md) for measurements and limits. Speaker output and extended manual play still need an interactive check.

### Level 3: Full Course Meal

Level 3 is playable after completing Level 2. See [LEVEL3.md](LEVEL3.md) for controls, Stack/LIFO rules, asset mapping, save behavior, tests, and implementation limitations.
