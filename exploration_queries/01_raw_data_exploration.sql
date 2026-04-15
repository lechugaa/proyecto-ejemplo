-- Conteos iniciales
SELECT COUNT(*)
FROM raw.food_inspections;

-- Vista preeliminar
SELECT *
FROM raw.food_inspections
LIMIT 5;

-- ¿inspection_id es llave?
SELECT inspection_id, COUNT(*)
FROM raw.food_inspections
GROUP BY inspection_id
HAVING COUNT(*) > 1;

-- ¿El número de licencia es único por establecimiento?
SELECT license_number, COUNT(DISTINCT TRIM(UPPER(dba_name)))
FROM raw.food_inspections
GROUP BY license_number
ORDER BY COUNT(DISTINCT dba_name) DESC;

SELECT DISTINCT dba_name
FROM raw.food_inspections
WHERE license_number = 14616;

-- Perfiles
SELECT DISTINCT facility_type
FROM raw.food_inspections;

SELECT DISTINCT risk
FROM raw.food_inspections;

SELECT DISTINCT city
FROM raw.food_inspections;

SELECT DISTINCT TRIM(UPPER(city)) clean_city
FROM raw.food_inspections
ORDER BY clean_city;

SELECT DISTINCT state
FROM raw.food_inspections;

SELECT DISTINCT inspection_type
FROM raw.food_inspections;

SELECT DISTINCT results
FROM raw.food_inspections;

SELECT violations
FROM raw.food_inspections
WHERE violations IS NOT NULL
LIMIT 5;

SELECT violations
FROM raw.food_inspections
WHERE violations = '37. FOOD PROPERLY LABELED; ORIGINAL CONTAINER - Comments: 3-302.12: FOOD STORAGE CONTAINERS NOT LABELED WITH COMMON NAME. INSTD TO LABEL WITH COMMON NAME AND MAINTAIN. | 47. FOOD & NON-FOOD CONTACT SURFACES CLEANABLE, PROPERLY DESIGNED, CONSTRUCTED & USED - Comments: 4-101.19: CARDBOARD LINING ON BOTTOM OF STORAGE SHELF IN REAR PREP AREA. INSTD TO REMOVE SO AS SURFACE TO BE SMOOTH AND EASILY CLEANABLE ';


SELECT violations,
       CAST(UNNEST(REGEXP_MATCHES(violations, '(?<=^|\|\s*)(\d+)\.', 'g')) AS INT) AS violation_code
FROM raw.food_inspections
WHERE violations = '37. FOOD PROPERLY LABELED; ORIGINAL CONTAINER - Comments: 3-302.12: FOOD STORAGE CONTAINERS NOT LABELED WITH COMMON NAME. INSTD TO LABEL WITH COMMON NAME AND MAINTAIN. | 47. FOOD & NON-FOOD CONTACT SURFACES CLEANABLE, PROPERLY DESIGNED, CONSTRUCTED & USED - Comments: 4-101.19: CARDBOARD LINING ON BOTTOM OF STORAGE SHELF IN REAR PREP AREA. INSTD TO REMOVE SO AS SURFACE TO BE SMOOTH AND EASILY CLEANABLE ';

SELECT DISTINCT CAST(UNNEST(REGEXP_MATCHES(violations, '(?<=^|\|\s*)(\d+)\.', 'g')) AS INT) AS violation_code
FROM raw.food_inspections
ORDER BY violation_code;
