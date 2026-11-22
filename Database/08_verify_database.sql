-- ============================================================================
-- SCRIPT: 08_verify_database.sql
-- PURPOSE: Schema Verification & Compilation Health Audit
-- SCHEMA: FINAL_APP | PDB: FINALPDB | TARGET: Oracle Database 19c
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_InvalidCount NUMBER := 0;
    v_ErrorCount   NUMBER := 0;
BEGIN
    -- Recompile schema to ensure any cascading alterations are refreshed
    BEGIN
        DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE);
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    DBMS_OUTPUT.PUT_LINE('======================================================================');
    DBMS_OUTPUT.PUT_LINE('DATABASE COMPILATION & HEALTH VERIFICATION REPORT');
    DBMS_OUTPUT.PUT_LINE('======================================================================');

    -- 1. Check for invalid objects
    SELECT COUNT(*) INTO v_InvalidCount
    FROM USER_OBJECTS
    WHERE STATUS = 'INVALID';

    IF v_InvalidCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[SUCCESS] Invalid Objects: 0 (All database objects are VALID)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ERROR] Invalid Objects Found: ' || v_InvalidCount);
        FOR r IN (SELECT OBJECT_TYPE, OBJECT_NAME, STATUS FROM USER_OBJECTS WHERE STATUS = 'INVALID' ORDER BY OBJECT_TYPE, OBJECT_NAME) LOOP
            DBMS_OUTPUT.PUT_LINE('  - ' || RPAD(r.OBJECT_TYPE, 15) || ' : ' || r.OBJECT_NAME || ' [' || r.STATUS || ']');
        END LOOP;
    END IF;

    -- 2. Check for compilation errors in USER_ERRORS
    SELECT COUNT(*) INTO v_ErrorCount
    FROM USER_ERRORS;

    IF v_ErrorCount = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[SUCCESS] Compilation Errors: 0 (Zero unresolved PL/SQL compilation errors)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('[ERROR] Compilation Errors Found: ' || v_ErrorCount);
        FOR e IN (SELECT TYPE, NAME, LINE, POSITION, TEXT FROM USER_ERRORS ORDER BY TYPE, NAME, SEQUENCE) LOOP
            DBMS_OUTPUT.PUT_LINE('  - ' || e.TYPE || ' ' || e.NAME || ' (' || e.LINE || ':' || e.POSITION || ') : ' || e.TEXT);
        END LOOP;
    END IF;

    -- 3. Object counts by type
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('OBJECT INVENTORY BREAKDOWN:');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------');
    FOR o IN (
        SELECT OBJECT_TYPE, COUNT(*) AS TOTAL_COUNT
        FROM USER_OBJECTS
        GROUP BY OBJECT_TYPE
        ORDER BY OBJECT_TYPE
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  - ' || RPAD(o.OBJECT_TYPE, 20) || ' : ' || o.TOTAL_COUNT);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('======================================================================');

    IF v_InvalidCount > 0 OR v_ErrorCount > 0 THEN
        RAISE_APPLICATION_ERROR(-20099, 'Database verification failed: Invalid objects or compilation errors detected.');
    END IF;
END;
/
