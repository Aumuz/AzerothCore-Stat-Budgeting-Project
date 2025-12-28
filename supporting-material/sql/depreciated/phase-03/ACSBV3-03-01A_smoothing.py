# ============================================================================================
# Filename:       ACSBV3-03-01A_smoothing.py
# Title:          Phase 03 – Rolling Median + Monotonic Enforcement (Normalized Budgets)
# Author:         ChatGPT
# Version:        1.0
# Created:        2025-10-24
# Description:
#   Applies a 3-point rolling median and monotonic enforcement to the normalized_budget
#   for each (item_family, Quality) group in ACSBV3_03_00B_curve_export.csv.
#
#   Outputs:
#     - ACSBV3_03_00A_curve_equipment_smooth.csv
#     - ACSBV3_03_00B_curve_weapons_smooth.csv
# ============================================================================================

import pandas as pd
import numpy as np

# ---------------------------------------------------------------------------
# 1. Load dataset
# ---------------------------------------------------------------------------
df = pd.read_csv("ACSBV3_03_00B_curve_export.csv")

# Keep only necessary fields
df = df[["ItemLevel", "Quality", "normalized_budget", "item_family"]]

# ---------------------------------------------------------------------------
# 2. Function to smooth one subset (3-point rolling median + monotonic enforcement)
# ---------------------------------------------------------------------------
def smooth_curve(sub):
    sub = sub.sort_values("ItemLevel").copy()
    sub["smoothed"] = sub["normalized_budget"].rolling(window=3, center=True).median()
    sub["smoothed"] = sub["smoothed"].fillna(method="bfill").fillna(method="ffill")

    # Monotonic enforcement
    y = sub["smoothed"].values
    for i in range(1, len(y)):
        if y[i] < y[i - 1]:
            y[i] = y[i - 1]
    sub["smoothed"] = y
    return sub

# ---------------------------------------------------------------------------
# 3. Apply smoothing per item_family and Quality
# ---------------------------------------------------------------------------
smoothed_frames = []

for family in df["item_family"].unique():
    fam_df = df[df["item_family"] == family]
    for q in sorted(fam_df["Quality"].unique()):
        subset = fam_df[fam_df["Quality"] == q]
        smoothed = smooth_curve(subset)
        smoothed["family_quality"] = f"{family}_Q{q}"
        smoothed_frames.append(smoothed)

result = pd.concat(smoothed_frames, ignore_index=True)

# ---------------------------------------------------------------------------
# 4. Split and export per family
# ---------------------------------------------------------------------------
equip = result[result["item_family"] == "equipment"]
weap  = result[result["item_family"] == "weapon"]

equip[["ItemLevel", "Quality", "smoothed"]].to_csv(
    "ACSBV3_03_00A_curve_equipment_smooth.csv", index=False
)
weap[["ItemLevel", "Quality", "smoothed"]].to_csv(
    "ACSBV3_03_00B_curve_weapons_smooth.csv", index=False
)

# Optional summary output
print("Smoothing complete.")
print("Equipment curve points:", len(equip))
print("Weapon curve points:", len(weap))
# ============================================================================================
# End of File
# ============================================================================================
