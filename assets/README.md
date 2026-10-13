# Kenney artwork

The shipped demo uses original **Kenney** pixel-art assets under **CC0 1.0**. The PNG bytes are copied unchanged from official downloads. Godot displays them with nearest-neighbor filtering and whole pixel scales. The room layout and interaction code were created for CodingQuests.

| Local file | Original source | Use |
| --- | --- | --- |
| `kenney/tiny-dungeon.png` | Tiny Dungeon 1.0: `Tilemap/tilemap_packed.png` | Room tiles, adventurer, decorations, and chest states |
| `kenney/potion.png` | Tiny Dungeon: `Tiles/tile_0115.png` | Potion |
| `kenney/coin.png` | Pixel Platformer 1.2: `Tiles/tile_0151.png` | Coin |
| `kenney/gem.png` | Pixel Platformer: `Tiles/tile_0067.png` | Gem |
| `kenney/relic.png` | Pixel Platformer: `Tiles/tile_0027.png` | The rare Relic is represented by a golden key |

Official pack pages: [Tiny Dungeon](https://kenney.nl/assets/tiny-dungeon) and [Pixel Platformer](https://kenney.nl/assets/pixel-platformer).

Original license files are preserved as [Tiny Dungeon](kenney/LICENSE-Tiny-Dungeon.txt) and [Pixel Platformer](kenney/LICENSE-Pixel-Platformer.txt). CC0 allows personal, educational, and commercial use; attribution is optional, but we credit Kenney in the demo and README. The source mapping and checksums are in [UPSTREAM_SOURCES.json](UPSTREAM_SOURCES.json).

No generated artwork is included in this release. Earlier generated variants were retired from the public project. The unused Kenney packs inspected during selection are also excluded.

To try another theme, replace these PNGs and update the atlas tile mapping in `demo/loot_stage.gd`. Keep the original asset licenses when adding packs. Copying only `components/weighted_loot_table.gd` into another game does not require any demo artwork.
