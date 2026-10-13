extends Control
## A small room assembled from Kenney Tiny Dungeon's original 16px tiles.
const Art = preload("res://demo/loot_art.gd")
const DUNGEON = preload("res://assets/kenney/tiny-dungeon.png")
const CELL := 48
const ORIGIN := Vector2(44, 20)
var experiment: RefCounted
var pulse := 0.0
var motion: Tween

func reveal() -> void:
	if motion:
		motion.kill()
	pulse = 1.0
	motion = create_tween()
	motion.tween_method(func(value: float) -> void: pulse = value; queue_redraw(), 1.0, 0.0, 0.65)
	queue_redraw()

func _tile(index: int, cell: Vector2i, offset := Vector2.ZERO) -> void:
	var source := Rect2((index % 12) * 16, (index / 12) * 16, 16, 16)
	draw_texture_rect_region(DUNGEON, Rect2(ORIGIN + Vector2(cell) * CELL + offset, Vector2.ONE * CELL), source)

func _draw() -> void:
	var dropped: bool = experiment != null and not experiment.recent.is_empty()
	for y in 6:
		for x in 12:
			var tile := 48
			if y == 0:
				tile = 1 if x == 0 else (3 if x == 11 else 2)
			elif y == 5:
				tile = 25 if x == 0 else (27 if x == 11 else 26)
			elif x == 0:
				tile = 13
			elif x == 11:
				tile = 15
			elif y == 1:
				tile = 14
			elif (x * 7 + y * 3) % 13 == 0:
				tile = 49
			_tile(tile, Vector2i(x,y))
	# Decorations are sparse so the player and chest remain easy to identify.
	_tile(29, Vector2i(3,1))
	_tile(29, Vector2i(8,1))
	_tile(63, Vector2i(1,3))
	_tile(74, Vector2i(9,3))
	_tile(99, Vector2i(5,3))
	_tile(91 if dropped else 89, Vector2i(6,3), Vector2(0, -roundf(pulse*2)*3))
	var font := ThemeDB.fallback_font
	var center := Vector2(size.x - 135, size.y / 2)
	if not dropped:
		draw_string(font, center + Vector2(-130, 16), "Your next find?", HORIZONTAL_ALIGNMENT_CENTER, 260, 23, Color("ece5d8"))
		draw_string(font, center + Vector2(-130, 43), "Draw treasure to open the chest.", HORIZONTAL_ALIGNMENT_CENTER, 260, 13, Color("b9b09e"))
		return
	var index: int = experiment.recent.back()
	Art.paint(self, center - Vector2(0, 28 + roundf(pulse * 5)*3), 3.8, index, Color.WHITE)
	draw_string(font, center + Vector2(-130, -122), "YOU FOUND", HORIZONTAL_ALIGNMENT_CENTER, 260, 11, Color("dfad59"))
	draw_string(font, center + Vector2(-130, 80), experiment.table.item_ids[index], HORIZONTAL_ALIGNMENT_CENTER, 260, 28, Color("ece5d8"))
	draw_string(font, center + Vector2(-130, 103), "Latest draw · items return to the pool", HORIZONTAL_ALIGNMENT_CENTER, 260, 11, Color("b9b09e"))
