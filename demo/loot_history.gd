extends Control
const Art = preload("res://demo/loot_art.gd")
var experiment: RefCounted

func _draw() -> void:
	var cell := (size.x - 19 * 5) / 20
	for i in 20:
		var x := i * (cell + 5)
		draw_style_box(Art.box(Color("454137")), Rect2(x, 0, cell, 38))
		if experiment != null and i < experiment.recent.size():
			Art.paint(self, Vector2(x + cell / 2, 19), minf(cell - 4, 36) / 38, experiment.recent[i], Color.WHITE)
		else:
			draw_circle(Vector2(x + cell / 2, 19), 1.2, Color("8b816a"))
