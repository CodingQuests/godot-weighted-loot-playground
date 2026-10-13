extends SceneTree
## Runs the actual scene, dispatches GUI mouse events, and captures its viewport.
## -- --capture=absolute/path.png optionally writes an actual rendered screenshot.

var demo: Control
var failures := 0
var checks := 0


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + description)


func _initialize() -> void:
	call_deferred("run")


func click_control(control: Control) -> void:
	var point := control.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = point
	Input.parse_input_event(motion)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame


func key(code: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame


func run() -> void:
	demo = load("res://demo/loot_playground.tscn").instantiate()
	root.add_child(demo)
	await process_frame
	await process_frame
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--empty-capture="):
			await RenderingServer.frame_post_draw
			var error := root.get_texture().get_image().save_png(argument.trim_prefix("--empty-capture="))
			check(error == OK, "save initial viewport")
	check(demo.experiment.total == 0, "demo starts empty")
	await click_control(demo.roll_buttons[0])
	check(demo.experiment.total == 1, "mouse Roll 1")
	await click_control(demo.roll_buttons[1])
	check(demo.experiment.total == 101, "mouse +100")
	await click_control(demo.roll_buttons[2])
	check(demo.experiment.total == 10101, "mouse +10000")
	root.gui_release_focus()
	await key(KEY_R)
	check(demo.experiment.total == 0, "R resets")
	await key(KEY_SPACE)
	check(demo.experiment.total == 1, "Space rolls")
	# Range changes test the same value_changed connection used by SpinBox editing.
	demo.weight_inputs[3].value = 0
	check(demo.experiment.total == 0 and demo.table.weights[3] == 0, "weight edit resets and applies")
	await click_control(demo.roll_buttons[2])
	check(demo.experiment.counts[3] == 0, "zero relic weight respected by scene")
	demo.set_weights([0, 0, 0, 0])
	check(demo.roll_buttons[0].disabled and demo.roll_buttons[3].disabled, "all-zero disables roll controls")
	await key(KEY_SPACE)
	check(demo.experiment.total == 0, "invalid table cannot roll by shortcut")
	demo.set_weights([60, 25, 10, 5])
	var equal_button: Button = demo.find_children("*", "Button", true, false).filter(func(button: Button) -> bool: return button.text == "Equal")[0]
	await click_control(equal_button)
	check(demo.table.weights == PackedFloat64Array([1, 1, 1, 1]), "Equal preset mouse click")
	var no_relic_button: Button = demo.find_children("*", "Button", true, false).filter(func(button: Button) -> bool: return button.text == "No relic")[0]
	await click_control(no_relic_button)
	check(demo.table.weights[3] == 0, "No relic preset mouse click")
	var default_button: Button = demo.find_children("*", "Button", true, false).filter(func(button: Button) -> bool: return button.text == "Defaults")[0]
	await click_control(default_button)
	check(demo.table.weights == PackedFloat64Array([60, 25, 10, 5]), "Defaults preset mouse click")
	var entry: LineEdit = demo.weight_inputs[0].get_line_edit()
	await click_control(entry)
	entry.text = "120"
	await key(KEY_ENTER)
	check(demo.table.weights[0] == 120, "typed weight commits with Enter")
	demo.weight_inputs[2].value = 22.5
	check(is_equal_approx(demo.table.weights[2], 22.5), "fractional weight edit")
	await click_control(default_button)
	await click_control(demo.auto_button)
	await create_timer(0.35).timeout
	check(demo.experiment.total >= 2, "auto roll timer runs")
	await click_control(demo.auto_button)
	var paused: int = demo.experiment.total
	await create_timer(0.25).timeout
	check(demo.experiment.total == paused, "auto roll pauses")
	demo.seed_input.value = 43
	check(demo.experiment.total == 0 and demo.experiment.rng.seed == 43, "seed edit resets RNG")
	demo.seed_input.value = 42
	await click_control(demo.roll_buttons[2])
	root.gui_release_focus()
	await process_frame
	await create_timer(0.7).timeout
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			await RenderingServer.frame_post_draw
			var error := root.get_texture().get_image().save_png(argument.trim_prefix("--capture="))
			check(error == OK, "save actual rendered viewport")
	print("DEMO TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
