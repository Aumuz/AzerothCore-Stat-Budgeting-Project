# ============================================================================================
# Filename:       ACSBV3-03-01A_delta_comparison.py
# Title:          Phase 03 – Cross-Family ? Comparison (Equipment vs Weapons)
# Author:         ChatGPT
# Version:        1.0
# Created:        2025-10-24
# Description:
#   Compares smoothed, aggregated Equipment and Weapon curves to determine
#   percent deviation (?) per ItemLevel and Quality.
#   ? = |Budget_weapon - Budget_equipment| / Budget_equipment * 100
# ============================================================================================

import pandas as pd
import numpy as np

# ---------------------------------------------------------------------------
# 1. Load aggregated dataset
# ---------------------------------------------------------------------------
df = pd.read_csv("ACSBV3_03_01A_curve_aggregated.csv")

# Pivot so each row has equipment and weapon side-by-side
pivot = (
    df.pivot_table(
        index=["ItemLevel", "Quality"],
        columns="item_family",
        values="median_budget"
    )
    .reset_index()
)

# Drop rows missing either family
pivot = pivot.dropna(subset=["equipment", "weapon"])

# ---------------------------------------------------------------------------
# 2. Compute ? (percent difference)
# ---------------------------------------------------------------------------
pivot["delta"] = (
    (pivot["weapon"] - pivot["equipment"]).abs() / pivot["equipment"] * 100
)

# ---------------------------------------------------------------------------
# 3. Save results
# ---------------------------------------------------------------------------
pivot.to_csv("ACSBV3_03_01A_curve_comparison.csv", index=False)

# ---------------------------------------------------------------------------
# 4. Summary statistics
# ---------------------------------------------------------------------------
summary = pivot.groupby("Quality")["delta"].agg(
    mean_delta="mean",
    median_delta="median",
    p90=lambda x: np.percentile(x, 90),
    max_delta="max"
).reset_index()

print("? Comparison Complete.\n")
print(summary)
print("\nOverall mean ?:", round(pivot["delta"].mean(), 2), "%")

# ============================================================================================
# End of File
# ============================================================================================
