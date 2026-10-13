class_name CQWeightedLootTable
extends Resource
## A small, standalone weighted choice resource. No nodes or autoloads required.
## Each roll selects one ID with replacement. Zero weights disable an entry.

@export var item_ids: PackedStringArray = ["Coin", "Potion", "Gem", "Relic"]
@export var weights: PackedFloat64Array = [60.0, 25.0, 10.0, 5.0]


func validation_error() -> String:
	if item_ids.is_empty():
		return "Add at least one item."
	if item_ids.size() != weights.size():
		return "Give every item exactly one weight."
	var seen: Dictionary = {}
	var has_positive := false
	for i in item_ids.size():
		if item_ids[i].strip_edges().is_empty() or seen.has(item_ids[i]):
			return "Item IDs must be nonempty and unique."
		seen[item_ids[i]] = true
		if not is_finite(weights[i]) or weights[i] < 0.0:
			return "Weights must be finite and nonnegative."
		has_positive = has_positive or weights[i] > 0.0
	return "" if has_positive else "Set at least one weight above zero."


func probabilities() -> PackedFloat64Array:
	if not validation_error().is_empty():
		return PackedFloat64Array()
	# Scaling first avoids overflow when otherwise valid weights are very large.
	var largest := 0.0
	for weight in weights:
		largest = maxf(largest, weight)
	var result := PackedFloat64Array()
	var total := 0.0
	for weight in weights:
		var scaled := weight / largest
		result.append(scaled)
		total += scaled
	for i in result.size():
		result[i] /= total
	return result


func pick_index_at(unit_value: float) -> int:
	## Exposed for experiments and boundary tests. Input must be in [0, 1).
	if not is_finite(unit_value) or unit_value < 0.0 or unit_value >= 1.0:
		return -1
	var odds := probabilities()
	var cumulative := 0.0
	var last_positive := -1
	for i in odds.size():
		if odds[i] <= 0.0:
			continue
		last_positive = i
		cumulative += odds[i]
		if unit_value < cumulative:
			return i
	# Floating-point sums can finish a fraction below 1. Never pick a zero entry.
	return last_positive


func roll_index(rng: RandomNumberGenerator) -> int:
	if rng == null:
		return -1
	# randi() is a 32-bit unsigned integer. Division gives a value below 1.
	return pick_index_at(float(rng.randi()) / 4294967296.0)


func roll_id(rng: RandomNumberGenerator) -> String:
	var index := roll_index(rng)
	return item_ids[index] if index >= 0 else ""
