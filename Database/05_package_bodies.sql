-- ============================================================================
-- SCRIPT: 05_package_bodies.sql
-- PURPOSE: PL/SQL Package Bodies Implementation
-- SCHEMA: FINAL_APP | PDB: FINALPDB | TARGET: Oracle Database 19c
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. ADMIN_PACKAGE Body
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY ADMIN_PACKAGE AS

    PROCEDURE GetAllAdmins(p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT AdminID, Username, Email, FullName, IsActive, CreatedAt, UpdatedAt, LastLogin
            FROM ADMINS
            ORDER BY AdminID ASC;
    END GetAllAdmins;

    PROCEDURE GetAdminById(p_AdminID IN NUMBER, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT AdminID, Username, Email, FullName, IsActive, CreatedAt, UpdatedAt, LastLogin
            FROM ADMINS
            WHERE AdminID = p_AdminID;
    END GetAdminById;

    PROCEDURE GetAdminByUsername(p_Username IN VARCHAR2, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT AdminID, Username, PasswordHash, PasswordSalt, Email, FullName, IsActive, CreatedAt, UpdatedAt, LastLogin
            FROM ADMINS
            WHERE LOWER(Username) = LOWER(p_Username);
    END GetAdminByUsername;

    PROCEDURE CreateAdmin(
        p_Username     IN ADMINS.Username%TYPE,
        p_PasswordHash IN ADMINS.PasswordHash%TYPE,
        p_PasswordSalt IN ADMINS.PasswordSalt%TYPE,
        p_Email        IN ADMINS.Email%TYPE,
        p_FullName     IN ADMINS.FullName%TYPE,
        p_AdminID      OUT NUMBER
    ) IS
    BEGIN
        INSERT INTO ADMINS (
            Username, PasswordHash, PasswordSalt, Email, FullName, IsActive, CreatedAt
        ) VALUES (
            p_Username, p_PasswordHash, p_PasswordSalt, p_Email, p_FullName, 1, SYSTIMESTAMP
        ) RETURNING AdminID INTO p_AdminID;
    END CreateAdmin;

    PROCEDURE UpdateAdmin(
        p_AdminID      IN NUMBER,
        p_Username     IN ADMINS.Username%TYPE,
        p_Email        IN ADMINS.Email%TYPE,
        p_FullName     IN ADMINS.FullName%TYPE,
        p_IsActive     IN NUMBER
    ) IS
    BEGIN
        UPDATE ADMINS
        SET Username  = p_Username,
            Email     = p_Email,
            FullName  = p_FullName,
            IsActive  = p_IsActive,
            UpdatedAt = SYSTIMESTAMP
        WHERE AdminID = p_AdminID;
    END UpdateAdmin;

    PROCEDURE UpdatePassword(
        p_AdminID      IN NUMBER,
        p_PasswordHash IN ADMINS.PasswordHash%TYPE,
        p_PasswordSalt IN ADMINS.PasswordSalt%TYPE
    ) IS
    BEGIN
        UPDATE ADMINS
        SET PasswordHash = p_PasswordHash,
            PasswordSalt = p_PasswordSalt,
            UpdatedAt    = SYSTIMESTAMP
        WHERE AdminID    = p_AdminID;
    END UpdatePassword;

    PROCEDURE DeleteAdmin(p_AdminID IN NUMBER) IS
    BEGIN
        DELETE FROM ADMINS WHERE AdminID = p_AdminID;
    END DeleteAdmin;

END ADMIN_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 2. CATEGORY_PACKAGE Body
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY CATEGORY_PACKAGE AS

    PROCEDURE GetAllCategories(p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT CategoryID, CategoryName, Description, CreatedAt, UpdatedAt
            FROM CATEGORIES
            ORDER BY CategoryName ASC;
    END GetAllCategories;

    PROCEDURE GetCategoryById(p_CategoryID IN NUMBER, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT CategoryID, CategoryName, Description, CreatedAt, UpdatedAt
            FROM CATEGORIES
            WHERE CategoryID = p_CategoryID;
    END GetCategoryById;

    PROCEDURE CreateCategory(
        p_CategoryName IN CATEGORIES.CategoryName%TYPE,
        p_Description  IN CATEGORIES.Description%TYPE,
        p_CategoryID   OUT NUMBER
    ) IS
    BEGIN
        INSERT INTO CATEGORIES (
            CategoryName, Description, CreatedAt
        ) VALUES (
            p_CategoryName, p_Description, SYSTIMESTAMP
        ) RETURNING CategoryID INTO p_CategoryID;
    END CreateCategory;

    PROCEDURE UpdateCategory(
        p_CategoryID   IN NUMBER,
        p_CategoryName IN CATEGORIES.CategoryName%TYPE,
        p_Description  IN CATEGORIES.Description%TYPE
    ) IS
    BEGIN
        UPDATE CATEGORIES
        SET CategoryName = p_CategoryName,
            Description  = p_Description,
            UpdatedAt    = SYSTIMESTAMP
        WHERE CategoryID = p_CategoryID;
    END UpdateCategory;

    PROCEDURE DeleteCategory(p_CategoryID IN NUMBER) IS
    BEGIN
        DELETE FROM CATEGORIES WHERE CategoryID = p_CategoryID;
    END DeleteCategory;

END CATEGORY_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 3. COURSE_PACKAGE Body
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY COURSE_PACKAGE AS

    PROCEDURE GetAllCourses(p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT 
                c.CourseID, c.CategoryID, cat.CategoryName, c.CourseName,
                c.Description, c.LearningObjectives, c.Prerequisites,
                c.Price, c.Duration, c.DeliveryMode, c.IsFeatured,
                c.CreatedAt, c.UpdatedAt
            FROM COURSES c
            INNER JOIN CATEGORIES cat ON c.CategoryID = cat.CategoryID
            ORDER BY c.CourseName ASC;
    END GetAllCourses;

    PROCEDURE GetCourseById(p_CourseID IN NUMBER, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT 
                c.CourseID, c.CategoryID, cat.CategoryName, c.CourseName,
                c.Description, c.LearningObjectives, c.Prerequisites,
                c.Price, c.Duration, c.DeliveryMode, c.IsFeatured,
                c.CreatedAt, c.UpdatedAt
            FROM COURSES c
            INNER JOIN CATEGORIES cat ON c.CategoryID = cat.CategoryID
            WHERE c.CourseID = p_CourseID;
    END GetCourseById;

    PROCEDURE GetFeaturedCourses(p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT 
                c.CourseID, c.CategoryID, cat.CategoryName, c.CourseName,
                c.Description, c.LearningObjectives, c.Prerequisites,
                c.Price, c.Duration, c.DeliveryMode, c.IsFeatured,
                c.CreatedAt, c.UpdatedAt
            FROM COURSES c
            INNER JOIN CATEGORIES cat ON c.CategoryID = cat.CategoryID
            WHERE c.IsFeatured = 1
            ORDER BY c.CourseName ASC;
    END GetFeaturedCourses;

    PROCEDURE SearchAndFilterCourses(
        p_Search       IN VARCHAR2,
        p_CategoryID   IN NUMBER,
        p_MinPrice     IN NUMBER,
        p_MaxPrice     IN NUMBER,
        p_DeliveryMode IN VARCHAR2,
        p_SortBy       IN VARCHAR2,
        p_Cursor       OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT 
                c.CourseID, c.CategoryID, cat.CategoryName, c.CourseName,
                c.Description, c.LearningObjectives, c.Prerequisites,
                c.Price, c.Duration, c.DeliveryMode, c.IsFeatured,
                c.CreatedAt, c.UpdatedAt
            FROM COURSES c
            INNER JOIN CATEGORIES cat ON c.CategoryID = cat.CategoryID
            WHERE (p_Search IS NULL OR 
                   LOWER(c.CourseName) LIKE '%' || LOWER(TRIM(p_Search)) || '%' OR 
                   LOWER(c.Description) LIKE '%' || LOWER(TRIM(p_Search)) || '%')
              AND (p_CategoryID IS NULL OR c.CategoryID = p_CategoryID)
              AND (p_MinPrice IS NULL OR c.Price >= p_MinPrice)
              AND (p_MaxPrice IS NULL OR c.Price <= p_MaxPrice)
              AND (p_DeliveryMode IS NULL OR LOWER(c.DeliveryMode) = LOWER(TRIM(p_DeliveryMode)))
            ORDER BY
                CASE WHEN p_SortBy = 'price_asc'     THEN c.Price END ASC,
                CASE WHEN p_SortBy = 'price_desc'    THEN c.Price END DESC,
                CASE WHEN p_SortBy = 'duration_asc'  THEN c.Duration END ASC,
                CASE WHEN p_SortBy = 'duration_desc' THEN c.Duration END DESC,
                CASE WHEN p_SortBy = 'newest'        THEN c.CourseID END DESC,
                c.CourseName ASC;
    END SearchAndFilterCourses;

    PROCEDURE CreateCourse(
        p_CategoryID          IN COURSES.CategoryID%TYPE,
        p_CourseName          IN COURSES.CourseName%TYPE,
        p_Description         IN COURSES.Description%TYPE,
        p_LearningObjectives  IN COURSES.LearningObjectives%TYPE,
        p_Prerequisites       IN COURSES.Prerequisites%TYPE,
        p_Price               IN COURSES.Price%TYPE,
        p_Duration            IN COURSES.Duration%TYPE,
        p_DeliveryMode        IN COURSES.DeliveryMode%TYPE,
        p_IsFeatured          IN COURSES.IsFeatured%TYPE,
        p_CourseID            OUT NUMBER
    ) IS
    BEGIN
        INSERT INTO COURSES (
            CategoryID, CourseName, Description, LearningObjectives,
            Prerequisites, Price, Duration, DeliveryMode, IsFeatured, CreatedAt
        ) VALUES (
            p_CategoryID, p_CourseName, p_Description, p_LearningObjectives,
            p_Prerequisites, p_Price, p_Duration, p_DeliveryMode, NVL(p_IsFeatured, 0), SYSTIMESTAMP
        ) RETURNING CourseID INTO p_CourseID;
    END CreateCourse;

    PROCEDURE UpdateCourse(
        p_CourseID            IN NUMBER,
        p_CategoryID          IN COURSES.CategoryID%TYPE,
        p_CourseName          IN COURSES.CourseName%TYPE,
        p_Description         IN COURSES.Description%TYPE,
        p_LearningObjectives  IN COURSES.LearningObjectives%TYPE,
        p_Prerequisites       IN COURSES.Prerequisites%TYPE,
        p_Price               IN COURSES.Price%TYPE,
        p_Duration            IN COURSES.Duration%TYPE,
        p_DeliveryMode        IN COURSES.DeliveryMode%TYPE,
        p_IsFeatured          IN COURSES.IsFeatured%TYPE
    ) IS
    BEGIN
        UPDATE COURSES
        SET CategoryID         = p_CategoryID,
            CourseName         = p_CourseName,
            Description        = p_Description,
            LearningObjectives = p_LearningObjectives,
            Prerequisites      = p_Prerequisites,
            Price              = p_Price,
            Duration           = p_Duration,
            DeliveryMode       = p_DeliveryMode,
            IsFeatured         = NVL(p_IsFeatured, 0),
            UpdatedAt          = SYSTIMESTAMP
        WHERE CourseID         = p_CourseID;
    END UpdateCourse;

    PROCEDURE DeleteCourse(p_CourseID IN NUMBER) IS
    BEGIN
        DELETE FROM COURSES WHERE CourseID = p_CourseID;
    END DeleteCourse;

END COURSE_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 4. TRAINER_PACKAGE Body
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY TRAINER_PACKAGE AS

    PROCEDURE GetAllTrainers(p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT TrainerID, FullName, Specialization, Qualifications, ProfileDetails,
                   Email, PhoneNumber, CreatedAt, UpdatedAt
            FROM TRAINERS
            ORDER BY FullName ASC;
    END GetAllTrainers;

    PROCEDURE GetTrainerById(p_TrainerID IN NUMBER, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT TrainerID, FullName, Specialization, Qualifications, ProfileDetails,
                   Email, PhoneNumber, CreatedAt, UpdatedAt
            FROM TRAINERS
            WHERE TrainerID = p_TrainerID;
    END GetTrainerById;

    PROCEDURE SearchAndFilterTrainers(
        p_Search         IN VARCHAR2,
        p_Specialization IN VARCHAR2,
        p_Cursor         OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT TrainerID, FullName, Specialization, Qualifications, ProfileDetails,
                   Email, PhoneNumber, CreatedAt, UpdatedAt
            FROM TRAINERS
            WHERE (p_Search IS NULL OR 
                   LOWER(FullName) LIKE '%' || LOWER(TRIM(p_Search)) || '%' OR 
                   LOWER(Specialization) LIKE '%' || LOWER(TRIM(p_Search)) || '%')
              AND (p_Specialization IS NULL OR LOWER(Specialization) LIKE '%' || LOWER(TRIM(p_Specialization)) || '%')
            ORDER BY FullName ASC;
    END SearchAndFilterTrainers;

    PROCEDURE GetTrainerAssignedCourses(p_TrainerID IN NUMBER, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT DISTINCT
                co.OfferingID,
                co.CourseID,
                c.CourseName,
                c.Price,
                co.StartDate,
                co.EndDate,
                co.ScheduleDetails,
                co.MaxCapacity,
                co.AvailableSeats
            FROM COURSEOFFERINGS co
            INNER JOIN COURSES c ON co.CourseID = c.CourseID
            WHERE co.TrainerID = p_TrainerID
            ORDER BY co.StartDate DESC;
    END GetTrainerAssignedCourses;

    PROCEDURE CreateTrainer(
        p_FullName       IN TRAINERS.FullName%TYPE,
        p_Specialization IN TRAINERS.Specialization%TYPE,
        p_Qualifications IN TRAINERS.Qualifications%TYPE,
        p_ProfileDetails IN TRAINERS.ProfileDetails%TYPE,
        p_Email          IN TRAINERS.Email%TYPE,
        p_PhoneNumber    IN TRAINERS.PhoneNumber%TYPE,
        p_TrainerID      OUT NUMBER
    ) IS
    BEGIN
        INSERT INTO TRAINERS (
            FullName, Specialization, Qualifications, ProfileDetails,
            Email, PhoneNumber, CreatedAt
        ) VALUES (
            p_FullName, p_Specialization, p_Qualifications, p_ProfileDetails,
            p_Email, p_PhoneNumber, SYSTIMESTAMP
        ) RETURNING TrainerID INTO p_TrainerID;
    END CreateTrainer;

    PROCEDURE UpdateTrainer(
        p_TrainerID      IN NUMBER,
        p_FullName       IN TRAINERS.FullName%TYPE,
        p_Specialization IN TRAINERS.Specialization%TYPE,
        p_Qualifications IN TRAINERS.Qualifications%TYPE,
        p_ProfileDetails IN TRAINERS.ProfileDetails%TYPE,
        p_Email          IN TRAINERS.Email%TYPE,
        p_PhoneNumber    IN TRAINERS.PhoneNumber%TYPE
    ) IS
    BEGIN
        UPDATE TRAINERS
        SET FullName       = p_FullName,
            Specialization = p_Specialization,
            Qualifications = p_Qualifications,
            ProfileDetails = p_ProfileDetails,
            Email          = p_Email,
            PhoneNumber    = p_PhoneNumber,
            UpdatedAt      = SYSTIMESTAMP
        WHERE TrainerID    = p_TrainerID;
    END UpdateTrainer;

    PROCEDURE DeleteTrainer(p_TrainerID IN NUMBER) IS
    BEGIN
        DELETE FROM TRAINERS WHERE TrainerID = p_TrainerID;
    END DeleteTrainer;

END TRAINER_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 5. TRAINEE_PACKAGE Body
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY TRAINEE_PACKAGE AS

    PROCEDURE GetAllTrainees(p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT TraineeID, FullName, Email, PhoneNumber, EducationalBackground,
                   CreatedAt, UpdatedAt
            FROM TRAINEES
            ORDER BY FullName ASC;
    END GetAllTrainees;

    PROCEDURE GetTraineeById(p_TraineeID IN NUMBER, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT TraineeID, FullName, Email, PhoneNumber, EducationalBackground,
                   CreatedAt, UpdatedAt
            FROM TRAINEES
            WHERE TraineeID = p_TraineeID;
    END GetTraineeById;

    PROCEDURE GetTraineeByEmail(p_Email IN VARCHAR2, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT TraineeID, FullName, Email, PhoneNumber, EducationalBackground,
                   CreatedAt, UpdatedAt
            FROM TRAINEES
            WHERE LOWER(Email) = LOWER(TRIM(p_Email));
    END GetTraineeByEmail;

    PROCEDURE CreateTrainee(
        p_FullName              IN TRAINEES.FullName%TYPE,
        p_Email                 IN TRAINEES.Email%TYPE,
        p_PhoneNumber           IN TRAINEES.PhoneNumber%TYPE,
        p_EducationalBackground IN TRAINEES.EducationalBackground%TYPE,
        p_TraineeID             OUT NUMBER
    ) IS
    BEGIN
        INSERT INTO TRAINEES (
            FullName, Email, PhoneNumber, EducationalBackground, CreatedAt
        ) VALUES (
            p_FullName, p_Email, p_PhoneNumber, p_EducationalBackground, SYSTIMESTAMP
        ) RETURNING TraineeID INTO p_TraineeID;
    END CreateTrainee;

    PROCEDURE UpdateTrainee(
        p_TraineeID             IN NUMBER,
        p_FullName              IN TRAINEES.FullName%TYPE,
        p_Email                 IN TRAINEES.Email%TYPE,
        p_PhoneNumber           IN TRAINEES.PhoneNumber%TYPE,
        p_EducationalBackground IN TRAINEES.EducationalBackground%TYPE
    ) IS
    BEGIN
        UPDATE TRAINEES
        SET FullName              = p_FullName,
            Email                 = p_Email,
            PhoneNumber           = p_PhoneNumber,
            EducationalBackground = p_EducationalBackground,
            UpdatedAt             = SYSTIMESTAMP
        WHERE TraineeID           = p_TraineeID;
    END UpdateTrainee;

    PROCEDURE DeleteTrainee(p_TraineeID IN NUMBER) IS
    BEGIN
        DELETE FROM TRAINEES WHERE TraineeID = p_TraineeID;
    END DeleteTrainee;

END TRAINEE_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 6. COURSEOFFERING_PACKAGE Body
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY COURSEOFFERING_PACKAGE AS

    PROCEDURE GetAllOfferings(p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT * FROM VW_OFFERING_DETAILS
            ORDER BY StartDate DESC;
    END GetAllOfferings;

    PROCEDURE GetOfferingById(p_OfferingID IN NUMBER, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT * FROM VW_OFFERING_DETAILS
            WHERE OfferingID = p_OfferingID;
    END GetOfferingById;

    PROCEDURE GetOfferingsByCourse(p_CourseID IN NUMBER, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT * FROM VW_OFFERING_DETAILS
            WHERE CourseID = p_CourseID
            ORDER BY StartDate ASC;
    END GetOfferingsByCourse;

    PROCEDURE GetUpcomingOfferings(p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT * FROM VW_OFFERING_DETAILS
            WHERE StartDate >= TRUNC(SYSDATE)
            ORDER BY StartDate ASC;
    END GetUpcomingOfferings;

    PROCEDURE CreateOffering(
        p_CourseID        IN COURSEOFFERINGS.CourseID%TYPE,
        p_TrainerID       IN COURSEOFFERINGS.TrainerID%TYPE,
        p_StartDate       IN COURSEOFFERINGS.StartDate%TYPE,
        p_EndDate         IN COURSEOFFERINGS.EndDate%TYPE,
        p_ScheduleDetails IN COURSEOFFERINGS.ScheduleDetails%TYPE,
        p_MaxCapacity     IN COURSEOFFERINGS.MaxCapacity%TYPE,
        p_OfferingID      OUT NUMBER
    ) IS
    BEGIN
        IF p_EndDate <= p_StartDate THEN
            RAISE_APPLICATION_ERROR(-20010, 'Offering EndDate must be strictly after StartDate.');
        END IF;

        IF p_MaxCapacity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'MaxCapacity must be greater than zero.');
        END IF;

        INSERT INTO COURSEOFFERINGS (
            CourseID, TrainerID, StartDate, EndDate, ScheduleDetails,
            MaxCapacity, AvailableSeats, CreatedAt
        ) VALUES (
            p_CourseID, p_TrainerID, p_StartDate, p_EndDate, p_ScheduleDetails,
            p_MaxCapacity, p_MaxCapacity, SYSTIMESTAMP
        ) RETURNING OfferingID INTO p_OfferingID;
    END CreateOffering;

    PROCEDURE UpdateOffering(
        p_OfferingID      IN NUMBER,
        p_CourseID        IN COURSEOFFERINGS.CourseID%TYPE,
        p_TrainerID       IN COURSEOFFERINGS.TrainerID%TYPE,
        p_StartDate       IN COURSEOFFERINGS.StartDate%TYPE,
        p_EndDate         IN COURSEOFFERINGS.EndDate%TYPE,
        p_ScheduleDetails IN COURSEOFFERINGS.ScheduleDetails%TYPE,
        p_MaxCapacity     IN COURSEOFFERINGS.MaxCapacity%TYPE
    ) IS
        v_ActiveCount NUMBER := 0;
    BEGIN
        IF p_EndDate <= p_StartDate THEN
            RAISE_APPLICATION_ERROR(-20010, 'Offering EndDate must be strictly after StartDate.');
        END IF;

        -- Count confirmed/pending registrations
        SELECT COUNT(*)
        INTO v_ActiveCount
        FROM REGISTRATIONS
        WHERE OfferingID = p_OfferingID
          AND Status IN ('Confirmed', 'Pending');

        IF p_MaxCapacity < v_ActiveCount THEN
            RAISE_APPLICATION_ERROR(-20012, 'New MaxCapacity cannot be less than current active registrations (' || v_ActiveCount || ').');
        END IF;

        UPDATE COURSEOFFERINGS
        SET CourseID        = p_CourseID,
            TrainerID       = p_TrainerID,
            StartDate       = p_StartDate,
            EndDate         = p_EndDate,
            ScheduleDetails = p_ScheduleDetails,
            MaxCapacity     = p_MaxCapacity,
            AvailableSeats  = (p_MaxCapacity - v_ActiveCount),
            UpdatedAt       = SYSTIMESTAMP
        WHERE OfferingID    = p_OfferingID;
    END UpdateOffering;

    PROCEDURE DeleteOffering(p_OfferingID IN NUMBER) IS
    BEGIN
        DELETE FROM COURSEOFFERINGS WHERE OfferingID = p_OfferingID;
    END DeleteOffering;

END COURSEOFFERING_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 7. REGISTRATION_PACKAGE Body (Atomic Registration & Seat Management)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY REGISTRATION_PACKAGE AS

    PROCEDURE GetAllRegistrations(p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT * FROM VW_REGISTRATION_DETAILS
            ORDER BY RegistrationDate DESC;
    END GetAllRegistrations;

    PROCEDURE GetRegistrationById(p_RegistrationID IN NUMBER, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT * FROM VW_REGISTRATION_DETAILS
            WHERE RegistrationID = p_RegistrationID;
    END GetRegistrationById;

    PROCEDURE GetRegistrationsByTrainee(p_TraineeID IN NUMBER, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT * FROM VW_REGISTRATION_DETAILS
            WHERE TraineeID = p_TraineeID
            ORDER BY RegistrationDate DESC;
    END GetRegistrationsByTrainee;

    PROCEDURE GetRegistrationsByEmail(p_Email IN VARCHAR2, p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT * FROM VW_REGISTRATION_DETAILS
            WHERE LOWER(TraineeEmail) = LOWER(TRIM(p_Email))
            ORDER BY RegistrationDate DESC;
    END GetRegistrationsByEmail;

    PROCEDURE RegisterTrainee(
        p_TraineeID      IN NUMBER,
        p_OfferingID     IN NUMBER,
        p_Status         IN VARCHAR2,
        p_RegistrationID OUT NUMBER
    ) IS
        v_Seats        NUMBER;
        v_StartDate    DATE;
        v_ExistingCount NUMBER := 0;
        v_FinalStatus  VARCHAR2(20);
    BEGIN
        v_FinalStatus := NVL(p_Status, 'Confirmed');

        -- 1. Prevent duplicate active registrations for the same trainee and offering
        SELECT COUNT(*)
        INTO v_ExistingCount
        FROM REGISTRATIONS
        WHERE TraineeID = p_TraineeID
          AND OfferingID = p_OfferingID
          AND Status IN ('Confirmed', 'Pending');

        IF v_ExistingCount > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Trainee is already registered for this course offering.');
        END IF;

        -- 2. Lock the offering row to ensure atomic seat deduction and prevent race conditions
        BEGIN
            SELECT AvailableSeats, StartDate
            INTO v_Seats, v_StartDate
            FROM COURSEOFFERINGS
            WHERE OfferingID = p_OfferingID
            FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20005, 'Course offering not found with ID: ' || p_OfferingID);
        END;

        -- 3. Business rule: Do not allow registrations after the course has started
        IF v_StartDate < TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Cannot register for a course offering that has already started.');
        END IF;

        -- 4. Business rule: Verify seat availability
        IF v_Seats <= 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Course offering is fully booked. No available seats remaining.');
        END IF;

        -- 5. Insert registration record
        INSERT INTO REGISTRATIONS (
            TraineeID, OfferingID, RegistrationDate, Status, CreatedAt
        ) VALUES (
            p_TraineeID, p_OfferingID, SYSTIMESTAMP, v_FinalStatus, SYSTIMESTAMP
        ) RETURNING RegistrationID INTO p_RegistrationID;

        -- 6. Atomically decrement available seats
        UPDATE COURSEOFFERINGS
        SET AvailableSeats = AvailableSeats - 1,
            UpdatedAt      = SYSTIMESTAMP
        WHERE OfferingID   = p_OfferingID;

    END RegisterTrainee;

    PROCEDURE CancelRegistration(
        p_RegistrationID IN NUMBER,
        p_Reason         IN VARCHAR2
    ) IS
        v_OfferingID  NUMBER;
        v_Status      VARCHAR2(20);
        v_StartDate   DATE;
        v_MaxCapacity NUMBER;
        v_Seats       NUMBER;
    BEGIN
        -- 1. Lock the registration row
        BEGIN
            SELECT OfferingID, Status
            INTO v_OfferingID, v_Status
            FROM REGISTRATIONS
            WHERE RegistrationID = p_RegistrationID
            FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20006, 'Registration not found with ID: ' || p_RegistrationID);
        END;

        -- 2. If already cancelled, no-op
        IF v_Status = 'Cancelled' THEN
            RETURN;
        END IF;

        -- 3. Lock the offering row to check start date and restore seat
        SELECT StartDate, MaxCapacity, AvailableSeats
        INTO v_StartDate, v_MaxCapacity, v_Seats
        FROM COURSEOFFERINGS
        WHERE OfferingID = v_OfferingID
        FOR UPDATE;

        -- 4. Business rule: Cannot cancel after the offering has started
        IF v_StartDate < TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20004, 'Cannot cancel registration for a course offering that has already started.');
        END IF;

        -- 5. Update registration status
        UPDATE REGISTRATIONS
        SET Status             = 'Cancelled',
            CancellationReason = p_Reason,
            CancellationDate   = SYSTIMESTAMP,
            UpdatedAt          = SYSTIMESTAMP
        WHERE RegistrationID   = p_RegistrationID;

        -- 6. Restore available seat up to MaxCapacity
        IF v_Seats < v_MaxCapacity THEN
            UPDATE COURSEOFFERINGS
            SET AvailableSeats = AvailableSeats + 1,
                UpdatedAt      = SYSTIMESTAMP
            WHERE OfferingID   = v_OfferingID;
        END IF;

    END CancelRegistration;

    PROCEDURE UpdateRegistrationStatus(
        p_RegistrationID IN NUMBER,
        p_Status         IN VARCHAR2
    ) IS
        v_OldStatus VARCHAR2(20);
    BEGIN
        SELECT Status INTO v_OldStatus
        FROM REGISTRATIONS
        WHERE RegistrationID = p_RegistrationID;

        IF p_Status = 'Cancelled' AND v_OldStatus <> 'Cancelled' THEN
            CancelRegistration(p_RegistrationID, 'Status updated to Cancelled');
        ELSE
            UPDATE REGISTRATIONS
            SET Status    = p_Status,
                UpdatedAt = SYSTIMESTAMP
            WHERE RegistrationID = p_RegistrationID;
        END IF;
    END UpdateRegistrationStatus;

    PROCEDURE DeleteRegistration(p_RegistrationID IN NUMBER) IS
        v_OfferingID NUMBER;
        v_Status     VARCHAR2(20);
    BEGIN
        BEGIN
            SELECT OfferingID, Status
            INTO v_OfferingID, v_Status
            FROM REGISTRATIONS
            WHERE RegistrationID = p_RegistrationID;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN;
        END;

        IF v_Status IN ('Confirmed', 'Pending') THEN
            UPDATE COURSEOFFERINGS
            SET AvailableSeats = LEAST(AvailableSeats + 1, MaxCapacity),
                UpdatedAt      = SYSTIMESTAMP
            WHERE OfferingID   = v_OfferingID;
        END IF;

        DELETE FROM REGISTRATIONS WHERE RegistrationID = p_RegistrationID;
    END DeleteRegistration;

END REGISTRATION_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 8. REPORTING_PACKAGE Body
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY REPORTING_PACKAGE AS

    PROCEDURE GetDashboardKPIs(p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT 
                (SELECT COUNT(*) FROM COURSES) AS TotalCourses,
                (SELECT COUNT(*) FROM COURSEOFFERINGS) AS TotalOfferings,
                (SELECT COUNT(*) FROM TRAINERS) AS TotalTrainers,
                (SELECT COUNT(*) FROM TRAINEES) AS TotalTrainees,
                (SELECT COUNT(*) FROM REGISTRATIONS WHERE Status IN ('Confirmed', 'Pending')) AS TotalRegistrations,
                (SELECT COUNT(*) FROM COURSEOFFERINGS WHERE StartDate >= TRUNC(SYSDATE)) AS ActiveOfferings,
                (SELECT NVL(SUM(c.Price), 0)
                 FROM REGISTRATIONS r
                 INNER JOIN COURSEOFFERINGS co ON r.OfferingID = co.OfferingID
                 INNER JOIN COURSES c ON co.CourseID = c.CourseID
                 WHERE r.Status = 'Confirmed') AS TotalRevenue
            FROM DUAL;
    END GetDashboardKPIs;

    PROCEDURE GetRegistrationsByCategoryChart(p_Cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT 
                cat.CategoryID,
                cat.CategoryName,
                COUNT(r.RegistrationID) AS RegistrationCount,
                COUNT(DISTINCT c.CourseID) AS CourseCount
            FROM CATEGORIES cat
            LEFT JOIN COURSES c ON cat.CategoryID = c.CategoryID
            LEFT JOIN COURSEOFFERINGS co ON c.CourseID = co.CourseID
            LEFT JOIN REGISTRATIONS r ON co.OfferingID = r.OfferingID AND r.Status IN ('Confirmed', 'Pending')
            GROUP BY cat.CategoryID, cat.CategoryName
            ORDER BY RegistrationCount DESC, cat.CategoryName ASC;
    END GetRegistrationsByCategoryChart;

    PROCEDURE GetPopularCourses(p_Limit IN NUMBER, p_Cursor OUT SYS_REFCURSOR) IS
        v_Limit NUMBER := NVL(p_Limit, 5);
    BEGIN
        OPEN p_Cursor FOR
            SELECT *
            FROM (
                SELECT 
                    c.CourseID,
                    c.CourseName,
                    cat.CategoryName,
                    c.Price,
                    c.Duration,
                    c.DeliveryMode,
                    COUNT(r.RegistrationID) AS TotalEnrollments,
                    COUNT(DISTINCT co.OfferingID) AS TotalOfferings
                FROM COURSES c
                INNER JOIN CATEGORIES cat ON c.CategoryID = cat.CategoryID
                LEFT JOIN COURSEOFFERINGS co ON c.CourseID = co.CourseID
                LEFT JOIN REGISTRATIONS r ON co.OfferingID = r.OfferingID AND r.Status IN ('Confirmed', 'Pending')
                GROUP BY c.CourseID, c.CourseName, cat.CategoryName, c.Price, c.Duration, c.DeliveryMode
                ORDER BY TotalEnrollments DESC, c.CourseName ASC
            )
            WHERE ROWNUM <= v_Limit;
    END GetPopularCourses;

END REPORTING_PACKAGE;
/
