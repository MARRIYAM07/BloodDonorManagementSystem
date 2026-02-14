USE master;
GO

-- Delete old DB if exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'bloodBankSystem')
BEGIN
    ALTER DATABASE bloodBankSystem SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE bloodBankSystem;
    PRINT ' Existing bloodBankSystem database deleted successfully!';
END
ELSE
BEGIN
    PRINT ' bloodBankSystem database does not exist. Creating new one...';
END
GO

-- Create new database
CREATE DATABASE bloodBankSystem;
PRINT ' Database bloodBankSystem created successfully!';
GO

USE bloodBankSystem;
GO


-- 1. Lookup Tables
CREATE TABLE GenderType (
    genderID INT IDENTITY(1,1) PRIMARY KEY,
    genderName VARCHAR(10) NOT NULL UNIQUE
);
INSERT INTO GenderType VALUES ('Male'), ('Female'), ('Other');

CREATE TABLE BloodGroupType (
    bgTypeID INT IDENTITY(1,1) PRIMARY KEY,
    bgTypeName VARCHAR(10) NOT NULL UNIQUE
);
INSERT INTO BloodGroupType VALUES ('A'), ('B'), ('AB'), ('O');

CREATE TABLE BloodGroup (
    bgID INT IDENTITY(1,1) PRIMARY KEY,
    groupName VARCHAR(3) NOT NULL UNIQUE,
    bgTypeID INT NOT NULL,
    FOREIGN KEY (bgTypeID) REFERENCES BloodGroupType(bgTypeID)
);
INSERT INTO BloodGroup (groupName, bgTypeID) VALUES
('A+', 1), ('A-', 1),
('B+', 2), ('B-', 2),
('AB+', 3), ('AB-', 3),
('O+', 4), ('O-', 4);

CREATE TABLE Donor (
    donorID INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dateOfBirth DATE NOT NULL,
    genderID INT NOT NULL,
    bgID INT NOT NULL,
    contactNo VARCHAR(50) NOT NULL,
    donorEmail VARCHAR(50),
    address VARCHAR(100),
    lastDonationDate DATE
);

CREATE TABLE DonationType (
    donationTypeID INT IDENTITY(1,1) PRIMARY KEY,
    donationTypeName VARCHAR(40) UNIQUE NOT NULL
);
INSERT INTO DonationType VALUES
('Whole Blood'),
('Plasma'),
('Platelets'),
('Red Cells'),
('Double Red');


-- 2. Main Tables
CREATE TABLE BloodBankCenter (
    centerID INT IDENTITY(1,1) PRIMARY KEY,
    bloodCenterName VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    bloodBankCenterAddress VARCHAR(100) NOT NULL,
    contactNumber VARCHAR(20) NOT NULL,
    emailAddress VARCHAR(50) NOT NULL
);

CREATE TABLE DonorHealthScreening (
    screeningID INT IDENTITY(1,1) PRIMARY KEY,
    donorID INT NOT NULL,
    screeningDate DATE NOT NULL DEFAULT GETDATE(),
    weightKG DECIMAL(5,2),
    hemoglobinLevel DECIMAL(4,1),
    bloodPressureUp INT,
    bloodPressureDown INT,
    temperature DECIMAL(4,1),
    test_HIV BIT DEFAULT 0,
    test_AIDS BIT DEFAULT 0,
    test_HepatitisB BIT DEFAULT 0,
    test_HepatitisC BIT DEFAULT 0,
    test_Syphilis BIT DEFAULT 0,
    test_Malaria BIT DEFAULT 0,
    passed BIT NOT NULL DEFAULT 0,
    reasonIfFailed VARCHAR(200),
    FOREIGN KEY (donorID) REFERENCES Donor(donorID)
);

CREATE TABLE Staff (
    staffID INT IDENTITY(1,1) PRIMARY KEY,
    centerID INT NOT NULL,
    staffName VARCHAR(50) NOT NULL,
    staffRole VARCHAR(30) NOT NULL,
    staffContactNumber VARCHAR(30) NOT NULL,
    staffEmailAddress VARCHAR(50),
    FOREIGN KEY (centerID) REFERENCES BloodBankCenter(centerID)
);

CREATE TABLE Donation (
    donationID INT IDENTITY(1,1) PRIMARY KEY,
    donorID INT NOT NULL,
    screeningID INT NOT NULL,
    donationTypeID INT NOT NULL,
    donationDate DATE NOT NULL DEFAULT GETDATE(),
    amountINml DECIMAL(10,2) NOT NULL,
    collectedByStaffID INT NOT NULL,
    FOREIGN KEY (donorID) REFERENCES Donor(donorID),
    FOREIGN KEY (screeningID) REFERENCES DonorHealthScreening(screeningID),
    FOREIGN KEY (donationTypeID) REFERENCES DonationType(donationTypeID),
    FOREIGN KEY (collectedByStaffID) REFERENCES Staff(staffID)
);

ALTER TABLE Donation
ALTER COLUMN screeningID INT NULL;

CREATE TRIGGER trg_UpdateLastDonation
ON Donation
AFTER INSERT
AS
BEGIN
    UPDATE Donor
    SET lastDonationDate = i.donationDate
    FROM Donor d
    JOIN inserted i ON d.donorID = i.donorID;
END;
GO

CREATE TABLE BloodUnit (
    bloodUnitID INT IDENTITY(1,1) PRIMARY KEY,
    donationID INT NOT NULL,
    bgID INT NOT NULL,
    centerID INT NOT NULL,
    storageDate DATE DEFAULT GETDATE(),
    expiryDate DATE NOT NULL,
    latestResult VARCHAR(50) DEFAULT 'Pending',
    status VARCHAR(20) CHECK(status IN ('stored','used','rejected','expired')) NOT NULL DEFAULT 'stored',
    FOREIGN KEY (donationID) REFERENCES Donation(donationID),
    FOREIGN KEY (bgID) REFERENCES BloodGroup(bgID),
    FOREIGN KEY (centerID) REFERENCES BloodBankCenter(centerID)
);

CREATE TABLE Hospital (
    hospitalID INT IDENTITY(1,1) PRIMARY KEY,
    hospitalName VARCHAR(50) NOT NULL,
    hospitalAddress VARCHAR(100) NOT NULL,
    city VARCHAR(30) NOT NULL,
    contactNumber VARCHAR(30),
    emailAddress VARCHAR(50)
);

CREATE TABLE Doctor (
    doctorID INT IDENTITY(1,1) PRIMARY KEY,
    hospitalID INT,
    doctorName VARCHAR(50) NOT NULL,
    specialization VARCHAR(50),
    contactNumber VARCHAR(20) NOT NULL,
    emailAddress VARCHAR(50),
    FOREIGN KEY (hospitalID) REFERENCES Hospital(hospitalID)
);

CREATE TABLE Patient (
    patientID INT IDENTITY(1,1) PRIMARY KEY,
    doctorID INT,
    patientName VARCHAR(50) NOT NULL,
    dateOfBirth DATE NOT NULL,
    genderID INT,
    disease VARCHAR(70) NOT NULL,
    bgID_Required INT NOT NULL,
    bloodAmountRequiredML INT,
    FOREIGN KEY (doctorID) REFERENCES Doctor(doctorID),
    FOREIGN KEY (genderID) REFERENCES GenderType(genderID),
    FOREIGN KEY (bgID_Required) REFERENCES BloodGroup(bgID)
);

CREATE TABLE BloodRequest (
    bloodRequestID INT IDENTITY(1,1) PRIMARY KEY,
    hospitalID INT,
    doctorID INT,
    patientID INT,
    bgID_Requested INT NOT NULL,
    requiredUnits INT NOT NULL,
    urgency VARCHAR(10) CHECK(urgency IN ('Low','Medium','High')) NOT NULL,
    requestDate DATE DEFAULT GETDATE(),
    requestStatus VARCHAR(20) CHECK(requestStatus IN ('pending','delivered','rejected','partial')) DEFAULT 'pending',
    FOREIGN KEY (hospitalID) REFERENCES Hospital(hospitalID),
    FOREIGN KEY (doctorID) REFERENCES Doctor(doctorID),
    FOREIGN KEY (patientID) REFERENCES Patient(patientID),
    FOREIGN KEY (bgID_Requested) REFERENCES BloodGroup(bgID)
);

CREATE TABLE DeliveryRecord (
    deliveryID INT IDENTITY(1,1) PRIMARY KEY,
    bloodRequestID INT,
    bloodUnitID INT,
    deliveryDate DATE DEFAULT GETDATE(),
    deliveredByStaffID INT,
    bloodCondition VARCHAR(30) CHECK(bloodCondition IN ('normal','cold chain maintained')),
    FOREIGN KEY (bloodRequestID) REFERENCES BloodRequest(bloodRequestID),
    FOREIGN KEY (bloodUnitID) REFERENCES BloodUnit(bloodUnitID),
    FOREIGN KEY (deliveredByStaffID) REFERENCES Staff(staffID)
);

-- 1. Donors
INSERT INTO Donor (name, dateOfBirth, genderID, bgID, contactNo, donorEmail, address, lastDonationDate) VALUES
('Ali Raza', '1990-05-12', 1, 1, '0301-2221111', 'ali@gmail.com', 'Lahore', '2024-05-01'),
('Sara Khan', '1994-09-22', 2, 3, '0301-2221112', 'sara@gmail.com', 'Karachi', '2024-05-03'),
('Ahmed Malik', '1988-01-15', 1, 5, '0301-2221113', 'ahmed@gmail.com', 'Islamabad', '2024-03-20'),
('Danish Ali', '1991-03-18', 1, 8, '0301-2221115', 'danish@gmail.com', 'Lahore', '2024-06-05'),
('Iqra Shah', '1997-12-05', 2, 2, '0301-2221116', 'iqra@gmail.com', 'Faisalabad', '2024-05-08'),
('Bilal Ahmad', '1989-04-23', 1, 7, '0301-2221117', 'bilal@gmail.com', 'Multan', '2024-02-14'),
('Hira Rehman', '1995-02-11', 2, 6, '0301-2221118', 'hira@gmail.com', 'Karachi', '2024-05-10'),
('Usman Tariq', '1992-11-27', 1, 3, '0301-2221119', 'usman@gmail.com', 'Lahore', '2024-04-08'),
('Mehwish Khan', '1998-08-29', 2, 1, '0301-2221120', 'mehwish@gmail.com', 'Islamabad', '2024-05-12'),
('Zoya Iqbal', '1996-09-15', 2, 4, '0301-2221121', 'zoya@gmail.com', 'Karachi', '2024-06-01');

-- 2. Donor Health Screening
INSERT INTO DonorHealthScreening 
(donorID, screeningDate, weightKG, hemoglobinLevel, bloodPressureUp, bloodPressureDown, temperature, 
 test_HIV, test_AIDS, test_HepatitisB, test_HepatitisC, test_Syphilis, test_Malaria, passed, reasonIfFailed)
VALUES
(1,'2024-05-01',72,13.5,120,80,36.5,0,0,0,0,0,0,1,NULL),
(2,'2024-05-03',60,12.2,110,75,36.6,0,0,0,0,0,0,1,NULL),
(3,'2024-03-20',75,14.0,118,78,36.7,0,0,0,0,0,0,1,NULL),
(4,'2024-06-05',80,14.5,122,82,36.5,0,0,0,0,0,0,1,NULL),
(5,'2024-05-08',58,11.8,110,72,37.2,0,0,0,0,0,0,1,NULL),
(6,'2024-02-14',70,13.2,125,85,36.4,0,0,0,0,0,0,1,NULL),
(7,'2024-05-10',62,12.5,115,75,36.8,0,0,0,0,0,0,1,NULL),
(8,'2024-04-08',78,13.8,120,80,36.6,0,0,0,0,0,0,1,NULL),
(9,'2024-05-12',65,12.0,110,70,37.1,0,0,0,0,0,0,1,NULL),
(10,'2024-06-01',68,12.8,118,76,36.9,0,0,0,0,0,0,1,NULL);

INSERT INTO BloodBankCenter (bloodCenterName, city, bloodBankCenterAddress, contactNumber, emailAddress) VALUES
('Central Blood Bank', 'Lahore', 'Main Blvd Gulberg', '0300-1111111', 'central@gmail.com'),
('City Blood Center', 'Karachi', 'Shahrah-e-Faisal', '0300-1111112', 'cityblood@gmail.com'),
('Hope Blood Bank', 'Islamabad', 'F-8 Markaz', '0300-1111113', 'hope@gmail.com'),
('LifeSaver Blood Bank', 'Lahore', 'Ichra', '0300-1111114', 'lifesaver@gmail.com'),
('RedLine Blood Bank', 'Rawalpindi', 'Saddar', '0300-1111115', 'redline@gmail.com'),
('Universal Blood Center', 'Karachi', 'North Nazimabad', '0300-1111116', 'universal@gmail.com'),
('National Blood Center', 'Islamabad', 'Blue Area', '0300-1111117', 'national@gmail.com'),
('Care Blood Bank', 'Multan', 'Cantt Area', '0300-1111118', 'care@gmail.com'),
('Prime Blood Bank', 'Faisalabad', 'D Ground', '0300-1111119', 'prime@gmail.com'),
('Trust Blood Bank', 'Lahore', 'Johar Town', '0300-1111120', 'trust@gmail.com');

-- 4. Staff
INSERT INTO Staff (centerID, staffName, staffRole, staffContactNumber, staffEmailAddress) VALUES
(1,'Hamza Ali','Technician','0311-5550001','hamza@center.com'),
(2,'Sohail Khan','Nurse','0311-5550002','sohail@center.com'),
(3,'Zain Shah','Lab Assistant','0311-5550003','zain@center.com'),
(4,'Bushra Tariq','Technician','0311-5550004','bushra@center.com'),
(5,'Rashid Mehmood','Supervisor','0311-5550005','rashid@center.com'),
(6,'Farah Iqbal','Nurse','0311-5550006','farah@center.com'),
(7,'Arif Malik','Technician','0311-5550007','arif@center.com'),
(8,'Nimra Asif','Technician','0311-5550008','nimra@center.com'),
(9,'Imran Qureshi','Technician','0311-5550009','imran@center.com'),
(10,'Sara Malik','Lab Assistant','0311-5550010','sara@center.com');
select * from staff;

-- 4. Donations
INSERT INTO Donation (donorID, screeningID, donationTypeID, donationDate, amountINml, collectedByStaffID) VALUES
(1,1,1,'2024-05-01',450,11),
(2,2,1,'2024-05-03',420,12),
(3,3,1,'2024-03-20',460,3),
(4,4,1,'2024-06-05',450,4),
(5,5,1,'2024-05-08',430,5),
(6,6,1,'2024-02-14',460,6),
(7,7,3,'2024-05-10',250,7),
(8,8,1,'2024-04-08',450,8),
(9,9,1,'2024-05-12',440,9),
(10,10,2,'2024-06-01',300,10);
select * from donation;


-- 5. Blood Units
INSERT INTO BloodUnit (donationID, bgID, centerID, storageDate, expiryDate, latestResult, status) VALUES
(12,1,1,'2024-05-01','2024-08-01','Clear','stored'),
(11,3,2,'2024-05-03','2024-08-03','Clear','stored'),
(3,5,3,'2024-03-20','2024-06-20','Clear','used'),
(4,8,4,'2024-06-05','2024-09-05','Clear','stored'),
(5,2,5,'2024-05-08','2024-08-08','Clear','stored'),
(6,7,6,'2024-02-14','2024-05-14','Expired','expired'),
(7,6,7,'2024-05-10','2024-08-10','Clear','stored'),
(8,3,8,'2024-04-08','2024-07-08','Clear','stored'),
(9,1,9,'2024-05-12','2024-08-12','Clear','stored'),
(10,4,10,'2024-06-01','2024-09-01','Clear','stored');
select * from BloodUnit;


-- 6. Hospitals
INSERT INTO Hospital (hospitalName, hospitalAddress, city, contactNumber, emailAddress) VALUES
('General Hospital','F-7 Islamabad','Islamabad','042-1111001','gh@gmail.com'),
('City Hospital','Gulshan Karachi','Karachi','042-1111002','cityhospital@gmail.com'),
('Shifa Medical Center','Blue Area','Islamabad','042-1111003','shifa@gmail.com'),
('Al Noor Hospital','Johar Town','Lahore','042-1111004','alnoor@gmail.com'),
('National Hospital','Garden Town','Lahore','042-1111005','nationalhospital@gmail.com'),
('Medicare Hospital','Saddar','Rawalpindi','042-1111006','medicare@gmail.com'),
('Allied Hospital','Peoples Colony','Faisalabad','042-1111007','allied@gmail.com'),
('Shalimar Hospital','GT Road','Lahore','042-1111008','shalimar@gmail.com'),
('City Care Hospital','Cantt','Multan','042-1111009','citycare@gmail.com'),
('Prime Medical','North Nazimabad','Karachi','042-1111010','prime@gmail.com');
select * from Hospital;


-- 7. Doctors
INSERT INTO Doctor (hospitalID, doctorName, specialization, contactNumber, emailAddress) VALUES
(1,'Dr. Hamid','Cardiology','0333-1000001','hamid@hospital.com'),
(2,'Dr. Sana','Hematology','0333-1000002','sana@hospital.com'),
(3,'Dr. Asad','Surgery','0333-1000003','asad@hospital.com'),
(4,'Dr. Zainab','Oncology','0333-1000004','zainab@hospital.com'),
(5,'Dr. Fahad','Orthopedic','0333-1000005','fahad@hospital.com'),
(6,'Dr. Areeba','General Physician','0333-1000006','areeba@hospital.com'),
(7,'Dr. Usama','Cardiology','0333-1000007','usama@hospital.com'),
(8,'Dr. Nadia','Hematology','0333-1000008','nadia@hospital.com'),
(9,'Dr. Hammad','Surgery','0333-1000009','hammad@hospital.com'),
(10,'Dr. Rabia','Oncology','0333-1000010','rabia@hospital.com');



-- 8. Patients
INSERT INTO Patient (doctorID, patientName, dateOfBirth, genderID, disease, bgID_Required, bloodAmountRequiredML) VALUES
(1,'Imran Ali','1985-06-12',1,'Heart Surgery',1,500),
(2,'Sadia Noor','1990-09-20',2,'Dengue',3,450),
(3,'Kashif Raza','1978-12-01',1,'Accident Trauma',5,800),
(4,'Talha Ahmad','1989-04-15',1,'Fracture Surgery',8,300),
(5,'Fatima Saif','2000-10-11',2,'Anemia',2,400),
(6,'Junaid Malik','1983-01-05',1,'Cardiac Arrest',7,500),
(7,'Hira Aslam','1998-08-08',2,'Dengue',6,450),
(8,'Naveed Shah','1979-11-29',1,'Surgery',3,700),
(9,'Ayesha Khan','1995-05-05',2,'Plasma Therapy',4,350),
(10,'Bilal Riaz','1992-03-12',1,'Blood Loss',1,600);


-- 9. Blood Requests
INSERT INTO BloodRequest (hospitalID, doctorID, patientID, bgID_Requested, requiredUnits, urgency, requestDate, requestStatus) VALUES
(1,1,1,1,2,'High','2024-05-01','pending'),
(2,2,2,3,1,'Medium','2024-05-03','delivered'),
(3,3,3,5,3,'High','2024-03-20','pending'),
(4,4,4,8,1,'High','2024-06-05','pending'),
(5,5,5,2,2,'Medium','2024-05-08','delivered'),
(6,6,6,7,3,'High','2024-02-14','pending'),
(7,7,7,6,1,'Low','2024-05-10','pending'),
(8,8,8,3,2,'Medium','2024-04-08','delivered'),
(9,9,9,4,2,'High','2024-06-01','pending'),
(10,10,10,1,3,'High','2024-06-01','pending');
select * from BloodRequest;



-- 10. Delivery Records
INSERT INTO DeliveryRecord (bloodRequestID, bloodUnitID, deliveryDate, deliveredByStaffID, bloodCondition) VALUES
(1,12,'2024-05-01',11,'normal'),
(2,11,'2024-05-03',12,'cold chain maintained'),
(3,3,'2024-03-20',3,'normal'),
(4,4,'2024-06-05',4,'cold chain maintained'),
(5,5,'2024-05-08',5,'normal'),
(6,6,'2024-02-14',6,'normal'),
(7,7,'2024-05-10',7,'cold chain maintained'),
(8,8,'2024-04-08',8,'normal'),
(9,9,'2024-06-01',9,'cold chain maintained'),
(10,10,'2024-06-01',10,'normal');




-- 4. VIEWS
PRINT ' Creating views...';
GO

IF OBJECT_ID('v_LiveInventory', 'V') IS NOT NULL
    DROP VIEW v_LiveInventory;
GO

CREATE VIEW v_LiveInventory AS
SELECT 
    c.bloodCenterName,
    bg.groupName AS BloodGroup,
    COUNT(bu.bloodUnitID) AS TotalUnits
FROM BloodUnit bu
JOIN BloodGroup bg ON bu.bgID = bg.bgID
JOIN BloodBankCenter c ON bu.centerID = c.centerID
WHERE bu.status = 'stored'
GROUP BY c.bloodCenterName, bg.groupName;
GO

PRINT ' v_LiveInventory view created!';
GO

CREATE VIEW v_DonorDonationHistory AS
SELECT 
    d.donorID,
    d.name,
    don.donationDate,
    don.amountINml,
    dt.donationTypeName,
    s.staffName AS collectedBy
FROM Donation don
JOIN Donor d ON don.donorID = d.donorID
JOIN DonationType dt ON don.donationTypeID = dt.donationTypeID
JOIN Staff s ON don.collectedByStaffID = s.staffID;
GO


-- 5. LOGIN SYSTEM TABLES AND PROCEDURES
PRINT '🔐 Setting up login system...';
GO

--  Users Table for Staff, Doctors, and Admins
CREATE TABLE UserLogin (
    userID INT IDENTITY(1,1) PRIMARY KEY,
    staffID INT NULL,          -- Agar staff hai to yahan hoga
    doctorID INT NULL,         -- Agar doctor hai to yahan hoga
    username VARCHAR(50) NOT NULL UNIQUE, -- Email ya custom username
    passwordHash VARCHAR(255) NOT NULL,   -- Hashed password
    userRole VARCHAR(20) NOT NULL CHECK (userRole IN ('staff', 'doctor', 'admin')),
    isActive BIT NOT NULL DEFAULT 1,
    createdAt DATETIME DEFAULT GETDATE(),
    lastLogin DATETIME NULL,
    FOREIGN KEY (staffID) REFERENCES Staff(staffID) ON DELETE CASCADE,
    FOREIGN KEY (doctorID) REFERENCES Doctor(doctorID) ON DELETE CASCADE
);
PRINT '✅ UserLogin table created!';
GO

-- Stored Procedure: Verify Login
CREATE PROCEDURE sp_VerifyLogin
    @username VARCHAR(50),
    @password VARCHAR(50),
    @isValid BIT OUTPUT,
    @userRole VARCHAR(20) OUTPUT,
    @userID INT OUTPUT,
    @linkedID INT OUTPUT
AS
BEGIN
    SET @isValid = 0
    SET @userRole = NULL
    SET @userID = NULL
    SET @linkedID = NULL

    DECLARE @storedHash VARCHAR(255)

    SELECT @storedHash = passwordHash, 
           @userRole = userRole, 
           @userID = userID,
           @linkedID = COALESCE(staffID, doctorID)
    FROM UserLogin
    WHERE username = @username AND isActive = 1

    IF @storedHash IS NOT NULL 
        AND @storedHash = CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', @password))
    BEGIN
        SET @isValid = 1
        -- Update last login
        UPDATE UserLogin SET lastLogin = GETDATE() WHERE username = @username
    END
END
GO
PRINT '✅ sp_VerifyLogin procedure created!';
GO

--  Stored Procedure: Generate Password and Create User
CREATE PROCEDURE sp_CreateUserWithPassword
    @staffID INT = NULL,
    @doctorID INT = NULL,
    @userRole VARCHAR(20),
    @generatedPassword VARCHAR(12) OUTPUT
AS
BEGIN
    DECLARE @username VARCHAR(50)
    DECLARE @email VARCHAR(50)
    DECLARE @password VARCHAR(12)

    -- Generate random password (8 chars + 4 numbers)
    SET @password = LEFT(NEWID(), 8) + CAST(ABS(CHECKSUM(NEWID())) % 10000 AS VARCHAR(4))
    SET @generatedPassword = @password

    -- Find email based on role
    IF @userRole = 'staff' AND @staffID IS NOT NULL
    BEGIN
        SELECT @email = staffEmailAddress FROM Staff WHERE staffID = @staffID
        SET @username = @email
    END
    ELSE IF @userRole = 'doctor' AND @doctorID IS NOT NULL
    BEGIN
        SELECT @email = emailAddress FROM Doctor WHERE doctorID = @doctorID
        SET @username = @email
    END
    ELSE IF @userRole = 'admin'
    BEGIN
        SET @username = 'superadmin@bloodbank.org'
        SET @email = @username
    END

    -- Insert into UserLogin with hashed password
    INSERT INTO UserLogin (staffID, doctorID, username, passwordHash, userRole, isActive)
    VALUES (
        @staffID,
        @doctorID,
        @username,
        CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', @password)),
        @userRole,
        1
    )
END
GO
PRINT '✅ sp_CreateUserWithPassword procedure created!';
GO

--  Function: Check if user exists for a staff/doctor
CREATE FUNCTION fn_UserExistsForStaffOrDoctor
(
    @staffID INT,
    @doctorID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @exists BIT = 0
    IF EXISTS (SELECT 1 FROM UserLogin WHERE staffID = @staffID OR doctorID = @doctorID)
        SET @exists = 1
    RETURN @exists
END
GO
PRINT '✅ fn_UserExistsForStaffOrDoctor function created!';
GO


-- 6. CREATE LOGIN ACCOUNTS FOR ALL USERS
PRINT '👥 Creating user accounts...';
GO

DECLARE @adminPass VARCHAR(12)
EXEC sp_CreateUserWithPassword 
    @userRole = 'admin',
    @generatedPassword = @adminPass OUTPUT

UPDATE UserLogin SET passwordHash = CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', 'Admin@123')) 
WHERE username = 'superadmin@bloodbank.org'
PRINT '✅ Admin account: superadmin@bloodbank.org / Admin@123';
GO

-- Create accounts for all staff
DECLARE @staffCursor CURSOR, @sID INT, @sName VARCHAR(100), @sEmail VARCHAR(100), @sPassword VARCHAR(12)
SET @staffCursor = CURSOR FOR 
    SELECT staffID, staffName, staffEmailAddress 
    FROM Staff 
    WHERE staffEmailAddress IS NOT NULL AND staffEmailAddress != ''

OPEN @staffCursor
FETCH NEXT FROM @staffCursor INTO @sID, @sName, @sEmail
WHILE @@FETCH_STATUS = 0
BEGIN
    IF dbo.fn_UserExistsForStaffOrDoctor(@sID, NULL) = 0
    BEGIN
        EXEC sp_CreateUserWithPassword 
            @staffID = @sID,
            @userRole = 'staff',
            @generatedPassword = @sPassword OUTPUT
        
        PRINT '   ✅ Staff: ' + @sName + ' | Username: ' + @sEmail + ' | Password: ' + @sPassword
    END
    FETCH NEXT FROM @staffCursor INTO @sID, @sName, @sEmail
END
CLOSE @staffCursor
DEALLOCATE @staffCursor
GO

-- Create accounts for all doctors
DECLARE @doctorCursor CURSOR, @dID INT, @dName VARCHAR(100), @dEmail VARCHAR(100), @dPassword VARCHAR(12)
SET @doctorCursor = CURSOR FOR 
    SELECT doctorID, doctorName, emailAddress 
    FROM Doctor 
    WHERE emailAddress IS NOT NULL AND emailAddress != ''

OPEN @doctorCursor
FETCH NEXT FROM @doctorCursor INTO @dID, @dName, @dEmail
WHILE @@FETCH_STATUS = 0
BEGIN
    IF dbo.fn_UserExistsForStaffOrDoctor(NULL, @dID) = 0
    BEGIN
        EXEC sp_CreateUserWithPassword 
            @doctorID = @dID,
            @userRole = 'doctor',
            @generatedPassword = @dPassword OUTPUT
        
        PRINT '   ✅ Doctor: ' + @dName + ' | Username: ' + @dEmail + ' | Password: ' + @dPassword
    END
    FETCH NEXT FROM @doctorCursor INTO @dID, @dName, @dEmail
END
CLOSE @doctorCursor
DEALLOCATE @doctorCursor
GO


-- 7. ADDITIONAL HELPER PROCEDURES AND VIEWS

PRINT '🔧 Creating helper procedures and views...';
GO

-- Stored Procedure: Reset Password
CREATE PROCEDURE sp_ResetPassword
    @username VARCHAR(50),
    @newPassword VARCHAR(12) OUTPUT
AS
BEGIN
    SET @newPassword = LEFT(NEWID(), 8) + CAST(ABS(CHECKSUM(NEWID())) % 10000 AS VARCHAR(4))
    
    UPDATE UserLogin 
    SET passwordHash = CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', @newPassword)),
        lastLogin = NULL
    WHERE username = @username
END
GO
PRINT '✅ sp_ResetPassword procedure created!';
GO

-- View: Active Users
CREATE VIEW v_ActiveUsers AS
SELECT 
    u.userID,
    u.username,
    u.userRole,
    u.createdAt,
    u.lastLogin,
    CASE 
        WHEN u.userRole = 'staff' THEN s.staffName
        WHEN u.userRole = 'doctor' THEN d.doctorName
        WHEN u.userRole = 'admin' THEN 'System Administrator'
        ELSE 'Unknown'
    END AS FullName,
    CASE 
        WHEN u.userRole = 'staff' THEN s.staffRole
        WHEN u.userRole = 'doctor' THEN d.specialization
        ELSE 'System Admin'
    END AS RoleTitle,
    CASE u.isActive 
        WHEN 1 THEN 'Active' 
        ELSE 'Inactive' 
    END AS Status
FROM UserLogin u
LEFT JOIN Staff s ON u.staffID = s.staffID
LEFT JOIN Doctor d ON u.doctorID = d.doctorID
WHERE u.isActive = 1
GO
PRINT '✅ v_ActiveUsers view created!';
GO

-----------------------------------------------------------
-- 8. VERIFICATION QUERIES

PRINT ''
PRINT '✅ DATABASE CREATION COMPLETED SUCCESSFULLY!'
PRINT '============================================='
PRINT '📊 Database Summary:'
PRINT '---------------------------------------------'
GO

-- Separate batch for verification
DECLARE @tableCount INT, @userCount INT, @staffCount INT, @doctorCount INT, @donorCount INT, @patientCount INT

SELECT @tableCount = COUNT(*) FROM sys.tables WHERE type = 'U'
SELECT @userCount = COUNT(*) FROM UserLogin
SELECT @staffCount = COUNT(*) FROM Staff
SELECT @doctorCount = COUNT(*) FROM Doctor
SELECT @donorCount = COUNT(*) FROM Donor
SELECT @patientCount = COUNT(*) FROM Patient

PRINT '   Total Tables Created: ' + CAST(@tableCount AS VARCHAR(10))
PRINT '   Total Users Created: ' + CAST(@userCount AS VARCHAR(10))
PRINT '   Staff Members: ' + CAST(@staffCount AS VARCHAR(10))
PRINT '   Doctors: ' + CAST(@doctorCount AS VARCHAR(10))
PRINT '   Donors: ' + CAST(@donorCount AS VARCHAR(10))
PRINT '   Patients: ' + CAST(@patientCount AS VARCHAR(10))

PRINT ''
PRINT '🔑 LOGIN CREDENTIALS:'
PRINT '---------------------------------------------'
PRINT '   Admin: superadmin@bloodbank.org / Admin@123'
PRINT '   Staff: Use their email addresses as username'
PRINT '   Doctors: Use their email addresses as username'
PRINT '   (Passwords were generated and shown above)'

PRINT ''
PRINT '🌐 TEST LOGINS:'
PRINT '---------------------------------------------'
PRINT '   1. Username: superadmin@bloodbank.org | Role: admin | Name: Admin'
PRINT '   2. Username: hamza@center.com | Role: staff | Name: Hamza Ali'
PRINT '   3. Username: hamid@hospital.com | Role: doctor | Name: Dr. Hamid'

PRINT ''
PRINT '🚀 Database is ready for use!'
PRINT '============================================='
GO

-- Test the login system
PRINT ''
PRINT '🧪 Testing login system...'
GO

DECLARE @testUser1 VARCHAR(50) = 'superadmin@bloodbank.org'
DECLARE @testPass1 VARCHAR(50) = 'Admin@123'
DECLARE @isValid1 BIT, @userRole1 VARCHAR(20), @userID1 INT, @linkedID1 INT

EXEC sp_VerifyLogin @testUser1, @testPass1, 
     @isValid1 OUTPUT, @userRole1 OUTPUT, @userID1 OUTPUT, @linkedID1 OUTPUT

IF @isValid1 = 1
    PRINT '✅ Login test successful for admin!'
ELSE
    PRINT '❌ Login test failed for admin!'
GO

-- Show all users
PRINT ''
PRINT '📋 All User Accounts:'
PRINT '---------------------------------------------'

SELECT 
    ROW_NUMBER() OVER (ORDER BY userRole, username) AS 'No.',
    username AS 'Username',
    userRole AS 'Role',
    CASE isActive 
        WHEN 1 THEN '✅ Active' 
        ELSE '❌ Inactive' 
    END AS 'Status',
    COALESCE(s.staffName, d.doctorName, 'Administrator') AS 'Full Name',
    CONVERT(VARCHAR, createdAt, 103) AS 'Created Date'
FROM UserLogin u
LEFT JOIN Staff s ON u.staffID = s.staffID
LEFT JOIN Doctor d ON u.doctorID = d.doctorID
ORDER BY u.userRole, u.username
GO



USE bloodBankSystem;
GO

-- View all users with their information
SELECT 
    u.userID,
    u.username,
    u.userRole,
    CASE u.isActive 
        WHEN 1 THEN '✅ Active' 
        ELSE '❌ Inactive' 
    END AS Status,
    COALESCE(s.staffName, d.doctorName, 'Administrator') AS RealName,
    COALESCE(s.staffRole, d.specialization, 'System Admin') AS RoleTitle,
    CONVERT(VARCHAR, u.createdAt, 103) AS CreatedDate,
    CASE 
        WHEN u.lastLogin IS NULL THEN 'Never'
        ELSE CONVERT(VARCHAR, u.lastLogin, 103) + ' ' + CONVERT(VARCHAR, u.lastLogin, 108)
    END AS LastLogin
FROM UserLogin u
LEFT JOIN Staff s ON u.staffID = s.staffID
LEFT JOIN Doctor d ON u.doctorID = d.doctorID
ORDER BY u.userRole, u.username;



-- Add after UserLogin table creation (around line 31)
ALTER TABLE UserLogin ADD plainPassword VARCHAR(50) NULL;


UPDATE UserLogin SET plainPassword = LEFT(username, CHARINDEX('@', username) - 1) + '@231';
SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'UserLogin';

-- Final success message
PRINT ''
PRINT '🎉 DATABASE SETUP COMPLETED!'
PRINT '============================================='
PRINT 'Next Steps:'
PRINT '1. Run the Flask app (app.py)'
PRINT '2. Open http://127.0.0.1:5000 in browser'
PRINT '3. Login with provided credentials'
PRINT '============================================='
GO

USE bloodBankSystem;

UPDATE UserLogin 
SET plainPassword = 'Admin@123' 
WHERE username = 'superadmin@bloodbank.org';