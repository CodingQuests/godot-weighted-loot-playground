# Art direction and asset selection

Updated 2026-09-11 after the user proposed real assets from Kenney. Earlier generated artwork and both dark-blue and bright-ivory treatments were rejected. The current release uses actual Kenney sprites throughout the room and loot display; generated variants are outside the public package.

## Why these packs

[Tiny Dungeon](https://kenney.nl/assets/tiny-dungeon) supplies a coherent 16-pixel set of room tiles, adventurers, decorations, potion, and closed/open chest sprites. [Pixel Platformer](https://kenney.nl/assets/pixel-platformer) supplies readable pixel coin, gem, and key collectibles. Both official pages identify the packs as CC0, and their downloaded license notices were checked and preserved.

Scribble Dungeons, Adventure UI, and the larger Roguelike/RPG pack were also inspected. Their files are not shipped because this scene only needs the two selected packs.

The room is an original layout composed in Godot. Whole pixel scaling and nearest filtering preserve the source artwork. The loot table, history, and statistics share the same item sprites. A golden key represents the rare Relic. The interface retains subdued warm-charcoal surfaces with amber accents, and an explicit Kenney credit appears beside CodingQuests attribution.

## Research applied

Valve's [Character Art Guide](https://help.steampowered.com/en/faqs/view/0688-7692-4D5A-1935) emphasizes recognizable silhouettes, areas of rest, and reviewing art in game context. Riot's [Clarity in League](https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/) emphasizes recognition, an attention hierarchy, and limiting visual noise. These inform the sparse room layout and the separation of art from controls; they do not establish a test for whether an image looks AI-generated.

## Future revisions

Prefer a coherent existing licensed asset set before generating more art. Inspect assets at actual display size, preserve their licenses, and keep their palette and rendering consistent. Read recorded user feedback before changing the overall theme. The user's request to try Kenney authorizes this implementation; final artistic acceptance remains their judgment.

The [asset manifest](../assets/UPSTREAM_SOURCES.json) records sources and hashes. The actual Godot captures show empty and populated states at 1440 × 960.
