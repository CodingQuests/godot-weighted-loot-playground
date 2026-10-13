extends Control
const Art = preload("res://demo/loot_art.gd")
const COLORS: Array[Color] = [Color("e7ba61"), Color("e88d7f"), Color("86b6d1"), Color("c69ddf")]
var experiment: RefCounted

func _draw() -> void:
	if experiment == null:
		return
	var font := ThemeDB.fallback_font
	var odds: PackedFloat64Array = experiment.table.probabilities()
	var width := size.x / 4
	for i in 4:
		var x := i * width
		var track_width := width - 38
		var expected := odds[i] if not odds.is_empty() else 0.0
		var actual: float = float(experiment.counts[i]) / experiment.total if experiment.total > 0 else 0.0
		var color := COLORS[i]
		if i > 0:
			draw_line(Vector2(x - 16, 2), Vector2(x - 16, 109), Color("504a3f"), 1)
		Art.paint(self, Vector2(x + 21, 25), 1.0, i, color)
		draw_string(font, Vector2(x + 50, 22), experiment.table.item_ids[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("ece5d8"))
		draw_string(font, Vector2(x + 50, 40), str(experiment.counts[i]) + " drops", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("b9b09e"))
		draw_style_box(Art.box(Color("454137")), Rect2(x, 59, track_width, 6))
		if actual > 0:
			draw_style_box(Art.box(color), Rect2(x, 59, track_width * actual, 6))
		if expected > 0:
			var marker := x + track_width * expected
			draw_line(Vector2(marker, 53), Vector2(marker, 71), Color("ece5d8"), 2, true)
		var observed := "%.1f%%" % (actual * 100) if experiment.total > 0 else "—"
		draw_string(font, Vector2(x, 90), "EXPECTED  %.1f%%" % (expected * 100), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("b9b09e"))
		draw_string(font, Vector2(x + 142, 90), "ACTUAL  " + observed, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, color)
		draw_string(font, Vector2(x, 108), "0", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("a49c8c"))
		draw_string(font, Vector2(x + track_width - 29, 108), "100%", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("a49c8c"))
