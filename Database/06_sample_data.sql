-- ============================================================================
-- SCRIPT: 06_sample_data.sql
-- PURPOSE: Comprehensive, Re-runnable Seed Data
-- SCHEMA: FINAL_APP | PDB: FINALPDB | TARGET: Oracle Database 19c
-- ============================================================================

-- Clean existing data in reverse foreign-key order
DELETE FROM REGISTRATIONS;
DELETE FROM COURSEOFFERINGS;
DELETE FROM COURSES;
DELETE FROM TRAINERS;
DELETE FROM TRAINEES;
DELETE FROM CATEGORIES;
DELETE FROM ADMINS;

-- ----------------------------------------------------------------------------
-- 1. ADMINS (Initial Administrator Account Provisioning)
-- ----------------------------------------------------------------------------
-- Standard test admin accounts:
-- Username: admin     / See README.md Section H for setup
-- Username: sysadmin  / See README.md Section H for setup
INSERT INTO ADMINS (AdminID, Username, PasswordHash, PasswordSalt, Email, FullName, IsActive, CreatedAt)
VALUES (1, 'admin', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326bb5b263bc26531144aaf4f8d40d61d65ac', 's4lt_h4sh_k3y_99', 'admin@trainingcourses.com', 'System Administrator', 1, SYSTIMESTAMP);

INSERT INTO ADMINS (AdminID, Username, PasswordHash, PasswordSalt, Email, FullName, IsActive, CreatedAt)
VALUES (2, 'training_coord', 'b109f3bbbc244eb82441917ed06d618b9008dd09b3befd1b5e07394c706a8bb980b1d7785e5976ec049b46df5f1326bb5b263bc26531144aaf4f8d40d61d65ac', 's4lt_h4sh_k3y_99', 'coordinator@trainingcourses.com', 'Academic Coordinator', 1, SYSTIMESTAMP);

-- ----------------------------------------------------------------------------
-- 2. CATEGORIES
-- ----------------------------------------------------------------------------
INSERT INTO CATEGORIES (CategoryID, CategoryName, Description, CreatedAt)
VALUES (1, 'Database Systems & Architecture', 'Comprehensive database administration, performance tuning, and PL/SQL development.', SYSTIMESTAMP);

INSERT INTO CATEGORIES (CategoryID, CategoryName, Description, CreatedAt)
VALUES (2, 'Software Engineering & Web', 'Modern full-stack application development using ASP.NET Core, Angular, and cloud patterns.', SYSTIMESTAMP);

INSERT INTO CATEGORIES (CategoryID, CategoryName, Description, CreatedAt)
VALUES (3, 'Data Science & Artificial Intelligence', 'Applied machine learning, deep learning, Python data pipelines, and predictive analytics.', SYSTIMESTAMP);

INSERT INTO CATEGORIES (CategoryID, CategoryName, Description, CreatedAt)
VALUES (4, 'Cloud Computing & DevOps', 'Containerization, orchestration with Kubernetes, CI/CD pipelines, and multi-cloud solutions.', SYSTIMESTAMP);

INSERT INTO CATEGORIES (CategoryID, CategoryName, Description, CreatedAt)
VALUES (5, 'Cybersecurity & Governance', 'Enterprise security architecture, ethical hacking, compliance, and zero-trust engineering.', SYSTIMESTAMP);

-- ----------------------------------------------------------------------------
-- 3. TRAINERS
-- ----------------------------------------------------------------------------
INSERT INTO TRAINERS (TrainerID, FullName, Specialization, Qualifications, ProfileDetails, Email, PhoneNumber, CreatedAt)
VALUES (1, 'Dr. Sarah Jenkins', 'Oracle Database Architecture & High Availability', 'Ph.D. in Computer Engineering, Oracle Certified Master (OCM 19c)', '20+ years enterprise database consulting and performance optimization.', 'sarah.jenkins@trainingcourses.com', '+1-555-0101', SYSTIMESTAMP);

INSERT INTO TRAINERS (TrainerID, FullName, Specialization, Qualifications, ProfileDetails, Email, PhoneNumber, CreatedAt)
VALUES (2, 'Eng. Tariq Mansoor', 'ASP.NET Core & Distributed Cloud Systems', 'M.Sc. Software Engineering, Microsoft Certified Solutions Expert (MCSE)', 'Senior backend architect specializing in high-throughput enterprise REST APIs and microservices.', 'tariq.mansoor@trainingcourses.com', '+1-555-0102', SYSTIMESTAMP);

INSERT INTO TRAINERS (TrainerID, FullName, Specialization, Qualifications, ProfileDetails, Email, PhoneNumber, CreatedAt)
VALUES (3, 'Michael Chang', 'Angular & Modern Frontend Architectures', 'B.Sc. Computer Science, Google Developer Expert (GDE)', 'Specialist in single-page applications, reactive programming with RxJS, and enterprise design systems.', 'michael.chang@trainingcourses.com', '+1-555-0103', SYSTIMESTAMP);

INSERT INTO TRAINERS (TrainerID, FullName, Specialization, Qualifications, ProfileDetails, Email, PhoneNumber, CreatedAt)
VALUES (4, 'Elena Rostova', 'DevOps & Kubernetes Infrastructure', 'Certified Kubernetes Administrator (CKA), AWS Solutions Architect Pro', 'DevOps coach with deep expertise in cloud native automation, infrastructure-as-code, and observability.', 'elena.rostova@trainingcourses.com', '+1-555-0104', SYSTIMESTAMP);

-- ----------------------------------------------------------------------------
-- 4. COURSES
-- ----------------------------------------------------------------------------
INSERT INTO COURSES (CourseID, CategoryID, CourseName, Description, LearningObjectives, Prerequisites, Price, Duration, DeliveryMode, IsFeatured, CreatedAt)
VALUES (1, 1, 'Oracle Database 19c Administration & PL/SQL Masterclass',
        'In-depth mastery of Oracle 19c architecture, multitenant CDB/PDB configuration, storage management, backup & recovery via RMAN, and enterprise PL/SQL development.',
        'Master CDB/PDB architecture; Implement robust PL/SQL packages; Conduct performance diagnosis and tuning; Enforce ACID transaction control.',
        'Basic understanding of relational databases and SQL queries.',
        850.00, 40, 'Hybrid', 1, SYSTIMESTAMP);

INSERT INTO COURSES (CourseID, CategoryID, CourseName, Description, LearningObjectives, Prerequisites, Price, Duration, DeliveryMode, IsFeatured, CreatedAt)
VALUES (2, 2, 'ASP.NET Core 8 Web API Enterprise Development',
        'Build production-ready, secure, and scalable RESTful APIs with ASP.NET Core 8, Entity Framework Core, JWT authentication, and clean architecture patterns.',
        'Architect modular Web APIs; Implement JWT token authentication; Integrate Oracle via ODP.NET; Build clean dependency injection architectures.',
        'Solid knowledge of C# and object-oriented programming concepts.',
        750.00, 36, 'Online', 1, SYSTIMESTAMP);

INSERT INTO COURSES (CourseID, CategoryID, CourseName, Description, LearningObjectives, Prerequisites, Price, Duration, DeliveryMode, IsFeatured, CreatedAt)
VALUES (3, 2, 'Modern Angular & TypeScript Single Page Applications',
        'Comprehensive guide to Angular standalone components, RxJS reactive state management, Angular Router, HTTP interceptors, and responsive UI design.',
        'Develop rich SPAs with Angular; Manage asynchronous data streams with RxJS; Connect frontends to REST APIs with JWT auth; Implement route guards.',
        'Familiarity with HTML5, CSS3, and JavaScript basics.',
        700.00, 32, 'Online', 1, SYSTIMESTAMP);

INSERT INTO COURSES (CourseID, CategoryID, CourseName, Description, LearningObjectives, Prerequisites, Price, Duration, DeliveryMode, IsFeatured, CreatedAt)
VALUES (4, 4, 'Kubernetes & Docker Production Deployment Mastery',
        'Containerize multi-tier enterprise systems, orchestrate scalable workloads on Kubernetes clusters, configure ingress controllers, and set up GitOps pipelines.',
        'Containerize legacy and modern applications; Configure Kubernetes pods, services, and deployments; Set up persistent volumes and secrets.',
        'Linux command line fundamentals and basic networking concepts.',
        920.00, 35, 'In-Person', 0, SYSTIMESTAMP);

INSERT INTO COURSES (CourseID, CategoryID, CourseName, Description, LearningObjectives, Prerequisites, Price, Duration, DeliveryMode, IsFeatured, CreatedAt)
VALUES (5, 3, 'Applied Machine Learning & Python Data Engineering',
        'Practical data analysis, feature engineering, predictive model building using Scikit-Learn, and deployment of machine learning models via REST endpoints.',
        'Build end-to-end data pipelines in Python; Train and evaluate regression and classification models; Deploy inference services.',
        'Introductory Python programming and high-school algebra.',
        800.00, 30, 'Hybrid', 0, SYSTIMESTAMP);

-- ----------------------------------------------------------------------------
-- 5. COURSEOFFERINGS
-- ----------------------------------------------------------------------------
-- Offering 1: Oracle 19c Course - Upcoming (Starts in 10 days, 20 seats, 18 remaining after 2 regs)
INSERT INTO COURSEOFFERINGS (OfferingID, CourseID, TrainerID, StartDate, EndDate, ScheduleDetails, MaxCapacity, AvailableSeats, CreatedAt)
VALUES (1, 1, 1, TRUNC(SYSDATE) + 10, TRUNC(SYSDATE) + 25, 'Mon, Wed, Fri (18:00 - 21:00)', 20, 18, SYSTIMESTAMP);

-- Offering 2: ASP.NET Core Course - Upcoming (Starts in 14 days, 25 seats, 23 remaining after 2 regs)
INSERT INTO COURSEOFFERINGS (OfferingID, CourseID, TrainerID, StartDate, EndDate, ScheduleDetails, MaxCapacity, AvailableSeats, CreatedAt)
VALUES (2, 2, 2, TRUNC(SYSDATE) + 14, TRUNC(SYSDATE) + 30, 'Tue, Thu (18:00 - 22:00)', 25, 23, SYSTIMESTAMP);

-- Offering 3: Angular Course - Upcoming (Starts in 18 days, 25 seats, 23 remaining after 2 regs)
INSERT INTO COURSEOFFERINGS (OfferingID, CourseID, TrainerID, StartDate, EndDate, ScheduleDetails, MaxCapacity, AvailableSeats, CreatedAt)
VALUES (3, 3, 3, TRUNC(SYSDATE) + 18, TRUNC(SYSDATE) + 35, 'Mon, Wed (18:00 - 21:30)', 25, 23, SYSTIMESTAMP);

-- Offering 4: Kubernetes Course - Upcoming (Starts in 22 days, 15 seats, 14 remaining after 1 reg)
INSERT INTO COURSEOFFERINGS (OfferingID, CourseID, TrainerID, StartDate, EndDate, ScheduleDetails, MaxCapacity, AvailableSeats, CreatedAt)
VALUES (4, 4, 4, TRUNC(SYSDATE) + 22, TRUNC(SYSDATE) + 40, 'Sat, Sun (09:00 - 16:00)', 15, 14, SYSTIMESTAMP);

-- Offering 5: Machine Learning Course - Upcoming (Starts in 28 days, 20 seats, 19 remaining after 1 reg)
INSERT INTO COURSEOFFERINGS (OfferingID, CourseID, TrainerID, StartDate, EndDate, ScheduleDetails, MaxCapacity, AvailableSeats, CreatedAt)
VALUES (5, 5, 2, TRUNC(SYSDATE) + 28, TRUNC(SYSDATE) + 45, 'Tue, Thu (17:30 - 20:30)', 20, 19, SYSTIMESTAMP);

-- ----------------------------------------------------------------------------
-- 6. TRAINEES
-- ----------------------------------------------------------------------------
INSERT INTO TRAINEES (TraineeID, FullName, Email, PhoneNumber, EducationalBackground, CreatedAt)
VALUES (1, 'Alice Walker', 'alice.walker@example.com', '+1-555-1001', 'B.Sc. Information Technology, University of Washington', SYSTIMESTAMP);

INSERT INTO TRAINEES (TraineeID, FullName, Email, PhoneNumber, EducationalBackground, CreatedAt)
VALUES (2, 'Bob Martinez', 'bob.martinez@example.com', '+1-555-1002', 'B.Eng. Computer Science, University of Texas', SYSTIMESTAMP);

INSERT INTO TRAINEES (TraineeID, FullName, Email, PhoneNumber, EducationalBackground, CreatedAt)
VALUES (3, 'Carol Danvers', 'carol.danvers@example.com', '+1-555-1003', 'M.Sc. Data Analytics, Columbia University', SYSTIMESTAMP);

INSERT INTO TRAINEES (TraineeID, FullName, Email, PhoneNumber, EducationalBackground, CreatedAt)
VALUES (4, 'David Kim', 'david.kim@example.com', '+1-555-1004', 'B.Sc. Systems Engineering, Georgia Tech', SYSTIMESTAMP);

-- ----------------------------------------------------------------------------
-- 7. REGISTRATIONS (8 Seed Registrations matching AvailableSeats deductions)
-- ----------------------------------------------------------------------------
-- Alice Walker -> Offering 1 (Oracle), Offering 2 (ASP.NET)
INSERT INTO REGISTRATIONS (RegistrationID, TraineeID, OfferingID, RegistrationDate, Status, CreatedAt)
VALUES (1, 1, 1, SYSTIMESTAMP - 5, 'Confirmed', SYSTIMESTAMP);

INSERT INTO REGISTRATIONS (RegistrationID, TraineeID, OfferingID, RegistrationDate, Status, CreatedAt)
VALUES (2, 1, 2, SYSTIMESTAMP - 4, 'Confirmed', SYSTIMESTAMP);

-- Bob Martinez -> Offering 2 (ASP.NET), Offering 3 (Angular)
INSERT INTO REGISTRATIONS (RegistrationID, TraineeID, OfferingID, RegistrationDate, Status, CreatedAt)
VALUES (3, 2, 2, SYSTIMESTAMP - 4, 'Confirmed', SYSTIMESTAMP);

INSERT INTO REGISTRATIONS (RegistrationID, TraineeID, OfferingID, RegistrationDate, Status, CreatedAt)
VALUES (4, 2, 3, SYSTIMESTAMP - 3, 'Confirmed', SYSTIMESTAMP);

-- Carol Danvers -> Offering 1 (Oracle), Offering 5 (Machine Learning)
INSERT INTO REGISTRATIONS (RegistrationID, TraineeID, OfferingID, RegistrationDate, Status, CreatedAt)
VALUES (5, 3, 1, SYSTIMESTAMP - 3, 'Confirmed', SYSTIMESTAMP);

INSERT INTO REGISTRATIONS (RegistrationID, TraineeID, OfferingID, RegistrationDate, Status, CreatedAt)
VALUES (6, 3, 5, SYSTIMESTAMP - 2, 'Confirmed', SYSTIMESTAMP);

-- David Kim -> Offering 3 (Angular), Offering 4 (Kubernetes)
INSERT INTO REGISTRATIONS (RegistrationID, TraineeID, OfferingID, RegistrationDate, Status, CreatedAt)
VALUES (7, 4, 3, SYSTIMESTAMP - 2, 'Confirmed', SYSTIMESTAMP);

INSERT INTO REGISTRATIONS (RegistrationID, TraineeID, OfferingID, RegistrationDate, Status, CreatedAt)
VALUES (8, 4, 4, SYSTIMESTAMP - 1, 'Confirmed', SYSTIMESTAMP);

-- Re-align identity sequences above seed data
ALTER TABLE ADMINS MODIFY AdminID GENERATED BY DEFAULT AS IDENTITY (START WITH 100);
ALTER TABLE CATEGORIES MODIFY CategoryID GENERATED BY DEFAULT AS IDENTITY (START WITH 100);
ALTER TABLE TRAINERS MODIFY TrainerID GENERATED BY DEFAULT AS IDENTITY (START WITH 100);
ALTER TABLE COURSES MODIFY CourseID GENERATED BY DEFAULT AS IDENTITY (START WITH 100);
ALTER TABLE COURSEOFFERINGS MODIFY OfferingID GENERATED BY DEFAULT AS IDENTITY (START WITH 100);
ALTER TABLE TRAINEES MODIFY TraineeID GENERATED BY DEFAULT AS IDENTITY (START WITH 100);
ALTER TABLE REGISTRATIONS MODIFY RegistrationID GENERATED BY DEFAULT AS IDENTITY (START WITH 100);

-- Recompile schema after DDL alterations
BEGIN
    DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE);
END;
/

COMMIT;
