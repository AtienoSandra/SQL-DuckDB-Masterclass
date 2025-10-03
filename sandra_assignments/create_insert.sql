--- May 2024 Yellow Taxi Table
CREATE TABLE yellow_taxi_may (
    VendorID INTEGER,
    tpep_pickup_datetime TIMESTAMP NOT NULL,
    tpep_dropoff_datetime TIMESTAMP NOT NULL,
    passenger_count INTEGER,
    trip_distance FLOAT,
    fare_amount NUMERIC(10,2),
    tip_amount NUMERIC(10,2) DEFAULT 0,
    payment_type INTEGER
);

--- May 2024 Green Taxi Table
CREATE TABLE green_taxi_may (
    VendorID INTEGER,
    lpep_pickup_datetime TIMESTAMP NOT NULL,
    lpep_dropoff_datetime TIMESTAMP NOT NULL,
    passenger_count INTEGER,
    trip_distance FLOAT,
    fare_amount NUMERIC(10,2),
    tip_amount NUMERIC(10,2) DEFAULT 0,
    payment_type INTEGER
);

INSERT INTO yellow_taxi_may
SELECT VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
       passenger_count, trip_distance, fare_amount, tip_amount, payment_type
FROM read_parquet('https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-05.parquet');


INSERT INTO green_taxi_may
SELECT VendorID, lpep_pickup_datetime, lpep_dropoff_datetime,
       passenger_count, trip_distance, fare_amount, tip_amount, payment_type
FROM read_parquet('https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2024-05.parquet');


