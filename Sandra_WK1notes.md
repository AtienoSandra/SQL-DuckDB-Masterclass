## Introduction.

DuckDB is an open-source, in-process Online Analytical Processing (OLAP) database management system (DBMS) 
designed for analytical workloads. Unlike the traditional databases DuckDB uses columnar storage, which is highly efficient 
for analytical queries involving aggregations, filters, and joins on large datasets. DuckDB supports standard SQL, allowing users to leverage 
familiar syntax for data manipulation and querying. It can directly query data from various file formats like CSV, Parquet, and JSON, eliminating 
the need for explicit data loading into a separate database.

## Data Types.
DuckDB supports standard SQL data types and even more complex structures. We looked at:
- Text: *VARCHAR*, *CHAR*, *TEXT*
- Numeric: *Integers*, *Decimal*
- Date|Time: *Date*, *Timestamp*, *Time interval*
- Arrays

## CRUD Operations (Create, Read, Update, Delete)
DuckDB uses standard SQL syntax for CRUD operations. 
- Create - INSERT: adds new records to a table.
- Read - SELECT: retrieves data, supports filters, aggregations, ordering.
- Update - UPDATE: modifies existing rows. In DuckDB it is important to include WHERE because without it all rows will be updated.
                It is important to run SELECT before UPDATE to preview the effect on your dataset. (UPDATE trips set fare_amount = 50 
                WHERE trip_id = 2025;)
- Delete - DELETE: removes rows from dataset. Must also specify WHERE to avoid data loss (DELETE FROM trips WHERE trip_id = 1001;)
