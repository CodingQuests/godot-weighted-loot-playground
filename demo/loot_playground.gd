extends Control

const Experiment = preload("res://demo/loot_experiment.gd")
const Chart = preload("res://demo/loot_chart.gd")
const Art = preload("res://demo/loot_art.gd")
const Stage = preload("res://demo/loot_stage.gd")
const History = preload("res://demo/loot_history.gd")
const DEFAULT_TABLE = preload("res://demo/default_loot.tres")
const INK := Color("ece5d8")
const MUTED := Color("b9b09e")
var table: CQWeightedLootTable
var experiment: RefCounted
var weight_inputs: Array[SpinBox] = []
var odds_labels: Array[Label] = []
var seed_input: SpinBox
var status_label: Label
var total_label: Label
var chart: Control
var stage: Control
var history: Control
var roll_buttons: Array[Button] = []
var auto_button: Button
var timer: Timer
var updating := false

func _ready() -> void:
	# Kenney's pixel sprites use nearest filtering and whole pixel scales.
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	table = DEFAULT_TABLE.duplicate(true)
	experiment = Experiment.new(table)
	_build_interface()
	timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(func() -> void: _roll(1))
	add_child(timer)
	restart()

func _build_interface() -> void:
	var background := ColorRect.new()
	background.color = Color("252420")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var shade := ColorRect.new()
	shade.color = Color.TRANSPARENT
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var ui_theme := Theme.new()
	ui_theme.default_font_size = 15
	ui_theme.set_color("font_color", "Label", INK)
	for key in ["font_color", "font_hover_color", "font_pressed_color"]:
		ui_theme.set_color(key, "Button", INK)
	ui_theme.set_color("font_disabled_color", "Button", Color("80796e"))
	ui_theme.set_color("font_color", "LineEdit", INK)
	ui_theme.set_color("caret_color", "LineEdit", INK)
	ui_theme.set_color("selection_color", "LineEdit", Color("454137"))
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := _panel(Color("302e29") if state == "normal" else Color("454137"), 2, 12)
		style.content_margin_top = 10
		style.content_margin_bottom = 10
		ui_theme.set_stylebox(state, "Button", style)
	var focus := _panel(Color.TRANSPARENT, 2, 0)
	focus.border_color = Color("dfad59")
	focus.set_border_width_all(2)
	ui_theme.set_stylebox("focus", "Button", focus)
	ui_theme.set_stylebox("normal", "LineEdit", _panel(Color("302e29"), 2, 8))
	ui_theme.set_stylebox("focus", "LineEdit", focus)
	for direction in ["up", "down"]:
		for suffix in ["", "_hover", "_pressed", "_disabled"]:
			ui_theme.set_icon(direction + suffix, "SpinBox", _arrow_icon(direction == "up"))
	theme = ui_theme
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for edge in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 24 if edge in ["top", "bottom"] else 40)
	scroll.add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 10)
	margin.add_child(page)
	var nav := HBoxContainer.new()
	page.add_child(nav)
	var brand := _label(nav, "C O D I N G Q U E S T S    /    THE FREE RESOURCE COLLECTION", 11, Color("dfad59"))
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(nav, "GODOT 4.7.2   ·   MIT LICENSE", 11, MUTED)
	var title := _label(page, "Weighted Loot Playground", 40)
	title.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 3)
	_label(page, "Set the odds. Uncover the treasure. Learn what chance really means.", 15, Color("c3bcae"))
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 30)
	page.add_child(columns)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 12)
	columns.add_child(left)
	stage = Stage.new()
	stage.clip_contents = true
	stage.experiment = experiment
	stage.custom_minimum_size = Vector2(890, 330)
	left.add_child(stage)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 10)
	left.add_child(actions)
	var primary := _button(actions, "DRAW TREASURE   [Space]", func() -> void: _roll(1))
	_primary_style(primary)
	primary.custom_minimum_size.x = 270
	roll_buttons.append(primary)
	roll_buttons.append(_button(actions, "+100", func() -> void: _roll(100)))
	roll_buttons.append(_button(actions, "+10,000", func() -> void: _roll(10000)))
	auto_button = _button(actions, "Auto roll", _toggle_auto)
	roll_buttons.append(auto_button)
	var history_box := _card(left, 0, true, 12)
	_label(history_box, "RECENT FINDS     /     OLDEST → NEWEST", 10, MUTED)
	history = History.new()
	history.experiment = experiment
	history.custom_minimum_size.y = 38
	history_box.add_child(history)
	var settings := _card(columns, 370, false, 20)
	settings.add_theme_constant_override("separation", 5)
	_label(settings, "THE LOOT TABLE", 11, Color("dfad59"))
	_label(settings, "Change your fortune", 23)
	_label(settings, "Weights are relative. Zero disables an item.", 12, MUTED)
	_separator(settings)
	for i in table.item_ids.size():
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 49
		row.add_theme_constant_override("separation", 12)
		settings.add_child(row)
		_icon(row, i, 48)
		var words := VBoxContainer.new()
		words.alignment = BoxContainer.ALIGNMENT_CENTER
		words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(words)
		_label(words, table.item_ids[i], 16)
		odds_labels.append(_label(words, "", 12, Chart.COLORS[i]))
		var spin := SpinBox.new()
		spin.min_value = 0
		spin.max_value = 1000
		spin.step = 0.1
		spin.value = table.weights[i]
		spin.custom_minimum_size.x = 95
		spin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		spin.get_line_edit().alignment = HORIZONTAL_ALIGNMENT_CENTER
		spin.tooltip_text = "Relative weight. Type a value and press Enter. Zero disables this item."
		spin.value_changed.connect(_weight_changed.bind(i))
		row.add_child(spin)
		weight_inputs.append(spin)
	var presets := HBoxContainer.new()
	presets.add_theme_constant_override("separation", 6)
	settings.add_child(presets)
	for preset in ["Defaults", "Equal", "No relic"]:
		var values := {"Defaults": [60,25,10,5], "Equal": [1,1,1,1], "No relic": [60,25,10,0]}
		var button := _button(presets, preset, func() -> void: set_weights(PackedFloat64Array(values[preset])))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 13)
	_separator(settings)
	var seed_row := HBoxContainer.new()
	settings.add_child(seed_row)
	var seed_label := _label(seed_row, "Experiment seed", 13, MUTED)
	seed_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seed_input = SpinBox.new()
	seed_input.max_value = 2147483647
	seed_input.step = 1
	seed_input.value = 42
	seed_input.custom_minimum_size.x = 148
	seed_input.value_changed.connect(func(_value: float) -> void: restart())
	seed_row.add_child(seed_input)
	_button(settings, "↺  Restart same seed   [R]", restart)
	status_label = _label(settings, "", 11, MUTED)
	status_label.custom_minimum_size = Vector2(300, 30)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var results := _card(page, 0, true, 16)
	var result_header := HBoxContainer.new()
	results.add_child(result_header)
	var heading := _label(result_header, "THE RECORD OF YOUR FINDS", 11, Color("dfad59"))
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(result_header, "Marker: expected odds   /   Bar: actual frequency     ", 11, MUTED)
	total_label = _label(result_header, "0 rolls", 19)
	chart = Chart.new()
	chart.experiment = experiment
	chart.custom_minimum_size.y = 111
	results.add_child(chart)
	var footer := HBoxContainer.new()
	page.add_child(footer)
	var quest := VBoxContainer.new()
	quest.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(quest)
	_label(quest, "TRY THIS  /  Double every weight. Will the odds change?", 14)
	_label(quest, "Every draw is independent. A 5% chance does not promise one drop in twenty.", 12, MUTED)
	var footer_right := VBoxContainer.new()
	footer.add_child(footer_right)
	_label(footer_right, "Tab: navigate   ·   Enter: apply   ·   R: restart", 11, MUTED)
	_label(footer_right, "Art: Kenney · CC0", 11, MUTED)
	var credit := LinkButton.new()
	credit.text = "Made by CodingQuests  ↗"
	credit.add_theme_color_override("font_color", Color("dfad59"))
	credit.add_theme_font_size_override("font_size", 12)
	credit.pressed.connect(func() -> void: OS.shell_open("https://codingquests.io"))
	footer_right.add_child(credit)

func _panel(color: Color, radius := 2, padding := 20) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("504a3f")
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	for edge in ["left", "top", "right", "bottom"]:
		style.set("content_margin_" + edge, float(padding))
	return style

func _card(parent: Node, width := 0, expand := true, padding := 20) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel(Color("302e29"), 2, padding))
	panel.custom_minimum_size.x = width
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if expand else Control.SIZE_FILL
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	panel.add_child(box)
	return box

func _label(parent: Node, value: String, font_size: int, color := INK) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _button(parent: Node, value: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = value
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _icon(parent: Node, index: int, extent: int) -> void:
	var icon := Art.new()
	icon.item = index
	icon.custom_minimum_size = Vector2(extent, extent)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(icon)

func _separator(parent: Node) -> void:
	var separator := HSeparator.new()
	var style := StyleBoxLine.new()
	style.color = Color("504a3f")
	style.thickness = 1
	separator.add_theme_stylebox_override("separator", style)
	parent.add_child(separator)

func _primary_style(button: Button) -> void:
	for state in ["normal", "hover", "pressed"]:
		button.add_theme_stylebox_override(state, _panel(Color("dfad59") if state == "normal" else Color("ebc57f"), 2, 12))
	for state in ["font_color", "font_hover_color", "font_pressed_color"]:
		button.add_theme_color_override(state, Color("252015"))

func _arrow_icon(up: bool) -> Texture2D:
	var points := "M2 8 L6 4 L10 8" if up else "M2 4 L6 8 L10 4"
	var svg := '<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12"><path d="%s" fill="none" stroke="#dfad59" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>' % points
	var icon := Image.new()
	icon.load_svg_from_string(svg)
	return ImageTexture.create_from_image(icon)

func _weight_changed(value: float, index: int) -> void:
	if updating:
		return
	table.weights[index] = value
	restart()

func set_weights(values: PackedFloat64Array) -> void:
	updating = true
	for i in values.size():
		weight_inputs[i].value = values[i]
		table.weights[i] = weight_inputs[i].value
	updating = false
	restart()

func restart() -> void:
	if timer != null:
		timer.stop()
	auto_button.text = "Auto roll"
	experiment.restart(int(seed_input.value))
	_refresh()

func _roll(amount: int) -> void:
	experiment.roll_many(amount)
	_refresh()
	stage.reveal()

func _toggle_auto() -> void:
	if timer.is_stopped():
		timer.start()
		auto_button.text = "Pause"
	else:
		timer.stop()
		auto_button.text = "Auto roll"

func _refresh() -> void:
	var error := table.validation_error()
	status_label.text = "Same seed, same sequence.\nEditing weights begins a new experiment." if error.is_empty() else error
	status_label.modulate = Color.WHITE if error.is_empty() else Color("f59685")
	for button in roll_buttons:
		button.disabled = not error.is_empty()
	var odds := table.probabilities()
	for i in odds_labels.size():
		odds_labels[i].text = "%.1f%% chance" % (odds[i] * 100) if not odds.is_empty() else "Set a weight"
	var count_text := str(experiment.total)
	for position in range(count_text.length() - 3, 0, -3):
		count_text = count_text.insert(position, ",")
	total_label.text = "%s rolls" % count_text
	chart.queue_redraw()
	stage.queue_redraw()
	history.queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	if get_viewport().gui_get_focus_owner() is LineEdit:
		return
	if event.keycode == KEY_SPACE:
		_roll(1)
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_R:
		restart()
		get_viewport().set_input_as_handled()
