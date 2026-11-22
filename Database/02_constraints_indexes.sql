-- ============================================================================
-- SCRIPT: 02_constraints_indexes.sql
-- PURPOSE: Apply primary keys, foreign keys, unique, check constraints & indexes
-- SCHEMA: FINAL_APP | PDB: FINALPDB | TARGET: Oracle Database 19c
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. PRIMARY KEY CONSTRAINTS
-- ----------------------------------------------------------------------------
ALTER TABLE ADMINS 
    ADD CONSTRAINT PK_ADMINS PRIMARY KEY (AdminID);

ALTER TABLE CATEGORIES 
    ADD CONSTRAINT PK_CATEGORIES PRIMARY KEY (CategoryID);

ALTER TABLE TRAINERS 
    ADD CONSTRAINT PK_TRAINERS PRIMARY KEY (TrainerID);

ALTER TABLE COURSES 
    ADD CONSTRAINT PK_COURSES PRIMARY KEY (CourseID);

ALTER TABLE COURSEOFFERINGS 
    ADD CONSTRAINT PK_COURSEOFFERINGS PRIMARY KEY (OfferingID);

ALTER TABLE TRAINEES 
    ADD CONSTRAINT PK_TRAINEES PRIMARY KEY (TraineeID);

ALTER TABLE REGISTRATIONS 
    ADD CONSTRAINT PK_REGISTRATIONS PRIMARY KEY (RegistrationID);

-- ----------------------------------------------------------------------------
-- 2. UNIQUE CONSTRAINTS
-- ----------------------------------------------------------------------------
ALTER TABLE ADMINS 
    ADD CONSTRAINT UQ_ADMIN_USERNAME UNIQUE (Username);

ALTER TABLE ADMINS 
    ADD CONSTRAINT UQ_ADMIN_EMAIL UNIQUE (Email);

ALTER TABLE CATEGORIES 
    ADD CONSTRAINT UQ_CATEGORY_NAME UNIQUE (CategoryName);

ALTER TABLE TRAINERS 
    ADD CONSTRAINT UQ_TRAINER_EMAIL UNIQUE (Email);

ALTER TABLE TRAINEES 
    ADD CONSTRAINT UQ_TRAINEE_EMAIL UNIQUE (Email);

-- Prevent duplicate registration for the same trainee in the same course offering
ALTER TABLE REGISTRATIONS 
    ADD CONSTRAINT UQ_TRAINEE_OFFERING UNIQUE (TraineeID, OfferingID);

-- ----------------------------------------------------------------------------
-- 3. FOREIGN KEY CONSTRAINTS (Referential Integrity)
-- ----------------------------------------------------------------------------
-- Course belongs to Category (Restrict deletion of category if courses exist)
ALTER TABLE COURSES 
    ADD CONSTRAINT FK_COURSE_CATEGORY FOREIGN KEY (CategoryID) 
    REFERENCES CATEGORIES (CategoryID);

-- CourseOffering belongs to Course (Cascade delete offerings if course removed)
ALTER TABLE COURSEOFFERINGS 
    ADD CONSTRAINT FK_OFFERING_COURSE FOREIGN KEY (CourseID) 
    REFERENCES COURSES (CourseID) ON DELETE CASCADE;

-- CourseOffering assigned to Trainer (Restrict deletion of trainer with active offerings)
ALTER TABLE COURSEOFFERINGS 
    ADD CONSTRAINT FK_OFFERING_TRAINER FOREIGN KEY (TrainerID) 
    REFERENCES TRAINERS (TrainerID);

-- Registration belongs to Trainee (Restrict deletion to preserve registration audit history)
ALTER TABLE REGISTRATIONS 
    ADD CONSTRAINT FK_REG_TRAINEE FOREIGN KEY (TraineeID) 
    REFERENCES TRAINEES (TraineeID);

-- Registration belongs to CourseOffering (Cascade delete registrations if offering removed)
ALTER TABLE REGISTRATIONS 
    ADD CONSTRAINT FK_REG_OFFERING FOREIGN KEY (OfferingID) 
    REFERENCES COURSEOFFERINGS (OfferingID) ON DELETE CASCADE;

-- ----------------------------------------------------------------------------
-- 4. CHECK CONSTRAINTS (Domain & Business Rules)
-- ----------------------------------------------------------------------------
-- Valid Email formats
ALTER TABLE ADMINS 
    ADD CONSTRAINT CHK_ADMIN_EMAIL CHECK (REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'));

ALTER TABLE TRAINERS 
    ADD CONSTRAINT CHK_TRAINER_EMAIL CHECK (REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'));

ALTER TABLE TRAINEES 
    ADD CONSTRAINT CHK_TRAINEE_EMAIL CHECK (REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'));

-- Courses Rules
ALTER TABLE COURSES 
    ADD CONSTRAINT CHK_COURSE_PRICE CHECK (Price >= 0);

ALTER TABLE COURSES 
    ADD CONSTRAINT CHK_COURSE_FEATURED CHECK (IsFeatured IN (0, 1));

ALTER TABLE COURSES 
    ADD CONSTRAINT CHK_COURSE_DELIVERY CHECK (DeliveryMode IN ('In-Person', 'Online', 'Blended', 'Classroom', 'Hybrid'));

-- Course Offerings Rules
ALTER TABLE COURSEOFFERINGS 
    ADD CONSTRAINT CHK_OFFERING_DATES CHECK (EndDate >= StartDate);

ALTER TABLE COURSEOFFERINGS 
    ADD CONSTRAINT CHK_OFFERING_CAPACITY CHECK (MaxCapacity > 0);

ALTER TABLE COURSEOFFERINGS 
    ADD CONSTRAINT CHK_OFFERING_SEATS CHECK (AvailableSeats >= 0 AND AvailableSeats <= MaxCapacity);

-- Registration Status Rules
ALTER TABLE REGISTRATIONS 
    ADD CONSTRAINT CHK_REG_STATUS CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled'));

-- ----------------------------------------------------------------------------
-- 5. PERFORMANCE & SEARCH INDEXES (B-Tree)
-- ----------------------------------------------------------------------------
-- Foreign key indexing to eliminate full table scans during joins and parent locks
CREATE INDEX IDX_COURSES_CATEGORY ON COURSES (CategoryID);
CREATE INDEX IDX_COURSES_PRICE ON COURSES (Price);
CREATE INDEX IDX_COURSES_FEATURED ON COURSES (IsFeatured);
CREATE INDEX IDX_COURSES_DELIVERY ON COURSES (DeliveryMode);

CREATE INDEX IDX_OFFERINGS_COURSE ON COURSEOFFERINGS (CourseID);
CREATE INDEX IDX_OFFERINGS_TRAINER ON COURSEOFFERINGS (TrainerID);
CREATE INDEX IDX_OFFERINGS_STARTDATE ON COURSEOFFERINGS (StartDate);
CREATE INDEX IDX_OFFERINGS_DATES ON COURSEOFFERINGS (StartDate, EndDate);

CREATE INDEX IDX_REG_TRAINEE ON REGISTRATIONS (TraineeID);
CREATE INDEX IDX_REG_OFFERING ON REGISTRATIONS (OfferingID);
CREATE INDEX IDX_REG_STATUS ON REGISTRATIONS (Status);
CREATE INDEX IDX_REG_DATE ON REGISTRATIONS (RegistrationDate);

CREATE INDEX IDX_TRAINERS_SPEC ON TRAINERS (Specialization);
CREATE INDEX IDX_TRAINERS_NAME ON TRAINERS (FullName);
CREATE INDEX IDX_TRAINEES_NAME ON TRAINEES (FullName);
