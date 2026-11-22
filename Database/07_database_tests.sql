-- ============================================================================
-- SCRIPT: 07_database_tests.sql
-- PURPOSE: Automated Database Test Suite (Constraints, Packages, ACID Concurrency)
-- SCHEMA: FINAL_APP | PDB: FINALPDB | TARGET: Oracle Database 19c
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_PassCount NUMBER := 0;
    v_FailCount NUMBER := 0;

    -- Test variables
    v_TempTraineeID   NUMBER;
    v_TempOfferingID  NUMBER;
    v_TempRegID       NUMBER;
    v_SeatsBefore     NUMBER;
    v_SeatsAfter      NUMBER;
    v_SeatsCancelled  NUMBER;
    v_ExpectedError   BOOLEAN;
    v_Cursor          SYS_REFCURSOR;
    v_Count           NUMBER;

    PROCEDURE RecordResult(p_TestName IN VARCHAR2, p_Passed IN BOOLEAN, p_Detail IN VARCHAR2 DEFAULT '') IS
    BEGIN
        IF p_Passed THEN
            v_PassCount := v_PassCount + 1;
            DBMS_OUTPUT.PUT_LINE('[PASS] ' || RPAD(p_TestName, 45) || ' | ' || p_Detail);
        ELSE
            v_FailCount := v_FailCount + 1;
            DBMS_OUTPUT.PUT_LINE('[FAIL] ' || RPAD(p_TestName, 45) || ' | ' || p_Detail);
        END IF;
    END RecordResult;

BEGIN
    DBMS_OUTPUT.PUT_LINE('======================================================================');
    DBMS_OUTPUT.PUT_LINE('STARTING AUTOMATED DATABASE TEST SUITE FOR TRAINING COURSES SYSTEM');
    DBMS_OUTPUT.PUT_LINE('======================================================================');

    -- ------------------------------------------------------------------------
    -- TEST 1: Table Row Counts (Seed Data Verification)
    -- ------------------------------------------------------------------------
    SELECT COUNT(*) INTO v_Count FROM CATEGORIES;
    RecordResult('Seed Data: Categories Count', (v_Count >= 5), 'Found ' || v_Count || ' rows (expected >= 5)');

    SELECT COUNT(*) INTO v_Count FROM COURSES;
    RecordResult('Seed Data: Courses Count', (v_Count >= 5), 'Found ' || v_Count || ' rows (expected >= 5)');

    SELECT COUNT(*) INTO v_Count FROM TRAINERS;
    RecordResult('Seed Data: Trainers Count', (v_Count >= 4), 'Found ' || v_Count || ' rows (expected >= 4)');

    SELECT COUNT(*) INTO v_Count FROM COURSEOFFERINGS;
    RecordResult('Seed Data: Offerings Count', (v_Count >= 5), 'Found ' || v_Count || ' rows (expected >= 5)');

    SELECT COUNT(*) INTO v_Count FROM TRAINEES;
    RecordResult('Seed Data: Trainees Count', (v_Count >= 4), 'Found ' || v_Count || ' rows (expected >= 4)');

    SELECT COUNT(*) INTO v_Count FROM REGISTRATIONS;
    RecordResult('Seed Data: Registrations Count', (v_Count >= 8), 'Found ' || v_Count || ' rows (expected >= 8)');

    -- ------------------------------------------------------------------------
    -- TEST 2: CHECK Constraint Validation (Negative Price Rejection)
    -- ------------------------------------------------------------------------
    v_ExpectedError := FALSE;
    BEGIN
        INSERT INTO COURSES (CategoryID, CourseName, Price, Duration, DeliveryMode)
        VALUES (1, 'Negative Price Test Course', -50.00, 10, 'Online');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2290 THEN -- ORA-02290: check constraint violated
                v_ExpectedError := TRUE;
            END IF;
    END;
    RecordResult('Constraint: Reject Negative Course Price', v_ExpectedError, 'ORA-02290 correctly raised');

    -- ------------------------------------------------------------------------
    -- TEST 3: CHECK Constraint Validation (Invalid Offering Dates)
    -- ------------------------------------------------------------------------
    v_ExpectedError := FALSE;
    BEGIN
        INSERT INTO COURSEOFFERINGS (CourseID, TrainerID, StartDate, EndDate, ScheduleDetails, MaxCapacity, AvailableSeats)
        VALUES (1, 1, TRUNC(SYSDATE) + 10, TRUNC(SYSDATE) + 5, 'Daily 10am', 20, 20);
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2290 THEN
                v_ExpectedError := TRUE;
            END IF;
    END;
    RecordResult('Constraint: Reject EndDate <= StartDate', v_ExpectedError, 'ORA-02290 correctly raised');

    -- ------------------------------------------------------------------------
    -- TEST 4: UNIQUE Constraint Validation (Duplicate Admin Username)
    -- ------------------------------------------------------------------------
    v_ExpectedError := FALSE;
    BEGIN
        INSERT INTO ADMINS (Username, PasswordHash, PasswordSalt, Email, FullName)
        VALUES ('admin', 'dummy_hash', 'dummy_salt', 'other@example.com', 'Duplicate Admin');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN -- ORA-00001: unique constraint violated
                v_ExpectedError := TRUE;
            END IF;
    END;
    RecordResult('Constraint: Reject Duplicate Admin Username', v_ExpectedError, 'ORA-00001 correctly raised');

    -- ------------------------------------------------------------------------
    -- TEST 5: FOREIGN KEY Constraint Validation (Invalid CategoryID in Courses)
    -- ------------------------------------------------------------------------
    v_ExpectedError := FALSE;
    BEGIN
        INSERT INTO COURSES (CategoryID, CourseName, Price, Duration, DeliveryMode)
        VALUES (999999, 'Invalid Category Course', 500, 20, 'Online');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2291 THEN -- ORA-02291: integrity constraint violated - parent key not found
                v_ExpectedError := TRUE;
            END IF;
    END;
    RecordResult('Constraint: Reject Invalid Parent CategoryID', v_ExpectedError, 'ORA-02291 correctly raised');

    -- ------------------------------------------------------------------------
    -- TEST 6: Atomic Registration & Seat Decrement Test
    -- ------------------------------------------------------------------------
    -- Create temporary test offering
    INSERT INTO COURSEOFFERINGS (
        CourseID, TrainerID, StartDate, EndDate, ScheduleDetails, MaxCapacity, AvailableSeats
    ) VALUES (
        1, 1, TRUNC(SYSDATE) + 15, TRUNC(SYSDATE) + 30, 'Test Schedule', 5, 5
    ) RETURNING OfferingID INTO v_TempOfferingID;

    -- Create temporary trainee
    INSERT INTO TRAINEES (FullName, Email, PhoneNumber, EducationalBackground)
    VALUES ('Automated Test Trainee', 'test.trainee.unit@example.com', '+1-555-9999', 'Computer Engineering B.Sc.')
    RETURNING TraineeID INTO v_TempTraineeID;

    SELECT AvailableSeats INTO v_SeatsBefore FROM COURSEOFFERINGS WHERE OfferingID = v_TempOfferingID;

    -- Register trainee
    REGISTRATION_PACKAGE.RegisterTrainee(
        p_TraineeID      => v_TempTraineeID,
        p_OfferingID     => v_TempOfferingID,
        p_Status         => 'Confirmed',
        p_RegistrationID => v_TempRegID
    );

    SELECT AvailableSeats INTO v_SeatsAfter FROM COURSEOFFERINGS WHERE OfferingID = v_TempOfferingID;

    RecordResult('Package: RegisterTrainee Decrements Seat',
                 (v_SeatsAfter = v_SeatsBefore - 1 AND v_TempRegID IS NOT NULL),
                 'Seats before=' || v_SeatsBefore || ', seats after=' || v_SeatsAfter || ', RegID=' || v_TempRegID);

    -- ------------------------------------------------------------------------
    -- TEST 7: Duplicate Registration Prevention
    -- ------------------------------------------------------------------------
    v_ExpectedError := FALSE;
    BEGIN
        REGISTRATION_PACKAGE.RegisterTrainee(
            p_TraineeID      => v_TempTraineeID,
            p_OfferingID     => v_TempOfferingID,
            p_Status         => 'Confirmed',
            p_RegistrationID => v_Count
        );
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20001 THEN -- Trainee already registered
                v_ExpectedError := TRUE;
            END IF;
    END;
    RecordResult('Package: Prevent Duplicate Registration', v_ExpectedError, 'ORA-20001 correctly raised');

    -- ------------------------------------------------------------------------
    -- TEST 8: Registration Cancellation & Seat Restoration
    -- ------------------------------------------------------------------------
    REGISTRATION_PACKAGE.CancelRegistration(
        p_RegistrationID => v_TempRegID,
        p_Reason         => 'Unit testing cancellation flow'
    );

    SELECT AvailableSeats INTO v_SeatsCancelled FROM COURSEOFFERINGS WHERE OfferingID = v_TempOfferingID;

    RecordResult('Package: CancelRegistration Restores Seat',
                 (v_SeatsCancelled = v_SeatsBefore),
                 'Seats restored to=' || v_SeatsCancelled || ' (expected ' || v_SeatsBefore || ')');

    -- Clean up temporary test data
    DELETE FROM REGISTRATIONS WHERE RegistrationID = v_TempRegID;
    DELETE FROM COURSEOFFERINGS WHERE OfferingID = v_TempOfferingID;
    DELETE FROM TRAINEES WHERE TraineeID = v_TempTraineeID;

    -- ------------------------------------------------------------------------
    -- TEST 9: Reporting Package Execution
    -- ------------------------------------------------------------------------
    BEGIN
        REPORTING_PACKAGE.GetDashboardKPIs(v_Cursor);
        CLOSE v_Cursor;
        RecordResult('Package: REPORTING_PACKAGE.GetDashboardKPIs', TRUE, 'Executed successfully');
    EXCEPTION
        WHEN OTHERS THEN
            RecordResult('Package: REPORTING_PACKAGE.GetDashboardKPIs', FALSE, SQLERRM);
    END;

    -- ------------------------------------------------------------------------
    -- TEST 10: Views Query Validation
    -- ------------------------------------------------------------------------
    BEGIN
        SELECT COUNT(*) INTO v_Count FROM VW_OFFERING_DETAILS;
        SELECT COUNT(*) INTO v_Count FROM VW_REGISTRATION_DETAILS;
        SELECT COUNT(*) INTO v_Count FROM VW_COURSE_SUMMARY;
        RecordResult('Views: Reporting Views Operational', TRUE, 'All views accessible without error');
    EXCEPTION
        WHEN OTHERS THEN
            RecordResult('Views: Reporting Views Operational', FALSE, SQLERRM);
    END;

    DBMS_OUTPUT.PUT_LINE('======================================================================');
    DBMS_OUTPUT.PUT_LINE('TEST SUITE SUMMARY: PASSED=' || v_PassCount || ' | FAILED=' || v_FailCount);
    DBMS_OUTPUT.PUT_LINE('======================================================================');

    IF v_FailCount > 0 THEN
        RAISE_APPLICATION_ERROR(-20999, 'Test suite failed with ' || v_FailCount || ' failure(s).');
    END IF;
END;
/
