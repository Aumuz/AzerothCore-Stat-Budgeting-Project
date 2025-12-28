# ============================================================================================
# Filename:      ACSBV3-02-02B_Analysis.py
# Title:         Phase 02 – Curve Validation (External Analysis)
# Author:        ChatGPT
# Version:       1.0
# Created:       2025-10-23
# Description:
#   Compares unweighted vs. weighted curve performance using exported CSVs from MySQL.
#   Computes MAPE, MdAPE, and percentile (P50/P75/P90) errors for both curve families.
# --------------------------------------------------------------------------------------------
# Inputs  (exported by ACSBV3-02-02B.sql):
#   • ACSBV3_02_01A_curve_unweighted.csv
#   • ACSBV3_02_01B_curve_weighted.csv
#   • ACSBV3_02_02A_testset_equipment.csv
# Output:
#   • Printed summary table
#   • Optional CSV: ACSBV3_02_02B_validation_results.csv
# ============================================================================================

import pandas as pd
import numpy as np

# --------------------------------------------------------------------------------------------
# 1. Load data
# --------------------------------------------------------------------------------------------
unweighted = pd.read_csv("ACSBV3_02_01A_curve_unweighted.csv")
weighted   = pd.read_csv("ACSBV3_02_01B_curve_weighted.csv")
testset    = pd.read_csv("ACSBV3_02_02A_testset_equipment.csv")

# Standardize column names just in case
unweighted.columns = [c.lower() for c in unweighted.columns]
weighted.columns   = [c.lower() for c in weighted.columns]
testset.columns    = [c.lower() for c in testset.columns]

# --------------------------------------------------------------------------------------------
# 2. Join curves to test set (on ItemLevel + Quality)
# --------------------------------------------------------------------------------------------
merged = (
    testset
    .merge(unweighted, on=["itemlevel", "quality"], how="left")
    .merge(weighted,   on=["itemlevel", "quality"], how="left", suffixes=("_unw", "_wgt"))
)

merged.rename(columns={
    "median_budget": "pred_unweighted",
    "weighted_median_budget": "pred_weighted"
}, inplace=True)

# --------------------------------------------------------------------------------------------
# 3. Compute percent errors
# --------------------------------------------------------------------------------------------
merged["pct_error_norm_unweighted"] = (
    np.abs(merged["pred_unweighted"] - merged["normalized_budget"]) /
    merged["normalized_budget"].replace(0, np.nan) * 100
)
merged["pct_error_norm_weighted"] = (
    np.abs(merged["pred_weighted"] - merged["normalized_budget"]) /
    merged["normalized_budget"].replace(0, np.nan) * 100
)
merged["pct_error_actual_unweighted"] = (
    np.abs(merged["pred_unweighted"] - merged["actual_stat_budget"]) /
    merged["actual_stat_budget"].replace(0, np.nan) * 100
)
merged["pct_error_actual_weighted"] = (
    np.abs(merged["pred_weighted"] - merged["actual_stat_budget"]) /
    merged["actual_stat_budget"].replace(0, np.nan) * 100
)

# --------------------------------------------------------------------------------------------
# 4. Helper for summary stats
# --------------------------------------------------------------------------------------------
def summarize(df, col_norm_u, col_norm_w, col_act_u, col_act_w):
    def pctile(x, p): return np.nanpercentile(x, p)
    summary = pd.DataFrame({
        "Curve": ["Unweighted", "Weighted"],
        "MAPE_norm": [
            np.nanmean(df[col_norm_u]),
            np.nanmean(df[col_norm_w])
        ],
        "MAPE_actual": [
            np.nanmean(df[col_act_u]),
            np.nanmean(df[col_act_w])
        ],
        "MdAPE_actual": [
            np.nanmedian(df[col_act_u]),
            np.nanmedian(df[col_act_w])
        ],
        "P75_actual": [
            pctile(df[col_act_u], 75),
            pctile(df[col_act_w], 75)
        ],
        "P90_actual": [
            pctile(df[col_act_u], 90),
            pctile(df[col_act_w], 90)
        ]
    })
    return summary.round(2)

# --------------------------------------------------------------------------------------------
# 5. Overall summary
# --------------------------------------------------------------------------------------------
overall_summary = summarize(
    merged,
    "pct_error_norm_unweighted", "pct_error_norm_weighted",
    "pct_error_actual_unweighted", "pct_error_actual_weighted"
)

print("\n=== PHASE 02: CURVE VALIDATION SUMMARY (OVERALL) ===")
print(overall_summary.to_string(index=False))

# --------------------------------------------------------------------------------------------
# 6. Per-quality summary (median only)
# --------------------------------------------------------------------------------------------
quality_summary = []
for q, sub in merged.groupby("quality"):
    quality_summary.append({
        "Quality": q,
        "MAPE_actual_unweighted": np.nanmean(sub["pct_error_actual_unweighted"]),
        "MAPE_actual_weighted":   np.nanmean(sub["pct_error_actual_weighted"]),
        "MdAPE_unweighted":       np.nanmedian(sub["pct_error_actual_unweighted"]),
        "MdAPE_weighted":         np.nanmedian(sub["pct_error_actual_weighted"]),
    })
quality_summary = pd.DataFrame(quality_summary).round(2)

print("\n=== PHASE 02: CURVE VALIDATION BY QUALITY ===")
print(quality_summary.to_string(index=False))

# --------------------------------------------------------------------------------------------
# 7. Identify top 10 high-error items
# --------------------------------------------------------------------------------------------
merged["max_err"] = merged[["pct_error_actual_unweighted","pct_error_actual_weighted"]].max(axis=1)
outliers = merged.nlargest(10, "max_err")[[
    "entry", "name", "itemlevel", "quality",
    "actual_stat_budget", "normalized_budget",
    "pred_unweighted", "pred_weighted",
    "pct_error_actual_unweighted", "pct_error_actual_weighted"
]].round(2)

print("\n=== TOP 10 HIGHEST-ERROR ITEMS ===")
print(outliers.to_string(index=False))

# --------------------------------------------------------------------------------------------
# 8. Optional: export merged validation results for archival
# --------------------------------------------------------------------------------------------
merged.to_csv("ACSBV3_02_02B_validation_results.csv", index=False)
print("\nValidation results written to ACSBV3_02_02B_validation_results.csv")

# ============================================================================================
# End of File
# ============================================================================================
