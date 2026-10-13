extends RefCounted
## Demo state is separate from the reusable picker and the presentation.

var table: CQWeightedLootTable
var rng := RandomNumberGenerator.new()
var counts: PackedInt64Array = []
var recent: Array[int] = []
var total := 0


func _init(source: CQWeightedLootTable) -> void:
	table = source


func restart(seed_value: int) -> void:
	rng.seed = seed_value
	counts.resize(table.item_ids.size())
	counts.fill(0)
	recent.clear()
	total = 0


func roll_many(amount: int) -> void:
	if not table.validation_error().is_empty():
		return
	for _i in clampi(amount, 0, 10000):
		var index := table.roll_index(rng)
		if index < 0:
			return
		counts[index] += 1
		total += 1
		recent.append(index)
		if recent.size() > 20:
			recent.pop_front()
