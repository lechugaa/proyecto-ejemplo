/*

    Setup inicial

*/

-- Extensiones
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- Permitiendo idempotencia a través de un refresh destructivo
DROP SCHEMA IF EXISTS cleaning CASCADE;
CREATE SCHEMA cleaning;

-- Creando copia de la tabla original excluyendo la columna `location`
DROP TABLE IF EXISTS cleaning.food_inspections;
CREATE TABLE cleaning.food_inspections (
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
    longitude DOUBLE PRECISION
);

INSERT INTO cleaning.food_inspections
SELECT inspection_id,
       TRIM(UPPER(dba_name)),
       TRIM(UPPER(aka_name)),
       license_number,
       TRIM(UPPER(facility_type)),
       TRIM(UPPER(risk)),
       TRIM(UPPER(address)),
       TRIM(UPPER(city)),
       TRIM(UPPER(state)),
       TRIM(zip),
       inspection_date,
       TRIM(UPPER(inspection_type)),
       TRIM(UPPER(results)),
       TRIM(UPPER(violations)),
       latitude,
       longitude
FROM raw.food_inspections;

/*

    Limpieza de `city`

    Consulta de prueba

    SELECT city, COUNT(*) no_rows
    FROM cleaning.food_inspections
    GROUP BY city
    ORDER BY no_rows DESC;

*/

-- Quitando números
UPDATE cleaning.food_inspections
SET city = REGEXP_REPLACE(UPPER(TRIM(city)), '[0-9.]', '', 'g');

-- Actualizando a Chicago las cercanas con ILIKE
UPDATE cleaning.food_inspections
SET city = 'CHICAGO'
WHERE city LIKE '%CHICAGO%';

-- Actualizando a Chicago empleando distancia de edición
UPDATE cleaning.food_inspections
SET city = 'CHICAGO'
WHERE LEVENSHTEIN('CHICAGO', city) BETWEEN 1 AND 2;

-- Creando campo de otras para ciudades con menos de 10 tuplas
WITH cities_with_10_or_more_entries AS (
    SELECT city
    FROM cleaning.food_inspections
    WHERE city IS NOT NULL
    GROUP BY city
    HAVING COUNT(*) >= 10
)
UPDATE cleaning.food_inspections
SET city = 'OTHER'
WHERE city NOT IN (
    SELECT city
    FROM cities_with_10_or_more_entries
);
