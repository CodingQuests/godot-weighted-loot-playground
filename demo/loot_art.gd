extends Control
## Original Kenney CC0 sprites, shared by the UI, reveal and history.
const TEXTURES: Array[Texture2D] = [preload("res://assets/kenney/coin.png"), preload("res://assets/kenney/potion.png"), preload("res://assets/kenney/gem.png"), preload("res://assets/kenney/relic.png")]
var item := 0

func _draw() -> void:
	var source := TEXTURES[item % TEXTURES.size()]
	var extent := floorf(minf(size.x, size.y) / source.get_width()) * source.get_width()
	draw_texture_rect(TEXTURES[item % TEXTURES.size()], Rect2((size - Vector2.ONE * extent) / 2, Vector2.ONE * extent), false)

static func paint(canvas: CanvasItem, center: Vector2, s: float, index: int, _color: Color) -> void:
	var source := TEXTURES[index % TEXTURES.size()]
	# Whole pixel scales preserve the original art without blurring or uneven edges.
	var extent := maxf(1.0, floorf(38.0 * s / source.get_width())) * source.get_width()
	canvas.draw_texture_rect(TEXTURES[index % TEXTURES.size()], Rect2(center - Vector2.ONE * extent / 2, Vector2.ONE * extent), false)

static func box(color: Color, radius := 2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	return style
