CREATE DATABASE bloodBankNGO;
USE bloodBankNGO;


CREATE TABLE Campaign (
    campaignID INT IDENTITY(1,1) PRIMARY KEY,
    campaignName VARCHAR(100) NOT NULL,
    campaignDate DATE NOT NULL,
    location VARCHAR(150) NOT NULL,
    organizedBy VARCHAR(100),
    status VARCHAR(20) CHECK(status IN ('upcoming','completed','cancelled'))
);


CREATE TABLE CampaignVolunteer (
    volunteerID INT IDENTITY(1,1) PRIMARY KEY,
    volunteerName VARCHAR(100) NOT NULL,
    contactNumber VARCHAR(30),
    emailAddress VARCHAR(50),
    role VARCHAR(50)
);


CREATE TABLE CampaignVolunteerAssignment (
    assignmentID INT IDENTITY(1,1) PRIMARY KEY,
    campaignID INT NOT NULL,
    volunteerID INT NOT NULL,
    assignedRole VARCHAR(50),
    FOREIGN KEY (campaignID) REFERENCES Campaign(campaignID),
    FOREIGN KEY (volunteerID) REFERENCES CampaignVolunteer(volunteerID)
);


CREATE TABLE CampaignDonorRegistration (
    registrationID INT IDENTITY(1,1) PRIMARY KEY,
    campaignID INT NOT NULL,
    donorName VARCHAR(100) NOT NULL,
    donorAge INT CHECK(donorAge BETWEEN 18 AND 60),
    donorGender VARCHAR(10),
    donorBloodGroup VARCHAR(3) CHECK (donorBloodGroup IN 
        ('A-','A+','B-','B+','AB-','AB+','O-','O+')),
    contactNumber VARCHAR(30),
    FOREIGN KEY (campaignID) REFERENCES Campaign(campaignID)
);



CREATE TABLE CampaignSponsor (
    sponsorID INT IDENTITY(1,1) PRIMARY KEY,
    sponsorName VARCHAR(100) NOT NULL,
    sponsorType VARCHAR(50),
    contactNumber VARCHAR(30),
    emailAddress VARCHAR(50)
);



CREATE TABLE CampaignSponsorshipDetail (
    sponsorshipID INT IDENTITY(1,1) PRIMARY KEY,
    campaignID INT NOT NULL,
    sponsorID INT NOT NULL,
    amountSponsored DECIMAL(10,2),
    FOREIGN KEY (campaignID) REFERENCES Campaign(campaignID),
    FOREIGN KEY (sponsorID) REFERENCES CampaignSponsor(sponsorID)
);


CREATE TABLE CampaignInventory (
    itemID INT IDENTITY(1,1) PRIMARY KEY,
    itemName VARCHAR(100) NOT NULL,
    itemType VARCHAR(50),
    quantityAvailable INT,
    quantityUsed INT,
    campaignID INT,
    FOREIGN KEY (campaignID) REFERENCES Campaign(campaignID)
);


CREATE TABLE CampaignFeedback (
    feedbackID INT IDENTITY(1,1) PRIMARY KEY,
    campaignID INT NOT NULL,
    feedbackProvider VARCHAR(100),
    rating INT CHECK(rating BETWEEN 1 AND 5),
    comments VARCHAR(300),
    FOREIGN KEY (campaignID) REFERENCES Campaign(campaignID)
);


INSERT INTO Campaign (campaignName, campaignDate, location, organizedBy, status) VALUES ('Save Lives Blood Drive', '2025-12-08', 'Karachi, Sindh', 'Edhi Foundation', 'upcoming');
INSERT INTO Campaign (campaignName, campaignDate, location, organizedBy, status) VALUES ('Hope for Humanity', '2025-12-09', 'Lahore, Punjab', 'Shaukat Khanum Memorial Trust', 'completed');
INSERT INTO Campaign (campaignName, campaignDate, location, organizedBy, status) VALUES ('Red Ribbon Blood Donation', '2025-12-10', 'Islamabad, ICT', 'Aga Khan Health Services', 'cancelled');
INSERT INTO Campaign (campaignName, campaignDate, location, organizedBy, status) VALUES ('Life Stream Blood Drive', '2025-12-11', 'Peshawar, KPK', 'Pakistan Red Crescent Society', 'upcoming');
INSERT INTO Campaign (campaignName, campaignDate, location, organizedBy, status) VALUES ('Blood for Hope', '2025-12-12', 'Quetta, Balochistan', 'Indus Hospital', 'completed');
INSERT INTO Campaign (campaignName, campaignDate, location, organizedBy, status) VALUES ('Lifeline Blood Camp', '2025-12-13', 'Faisalabad, Punjab', 'Aman Foundation', 'cancelled');
INSERT INTO Campaign (campaignName, campaignDate, location, organizedBy, status) VALUES ('Give Blood, Save Lives', '2025-12-14', 'Multan, Punjab', 'Saylani Welfare Trust', 'upcoming');
INSERT INTO Campaign (campaignName, campaignDate, location, organizedBy, status) VALUES ('Red Drop Campaign', '2025-12-15', 'Rawalpindi, Punjab', 'Edhi Foundation', 'completed');


SELECT *
FROM Campaign
ORDER BY campaignID ASC;



--1 phr ayesha us ke id 2 phr bilal us ke id 3 than 


INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (1, 1, 'Coordinator');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (1, 2, 'Assistant');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (1, 3, 'Nurse');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (2, 4, 'Field Staff');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (2, 5, 'Coordinator');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (2, 6, 'Assistant');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (3, 7, 'Nurse');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (3, 8, 'Field Staff');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (3, 9, 'Coordinator');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (4, 10, 'Assistant');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (4, 11, 'Nurse');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (4, 12, 'Field Staff');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (5, 13, 'Coordinator');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (5, 14, 'Assistant');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (5, 15, 'Nurse');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (6, 16, 'Field Staff');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (6, 17, 'Coordinator');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (6, 18, 'Assistant');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (7, 19, 'Nurse');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (7, 20, 'Field Staff');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (7, 21, 'Coordinator');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (8, 22, 'Assistant');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (8, 23, 'Nurse');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (8, 24, 'Field Staff');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (9, 25, 'Coordinator');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (9, 26, 'Assistant');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (9, 27, 'Nurse');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (10, 28, 'Field Staff');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (10, 29, 'Coordinator');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (10, 30, 'Assistant');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (11, 31, 'Nurse');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (11, 32, 'Field Staff');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (11, 33, 'Coordinator');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (12, 34, 'Assistant');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (12, 35, 'Nurse');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (12, 36, 'Field Staff');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (13, 37, 'Coordinator');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (13, 38, 'Assistant');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (13, 39, 'Nurse');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (14, 40, 'Field Staff');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (14, 41, 'Coordinator');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (14, 42, 'Assistant');
INSERT INTO CampaignVolunteerAssignment (campaignID, volunteerID, assignedRole) VALUES (15, 43, 'Nurse');






INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (1, 'Ali Raza', 25, 'Male', 'A+', '0300-1234567');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (1, 'Ayesha Khan', 28, 'Female', 'B+', '0301-2345678');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (1, 'Bilal Ahmed', 30, 'Male', 'O+', '0302-3456789');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (2, 'Fatima Zahra', 22, 'Female', 'AB+', '0303-4567890');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (2, 'Hamza Ali', 35, 'Male', 'A-', '0304-5678901');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (2, 'Sara Khan', 26, 'Female', 'B-', '0305-6789012');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (3, 'Omar Farooq', 29, 'Male', 'O-', '0306-7890123');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (3, 'Hina Riaz', 33, 'Female', 'AB-', '0307-8901234');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (3, 'Usman Khan', 24, 'Male', 'A+', '0308-9012345');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (4, 'Maryam Shah', 27, 'Female', 'B+', '0309-0123456');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (4, 'Zain Khan', 31, 'Male', 'O+', '0310-1234567');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (4, 'Sana Ahmed', 23, 'Female', 'AB+', '0311-2345678');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (5, 'Ahmed Khan', 28, 'Male', 'A-', '0312-3456789');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (5, 'Laiba Ahmed', 25, 'Female', 'B-', '0313-4567890');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (5, 'Danish Khan', 30, 'Male', 'O-', '0314-5678901');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (6, 'Zoya Khan', 22, 'Female', 'AB-', '0315-6789012');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (6, 'Faraz Khan', 35, 'Male', 'A+', '0316-7890123');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (6, 'Hira Ahmed', 27, 'Female', 'B+', '0317-8901234');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (7, 'Shahid Ahmed', 32, 'Male', 'O+', '0318-9012345');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (7, 'Aimen Khan', 24, 'Female', 'AB+', '0319-0123456');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (7, 'Arslan Ahmed', 29, 'Male', 'A-', '0320-1234567');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (8, 'Sadia Khan', 26, 'Female', 'B-', '0321-2345678');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (8, 'Tariq Shah', 33, 'Male', 'O-', '0322-3456789');
INSERT INTO CampaignDonorRegistration (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber) VALUES (8, 'Huma Riaz', 28, 'Female', 'AB-', '0323-4567890');






INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Edhi Foundation', 'NGO', '0300-1112233', 'contact@edhi.org');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Shaukat Khanum Trust', 'NGO', '0301-2223344', 'info@shaukatkhanum.org');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Aga Khan Health Services', 'NGO', '0302-3334455', 'support@akdn.org');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Fauji Foundation', 'Company', '0303-4445566', 'contact@faujifoundation.org');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Pak Suzuki Motors', 'Company', '0304-5556677', 'info@suzuki.com.pk');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Nestle Pakistan', 'Company', '0305-6667788', 'csr@pk.nestle.com');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Unilever Pakistan', 'Company', '0306-7778899', 'info@unilever.com.pk');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Habib Bank Limited', 'Company', '0307-8889900', 'csr@hbl.com');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Jazz Pakistan', 'Company', '0308-9990011', 'support@jazz.com');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Telenor Pakistan', 'Company', '0309-1112233', 'contact@telenor.com.pk');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Agha Khan Foundation', 'NGO', '0310-2223344', 'info@akf.org');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('The Citizens Foundation', 'NGO', '0311-3334455', 'support@tcf.org.pk');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Saylani Welfare', 'NGO', '0312-4445566', 'contact@saylaniwelfare.org');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Imran Khan Foundation', 'NGO', '0313-5556677', 'info@ikf.org');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Lucky Cement', 'Company', '0314-6667788', 'csr@luckycement.com');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Engro Corporation', 'Company', '0315-7778899', 'info@engro.com');
INSERT INTO CampaignSponsor (sponsorName, sponsorType, contactNumber, emailAddress) VALUES ('Millat Tractors', 'Company', '0316-8889900', 'contact@millat.com');






INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (1, 1, 50000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (1, 2, 75000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (2, 3, 60000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (2, 4, 80000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (3, 5, 45000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (3, 6, 90000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (4, 7, 70000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (4, 8, 65000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (5, 9, 85000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (5, 10, 95000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (6, 11, 50000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (6, 12, 55000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (7, 13, 60000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (7, 14, 70000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (8, 15, 80000.00);
INSERT INTO CampaignSponsorshipDetail (campaignID, sponsorID, amountSponsored) VALUES (8, 16, 90000.00);







INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 200, 150, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 300, 250, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 500, 400, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 400, 350, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 600, 550, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 700, 650, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 200, 180, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 150, 130, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 100, 80, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Water Bottles', 'Refreshments', 300, 250, 1);

INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 180, 140, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 250, 220, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 450, 400, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 350, 300, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 550, 500, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 650, 600, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 220, 200, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 140, 120, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 90, 80, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Snacks', 'Refreshments', 200, 150, 2);

INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 220, 180, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 300, 250, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 500, 450, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 400, 350, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 600, 550, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 700, 650, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 200, 180, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 150, 130, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 100, 90, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Water Bottles', 'Refreshments', 250, 200, 3);

-- Campaign 4
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 200, 160, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 280, 230, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 480, 420, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 380, 330, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 580, 530, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 680, 630, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 210, 190, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 140, 120, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 95, 85, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Snacks', 'Refreshments', 220, 180, 4);






INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 200, 150, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 300, 250, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 500, 400, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 400, 350, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 600, 550, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 700, 650, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 200, 180, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 150, 130, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 100, 80, 1);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Water Bottles', 'Refreshments', 300, 250, 1);

INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 180, 140, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 250, 220, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 450, 400, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 350, 300, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 550, 500, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 650, 600, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 220, 200, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 140, 120, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 90, 80, 2);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Snacks', 'Refreshments', 200, 150, 2);

INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 220, 180, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 300, 250, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 500, 450, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 400, 350, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 600, 550, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 700, 650, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 200, 180, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 150, 130, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 100, 90, 3);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Water Bottles', 'Refreshments', 250, 200, 3);

INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 200, 160, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 280, 230, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 480, 420, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 380, 330, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 580, 530, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 680, 630, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 210, 190, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 140, 120, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 95, 85, 4);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Snacks', 'Refreshments', 220, 180, 4);

INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 210, 170, 5);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 290, 240, 5);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 490, 440, 5);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 390, 340, 5);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 590, 540, 5);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 690, 640, 5);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 205, 185, 5);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 145, 125, 5);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 98, 88, 5);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Water Bottles', 'Refreshments', 260, 210, 5);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 220, 180, 6);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 300, 260, 6);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 500, 450, 6);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 400, 350, 6);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 600, 550, 6);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 700, 650, 6);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 210, 190, 6);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 150, 130, 6);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 100, 90, 6);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Water Bottles', 'Refreshments', 250, 200, 6);

INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 230, 190, 7);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 310, 270, 7);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 510, 460, 7);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 410, 360, 7);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 610, 560, 7);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 710, 660, 7);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 215, 195, 7);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 155, 135, 7);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 105, 95, 7);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Snacks', 'Refreshments', 260, 210, 7);

INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 240, 200, 8);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 320, 280, 8);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 520, 470, 8);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 420, 370, 8);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 620, 570, 8);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 720, 670, 8);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 220, 200, 8);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 160, 140, 8);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 110, 100, 8);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Water Bottles', 'Refreshments', 270, 220, 8);

INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 250, 210, 9);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 330, 290, 9);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 530, 480, 9);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 430, 380, 9);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 630, 580, 9);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 730, 680, 9);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 225, 205, 9);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 165, 145, 9);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 115, 105, 9);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Snacks', 'Refreshments', 280, 230, 9);

INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Blood Bags', 'Medical', 260, 220, 10);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Syringes', 'Medical', 340, 300, 10);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Gloves', 'Medical', 540, 490, 10);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Masks', 'Medical', 440, 390, 10);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Alcohol Swabs', 'Medical', 640, 590, 10);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Cotton Balls', 'Medical', 740, 690, 10);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Registration Forms', 'Stationery', 230, 210, 10);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Pens', 'Stationery', 170, 150, 10);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Clipboards', 'Stationery', 120, 110, 10);
INSERT INTO CampaignInventory (itemName, itemType, quantityAvailable, quantityUsed, campaignID) VALUES ('Water Bottles', 'Refreshments', 290, 240, 10);












INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (1, 'Ali Khan', 5, 'Well organized and smooth blood donation process.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (1, 'Sara Ahmed', 4, 'Friendly staff and good coordination.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (1, 'Hassan Raza', 5, 'Excellent management and volunteers were very helpful.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (1, 'Zoya Malik', 4, 'Nice experience, will participate again.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (1, 'Bilal Qureshi', 5, 'Efficient setup and timely service.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (2, 'Ayesha Tariq', 4, 'Volunteers were supportive and kind.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (2, 'Omar Farooq', 5, 'Everything was very professional.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (2, 'Fatima Saeed', 3, 'Slightly crowded but overall good.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (2, 'Ahmed Iqbal', 5, 'Smooth registration and donation process.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (2, 'Sana Khurram', 4, 'Good volunteers, helpful staff.');

INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (3, 'Usman Shah', 5, 'Excellent coordination and setup.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (3, 'Mariam Ali', 4, 'Friendly and welcoming environment.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (3, 'Hira Khan', 5, 'Smooth process and very organized.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (3, 'Noman Rafiq', 4, 'Well managed and clean setup.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (3, 'Sadia Imran', 5, 'Highly recommended blood donation camp.');

INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (4, 'Ali Raza', 5, 'Great volunteers and smooth experience.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (4, 'Hina Malik', 4, 'Organized and professional staff.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (4, 'Kashif Ahmed', 5, 'Clean setup and easy registration.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (4, 'Sarah Javed', 3, 'Had to wait a bit, but overall fine.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (4, 'Bilal Shah', 5, 'Very smooth and welcoming experience.');

INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (5, 'Areeba Khan', 4, 'Good setup and friendly staff.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (5, 'Zain Ali', 5, 'Efficient and well managed.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (5, 'Hassan Tariq', 5, 'Smooth registration and donation process.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (5, 'Sana Iqbal', 4, 'Helpful volunteers and staff.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (5, 'Fahad Raza', 5, 'Excellent overall experience.');

INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (6, 'Aliya Shah', 5, 'Highly organized and efficient.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (6, 'Omar Khan', 4, 'Friendly volunteers, smooth process.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (6, 'Mariam Rafiq', 5, 'Great blood donation camp, very professional.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (6, 'Ahmed Malik', 4, 'Good experience and well managed.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (6, 'Sarah Tariq', 5, 'Clean and welcoming environment.');

INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (7, 'Usman Ali', 5, 'Very professional setup.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (7, 'Hira Raza', 4, 'Friendly staff and good organization.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (7, 'Bilal Khan', 5, 'Smooth donation process, well organized.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (7, 'Ayesha Malik', 4, 'Helpful volunteers, nice experience.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (7, 'Zainab Shah', 5, 'Excellent camp, very efficient.');

INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (8, 'Ali Rafiq', 5, 'Well managed and organized.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (8, 'Sana Khan', 4, 'Smooth process and friendly volunteers.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (8, 'Hassan Malik', 5, 'Excellent overall experience.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (8, 'Mariam Shah', 4, 'Helpful staff, clean environment.');
INSERT INTO CampaignFeedback (campaignID, feedbackProvider, rating, comments) VALUES (8, 'Omar Tariq', 5, 'Highly recommended blood camp.');






SELECT * FROM Campaign ORDER BY campaignDate DESC;

SELECT * FROM CampaignVolunteer;

SELECT * FROM CampaignSponsor;



UPDATE Campaign
SET status = 'completed'
WHERE campaignID = 1;

UPDATE CampaignVolunteerAssignment
SET assignedRole = 'Senior Nurse'
WHERE assignmentID = 10;


UPDATE CampaignInventory
SET quantityUsed = quantityUsed + 10
WHERE itemID = 4;


DELETE FROM Campaign WHERE campaignID = 5;


DELETE FROM CampaignVolunteerAssignment WHERE assignmentID = 3;


SELECT * FROM Campaign
WHERE campaignName LIKE '%blood%' OR location LIKE '%lahore%';


SELECT * FROM Campaign WHERE status = 'upcoming';


SELECT * FROM CampaignDonorRegistration
WHERE donorBloodGroup = 'A+';


SELECT C.campaignName, COUNT(R.registrationID) AS totalDonors
FROM Campaign C
LEFT JOIN CampaignDonorRegistration R ON C.campaignID = R.campaignID
GROUP BY C.campaignName;


SELECT C.campaignName, COUNT(A.assignmentID) AS totalVolunteers
FROM Campaign C
LEFT JOIN CampaignVolunteerAssignment A 
ON C.campaignID = A.campaignID
GROUP BY C.campaignName;


SELECT C.campaignName,
       SUM(D.amountSponsored) AS totalSponsored
FROM CampaignSponsorshipDetail D
JOIN Campaign C ON C.campaignID = D.campaignID
GROUP BY C.campaignName;

SELECT C.campaignName, I.itemName, I.quantityAvailable, I.quantityUsed
FROM CampaignInventory I
JOIN Campaign C ON I.campaignID = C.campaignID;


SELECT COUNT(*) FROM Campaign;


SELECT COUNT(*) FROM Campaign WHERE status='upcoming';

SELECT COUNT(*) FROM CampaignDonorRegistration;

SELECT COUNT(*) FROM CampaignVolunteer;

SELECT SUM(amountSponsored) FROM CampaignSponsorshipDetail;



CREATE TABLE CampaignDonor (
    donorID INT IDENTITY(1,1) PRIMARY KEY,
    campaignID INT NOT NULL,
    donorName VARCHAR(100) NOT NULL,
    donorAge INT CHECK(donorAge BETWEEN 18 AND 60),
    donorGender VARCHAR(10),
    donorBloodGroup VARCHAR(3) CHECK (donorBloodGroup IN 
        ('A-','A+','B-','B+','AB-','AB+','O-','O+')),
    contactNumber VARCHAR(30),
    FOREIGN KEY (campaignID) REFERENCES Campaign(campaignID)
);



ALTER TABLE CampaignVolunteerAssignment
DROP CONSTRAINT FK__CampaignV__campa__4E88ABD4;

ALTER TABLE CampaignVolunteerAssignment
ADD CONSTRAINT FK__CampaignV__campa__4E88ABD4
FOREIGN KEY (campaignID)
REFERENCES Campaign(campaignID)
ON DELETE CASCADE;






INSERT INTO CampaignDonor (campaignID, donorName, donorAge, donorGender, donorBloodGroup, contactNumber, donationDate)
VALUES
-- Campaign 1
(1, 'Ali Khan', 25, 'Male', 'A+', '03001234501', '2025-12-08'),
(1, 'Sara Ahmed', 30, 'Female', 'O+', '03001234502', '2025-12-08'),
(1, 'Hamza Malik', 28, 'Male', 'B+', '03001234503', '2025-12-08'),
(1, 'Ayesha Raza', 35, 'Female', 'AB+', '03001234504', '2025-12-08'),
(1, 'Zainab Qureshi', 22, 'Female', 'O-', '03001234505', '2025-12-08'),

-- Campaign 2
(2, 'Bilal Shah', 26, 'Male', 'A-', '03001234506', '2025-12-09'),
(2, 'Fatima Iqbal', 31, 'Female', 'B+', '03001234507', '2025-12-09'),
(2, 'Osman Tariq', 29, 'Male', 'O+', '03001234508', '2025-12-09'),
(2, 'Hina Malik', 33, 'Female', 'AB-', '03001234509', '2025-12-09'),
(2, 'Kamran Ali', 27, 'Male', 'A+', '03001234510', '2025-12-09'),

-- Campaign 3
(3, 'Sadia Khan', 24, 'Female', 'B+', '03001234511', '2025-12-10'),
(3, 'Imran Shah', 32, 'Male', 'O-', '03001234512', '2025-12-10'),
(3, 'Maira Qureshi', 28, 'Female', 'A+', '03001234513', '2025-12-10'),
(3, 'Fawad Malik', 35, 'Male', 'AB+', '03001234514', '2025-12-10'),
(3, 'Nida Riaz', 26, 'Female', 'O+', '03001234515', '2025-12-10'),

-- Campaign 4
(4, 'Zoya Khan', 27, 'Female', 'A+', '03001234516', '2025-12-11'),
(4, 'Arsalan Ahmed', 30, 'Male', 'B-', '03001234517', '2025-12-11'),
(4, 'Sana Malik', 29, 'Female', 'O+', '03001234518', '2025-12-11'),
(4, 'Danish Ali', 34, 'Male', 'AB-', '03001234519', '2025-12-11'),
(4, 'Areeba Shah', 25, 'Female', 'B+', '03001234520', '2025-12-11'),

-- Campaign 5
(5, 'Hassan Raza', 31, 'Male', 'O+', '03001234521', '2025-12-12'),
(5, 'Mariam Khan', 28, 'Female', 'A-', '03001234522', '2025-12-12'),
(5, 'Fahad Tariq', 33, 'Male', 'B+', '03001234523', '2025-12-12'),
(5, 'Sadia Ali', 26, 'Female', 'AB+', '03001234524', '2025-12-12'),
(5, 'Ahsan Qureshi', 27, 'Male', 'O-', '03001234525', '2025-12-12'),

-- Campaign 6
(6, 'Nawal Shah', 29, 'Female', 'A+', '03001234526', '2025-12-13'),
(6, 'Saad Malik', 32, 'Male', 'B+', '03001234527', '2025-12-13'),
(6, 'Huma Tariq', 28, 'Female', 'O+', '03001234528', '2025-12-13'),
(6, 'Shahbaz Ali', 35, 'Male', 'AB-', '03001234529', '2025-12-13'),
(6, 'Sana Qureshi', 24, 'Female', 'A-', '03001234530', '2025-12-13'),

-- Campaign 7
(7, 'Ali Raza', 30, 'Male', 'B+', '03001234531', '2025-12-14'),
(7, 'Sara Khan', 27, 'Female', 'O+', '03001234532', '2025-12-14'),
(7, 'Hamza Shah', 29, 'Male', 'AB+', '03001234533', '2025-12-14'),
(7, 'Ayesha Tariq', 31, 'Female', 'A+', '03001234534', '2025-12-14'),
(7, 'Zainab Ali', 26, 'Female', 'O-', '03001234535', '2025-12-14'),

-- Campaign 8
(8, 'Bilal Khan', 28, 'Male', 'B-', '03001234536', '2025-12-15'),
(8, 'Fatima Shah', 33, 'Female', 'O+', '03001234537', '2025-12-15'),
(8, 'Osman Raza', 27, 'Male', 'A+', '03001234538', '2025-12-15'),
(8, 'Hina Qureshi', 30, 'Female', 'AB-', '03001234539', '2025-12-15'),
(8, 'Kamran Malik', 29, 'Male', 'B+', '03001234540', '2025-12-15'),

-- Campaign 9
(9, 'Sadia Khan', 26, 'Female', 'O+', '03001234541', '2025-12-16'),
(9, 'Imran Ali', 31, 'Male', 'A-', '03001234542', '2025-12-16'),
(9, 'Maira Shah', 28, 'Female', 'B+', '03001234543', '2025-12-16'),
(9, 'Fawad Qureshi', 34, 'Male', 'AB+', '03001234544', '2025-12-16'),
(9, 'Nida Raza', 25, 'Female', 'O-', '03001234545', '2025-12-16'),

-- Campaign 10
(10, 'Zoya Ali', 27, 'Female', 'A+', '03001234546', '2025-12-17'),
(10, 'Arsalan Khan', 30, 'Male', 'B-', '03001234547', '2025-12-17'),
(10, 'Sana Shah', 29, 'Female', 'O+', '03001234548', '2025-12-17'),
(10, 'Danish Malik', 34, 'Male', 'AB-', '03001234549', '2025-12-17'),
(10, 'Areeba Tariq', 25, 'Female', 'B+', '03001234550', '2025-12-17');

ALTER TABLE CampaignDonor
ADD donationDate DATE;

SELECT campaignID, donorName, donorBloodGroup FROM CampaignDonorRegistration;

SELECT campaignID, donorName, donorBloodGroup FROM CampaignDonorRegistration;
select * from Campaign;
select * from CampaignDonor;

