-- ============================================================================
-- SCRIPT: 04_package_specs.sql
-- PURPOSE: PL/SQL Package Specifications (Clean Oracle 19c with OUT SYS_REFCURSOR)
-- SCHEMA: FINAL_APP | PDB: FINALPDB | TARGET: Oracle Database 19c
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. ADMIN_PACKAGE Specification
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE ADMIN_PACKAGE AS
    PROCEDURE GetAllAdmins(p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetAdminById(p_AdminID IN NUMBER, p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetAdminByUsername(p_Username IN VARCHAR2, p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE CreateAdmin(
        p_Username     IN ADMINS.Username%TYPE,
        p_PasswordHash IN ADMINS.PasswordHash%TYPE,
        p_PasswordSalt IN ADMINS.PasswordSalt%TYPE,
        p_Email        IN ADMINS.Email%TYPE,
        p_FullName     IN ADMINS.FullName%TYPE,
        p_AdminID      OUT NUMBER
    );
    PROCEDURE UpdateAdmin(
        p_AdminID      IN NUMBER,
        p_Username     IN ADMINS.Username%TYPE,
        p_Email        IN ADMINS.Email%TYPE,
        p_FullName     IN ADMINS.FullName%TYPE,
        p_IsActive     IN NUMBER
    );
    PROCEDURE UpdatePassword(
        p_AdminID      IN NUMBER,
        p_PasswordHash IN ADMINS.PasswordHash%TYPE,
        p_PasswordSalt IN ADMINS.PasswordSalt%TYPE
    );
    PROCEDURE DeleteAdmin(p_AdminID IN NUMBER);
END ADMIN_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 2. CATEGORY_PACKAGE Specification
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE CATEGORY_PACKAGE AS
    PROCEDURE GetAllCategories(p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetCategoryById(p_CategoryID IN NUMBER, p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE CreateCategory(
        p_CategoryName IN CATEGORIES.CategoryName%TYPE,
        p_Description  IN CATEGORIES.Description%TYPE,
        p_CategoryID   OUT NUMBER
    );
    PROCEDURE UpdateCategory(
        p_CategoryID   IN NUMBER,
        p_CategoryName IN CATEGORIES.CategoryName%TYPE,
        p_Description  IN CATEGORIES.Description%TYPE
    );
    PROCEDURE DeleteCategory(p_CategoryID IN NUMBER);
END CATEGORY_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 3. COURSE_PACKAGE Specification
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE COURSE_PACKAGE AS
    PROCEDURE GetAllCourses(p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetCourseById(p_CourseID IN NUMBER, p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetFeaturedCourses(p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE SearchAndFilterCourses(
        p_Search       IN VARCHAR2,
        p_CategoryID   IN NUMBER,
        p_MinPrice     IN NUMBER,
        p_MaxPrice     IN NUMBER,
        p_DeliveryMode IN VARCHAR2,
        p_SortBy       IN VARCHAR2,
        p_Cursor       OUT SYS_REFCURSOR
    );
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
    );
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
    );
    PROCEDURE DeleteCourse(p_CourseID IN NUMBER);
END COURSE_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 4. TRAINER_PACKAGE Specification
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE TRAINER_PACKAGE AS
    PROCEDURE GetAllTrainers(p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetTrainerById(p_TrainerID IN NUMBER, p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE SearchAndFilterTrainers(
        p_Search         IN VARCHAR2,
        p_Specialization IN VARCHAR2,
        p_Cursor         OUT SYS_REFCURSOR
    );
    PROCEDURE GetTrainerAssignedCourses(p_TrainerID IN NUMBER, p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE CreateTrainer(
        p_FullName       IN TRAINERS.FullName%TYPE,
        p_Specialization IN TRAINERS.Specialization%TYPE,
        p_Qualifications IN TRAINERS.Qualifications%TYPE,
        p_ProfileDetails IN TRAINERS.ProfileDetails%TYPE,
        p_Email          IN TRAINERS.Email%TYPE,
        p_PhoneNumber    IN TRAINERS.PhoneNumber%TYPE,
        p_TrainerID      OUT NUMBER
    );
    PROCEDURE UpdateTrainer(
        p_TrainerID      IN NUMBER,
        p_FullName       IN TRAINERS.FullName%TYPE,
        p_Specialization IN TRAINERS.Specialization%TYPE,
        p_Qualifications IN TRAINERS.Qualifications%TYPE,
        p_ProfileDetails IN TRAINERS.ProfileDetails%TYPE,
        p_Email          IN TRAINERS.Email%TYPE,
        p_PhoneNumber    IN TRAINERS.PhoneNumber%TYPE
    );
    PROCEDURE DeleteTrainer(p_TrainerID IN NUMBER);
END TRAINER_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 5. TRAINEE_PACKAGE Specification
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE TRAINEE_PACKAGE AS
    PROCEDURE GetAllTrainees(p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetTraineeById(p_TraineeID IN NUMBER, p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetTraineeByEmail(p_Email IN VARCHAR2, p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE CreateTrainee(
        p_FullName              IN TRAINEES.FullName%TYPE,
        p_Email                 IN TRAINEES.Email%TYPE,
        p_PhoneNumber           IN TRAINEES.PhoneNumber%TYPE,
        p_EducationalBackground IN TRAINEES.EducationalBackground%TYPE,
        p_TraineeID             OUT NUMBER
    );
    PROCEDURE UpdateTrainee(
        p_TraineeID             IN NUMBER,
        p_FullName              IN TRAINEES.FullName%TYPE,
        p_Email                 IN TRAINEES.Email%TYPE,
        p_PhoneNumber           IN TRAINEES.PhoneNumber%TYPE,
        p_EducationalBackground IN TRAINEES.EducationalBackground%TYPE
    );
    PROCEDURE DeleteTrainee(p_TraineeID IN NUMBER);
END TRAINEE_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 6. COURSEOFFERING_PACKAGE Specification
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE COURSEOFFERING_PACKAGE AS
    PROCEDURE GetAllOfferings(p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetOfferingById(p_OfferingID IN NUMBER, p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetOfferingsByCourse(p_CourseID IN NUMBER, p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetUpcomingOfferings(p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE CreateOffering(
        p_CourseID        IN COURSEOFFERINGS.CourseID%TYPE,
        p_TrainerID       IN COURSEOFFERINGS.TrainerID%TYPE,
        p_StartDate       IN COURSEOFFERINGS.StartDate%TYPE,
        p_EndDate         IN COURSEOFFERINGS.EndDate%TYPE,
        p_ScheduleDetails IN COURSEOFFERINGS.ScheduleDetails%TYPE,
        p_MaxCapacity     IN COURSEOFFERINGS.MaxCapacity%TYPE,
        p_OfferingID      OUT NUMBER
    );
    PROCEDURE UpdateOffering(
        p_OfferingID      IN NUMBER,
        p_CourseID        IN COURSEOFFERINGS.CourseID%TYPE,
        p_TrainerID       IN COURSEOFFERINGS.TrainerID%TYPE,
        p_StartDate       IN COURSEOFFERINGS.StartDate%TYPE,
        p_EndDate         IN COURSEOFFERINGS.EndDate%TYPE,
        p_ScheduleDetails IN COURSEOFFERINGS.ScheduleDetails%TYPE,
        p_MaxCapacity     IN COURSEOFFERINGS.MaxCapacity%TYPE
    );
    PROCEDURE DeleteOffering(p_OfferingID IN NUMBER);
END COURSEOFFERING_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 7. REGISTRATION_PACKAGE Specification (ACID Concurrency & Seat Management)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE REGISTRATION_PACKAGE AS
    PROCEDURE GetAllRegistrations(p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetRegistrationById(p_RegistrationID IN NUMBER, p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetRegistrationsByTrainee(p_TraineeID IN NUMBER, p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetRegistrationsByEmail(p_Email IN VARCHAR2, p_Cursor OUT SYS_REFCURSOR);
    
    -- Atomic registration procedure preventing overbooking and duplicate registrations
    PROCEDURE RegisterTrainee(
        p_TraineeID      IN NUMBER,
        p_OfferingID     IN NUMBER,
        p_Status         IN VARCHAR2,
        p_RegistrationID OUT NUMBER
    );
    
    -- Safe cancellation procedure restoring seats
    PROCEDURE CancelRegistration(
        p_RegistrationID IN NUMBER,
        p_Reason         IN VARCHAR2
    );
    
    PROCEDURE UpdateRegistrationStatus(
        p_RegistrationID IN NUMBER,
        p_Status         IN VARCHAR2
    );
    
    PROCEDURE DeleteRegistration(p_RegistrationID IN NUMBER);
END REGISTRATION_PACKAGE;
/

-- ----------------------------------------------------------------------------
-- 8. REPORTING_PACKAGE Specification
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE REPORTING_PACKAGE AS
    PROCEDURE GetDashboardKPIs(p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetRegistrationsByCategoryChart(p_Cursor OUT SYS_REFCURSOR);
    PROCEDURE GetPopularCourses(p_Limit IN NUMBER, p_Cursor OUT SYS_REFCURSOR);
END REPORTING_PACKAGE;
/
