-- ============================================================================
-- SCRIPT: 00_preflight.sql
-- PURPOSE: Preflight environment and session validation
-- SCHEMA: FINAL_APP | PDB: FINALPDB
-- ============================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET SERVEROUTPUT ON;

-- 1. Verify Active Connection and Container
SELECT 
    USER AS CURRENT_USER,
    SYS_CONTEXT('USERENV', 'CON_NAME') AS CONTAINER_NAME,
    SYS_CONTEXT('USERENV', 'DB_NAME') AS DATABASE_NAME,
    SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS SERVICE_NAME,
    TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') AS VERIFICATION_TIME
FROM DUAL;

-- 2. Verify Tablespace Quota
SELECT 
    TABLESPACE_NAME,
    BYTES / 1024 / 1024 AS MB_ALLOCATED,
    MAX_BYTES / 1024 / 1024 AS MB_MAX
FROM USER_TS_QUOTAS;

-- 3. Verify Existing Objects Inventory in FINAL_APP
SELECT 
    OBJECT_TYPE, 
    COUNT(*) AS OBJECT_COUNT 
FROM USER_OBJECTS 
GROUP BY OBJECT_TYPE 
ORDER BY OBJECT_TYPE;

PROMPT Preflight verification completed successfully.
