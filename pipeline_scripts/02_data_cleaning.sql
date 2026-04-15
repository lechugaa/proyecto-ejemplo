/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Configuración inicial
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */

-- Permitiendo idempotencia a través de un refresh destructivo
DROP SCHEMA IF EXISTS cleaning CASCADE;
CREATE SCHEMA cleaning;

-- Creando copia de la tabla original excluyendo la columna `location`
-- Creating a copy of the raw table excluding the location column
DROP TABLE IF EXISTS cleaning.food_inspections;
CREATE TABLE cleaning.food_inspections (
    inspection_id bigint,
    dba_name text,
    aka_name text,
    license_number bigint,
    facility_type text,
    risk text,
    address text,
    city text,
    state text,
    zip text,
    inspection_date timestamp,
    inspection_type text,
    results text,
    violations text,
    latitude double precision,
    longitude double precision
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

/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Limpiando `facility_type`
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */

-- Unificando `facility_types`
UPDATE cleaning.food_inspections
SET facility_type =
    CASE
        WHEN facility_type ILIKE '%CONVENIENCE STORE%' THEN 'CONVENIENCE STORE'
        WHEN facility_type ILIKE '%GAS STATION%' THEN 'GAS STATION'
        WHEN facility_type ILIKE '%1023%' THEN 'CHILDREN''S SERVICES FACILITY'
        WHEN facility_type ILIKE '%1005%' THEN 'NURSING HOME'
        WHEN facility_type ILIKE '%LIQUOR%' THEN 'LIQUOR'
        WHEN facility_type ILIKE '%LIQUOR%' THEN 'LIQUOR'
        WHEN facility_type ILIKE '%BANQUET%' THEN 'BANQUET'
        WHEN facility_type ILIKE '%SCHOOL%' THEN 'SCHOOL'
        WHEN facility_type ILIKE '%ART%' THEN 'ART'
        WHEN facility_type ILIKE '%BAKERY%' THEN 'BAKERY'
        WHEN facility_type ILIKE '%BAR%' THEN 'BAR'
        WHEN facility_type ILIKE '%ADULT%CARE%' OR facility_type ILIKE '%ADULT%DAY%' THEN 'ADULT CARE'
        WHEN facility_type ILIKE '%ASSIS%LIVING%' THEN 'ASSISTED LIVING'
        WHEN facility_type ILIKE '%CAFE%' OR facility_type ILIKE '%COFFEE%' THEN 'COFFEE'
        WHEN facility_type ILIKE '%ROOF%TOP%' THEN 'ROOFTOP'
        WHEN facility_type ILIKE '%CANDY%' THEN 'CANDY SHOP'
        WHEN facility_type ILIKE '%BREW%' THEN 'BREWERY'
        WHEN facility_type ILIKE '%WHOLESALE%' THEN 'WHOLESALE'
        WHEN facility_type ILIKE '%THEAT%' THEN 'THEATRE'
        WHEN facility_type ILIKE '%CHILD%' THEN 'CHILDREN'
        WHEN facility_type ILIKE '%CHURCH%' THEN 'CHURCH'
        WHEN facility_type ILIKE '%COLD%STORAGE%' THEN 'COLD STORAGE'
        WHEN facility_type ILIKE '%COMM%SARY%' THEN 'COMMISSARY'
        WHEN facility_type ILIKE '%CONV%NIENCE%' OR facility_type ILIKE '%CONVENIENT%' THEN 'CONVENIENCE'
        WHEN facility_type ILIKE '%DAY%CARE%' THEN 'DAYCARE'
        WHEN facility_type ILIKE '%DISTRIBUT%' THEN 'DISTRIBUTION'
        WHEN facility_type ILIKE '%DOLLAR%' THEN 'DOLLAR STORE'
        WHEN facility_type ILIKE '%DRUG%' THEN 'DRUGSTORE'
        WHEN facility_type ILIKE '%EVENT%' THEN 'EVENT VENUE'
        WHEN facility_type ILIKE '%GROCERY%' THEN 'GROCERY STORE'
        WHEN facility_type ILIKE '%GYM%' THEN 'GYM'
        WHEN facility_type ILIKE '%HEALTH%' THEN 'HEALTH'
        WHEN facility_type ILIKE '%HERBAL%' THEN 'HERBAL'
        WHEN facility_type ILIKE '%MEAT%' THEN 'MEAT'
        WHEN facility_type ILIKE '%DISPENSER%' THEN 'DISPENSER'
        WHEN facility_type ILIKE '%FITNESS%' THEN 'FITNESS'
        WHEN facility_type ILIKE '%GOLF%' THEN 'GOLF'
        WHEN facility_type ILIKE '%ICE%CREAM%' THEN 'ICE CREAM SHOP'
        WHEN facility_type ILIKE '%KITCHEN%' THEN 'KITCHEN'
        WHEN facility_type ILIKE '%LONG%TERM%CARE%' THEN 'LONG TERM CARE FACILITY'
        WHEN facility_type ILIKE '%MOBIL%' THEN 'MOBILE FOOD VENDOR'
        ELSE facility_type
    END;

-- Removing facility types that have less than 10 entries
WITH facility_types_with_less_than_10_entries AS (
    SELECT facility_type, COUNT(*)
    FROM cleaning.food_inspections
    GROUP BY facility_type
    HAVING COUNT(*) < 10
)
UPDATE cleaning.food_inspections
SET facility_type = 'OTHER'
WHERE facility_type IN (
    SELECT facility_type
    FROM facility_types_with_less_than_10_entries
);

-- Unifying remaining facility types
UPDATE cleaning.food_inspections
SET facility_type =
    CASE
        WHEN facility_type = 'A-NOT-FOR-PROFIT CHEF TRAINING PROGRAM' THEN 'CHEF TRAINING CENTER'
        WHEN facility_type = 'CHILDREN''S SERVICES FACILITY' THEN 'CHILDREN'
        WHEN facility_type = 'CONVENIENCE STORE' THEN 'CONVENIENCE'
        WHEN facility_type ILIKE '%POP-UP%' THEN 'POP-UP'
        WHEN facility_type ILIKE '%HOSPITAL%' THEN 'HOSPITAL'
        ELSE facility_type
    END;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Cleaning city
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
UPDATE cleaning.food_inspections
SET city =
    CASE
        WHEN city ILIKE '%CHICAGO%' THEN 'CHICAGO'
        WHEN city ILIKE '%CH%CAGO%' THEN 'CHICAGO'
        WHEN city = 'CH' THEN 'CHICAGO'
        WHEN city ILIKE '%O%LYMPIA FIELDS%' THEN 'OLIMPIA FIELDS'
        ELSE city
    END;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Cleaning inspection type
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- TODO: Create update command
SELECT DISTINCT inspection_type
FROM cleaning.food_inspections
ORDER BY inspection_type;


/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
-- Cleaning violations
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ */
DROP TABLE IF EXISTS cleaning.violations;
CREATE TABLE cleaning.violations (
    violation_code int,
    violation_description varchar(200)
);

INSERT INTO cleaning.violations (violation_code, violation_description)
VALUES
    (1,	'SOURCE SOUND CONDITION, NO SPOILAGE, FOODS PROPERLY LABELED, SHELLFISH TAGS IN PLACE'),
    (2,	'CITY OF CHICAGO FOOD SERVICE SANITATION CERTIFICATE'),
    (3,	'MANAGEMENT, FOOD EMPLOYEE AND CONDITIONAL EMPLOYEE; KNOWLEDGE, RESPONSIBILITIES AND REPORTING'),
    (4,	'PROPER USE OF RESTRICTION AND EXCLUSION'),
    (5,	'PROCEDURES FOR RESPONDING TO VOMITING AND DIARRHEAL EVENTS'),
    (6,	'PROPER EATING, TASTING, DRINKING, OR TOBACCO USE'),
    (7,	'WASH AND RINSE WATER: CLEAN AND PROPER TEMPERATURE'),
    (8,	'SANITIZING RINSE FOR EQUIPMENT AND UTENSILS'),
    (9,	'WATER SOURCE: SAFE, HOT & COLD UNDER CITY PRESSURE'),
    (10, 'SEWAGE AND WASTE WATER DISPOSAL, NO BACK SIPHONAGE, CROSS  CONNECTION AND/OR BACK FLOW'),
    (11, 'ADEQUATE NUMBER, CONVENIENT, ACCESSIBLE, DESIGNED, AND MAINTAINED'),
    (12, 'HAND WASHING FACILITIES: WITH SOAP AND SANITARY HAND DRYING DEVICES, CONVENIENT AND ACCESSIBLE TO FOOD PREP AREA'),
    (13, 'NO EVIDENCE OF RODENT OR INSECT INFESTATION, NO BIRDS, TURTLES OR OTHER ANIMALS'),
    (14, 'PREVIOUS SERIOUS VIOLATION CORRECTED'),
    (15, 'FOOD SEPARATED AND PROTECTED'),
    (16, 'FOOD PROTECTED DURING STORAGE, PREPARATION, DISPLAY, SERVICE AND TRANSPORTATION'),
    (17, 'POTENTIALLY HAZARDOUS FOOD PROPERLY THAWED'),
    (18, 'NO EVIDENCE OF RODENT OR INSECT OUTER OPENINGS PROTECTED/RODENT PROOFED, A WRITTEN LOG SHALL BE MAINTAINED AVAILABLE TO THE INSPECTORS'),
    (19, 'OUTSIDE GARBAGE WASTE GREASE AND STORAGE AREA; CLEAN, RODENT PROOF, ALL CONTAINERS COVERED'),
    (20, 'INSIDE CONTAINERS OR RECEPTACLES: ADEQUATE NUMBER, PROPERLY COVERED AND INSECT/RODENT PROOF'),
    (21, 'PROPER HOT HOLDING TEMPERATURES'),
    (22, 'DISH MACHINES: PROVIDED WITH ACCURATE THERMOMETERS, CHEMICAL TEST KITS AND SUITABLE GAUGE COCK'),
    (23, 'PROPER DATE MARKING AND DISPOSITION'),
    (24, 'TIME AS A PUBLIC HEALTH CONTROL; PROCEDURES & RECORDS'),
    (25, 'CONSUMER ADVISORY PROVIDED FOR RAW/UNDERCOOKED FOOD'),
    (26, 'ADEQUATE NUMBER, CONVENIENT, ACCESSIBLE, PROPERLY DESIGNED AND INSTALLED'),
    (27, 'TOILET ROOMS ENCLOSED CLEAN, PROVIDED WITH HAND CLEANSER, SANITARY HAND DRYING DEVICES AND PROPER WASTE RECEPTACLES'),
    (28, 'INSPECTION REPORT SUMMARY DISPLAYED AND VISIBLE TO ALL CUSTOMERS'),
    (29, 'PREVIOUS MINOR VIOLATION(S) CORRECTED'),
    (30, 'FOOD IN ORIGINAL CONTAINER, PROPERLY LABELED: CUSTOMER ADVISORY POSTED AS NEEDED'),
    (31, 'CLEAN MULTI-USE UTENSILS AND SINGLE SERVICE ARTICLES PROPERLY STORED'),
    (32, 'FOOD AND NON-FOOD CONTACT SURFACES PROPERLY DESIGNED, CONSTRUCTED AND MAINTAINED'),
    (33, 'FOOD AND NON-FOOD CONTACT EQUIPMENT UTENSILS CLEAN, FREE OF ABRASIVE DETERGENTS'),
    (34, 'FLOORS: CONSTRUCTED PER CODE, CLEANED, GOOD REPAIR, COVING INSTALLED, DUST-LESS CLEANING METHODS USED'),
    (35, 'WALLS, CEILINGS, ATTACHED EQUIPMENT CONSTRUCTED PER CODE: GOOD REPAIR, SURFACES CLEAN AND DUST-LESS CLEANING METHODS'),
    (36, 'LIGHTING: REQUIRED MINIMUM FOOT-CANDLES OF LIGHT PROVIDED, FIXTURES SHIELDED'),
    (37, 'TOILET ROOM DOORS SELF CLOSING: DRESSING ROOMS WITH LOCKERS PROVIDED: COMPLETE SEPARATION FROM LIVING/SLEEPING QUARTERS'),
    (38, 'VENTILATION: ROOMS AND EQUIPMENT VENTED AS REQUIRED: PLUMBING: INSTALLED AND MAINTAINED'),
    (39, 'CONTAMINATION PREVENTED DURING FOOD PREPARATION, STORAGE & DISPLAY'),
    (40, 'PERSONAL CLEANLINESS'),
    (41, 'PREMISES MAINTAINED FREE OF LITTER, UNNECESSARY ARTICLES, CLEANING  EQUIPMENT PROPERLY STORED'),
    (42, 'APPROPRIATE METHOD OF HANDLING OF FOOD (ICE) HAIR RESTRAINTS AND CLEAN APPAREL WORN'),
    (43, 'FOOD (ICE) DISPENSING UTENSILS, WASH CLOTHS PROPERLY STORED'),
    (44, 'UTENSILS, EQUIPMENT & LINENS: PROPERLY STORED, DRIED, & HANDLED'),
    (45, 'SINGLE-USE/SINGLE-SERVICE ARTICLES: PROPERLY STORED & USED'),
    (46, 'GLOVES USED PROPERLY'),
    (47, 'FOOD & NON-FOOD CONTACT SURFACES CLEANABLE, PROPERLY DESIGNED, CONSTRUCTED & USED'),
    (48, 'WAREWASHING FACILITIES: INSTALLED, MAINTAINED & USED; TEST STRIPS'),
    (49, 'NON-FOOD/FOOD CONTACT SURFACES CLEAN'),
    (50, 'HOT & COLD WATER AVAILABLE; ADEQUATE PRESSURE'),
    (51, 'PLUMBING INSTALLED; PROPER BACKFLOW DEVICES'),
    (52, 'SEWAGE & WASTE WATER PROPERLY DISPOSED'),
    (53, 'TOILET FACILITIES: PROPERLY CONSTRUCTED, SUPPLIED, & CLEANED'),
    (54, 'GARBAGE & REFUSE PROPERLY DISPOSED; FACILITIES MAINTAINED'),
    (55, 'PHYSICAL FACILITIES INSTALLED, MAINTAINED & CLEAN'),
    (56, 'ADEQUATE VENTILATION & LIGHTING'),
    (57, 'ALL FOOD EMPLOYEES HAVE FOOD HANDLER TRAINING'),
    (58, 'ALLERGEN TRAINING AS REQUIRED'),
    (59, 'PREVIOUS PRIORITY FOUNDATION VIOLATION CORRECTED'),
    (60, 'PREVIOUS CORE VIOLATION CORRECTED'),
    (61, 'SUMMARY REPORT DISPLAYED AND VISIBLE TO THE PUBLIC'),
    (62, 'COMPLIANCE WITH CLEAN INDOOR AIR ORDINANCE'),
    (63, 'REMOVAL OF SUSPENSION SIGN'),
    (64, 'MISCELLANEOUS / PUBLIC HEALTH ORDERS'),
    (70, 'NO SMOKING REGULATIONS');
