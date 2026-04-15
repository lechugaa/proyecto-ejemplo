-- Creating raw schema
DROP SCHEMA IF EXISTS raw CASCADE;
CREATE SCHEMA IF NOT EXISTS raw;

-- Creating table for raw data
DROP TABLE IF EXISTS raw.food_inspections;
CREATE TABLE raw.food_inspections (
    inspection_id BIGINT,
    dba_name TEXT,
    aka_name TEXT,
    license_number BIGINT,
    facility_type TEXT,
    risk TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip TEXT,
    inspection_date TIMESTAMP,
    inspection_type TEXT,
    results TEXT,
    violations TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location TEXT
);

-- Loading data from CSV file
\COPY raw.food_inspections (inspection_id, dba_name, aka_name, license_number, facility_type, risk, address, city, state, zip, inspection_date, inspection_type, results, violations, latitude, longitude, location) FROM './data/raw_data.csv' WITH (FORMAT CSV, HEADER true, DELIMITER ',');

