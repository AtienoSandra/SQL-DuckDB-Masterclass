import logging
import duckdb
from datetime import datetime

# --- Configuration ---
DB_PATH = "nyc_tlc_v2.duckdb"  # Separate DB for your improved pipeline
BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data"
LOG_FILE = "etl_v2.log"

SERVICES = ["yellow", "green"]
START_YEAR = 2015
END_YEAR = datetime.now().year
MONTHS = list(range(1, 13))

# --- Logging setup ---
logging.basicConfig(
    filename=LOG_FILE,
    filemode="a",  # Append logs (so you don’t lose previous runs)
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)
console = logging.StreamHandler()
console.setLevel(logging.INFO)
logging.getLogger().addHandler(console)

# --- Connect to DuckDB ---
con = duckdb.connect(DB_PATH)

# --- Create tables if not exist ---
con.execute("""
CREATE TABLE IF NOT EXISTS yellow_taxi_trip_data (
    vendorid                INTEGER,
    tpep_pickup_datetime    TIMESTAMP,
    tpep_dropoff_datetime   TIMESTAMP,
    passenger_count         INTEGER,
    trip_distance           DOUBLE,
    ratecodeid              INTEGER,
    pulocationid            INTEGER,
    dolocationid            INTEGER,
    payment_type            INTEGER,
    fare_amount             DOUBLE,
    extra                   DOUBLE,
    mta_tax                 DOUBLE,
    tip_amount              DOUBLE,
    tolls_amount            DOUBLE,
    improvement_surcharge   DOUBLE,
    total_amount            DOUBLE,
    congestion_surcharge    DOUBLE,
    year                    INTEGER
);
""")

con.execute("""
CREATE TABLE IF NOT EXISTS green_taxi_trip_data (
    vendorid                INTEGER,
    lpep_pickup_datetime    TIMESTAMP,
    lpep_dropoff_datetime   TIMESTAMP,
    passenger_count         INTEGER,
    trip_distance           DOUBLE,
    ratecodeid              INTEGER,
    pulocationid            INTEGER,
    dolocationid            INTEGER,
    payment_type            INTEGER,
    fare_amount             DOUBLE,
    extra                   DOUBLE,
    mta_tax                 DOUBLE,
    tip_amount              DOUBLE,
    tolls_amount             DOUBLE,
    improvement_surcharge    DOUBLE,
    total_amount             DOUBLE,
    congestion_surcharge     DOUBLE,
    year                     INTEGER
);
""")

# --- Summary stats ---
summary = {"inserted": 0, "skipped": 0, "failed": 0}


def data_exists(service: str, year: int) -> bool:
    """Check if data for the given year already exists in DuckDB"""
    try:
        if service == "yellow":
            result = con.execute(
                f"SELECT COUNT(*) FROM yellow_taxi_trip_data WHERE year={year}"
            ).fetchone()[0]
        else:
            result = con.execute(
                f"SELECT COUNT(*) FROM green_taxi_trip_data WHERE year={year}"
            ).fetchone()[0]
        return result > 0
    except Exception:
        return False


def insert_parquet(url: str, service: str):
    """Insert Parquet file directly into DuckDB table"""
    try:
        if service == "yellow":
            con.execute(f"""
                INSERT INTO yellow_taxi_trip_data
                SELECT 
                    vendorid,
                    tpep_pickup_datetime,
                    tpep_dropoff_datetime,
                    passenger_count,
                    trip_distance,
                    ratecodeid,
                    pulocationid,
                    dolocationid,
                    payment_type,
                    fare_amount,
                    extra,
                    mta_tax,
                    tip_amount,
                    tolls_amount,
                    improvement_surcharge,
                    total_amount,
                    congestion_surcharge,
                    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year
                FROM read_parquet('{url}')
            """)
        else:
            con.execute(f"""
                INSERT INTO green_taxi_trip_data
                SELECT 
                    vendorid,
                    lpep_pickup_datetime,
                    lpep_dropoff_datetime,
                    passenger_count,
                    trip_distance,
                    ratecodeid,
                    pulocationid,
                    dolocationid,
                    payment_type,
                    fare_amount,
                    extra,
                    mta_tax,
                    tip_amount,
                    tolls_amount,
                    improvement_surcharge,
                    total_amount,
                    congestion_surcharge,
                    EXTRACT(YEAR FROM lpep_pickup_datetime) AS year
                FROM read_parquet('{url}')
            """)
        logging.info(f"✅ Inserted {url}")
        summary["inserted"] += 1
    except Exception as e:
        logging.error(f"❌ FAILED {url} | {e}")
        summary["failed"] += 1


def run_pipeline():
    """Main ETL runner"""
    for year in range(START_YEAR, END_YEAR + 1):
        for service in SERVICES:
            # Skip if year already exists
            if data_exists(service, year):
                logging.info(f"⏭️ Skipping {service} {year} — already exists")
                summary["skipped"] += 1
                continue

            # Otherwise, process month by month
            for month in MONTHS:
                url = f"{BASE_URL}/{service}_tripdata_{year}-{month:02d}.parquet"
                logging.info(f"⬇️ Downloading {url}")
                insert_parquet(url, service)


# --- Main runner ---
if __name__ == "__main__":
    start_time = datetime.now()
    logging.info(f"🚀 Starting pipeline (v2) from {START_YEAR} to {END_YEAR}")
    run_pipeline()
    end_time = datetime.now()

    summary_text = f"""
📊 ==== PIPELINE V2 SUMMARY ({datetime.now().strftime('%Y-%m-%d %H:%M:%S')}) ====
✅ Files inserted: {summary['inserted']}
⏭️ Files skipped:  {summary['skipped']}
❌ Files failed:   {summary['failed']}
🕒 Duration: {(end_time - start_time).total_seconds():.2f}s
============================================================
"""
    print(summary_text)
    logging.info(summary_text)
    logging.info("✅ Pipeline V2 completed.\n")
