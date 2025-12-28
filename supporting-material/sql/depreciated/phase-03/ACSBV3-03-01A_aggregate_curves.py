# ============================================================================================
# Filename:       ACSBV3-03-01A_aggregate_curves.py
# Title:          Phase 03 – Aggregate Smoothed Curves (Median per iLvl / Quality / Family)
# Author:         ChatGPT
# Version:        1.0
# Created:        2025-10-24
# Description:
#   Aggregates the smoothed normalized budgets into one median point per
#   (ItemLevel, Quality, item_family).  Output will be used for ?-comparison.
# ============================================================================================

import pandas as pd

# ---------------------------------------------------------------------------
# 1. Load both smoothed curve CSVs
# ---------------------------------------------------------------------------
equip = pd.read_csv("ACSBV3_03_00A_curve_equipment_smooth.csv")
weap  = pd.read_csv("ACSBV3_03_00B_curve_weapons_smooth.csv")

# Ensure consistent columns
equip["item_family"] = "equipment"
weap["item_family"]  = "weapon"

# Merge both into one DataFrame
df = pd.concat([equip, weap], ignore_index=True)

# ---------------------------------------------------------------------------
# 2. Aggregate by (ItemLevel, Quality, item_family)
# ---------------------------------------------------------------------------
agg = (
    df.groupby(["ItemLevel", "Quality", "item_family"], as_index=False)["smoothed"]
    .median()
    .rename(columns={"smoothed": "median_budget"})
)

# Sort for clarity
agg = agg.sort_values(["item_family", "Quality", "ItemLevel"])

# ---------------------------------------------------------------------------
# 3. Save outputs
# ---------------------------------------------------------------------------
agg.to_csv("ACSBV3_03_01A_curve_aggregated.csv", index=False)

# Optional diagnostic: show sample
print("Aggregation complete.")
print(agg.groupby("item_family")["ItemLevel"].agg(["min", "max", "count"]))
print("\nPreview:")
print(agg.head(10))
# ============================================================================================
# End of File
# ============================================================================================
