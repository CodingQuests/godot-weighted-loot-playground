extends SceneTree

const Table = preload("res://components/weighted_loot_table.gd")
const Experiment = preload("res://demo/loot_experiment.gd")
var failures := 0
var checks := 0


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + description)


func _initialize() -> void:
	var table := Table.new()
	check(table.validation_error().is_empty(), "default table valid")
	var odds := table.probabilities()
	check(is_equal_approx(odds[0], 0.6) and is_equal_approx(odds[3], 0.05), "default probabilities")
	var original := table.probabilities()
	table.weights = [120, 50, 20, 10]
	check(table.probabilities() == original, "scaling weights preserves probabilities")
	table.item_ids = ["A", "disabled", "B", "off"]
	table.weights = [1, 0, 3, 0]
	check(table.pick_index_at(0) == 0, "lower boundary")
	check(table.pick_index_at(0.249999) == 0, "inside first interval")
	check(table.pick_index_at(0.25) == 2, "exact boundary skips zero weight")
	check(table.pick_index_at(0.9999999999) == 2, "last positive interval")
	check(table.pick_index_at(1) == -1 and table.pick_index_at(-0.1) == -1, "out of range draws rejected")
	check(table.pick_index_at(NAN) == -1, "NaN draw rejected")
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var excluded := true
	for _i in 10000:
		var index := table.roll_index(rng)
		excluded = excluded and index in [0, 2]
	check(excluded, "disabled entries never drawn in 10000 rolls")
	table.weights = [0, 0, 1, 0]
	check(table.roll_id(rng) == "B", "single active item")
	table.weights = [0, 0, 0, 0]
	check(not table.validation_error().is_empty() and table.roll_index(rng) == -1, "all-zero table rejected")
	table.weights = [1, -1, 1, 1]
	check(not table.validation_error().is_empty(), "negative weights rejected")
	table.weights = [INF, 1, 1, 1]
	check(not table.validation_error().is_empty(), "infinite weights rejected")
	table.weights = [NAN, 1, 1, 1]
	check(not table.validation_error().is_empty(), "NaN weights rejected")
	table.weights = [1e308, 1e308, 1e308, 1e308]
	check(is_equal_approx(table.probabilities()[0], 0.25), "large finite weights avoid overflow")
	table.weights = [1e-300, 1e-300, 1e-300, 1e-300]
	check(is_equal_approx(table.probabilities()[0], 0.25), "small finite equal weights")
	table.item_ids = ["A", "A", "B", "C"]
	check(not table.validation_error().is_empty(), "duplicate IDs rejected")
	table.item_ids = ["", "A", "B", "C"]
	check(not table.validation_error().is_empty(), "empty IDs rejected")
	table.item_ids = ["A"]
	check(not table.validation_error().is_empty(), "mismatched lengths rejected")
	table.item_ids = []
	table.weights = []
	check(not table.validation_error().is_empty() and table.roll_id(rng) == "", "empty table safe")
	table = Table.new()
	check(table.roll_index(null) == -1, "null RNG safe")
	var experiment := Experiment.new(table)
	experiment.restart(42)
	experiment.roll_many(100)
	var sequence: Array[int] = experiment.recent.duplicate()
	var counts: PackedInt64Array = experiment.counts.duplicate()
	experiment.restart(42)
	experiment.roll_many(100)
	check(sequence == experiment.recent and counts == experiment.counts, "same seed replays sequence")
	experiment.restart(42)
	check(experiment.total == 0 and experiment.recent.is_empty(), "restart clears results")
	for _i in 10:
		experiment.roll_many(10000)
	var sum := 0
	for count in experiment.counts:
		sum += count
	check(sum == 100000 and experiment.total == sum, "count conservation")
	for i in 4:
		var measured := float(experiment.counts[i]) / experiment.total
		check(absf(measured - original[i]) < 0.01, "100000-roll frequency within one percentage point: " + table.item_ids[i])
	print("Distribution (seed 42, n=100000): ", experiment.counts)
	print("CORE TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
