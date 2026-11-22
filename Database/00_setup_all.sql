-- ====================================================================
-- Master Deployment Script: Training Courses Management System
-- Target: Oracle Database 19c Enterprise Edition (Any Application Schema / PDB)
-- Tool:   Oracle SQL Developer / SQL*Plus / SQLcl
-- ====================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET SERVEROUTPUT ON;

PROMPT ====================================================================
PROMPT Step 1: Preflight connection and identity assertion...
PROMPT ====================================================================
@00_preflight.sql

PROMPT ====================================================================
PROMPT Step 2: Creating 3NF normalized tables (Identity columns & SecureFile CLOBs)...
PROMPT ====================================================================
@01_create_tables.sql

PROMPT ====================================================================
PROMPT Step 3: Establishing Primary Keys, Foreign Keys, Unique & Check Constraints, and Indexes...
PROMPT ====================================================================
@02_constraints_indexes.sql

PROMPT ====================================================================
PROMPT Step 4: Compiling reporting and multi-table join views...
PROMPT ====================================================================
@03_create_views.sql

PROMPT ====================================================================
PROMPT Step 5: Compiling PL/SQL package specifications (RefCursors)...
PROMPT ====================================================================
@04_package_specs.sql

PROMPT ====================================================================
PROMPT Step 6: Compiling PL/SQL package bodies (Row locking FOR UPDATE & atomic seat management)...
PROMPT ====================================================================
@05_package_bodies.sql

PROMPT ====================================================================
PROMPT Step 7: Seeding initial sample data (Categories, Courses, Trainers, Offerings, Trainees, Registrations)...
PROMPT ====================================================================
@06_sample_data.sql

PROMPT ====================================================================
PROMPT Step 8: Executing automated 15-scenario PL/SQL database test suite...
PROMPT ====================================================================
@07_database_tests.sql

PROMPT ====================================================================
PROMPT Step 9: Verifying database objects status and compilation errors...
PROMPT ====================================================================
@08_verify_database.sql

PROMPT ====================================================================
PROMPT Step 10: Generating complete schema inventory...
PROMPT ====================================================================
@09_schema_inventory.sql

PROMPT ====================================================================
PROMPT ALL DATABASE SETUP SCRIPTS EXECUTED SUCCESSFULLY!
PROMPT ====================================================================
