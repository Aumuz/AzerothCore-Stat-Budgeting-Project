import pandas as pd
import mysql.connector
import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="pandas")

# ------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------
MYSQL_CONFIG = {
    "host": "localhost",
    "user": "acore",                # <-- replace with your MySQL user
    "password": "acore",            # <-- replace with your MySQL password
    "database": "acore_world"       # your ACSBV3 database
}

# List of (source_table, target_table) pairs to process
TABLES = [
    ("ACSBV3_ref_curve_equipment_final", "ACSBV3_ref_curve_equipment_final_fixed"),
    ("ACSBV3_ref_curve_weapons_final",   "ACSBV3_ref_curve_weapons_final_fixed"),
]

# ------------------------------------------------------------
# FUNCTION: Apply monotonic enforcement and write back
# ------------------------------------------------------------
def fix_monotonic_curve(src_table, dst_table, conn):
    print(f"Processing {src_table} ? {dst_table} ...")

    # Load data from MySQL
    df = pd.read_sql(f"SELECT * FROM {src_table}", conn)
    print(f"  Loaded {len(df):,} rows.")

    # Apply cumulative max globally per Quality (ignore expansion boundaries)
    df["curve_value"] = (
        df.groupby(["Quality"])["smoothed_3pt"]
          .cummax()
    )

    # Optional rounding for readability
    df["curve_value"] = df["curve_value"].round(3)

    # Prepare database cursor
    cur = conn.cursor()
    cur.execute(f"DROP TABLE IF EXISTS {dst_table}")
    cur.execute(f"CREATE TABLE {dst_table} LIKE {src_table}")

    # Bulk insert back into MySQL
    cols = ",".join(df.columns)
    placeholders = ",".join(["%s"] * len(df.columns))
    insert_sql = f"INSERT INTO {dst_table} ({cols}) VALUES ({placeholders})"
    cur.executemany(insert_sql, df.values.tolist())
    conn.commit()

    print(f"  ? Monotonic curve written to {dst_table}")
    cur.close()


# ------------------------------------------------------------
# MAIN EXECUTION
# ------------------------------------------------------------
if __name__ == "__main__":
    conn = mysql.connector.connect(**MYSQL_CONFIG)

    try:
        for src, dst in TABLES:
            fix_monotonic_curve(src, dst, conn)
        print("\n? All curve tables processed successfully.")
    finally:
        conn.close()
