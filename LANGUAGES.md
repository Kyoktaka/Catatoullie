# Languages and cutscene videos

Level 2 cooking text and tutorial also support all seven languages. The supplied
Level 1/2 ending MP4s keep their original embedded text and audio. Their playback
and exact paths are documented in `LEVEL2.md`; the configuration below continues
to control the opening cutscene.

Choose **Options → Language**. English is the default. Tagalog, Spanish,
Simplified Chinese, Italian, French, and Russian translate menus, recipes,
instructions, ingredient names, wardrobe names, rewards, and game feedback.
Your selection saves automatically.

## Add your translated cutscenes

Place the videos directly inside `data/` using these names:

| Language | Configuration key | File inside data/ |
| --- | --- | --- |
| English | en | cutscene1-english.mp4 |
| Tagalog | tl | cutscene1-tagalog.mp4 |
| Spanish | es | cutscene1-spanish.mp4 |
| Simplified Chinese | zh | cutscene1-chinese.mp4 |
| Italian | it | cutscene1-italian.mp4 |
| French | fr | cutscene1-french.mp4 |
| Russian | ru | cutscene1-russian.mp4 |

The existing English video is already included under its new filename.
No translated videos are included yet. Until you add one, that language uses
the English video with timed subtitles in the selected language. No temporary
or fallback notice is shown.

For different filenames, subfolders, or links, edit **`data/cutscenes.json`**.
For example, change the Tagalog entry to either:

```json
"tl": "videos/my-tagalog-intro.mp4"
```

or a direct video-file link:

```json
"tl": "https://your-host.example/videos/tagalog.mp4"
```

Keep the surrounding JSON object and commas between entries. Local paths are
relative to `data/`; do not prefix them with `data/`. Use a direct HTTPS MP4
URL, not a YouTube, Drive preview, or webpage link. Remote playback requires
internet access and a server/format supported by Processing's Video library.
Local MP4 files are the most reliable option. Restart the game after editing.

`RuntimeMedia.pde` contains `introSource()` (language selection/fallback),
`startIntroMedia()` (playback), and `resetIntroLanguage()` (changing language).
You do not need to edit those functions to add your videos. Decoder or playback
failure uses the existing illustrated intro with its own subtitle timing.

`data/intro-subtitles.json` contains opening-caption start/end times in seconds.
The movie track follows the actual video playback position, so buffering does
not advance subtitles. The illustrated track follows story-page time. Caption
text is translated through `data/languages.json`. English displays no subtitle
overlay because the opening movie already contains English text. If a
replacement video changes timing or dialogue, update these cues and translations.
The original English lettering embedded in the MP4 remains part of that video;
subtitles do not modify the source video.

## Text, button art, and fonts

`data/languages.json` maps English phrases to six translations in this order:
Tagalog, Spanish, Chinese, Italian, French, Russian. Keep placeholders such as
`{0}` and `{1}` intact. `Localization.pde` applies them to dynamic feedback.

Supplied menu buttons live in `data/LOCALIZED_BUTTONS/<language>/`. English
buttons remain in `data/BUTTONS/buttons/`. Options and wardrobe controls use
translated text for consistent, readable sizing.

The game uses Trebuchet MS for a rounded interface and Microsoft YaHei for
Chinese. These fonts are available on the Windows target machine. On another
operating system, install equivalent fonts or update the font names in
`initLanguages()` in `Localization.pde`, especially for Chinese glyph support.

## New art and rewards

`data/WARDROBE/` contains the supplied hats and accessories. Transparent PNG
art keeps its existing alpha; older opaque sprites get background removal at
load time. Fit anchors are in `WardrobeAssets.pde` and `AvatarPreview.pde`.
Front-only accessory art appears on the front view; props sit beside the paws.

Each Level 1 trash can's **first successful clear** grants one random unowned
hat and one random unowned accessory. Failed attempts grant nothing. Replays
retain the same rewards. Five cans unlock five hats and five accessories; the
remaining new cosmetics stay locked for future stages. Existing progress can
be replayed to claim its first new reward. Original wardrobe items remain free.

`data/ingredient-assets.json` maps the FIND lists to the supplied food PNGs.
These shaded illustrations replace the drawn ingredient icons. Pile, held,
and set-aside items share one size; the collection bag uses thumbnails. Items
can be placed and picked up again anywhere within the playable trash interior.
The center pile remains LIFO, and collection still follows FIND order.
