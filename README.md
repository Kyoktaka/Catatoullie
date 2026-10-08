# Catatoullie

A Processing 4 game prototype about a hungry cat collecting ingredients. The current game covers the menu, customization, cutscene, and all five trash cans in Level 1.

## Run the game

1. Clone this repository:
   ```sh
   git clone https://github.com/Kyoktaka/Catatoullie.git
   ```
2. Install Processing 4 and select Java mode.
3. Install the **Video** library using **Sketch > Import Library > Manage Libraries**.
4. Open `Catatoullie.pde` from the `Catatoullie` folder and click **Run**.

Keep all `.pde` files, `GameModel.java`, and the `data` folder together. If downloading a ZIP, rename the extracted folder to `Catatoullie` before opening the sketch. The game uses a 1280 x 720 window.

## Play

- Customize five cat coats with hats and accessories. Drag the cat preview left or right to turn it.
- Choose a trash can, open the recipe folder, and read both papers.
- Drag a cat paw to the top object in the central pile. Objects are removed in LIFO order.
- Follow the **FIND** list from top to bottom. Only the ingredient marked **NEXT** can enter **COLLECT**.
- Set later ingredients aside to reach the current ingredient, then pick them up when their turn comes. Leave junk beside the pile.
- Finish each search within two minutes, earn stars, and unlock the next can.

Cooking and arranging ingredients are planned for Level 2.

## Controls

| Control | Action |
| --- | --- |
| Mouse | Menus, wardrobe, papers, and paw dragging |
| Drag cat preview | Rotate the cat |
| Space / Enter | Skip the cutscene |
| Esc during a search | Pause or resume |
| H / ? during a search | Show help and pause the countdown |

Progress and preferences save locally to `data/savegame.json`. This file, temporary output, and local builds are excluded from Git.

## Project notes

- [Detailed game guide](README.txt)
- [Original play flow](data/PLAY-FLOW.pdf)
- [Checks and manual verification notes](tests/README.md)

The latest ordered-collection and ingredient-staging changes have not been validated by the existing automated checks. Those checks still contain assumptions from the previous collection rules and need updating before they can verify this version.
