# From weights to drops

## Explain

A weight describes how often an option should be selected relative to the other options. Weights do not need to sum to 100. For weights `[6, 3, 1]`, the total is 10, so the probabilities are 60%, 30%, and 10%.

Divide each weight by the total and place the resulting intervals end to end:

```text
0.0                    0.6           0.9   1.0
|--------- A -----------|----- B ------|- C -|
```

Draw a number in `[0, 1)`. A value of 0.2 selects A; 0.7 selects B; 0.95 selects C. At exactly 0.6, choose B. Each interval includes its left boundary and excludes its right boundary. A zero weight occupies no space and must never be selected, including when the random point is zero.

The implementation scales weights by the largest weight before normalizing, which prevents overflow when their unscaled sum would be too large. This preserves ratios. Invalid tables return a sentinel (`-1` or `""`); they never silently award the final item.

## Demonstrate

Run the default demo and click +100. Observed proportions can differ noticeably from 60/25/10/5. Add 10,000 and compare again. Larger samples generally give a better estimate; convergence need not be monotonic, and exact counts are never guaranteed.

At a 5% Relic probability, the probability of receiving zero Relics in 20 independent rolls is `0.95^20`, roughly 35.8%. A streak without a rare item is not by itself a bug. This project does not implement a guarantee or a pity system.

Restart with the same seed and settings. The sequence repeats on the supported engine version. When settings change, the demo clears the old results so counts from different distributions are not misleadingly mixed.

For Godot's built-in alternative, see [RandomNumberGenerator.rand_weighted](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html#class-randomnumbergenerator-method-rand-weighted). This example exposes its own cumulative intervals to make their behavior inspectable.

## Experiment: target one probability

Keep Coin = 60, Potion = 25, and Relic = 5. Change only Gem so its probability is exactly 20%.

1. Predict the weight. Remember that changing Gem also changes the total.
2. Open `demo/default_loot.tres` in Godot's Inspector and edit the third weight.
3. Run the project. Check the expected Gem label, then roll 10,000 times.
4. Explain why the observed fraction can differ from exactly 20%.

<details>
<summary>Check your reasoning after trying</summary>

The other weights sum to 90. Solve `g / (90 + g) = 0.2`: `0.8g = 18`, so **g = 22.5**. You can also type 22.5 into the live Gem control and press Enter. Expected probabilities are exact ratios up to floating-point precision; observed results are a finite random sample.

</details>

Extension: double all four weights. Explain why this changes neither the probability labels nor the seeded sequence in this implementation. Then replace loot IDs with enemy types and reuse the component to choose spawns.
