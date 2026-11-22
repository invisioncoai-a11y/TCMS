-- ============================================================================
-- SCRIPT: 03_create_views.sql
-- PURPOSE: Create reporting views and composite multi-table join views
-- SCHEMA: FINAL_APP | PDB: FINALPDB | TARGET: Oracle Database 19c
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. View: vw_CoursesWithCategory (and alias VW_COURSE_SUMMARY)
-- Purpose: Public Courses catalog and category browsing (PDF Sec 1, 3, 11)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_CoursesWithCategory AS
SELECT 
    c.CourseID,
    c.CategoryID,
    cat.CategoryName,
    c.CourseName,
    c.Description,
    c.LearningObjectives,
    c.Prerequisites,
    c.Price,
    c.Duration,
    c.DeliveryMode,
    c.IsFeatured,
    c.CreatedAt,
    c.UpdatedAt
FROM COURSES c
INNER JOIN CATEGORIES cat ON c.CategoryID = cat.CategoryID;
/

CREATE OR REPLACE VIEW VW_COURSE_SUMMARY AS
SELECT * FROM vw_CoursesWithCategory;
/

-- ----------------------------------------------------------------------------
-- 2. View: vw_CourseOfferingsDetailed (and alias VW_OFFERING_DETAILS)
-- Purpose: Detailed course schedules with trainer and seat inventory (PDF Sec 4, 8, 11)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_CourseOfferingsDetailed AS
SELECT 
    o.OfferingID,
    o.CourseID,
    c.CourseName,
    c.Price,
    c.Duration,
    c.DeliveryMode,
    c.CategoryID,
    cat.CategoryName,
    o.TrainerID,
    t.FullName AS TrainerName,
    t.Specialization AS TrainerSpecialization,
    t.Email AS TrainerEmail,
    o.StartDate,
    o.EndDate,
    o.ScheduleDetails,
    o.MaxCapacity,
    o.AvailableSeats,
    (o.MaxCapacity - o.AvailableSeats) AS EnrolledCount,
    CASE 
        WHEN o.AvailableSeats = 0 THEN 'Sold Out'
        WHEN o.AvailableSeats <= 3 THEN 'Almost Full'
        ELSE 'Available'
    END AS SeatStatus,
    CASE 
        WHEN o.StartDate > TRUNC(SYSDATE) THEN 1
        ELSE 0
    END AS IsUpcoming,
    o.CreatedAt
FROM COURSEOFFERINGS o
INNER JOIN COURSES c ON o.CourseID = c.CourseID
INNER JOIN CATEGORIES cat ON c.CategoryID = cat.CategoryID
INNER JOIN TRAINERS t ON o.TrainerID = t.TrainerID;
/

CREATE OR REPLACE VIEW VW_OFFERING_DETAILS AS
SELECT * FROM vw_CourseOfferingsDetailed;
/

-- ----------------------------------------------------------------------------
-- 3. View: vw_TraineeRegistrationsDetailed (and alias VW_REGISTRATION_DETAILS)
-- Purpose: "My Registrations" page and admin registration tracking (PDF Sec 9, 11)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_TraineeRegistrationsDetailed AS
SELECT 
    r.RegistrationID,
    r.RegistrationDate,
    r.Status,
    r.CancellationReason,
    r.CancellationDate,
    r.TraineeID,
    tr.FullName AS TraineeName,
    tr.Email AS TraineeEmail,
    tr.PhoneNumber AS TraineePhone,
    tr.EducationalBackground,
    o.OfferingID,
    c.CourseID,
    c.CourseName,
    c.Price,
    c.DeliveryMode,
    t.TrainerID,
    t.FullName AS TrainerName,
    o.StartDate,
    o.EndDate,
    o.ScheduleDetails,
    CASE 
        WHEN o.StartDate > TRUNC(SYSDATE) AND r.Status IN ('Pending', 'Confirmed') THEN 1
        ELSE 0
    END AS IsCancellable,
    r.CreatedAt
FROM REGISTRATIONS r
INNER JOIN TRAINEES tr ON r.TraineeID = tr.TraineeID
INNER JOIN COURSEOFFERINGS o ON r.OfferingID = o.OfferingID
INNER JOIN COURSES c ON o.CourseID = c.CourseID
INNER JOIN TRAINERS t ON o.TrainerID = t.TrainerID;
/

CREATE OR REPLACE VIEW VW_REGISTRATION_DETAILS AS
SELECT * FROM vw_TraineeRegistrationsDetailed;
/

-- ----------------------------------------------------------------------------
-- 4. View: vw_TrainerAssignedCourses
-- Purpose: Trainer profile details with assigned offerings (PDF Sec 5, 6)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_TrainerAssignedCourses AS
SELECT 
    t.TrainerID,
    t.FullName AS TrainerName,
    t.Specialization,
    t.Qualifications,
    t.ProfileDetails,
    t.Email AS TrainerEmail,
    t.PhoneNumber AS TrainerPhone,
    o.OfferingID,
    c.CourseID,
    c.CourseName,
    c.Duration,
    c.Price,
    c.DeliveryMode,
    o.StartDate,
    o.EndDate,
    o.ScheduleDetails,
    o.AvailableSeats,
    o.MaxCapacity
FROM TRAINERS t
LEFT JOIN COURSEOFFERINGS o ON t.TrainerID = o.TrainerID
LEFT JOIN COURSES c ON o.CourseID = c.CourseID;
/

-- ----------------------------------------------------------------------------
-- 5. View: vw_DashboardStats
-- Purpose: Executive summary KPIs for the Admin Dashboard (PDF Sec 10)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_DashboardStats AS
SELECT
    (SELECT COUNT(*) FROM COURSES) AS TotalCourses,
    (SELECT COUNT(*) FROM TRAINERS) AS TotalTrainers,
    (SELECT COUNT(*) FROM TRAINEES) AS TotalTrainees,
    (SELECT COUNT(*) FROM REGISTRATIONS WHERE Status IN ('Pending', 'Confirmed')) AS ActiveRegistrations,
    (SELECT COUNT(*) FROM REGISTRATIONS) AS TotalRegistrations,
    (SELECT COUNT(*) FROM COURSEOFFERINGS WHERE StartDate > TRUNC(SYSDATE)) AS UpcomingOfferings,
    (SELECT NVL(SUM(AvailableSeats), 0) FROM COURSEOFFERINGS WHERE StartDate > TRUNC(SYSDATE)) AS TotalAvailableSeats
FROM DUAL;
/

-- ----------------------------------------------------------------------------
-- 6. View: vw_RegistrationsByCategory
-- Purpose: Admin Dashboard chart data: registrations by course category (PDF Sec 10)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_RegistrationsByCategory AS
SELECT 
    cat.CategoryID,
    cat.CategoryName,
    COUNT(r.RegistrationID) AS RegistrationCount
FROM CATEGORIES cat
LEFT JOIN COURSES c ON cat.CategoryID = c.CategoryID
LEFT JOIN COURSEOFFERINGS o ON c.CourseID = o.CourseID
LEFT JOIN REGISTRATIONS r ON o.OfferingID = r.OfferingID AND r.Status IN ('Pending', 'Confirmed')
GROUP BY cat.CategoryID, cat.CategoryName
ORDER BY RegistrationCount DESC, cat.CategoryName ASC;
/

-- ----------------------------------------------------------------------------
-- 7. View: vw_PopularCourses
-- Purpose: Home Page popular courses ranking (PDF Sec 1)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_PopularCourses AS
SELECT 
    c.CourseID,
    c.CourseName,
    cat.CategoryName,
    c.Price,
    c.Duration,
    c.DeliveryMode,
    c.IsFeatured,
    COUNT(r.RegistrationID) AS TotalEnrollments
FROM COURSES c
INNER JOIN CATEGORIES cat ON c.CategoryID = cat.CategoryID
LEFT JOIN COURSEOFFERINGS o ON c.CourseID = o.CourseID
LEFT JOIN REGISTRATIONS r ON o.OfferingID = r.OfferingID AND r.Status IN ('Pending', 'Confirmed')
GROUP BY c.CourseID, c.CourseName, cat.CategoryName, c.Price, c.Duration, c.DeliveryMode, c.IsFeatured
ORDER BY TotalEnrollments DESC, c.CourseName ASC;
/

-- ----------------------------------------------------------------------------
-- 8. View: vw_FeaturedCourses
-- Purpose: Home Page featured courses display (PDF Sec 1)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_FeaturedCourses AS
SELECT * 
FROM vw_CoursesWithCategory 
WHERE IsFeatured = 1;
/
