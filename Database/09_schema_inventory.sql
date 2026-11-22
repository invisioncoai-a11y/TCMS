-- ============================================================================
-- SCRIPT: 09_schema_inventory.sql
-- PURPOSE: Detailed Data Dictionary and Schema Inventory
-- SCHEMA: FINAL_APP | PDB: FINALPDB | TARGET: Oracle Database 19c
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

BEGIN
    DBMS_OUTPUT.PUT_LINE('======================================================================');
    DBMS_OUTPUT.PUT_LINE('ORACLE 19c DATA DICTIONARY & SCHEMA INVENTORY: FINAL_APP@FINALPDB');
    DBMS_OUTPUT.PUT_LINE('======================================================================');

    -- Table Row Counts
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- TABLE SUMMARY & CURRENT ROW COUNTS ---');
    FOR t IN (SELECT TABLE_NAME FROM USER_TABLES ORDER BY TABLE_NAME) LOOP
        DECLARE
            v_Cnt NUMBER;
        BEGIN
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || t.TABLE_NAME INTO v_Cnt;
            DBMS_OUTPUT.PUT_LINE('Table: ' || RPAD(t.TABLE_NAME, 25) || ' Rows: ' || v_Cnt);
        END;
    END LOOP;

    -- Views
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- REGISTERED VIEWS ---');
    FOR v IN (SELECT VIEW_NAME FROM USER_VIEWS ORDER BY VIEW_NAME) LOOP
        DBMS_OUTPUT.PUT_LINE('View: ' || v.VIEW_NAME);
    END LOOP;

    -- Packages
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- PL/SQL PACKAGES ---');
    FOR p IN (SELECT OBJECT_NAME, STATUS FROM USER_OBJECTS WHERE OBJECT_TYPE = 'PACKAGE' ORDER BY OBJECT_NAME) LOOP
        DBMS_OUTPUT.PUT_LINE('Package: ' || RPAD(p.OBJECT_NAME, 30) || ' Status: ' || p.STATUS);
    END LOOP;

    -- Constraints Summary
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- CONSTRAINTS SUMMARY BY TYPE ---');
    FOR c IN (
        SELECT CONSTRAINT_TYPE,
               DECODE(CONSTRAINT_TYPE, 'P', 'PRIMARY KEY', 'R', 'FOREIGN KEY (REFERENTIAL)', 'U', 'UNIQUE', 'C', 'CHECK / NOT NULL', CONSTRAINT_TYPE) AS TYPE_DESC,
               COUNT(*) AS TOTAL
        FROM USER_CONSTRAINTS
        GROUP BY CONSTRAINT_TYPE
        ORDER BY CONSTRAINT_TYPE
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Type ' || c.CONSTRAINT_TYPE || ' (' || RPAD(c.TYPE_DESC, 30) || '): ' || c.TOTAL);
    END LOOP;

    -- Indexes Summary
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('--- INDEXES SUMMARY ---');
    FOR i IN (SELECT TABLE_NAME, INDEX_NAME, UNIQUENESS FROM USER_INDEXES ORDER BY TABLE_NAME, INDEX_NAME) LOOP
        DBMS_OUTPUT.PUT_LINE('Index: ' || RPAD(i.INDEX_NAME, 30) || ' on Table: ' || RPAD(i.TABLE_NAME, 20) || ' [' || i.UNIQUENESS || ']');
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('======================================================================');
    DBMS_OUTPUT.PUT_LINE('END OF SCHEMA INVENTORY');
    DBMS_OUTPUT.PUT_LINE('======================================================================');
END;
/
