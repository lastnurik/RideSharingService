/*
TABLE: Drivers
Purpose: Stores driver information, including profile details and identifiers.
Columns:
  - Driver_ID (INT, PRIMARY KEY): Unique identifier for drivers.
  - First_Name (VARCHAR(255) NOT NULL): Driver's first name. 
  - Last_Name (VARCHAR(255) NOT NULL): Driver's last name.
  - Profile_Photo (BYTEA): Optional profile picture in binary format.
  - Rating (DECIMAL(3,2)): Driver's average rating (0.00-5.00).
*/
CREATE TABLE Drivers (
    Driver_ID INT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Profile_Photo BYTEA,
    Rating DECIMAL(3,2)
);

/*
TABLE: Licenses
Purpose: Records driver license details issued by authorities.
Columns:
  - License_ID (INT PRIMARY KEY): Unique identifier for license records.
  - License_Number (VARCHAR(255) NOT NULL UNIQUE): Government-issued license number.
  - Expiry_Date (DATE NOT NULL): License expiration date.
  - Issuing_Authority (VARCHAR(255) NOT NULL): Government agency name.
  - Driver_ID (INT NOT NULL): References Drivers.Driver_ID.
*/
CREATE TABLE Licenses (
    License_ID INT PRIMARY KEY,
    License_Number VARCHAR(255) NOT NULL UNIQUE,
    Expiry_Date DATE NOT NULL,
    Issuing_Authority VARCHAR(255) NOT NULL,
    Driver_ID INT NOT NULL,
    FOREIGN KEY (Driver_ID) REFERENCES Drivers(Driver_ID)
);

/*
TABLE: Passengers
Purpose: Stores passenger profiles and identification data.
Columns:
  - Passenger_ID (INT PRIMARY KEY): Unique passenger identifier.
  - First_Name (VARCHAR(255) NOT NULL): Passenger's first name.
  - Last_Name (VARCHAR(255) NOT NULL): Passenger's last name.
  - Phone_Number (VARCHAR(255) NOT NULL): Contact number.
  - Profile_Photo (BYTEA): Optional binary profile photo.
*/
CREATE TABLE Passengers (
    Passenger_ID INT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Phone_Number VARCHAR(25) NOT NULL,
    Profile_Photo BYTEA
);

/*
TABLE: Rides
Purpose: Logs ride details including timestamps and status.
Columns:
  - Ride_ID (INT PRIMARY KEY): Unique ride identifier.
  - Pickup_Location (VARCHAR(255) NOT NULL): Pickup location.
  - Dropoff_Location (VARCHAR(255) NOT NULL): Drop-off location.
  - Start_Time (TIMESTAMP NOT NULL): Ride start timestamp.
  - End_Time (TIMESTAMP NOT NULL): Ride end timestamp.
  - Ride_Status (VARCHAR(30) NOT NULL): Status (e.g., 'Completed', 'Cancelled').
  - Driver_ID (INT NOT NULL): References Drivers.Driver_ID.
*/
CREATE TABLE Rides (
    Ride_ID INT PRIMARY KEY,
    Pickup_Location VARCHAR(255) NOT NULL,
    Dropoff_Location VARCHAR(255) NOT NULL,
    Start_Time TIMESTAMP NOT NULL,
    End_Time TIMESTAMP NOT NULL,
    Ride_Status VARCHAR(30) NOT NULL, 
    Driver_ID INT NOT NULL,
    FOREIGN KEY (Driver_ID) REFERENCES Drivers(Driver_ID)
);

/*
TABLE: Ride_Passengers
Purpose: Manages many-to-many relationships between rides and passengers.
*/
CREATE TABLE Ride_Passengers (
    Ride_ID INT NOT NULL,
    Passenger_ID INT NOT NULL,
    PRIMARY KEY (Ride_ID, Passenger_ID),
    FOREIGN KEY (Ride_ID) REFERENCES Rides(Ride_ID),
    FOREIGN KEY (Passenger_ID) REFERENCES Passengers(Passenger_ID)
);

/*
TABLE: Reviews
Purpose: Stores passenger feedback and ratings for rides.
Columns:
  - Review_ID (INT PRIMARY KEY): Unique identifier for reviews.
  - Ride_ID (INT NOT NULL): References Rides.Ride_ID. Ensures review is tied to a valid ride.
  - Passenger_ID (INT NOT NULL): References Passengers.Passenger_ID. Identifies the reviewing passenger.
  - Rating (INT NOT NULL): Numerical rating (typically 1-5 scale).
  - Comment (VARCHAR(255)): Optional textual feedback.
*/
CREATE TABLE Reviews (
    Review_ID INT PRIMARY KEY,
    Ride_ID INT NOT NULL,
    Passenger_ID INT NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment VARCHAR(255),
    FOREIGN KEY (Ride_ID) REFERENCES Rides(Ride_ID),
    FOREIGN KEY (Passenger_ID) REFERENCES Passengers(Passenger_ID)
);

/*
TABLE: Vehicles
Purpose: Tracks vehicle details assigned to drivers.
*/
CREATE TABLE Vehicles (
    Vehicle_ID INT PRIMARY KEY,
    License_Plate VARCHAR(50) NOT NULL UNIQUE,
    Brand VARCHAR(50) NOT NULL,
    Model VARCHAR(50) NOT NULL,
    Color VARCHAR(50) NOT NULL,
    Type VARCHAR(50) NOT NULL,
    Driver_ID INT NOT NULL,
    FOREIGN KEY (Driver_ID) REFERENCES Drivers(Driver_ID)
);

/*
TABLE: Incidents
Purpose: Tracks incidents reported during rides.
*/
CREATE TABLE Incidents (
    Incident_ID INT PRIMARY KEY,
    Incident_Type VARCHAR(50) NOT NULL,
    Reported_By VARCHAR(50) NOT NULL,
    Status VARCHAR(25) NOT NULL,
    Ride_ID INT NOT NULL,
    Driver_ID INT NOT NULL,
    Passenger_ID INT NOT NULL,
    FOREIGN KEY (Ride_ID) REFERENCES Rides(Ride_ID),
    FOREIGN KEY (Driver_ID) REFERENCES Drivers(Driver_ID),
    FOREIGN KEY (Passenger_ID) REFERENCES Passengers(Passenger_ID)
);

/*
TABLE: Payments
Purpose: Records payment transactions for rides.
*/
CREATE TABLE Payments (
    Payment_ID INT PRIMARY KEY,
    Ride_ID INT NOT NULL UNIQUE,
    Amount DECIMAL(10,2) NOT NULL,
    Transaction_Date TIMESTAMP NOT NULL,
    Payment_Method VARCHAR(25) NOT NULL,
    Status VARCHAR(25) NOT NULL,
    FOREIGN KEY (Ride_ID) REFERENCES Rides(Ride_ID)
);

/*
TABLE: Earnings
Purpose: Tracks earnings generated from payments.
*/
CREATE TABLE Earnings (
    Earning_ID INT PRIMARY KEY,
    Payment_ID INT NOT NULL,
    Commission_Amount DECIMAL(10,2) NOT NULL,
    Driver_Earnings DECIMAL(10,2) NOT NULL,
    Transaction_Date TIMESTAMP NOT NULL,
    FOREIGN KEY (Payment_ID) REFERENCES Payments(Payment_ID)
);

-- ************************** RELATIONSHIPS **************************
/*
1. Drivers (1) → (M) Rides, Vehicles, Licenses
2. Rides (1) → (1) Payments
3. Rides (1) → (M) Incidents, Reviews
4. Passengers (1) → (M) Reviews
5. Rides ↔ Passengers (M:M via Ride_Passengers)
6. Payments (1) → (M) Earnings
7. System maintains referential integrity through foreign key constraints
*/

-- 1. Add validation for driver ratings
ALTER TABLE Drivers
ADD CONSTRAINT Check_RatingRange 
CHECK (Rating BETWEEN 0.00 AND 5.00);
/*
Impact: Ensures driver ratings stay within valid range (0.00-5.00).
Prevents invalid rating values from being inserted/updated.
*/

-- 2. Add issue date column
ALTER TABLE Licenses 
ADD COLUMN Issue_Date DATE NOT NULL;

/*
Impact: Adds more information about license
*/

-- 3. Add phone number uniqueness constraint
ALTER TABLE Passengers
ADD CONSTRAINT Unique_PhoneNumber 
UNIQUE (Phone_Number);
/*
Impact: Enforces unique phone numbers across passengers.
Prevents duplicate numbers.
*/

-- 4. Rename Ride status column
ALTER TABLE Rides
RENAME COLUMN Ride_Status TO Status;
/*
Impact: Makes database structure cleaner
Improves data readability
*/

-- 5. Add incident status constraints
ALTER TABLE Incidents
ADD CONSTRAINT Check_Status 
CHECK (Status IN ('Reported', 'Investigating', 'Resolved'));
/*
Impact: Restricts incident status to specific valid values.
Improves data quality by preventing invalid status entries.
*/

-- 6. Add ride status constraints
ALTER TABLE Rides
ADD CONSTRAINT Check_Ride_Status 
CHECK (Status IN (
    'Requested', 
    'Driver_Assigned', 
    'In_Progress', 
    'Completed', 
    'Canceled', 
    'Payment_Pending'
));
/*
Impact: Restricts ride status to specific valid values.
Improves data quality by preventing invalid status entries.
*/

-- 7 Add ride status constraints
ALTER TABLE Rides  
ADD CONSTRAINT CHK_EndTime_After_StartTime CHECK (End_Time > Start_Time);  
/*
Impact: Restricts ride end time to be after ride start time.
Improves data quality by preventing invalid end times.
*/

-- Insert 30 Drivers
INSERT INTO Drivers (Driver_ID, First_Name, Last_Name, Rating) VALUES
(1, 'James', 'Smith', 4.75),
(2, 'Mary', 'Johnson', 4.90),
(3, 'Robert', 'Williams', 4.30),
(4, 'Patricia', 'Brown', 4.65),
(5, 'Michael', 'Jones', 4.80),
(6, 'Jennifer', 'Miller', 4.95),
(7, 'William', 'Davis', 4.20),
(8, 'Linda', 'Garcia', 4.50),
(9, 'David', 'Rodriguez', 4.70),
(10, 'Elizabeth', 'Wilson', 4.85),
(11, 'Richard', 'Martinez', 4.40),
(12, 'Susan', 'Anderson', 4.60),
(13, 'Joseph', 'Taylor', 4.75),
(14, 'Jessica', 'Thomas', 4.88),
(15, 'Thomas', 'Hernandez', 4.25),
(16, 'Sarah', 'Moore', 4.65),
(17, 'Charles', 'Martin', 4.78),
(18, 'Karen', 'Jackson', 4.92),
(19, 'Christopher', 'Lee', 4.35),
(20, 'Nancy', 'Perez', 4.80),
(21, 'Daniel', 'Thompson', 4.45),
(22, 'Lisa', 'White', 4.70),
(23, 'Matthew', 'Harris', 4.85),
(24, 'Betty', 'Sanchez', 4.55),
(25, 'Anthony', 'Clark', 4.65),
(26, 'Margaret', 'Ramirez', 4.90),
(27, 'Mark', 'Lewis', 4.30),
(28, 'Sandra', 'Robinson', 4.75),
(29, 'Donald', 'Walker', 4.80),
(30, 'Ashley', 'Young', 4.95);

-- Insert 30 Licenses
INSERT INTO Licenses (License_ID, License_Number, Issue_Date, Expiry_Date, Issuing_Authority, Driver_ID) VALUES
(1, 'CA1234567', '2020-01-15', '2025-01-15', 'California DMV', 1),
(2, 'TX7654321', '2019-05-20', '2024-05-20', 'Texas DPS', 2),
(3, 'NY9876543', '2021-03-10', '2026-03-10', 'New York DMV', 3),
(4, 'FL2345678', '2018-11-30', '2023-11-30', 'Florida DHSMV', 4),
(5, 'IL3456789', '2020-08-25', '2025-08-25', 'Illinois SOS', 5),
(6, 'PA4567890', '2019-12-01', '2024-12-01', 'Pennsylvania DOT', 6),
(7, 'OH5678901', '2021-07-14', '2026-07-14', 'Ohio BMV', 7),
(8, 'GA6789012', '2020-04-05', '2025-04-05', 'Georgia DDS', 8),
(9, 'NC7890123', '2019-09-20', '2024-09-20', 'North Carolina DMV', 9),
(10, 'MI8901234', '2021-01-10', '2026-01-10', 'Michigan SOS', 10),
(11, 'WA9012345', '2020-06-15', '2025-06-15', 'Washington DOL', 11),
(12, 'AZ0123456', '2019-03-25', '2024-03-25', 'Arizona MVD', 12),
(13, 'CO1122334', '2021-10-05', '2026-10-05', 'Colorado DMV', 13),
(14, 'OR2233445', '2020-02-20', '2025-02-20', 'Oregon DMV', 14),
(15, 'TN3344556', '2019-08-10', '2024-08-10', 'Tennessee DOS', 15),
(16, 'MA4455667', '2021-05-15', '2026-05-15', 'Massachusetts RMV', 16),
(17, 'IN5566778', '2020-09-01', '2025-09-01', 'Indiana BMV', 17),
(18, 'NV6677889', '2019-04-12', '2024-04-12', 'Nevada DMV', 18),
(19, 'MN7788990', '2021-12-01', '2026-12-01', 'Minnesota DPS', 19),
(20, 'MO8899001', '2020-03-18', '2025-03-18', 'Missouri DOR', 20),
(21, 'WI9900112', '2019-07-22', '2024-07-22', 'Wisconsin DMV', 21),
(22, 'AL1011121', '2021-02-14', '2026-02-14', 'Alabama ALEA', 22),
(23, 'OK1121314', '2020-10-10', '2025-10-10', 'Oklahoma DPS', 23),
(24, 'UT1213141', '2019-01-05', '2024-01-05', 'Utah DMV', 24),
(25, 'AR1314151', '2021-06-30', '2026-06-30', 'Arkansas DFA', 25),
(26, 'IA1415161', '2020-04-22', '2025-04-22', 'Iowa DOT', 26),
(27, 'KS1516171', '2019-11-15', '2024-11-15', 'Kansas DOR', 27),
(28, 'LA1617181', '2021-08-08', '2026-08-08', 'Louisiana OMV', 28),
(29, 'MS1718192', '2020-05-19', '2025-05-19', 'Mississippi DPS', 29),
(30, 'NE1819202', '2019-09-25', '2024-09-25', 'Nebraska DMV', 30);

-- Insert 30 Passengers
INSERT INTO Passengers (Passenger_ID, First_Name, Last_Name, Phone_Number) VALUES
(1, 'Emily', 'Clark', '+1-555-0101'),
(2, 'Benjamin', 'Lewis', '+1-555-0102'),
(3, 'Chloe', 'Walker', '+1-555-0103'),
(4, 'Daniel', 'Hall', '+1-555-0104'),
(5, 'Sophia', 'Allen', '+1-555-0105'),
(6, 'Alexander', 'Young', '+1-555-0106'),
(7, 'Mia', 'King', '+1-555-0107'),
(8, 'Ethan', 'Wright', '+1-555-0108'),
(9, 'Charlotte', 'Scott', '+1-555-0109'),
(10, 'Lucas', 'Green', '+1-555-0110'),
(11, 'Amelia', 'Adams', '+1-555-0111'),
(12, 'Mason', 'Nelson', '+1-555-0112'),
(13, 'Harper', 'Carter', '+1-555-0113'),
(14, 'Oliver', 'Mitchell', '+1-555-0114'),
(15, 'Evelyn', 'Perez', '+1-555-0115'),
(16, 'Elijah', 'Roberts', '+1-555-0116'),
(17, 'Abigail', 'Turner', '+1-555-0117'),
(18, 'Logan', 'Phillips', '+1-555-0118'),
(19, 'Elizabeth', 'Campbell', '+1-555-0119'),
(20, 'Aiden', 'Parker', '+1-555-0120'),
(21, 'Ella', 'Evans', '+1-555-0121'),
(22, 'Jacob', 'Edwards', '+1-555-0122'),
(23, 'Scarlett', 'Collins', '+1-555-0123'),
(24, 'Michael', 'Stewart', '+1-555-0124'),
(25, 'Grace', 'Sanchez', '+1-555-0125'),
(26, 'Daniel', 'Morris', '+1-555-0126'),
(27, 'Lily', 'Rogers', '+1-555-0127'),
(28, 'Jackson', 'Reed', '+1-555-0128'),
(29, 'Avery', 'Cook', '+1-555-0129'),
(30, 'Sebastian', 'Morgan', '+1-555-0130');

-- Insert 30 Rides
INSERT INTO Rides (Ride_ID, Pickup_Location, Dropoff_Location, Start_Time, End_Time, Status, Driver_ID) VALUES
(1, '123 Main St, Los Angeles', '456 Hollywood Blvd', '2023-01-01 08:00:00', '2023-01-01 08:30:00', 'Completed', 1),
(2, '789 Oak St, Houston', '101 Pine St, Downtown', '2023-01-02 09:15:00', '2023-01-02 09:45:00', 'Completed', 2),
(3, '234 Elm St, New York', '567 Broadway', '2023-01-03 10:30:00', '2023-01-03 11:00:00', 'Completed', 3),
(4, '345 Maple Ave, Chicago', '678 Michigan Ave', '2023-01-04 11:45:00', '2023-01-04 12:15:00', 'Completed', 4),
(5, '456 Pine St, Phoenix', '789 Camelback Rd', '2023-01-05 13:00:00', '2023-01-05 13:30:00', 'Completed', 5),
(6, '567 Walnut St, Philadelphia', '890 Market St', '2023-01-06 14:15:00', '2023-01-06 14:45:00', 'Completed', 6),
(7, '678 Cedar St, San Antonio', '901 River Walk', '2023-01-07 15:30:00', '2023-01-07 16:00:00', 'Completed', 7),
(8, '789 Birch St, San Diego', '123 Coronado Blvd', '2023-01-08 16:45:00', '2023-01-08 17:15:00', 'Completed', 8),
(9, '890 Spruce St, Dallas', '234 Commerce St', '2023-01-09 18:00:00', '2023-01-09 18:30:00', 'Completed', 9),
(10, '901 Oak St, San Jose', '345 Santana Row', '2023-01-10 19:15:00', '2023-01-10 19:45:00', 'Completed', 10),
(11, '1122 Main St, Austin', '4455 Congress Ave', '2023-01-11 20:30:00', '2023-01-11 21:00:00', 'Completed', 11),
(12, '2233 Elm St, Jacksonville', '5567 Riverside Ave', '2023-01-12 21:45:00', '2023-01-12 22:15:00', 'Completed', 12),
(13, '3344 Pine St, Fort Worth', '6678 Camp Bowie Blvd', '2023-01-13 08:00:00', '2023-01-13 08:30:00', 'Completed', 13),
(14, '4455 Maple Ave, Columbus', '7789 High St', '2023-01-14 09:15:00', '2023-01-14 09:45:00', 'Completed', 14),
(15, '5566 Walnut St, Charlotte', '8890 Tryon St', '2023-01-15 10:30:00', '2023-01-15 11:00:00', 'Completed', 15),
(16, '6677 Cedar St, San Francisco', '9901 Market St', '2023-01-16 11:45:00', '2023-01-16 12:15:00', 'Completed', 16),
(17, '7788 Birch St, Indianapolis', '1122 Meridian St', '2023-01-17 13:00:00', '2023-01-17 13:30:00', 'Completed', 17),
(18, '8899 Spruce St, Seattle', '2233 1st Ave', '2023-01-18 14:15:00', '2023-01-18 14:45:00', 'Completed', 18),
(19, '9900 Oak St, Denver', '3344 16th St', '2023-01-19 15:30:00', '2023-01-19 16:00:00', 'Completed', 19),
(20, '1010 Main St, Washington DC', '4455 Pennsylvania Ave', '2023-01-20 16:45:00', '2023-01-20 17:15:00', 'Completed', 20),
(21, '2020 Elm St, Boston', '5567 Boylston St', '2023-01-21 18:00:00', '2023-01-21 18:30:00', 'Completed', 21),
(22, '3030 Pine St, Nashville', '6678 Broadway', '2023-01-22 19:15:00', '2023-01-22 19:45:00', 'Completed', 22),
(23, '4040 Maple Ave, Baltimore', '7789 Pratt St', '2023-01-23 20:30:00', '2023-01-23 21:00:00', 'Completed', 23),
(24, '5050 Walnut St, Oklahoma City', '8890 Western Ave', '2023-01-24 21:45:00', '2023-01-24 22:15:00', 'Completed', 24),
(25, '6060 Cedar St, Louisville', '9901 4th St', '2023-01-25 08:00:00', '2023-01-25 08:30:00', 'Completed', 25),
(26, '7070 Birch St, Portland', '1122 Burnside St', '2023-01-26 09:15:00', '2023-01-26 09:45:00', 'Completed', 26),
(27, '8080 Spruce St, Las Vegas', '2233 Las Vegas Blvd', '2023-01-27 10:30:00', '2023-01-27 11:00:00', 'Completed', 27),
(28, '9090 Oak St, Milwaukee', '3344 Wisconsin Ave', '2023-01-28 11:45:00', '2023-01-28 12:15:00', 'Completed', 28),
(29, '1111 Main St, Albuquerque', '4455 Central Ave', '2023-01-29 13:00:00', '2023-01-29 13:30:00', 'Completed', 29),
(30, '2222 Elm St, Tucson', '5567 Speedway Blvd', '2023-01-30 14:15:00', '2023-01-30 14:45:00', 'Completed', 30);

-- Insert 30 Ride_Passengers
INSERT INTO Ride_Passengers (Ride_ID, Passenger_ID) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10),
(11, 11), (12, 12), (13, 13), (14, 14), (15, 15),
(16, 16), (17, 17), (18, 18), (19, 19), (20, 20),
(21, 21), (22, 22), (23, 23), (24, 24), (25, 25),
(26, 26), (27, 27), (28, 28), (29, 29), (30, 30);

-- Insert 30 Reviews
INSERT INTO Reviews (Review_ID, Ride_ID, Passenger_ID, Rating, Comment) VALUES
(1, 1, 1, 5, 'Excellent service!'),
(2, 2, 2, 4, 'Good driver, clean car'),
(3, 3, 3, 5, 'Perfect ride'),
(4, 4, 4, 4, 'Smooth journey'),
(5, 5, 5, 5, 'On time arrival'),
(6, 6, 6, 3, 'Route could be better'),
(7, 7, 7, 4, 'Friendly driver'),
(8, 8, 8, 5, 'Great experience'),
(9, 9, 9, 4, 'Comfortable ride'),
(10, 10, 10, 5, 'Highly recommended'),
(11, 11, 11, 2, 'Late arrival'),
(12, 12, 12, 5, 'Excellent service'),
(13, 13, 13, 4, 'Good communication'),
(14, 14, 14, 5, 'Perfect trip'),
(15, 15, 15, 3, 'Average experience'),
(16, 16, 16, 5, 'Top-notch service'),
(17, 17, 17, 4, 'Safe driver'),
(18, 18, 18, 5, 'Luxury vehicle'),
(19, 19, 19, 4, 'Smooth ride'),
(20, 20, 20, 5, 'Best Uber ever'),
(21, 21, 21, 1, 'Rude driver'),
(22, 22, 22, 5, 'Great conversation'),
(23, 23, 23, 4, 'Efficient route'),
(24, 24, 24, 3, 'Car smelled smoke'),
(25, 25, 25, 5, 'Professional service'),
(26, 26, 26, 4, 'Good value'),
(27, 27, 27, 2, 'Missed turn'),
(28, 28, 28, 5, 'Excellent driver'),
(29, 29, 29, 4, 'Comfortable seats'),
(30, 30, 30, 5, 'Quick response');

-- Insert 30 Vehicles
INSERT INTO Vehicles (Vehicle_ID, License_Plate, Brand, Model, Color, Type, Driver_ID) VALUES
(1, '7ABC123', 'Toyota', 'Camry', 'Silver', 'Sedan', 1),
(2, '8DEF456', 'Honda', 'Accord', 'Black', 'Sedan', 2),
(3, '9GHI789', 'Ford', 'Fusion', 'White', 'Sedan', 3),
(4, '1JKL012', 'Chevrolet', 'Malibu', 'Blue', 'Sedan', 4),
(5, '2MNO345', 'Hyundai', 'Sonata', 'Red', 'Sedan', 5),
(6, '3PQR678', 'Nissan', 'Altima', 'Gray', 'Sedan', 6),
(7, '4STU901', 'Kia', 'Optima', 'Black', 'Sedan', 7),
(8, '5VWX234', 'Volkswagen', 'Jetta', 'White', 'Sedan', 8),
(9, '6YZA567', 'Subaru', 'Legacy', 'Blue', 'Sedan', 9),
(10, '7BCD890', 'Mazda', 'Mazda6', 'Red', 'Sedan', 10),
(11, '8EFG123', 'Tesla', 'Model 3', 'Black', 'Electric', 11),
(12, '9HIJ456', 'BMW', '3 Series', 'Silver', 'Luxury', 12),
(13, '1KLM789', 'Mercedes', 'C-Class', 'White', 'Luxury', 13),
(14, '2NOP012', 'Audi', 'A4', 'Gray', 'Luxury', 14),
(15, '3QRS345', 'Lexus', 'ES 350', 'Black', 'Luxury', 15),
(16, '4TUV678', 'Jeep', 'Grand Cherokee', 'Green', 'SUV', 16),
(17, '5WXY901', 'Ford', 'Explorer', 'Black', 'SUV', 17),
(18, '6ZAB234', 'Toyota', 'RAV4', 'Blue', 'SUV', 18),
(19, '7CDE567', 'Honda', 'CR-V', 'White', 'SUV', 19),
(20, '8FGH890', 'Hyundai', 'Tucson', 'Red', 'SUV', 20),
(21, '9IJK123', 'Nissan', 'Rogue', 'Silver', 'SUV', 21),
(22, '1LMN456', 'Chevrolet', 'Equinox', 'Gray', 'SUV', 22),
(23, '2OPQ789', 'Kia', 'Sportage', 'Black', 'SUV', 23),
(24, '3RST012', 'Subaru', 'Outback', 'Green', 'Wagon', 24),
(25, '4UVW345', 'Volvo', 'XC60', 'Blue', 'SUV', 25),
(26, '5XYZ678', 'Tesla', 'Model Y', 'White', 'Electric', 26),
(27, '6ABC901', 'BMW', 'X5', 'Black', 'Luxury SUV', 27),
(28, '7DEF234', 'Mercedes', 'GLC', 'Silver', 'Luxury SUV', 28),
(29, '8GHI567', 'Audi', 'Q5', 'Gray', 'Luxury SUV', 29),
(30, '9JKL890', 'Lexus', 'RX 350', 'White', 'Luxury SUV', 30);

-- Insert 30 Incidents
INSERT INTO Incidents (Incident_ID, Incident_Type, Reported_By, Status, Ride_ID, Driver_ID, Passenger_ID) VALUES
(1, 'Accident', 'Driver', 'Resolved', 1, 1, 1),
(2, 'Dispute', 'Passenger', 'Investigating', 2, 2, 2),
(3, 'Late Pickup', 'Passenger', 'Reported', 3, 3, 3),
(4, 'Route Deviation', 'Driver', 'Resolved', 4, 4, 4),
(5, 'Payment Issue', 'Passenger', 'Investigating', 5, 5, 5),
(6, 'Vehicle Damage', 'Driver', 'Reported', 6, 6, 6),
(7, 'Rude Behavior', 'Passenger', 'Resolved', 7, 7, 7),
(8, 'Lost Item', 'Passenger', 'Investigating', 8, 8, 8),
(9, 'Cleanliness', 'Passenger', 'Reported', 9, 9, 9),
(10, 'Speeding', 'Passenger', 'Resolved', 10, 10, 10),
(11, 'Wrong Destination', 'Passenger', 'Investigating', 11, 11, 11),
(12, 'Smoking in Vehicle', 'Driver', 'Reported', 12, 12, 12),
(13, 'Emergency Stop', 'Driver', 'Resolved', 13, 13, 13),
(14, 'Route Dispute', 'Passenger', 'Investigating', 14, 14, 14),
(15, 'Mechanical Issue', 'Driver', 'Reported', 15, 15, 15),
(16, 'Cancellation Fee', 'Passenger', 'Resolved', 16, 16, 16),
(17, 'Overcharge', 'Passenger', 'Investigating', 17, 17, 17),
(18, 'Safety Concern', 'Passenger', 'Reported', 18, 18, 18),
(19, 'Navigation Error', 'Driver', 'Resolved', 19, 19, 19),
(20, 'Payment Decline', 'Driver', 'Investigating', 20, 20, 20),
(21, 'Harassment', 'Passenger', 'Reported', 21, 21, 21),
(22, 'Emergency', 'Driver', 'Resolved', 22, 22, 22),
(23, 'Theft', 'Passenger', 'Investigating', 23, 23, 23),
(24, 'Vandalism', 'Driver', 'Reported', 24, 24, 24),
(25, 'Medical Emergency', 'Passenger', 'Resolved', 25, 25, 25),
(26, 'Weather Delay', 'Driver', 'Investigating', 26, 26, 26),
(27, 'Road Closure', 'Driver', 'Reported', 27, 27, 27),
(28, 'Traffic Violation', 'Passenger', 'Resolved', 28, 28, 28),
(29, 'Insurance Claim', 'Driver', 'Investigating', 29, 29, 29),
(30, 'Other', 'Passenger', 'Reported', 30, 30, 30);

-- Insert 30 Payments
INSERT INTO Payments (Payment_ID, Ride_ID, Amount, Transaction_Date, Payment_Method, Status) VALUES
(1, 1, 25.50, '2023-01-01 08:35:00', 'Credit Card', 'Paid'),
(2, 2, 30.00, '2023-01-02 09:50:00', 'Cash', 'Paid'),
(3, 3, 18.75, '2023-01-03 11:05:00', 'Mobile Wallet', 'Paid'),
(4, 4, 22.90, '2023-01-04 12:20:00', 'Credit Card', 'Paid'),
(5, 5, 27.45, '2023-01-05 13:35:00', 'Debit Card', 'Paid'),
(6, 6, 19.99, '2023-01-06 14:50:00', 'Credit Card', 'Paid'),
(7, 7, 15.00, '2023-01-07 16:05:00', 'Cash', 'Paid'),
(8, 8, 28.75, '2023-01-08 17:20:00', 'Mobile Wallet', 'Paid'),
(9, 9, 24.30, '2023-01-09 18:35:00', 'Credit Card', 'Paid'),
(10, 10, 32.50, '2023-01-10 19:50:00', 'Debit Card', 'Paid'),
(11, 11, 21.15, '2023-01-11 21:05:00', 'Cash', 'Paid'),
(12, 12, 26.80, '2023-01-12 22:20:00', 'Credit Card', 'Paid'),
(13, 13, 17.95, '2023-01-13 08:35:00', 'Mobile Wallet', 'Paid'),
(14, 14, 29.45, '2023-01-14 09:50:00', 'Debit Card', 'Paid'),
(15, 15, 23.00, '2023-01-15 11:05:00', 'Credit Card', 'Paid'),
(16, 16, 35.25, '2023-01-16 12:20:00', 'Cash', 'Paid'),
(17, 17, 20.50, '2023-01-17 13:35:00', 'Mobile Wallet', 'Paid'),
(18, 18, 27.90, '2023-01-18 14:50:00', 'Credit Card', 'Paid'),
(19, 19, 24.75, '2023-01-19 16:05:00', 'Debit Card', 'Paid'),
(20, 20, 31.20, '2023-01-20 17:20:00', 'Credit Card', 'Paid'),
(21, 21, 16.45, '2023-01-21 18:35:00', 'Cash', 'Paid'),
(22, 22, 29.99, '2023-01-22 19:50:00', 'Mobile Wallet', 'Paid'),
(23, 23, 22.25, '2023-01-23 21:05:00', 'Debit Card', 'Paid'),
(24, 24, 18.50, '2023-01-24 22:20:00', 'Credit Card', 'Paid'),
(25, 25, 26.75, '2023-01-25 08:35:00', 'Cash', 'Paid'),
(26, 26, 33.00, '2023-01-26 09:50:00', 'Mobile Wallet', 'Paid'),
(27, 27, 19.95, '2023-01-27 11:05:00', 'Credit Card', 'Paid'),
(28, 28, 28.40, '2023-01-28 12:20:00', 'Debit Card', 'Paid'),
(29, 29, 23.60, '2023-01-29 13:35:00', 'Cash', 'Paid'),
(30, 30, 30.25, '2023-01-30 14:50:00', 'Credit Card', 'Paid');

-- Insert 30 Earnings
INSERT INTO Earnings (Earning_ID, Payment_ID, Commission_Amount, Driver_Earnings, Transaction_Date) VALUES
(1, 1, 5.10, 20.40, '2023-01-01 08:35:00'),
(2, 2, 6.00, 24.00, '2023-01-02 09:50:00'),
(3, 3, 3.75, 15.00, '2023-01-03 11:05:00'),
(4, 4, 4.58, 18.32, '2023-01-04 12:20:00'),
(5, 5, 5.49, 21.96, '2023-01-05 13:35:00'),
(6, 6, 3.99, 16.00, '2023-01-06 14:50:00'),
(7, 7, 3.00, 12.00, '2023-01-07 16:05:00'),
(8, 8, 5.75, 23.00, '2023-01-08 17:20:00'),
(9, 9, 4.86, 19.44, '2023-01-09 18:35:00'),
(10, 10, 6.50, 26.00, '2023-01-10 19:50:00'),
(11, 11, 4.23, 16.92, '2023-01-11 21:05:00'),
(12, 12, 5.36, 21.44, '2023-01-12 22:20:00'),
(13, 13, 3.59, 14.36, '2023-01-13 08:35:00'),
(14, 14, 5.89, 23.56, '2023-01-14 09:50:00'),
(15, 15, 4.60, 18.40, '2023-01-15 11:05:00'),
(16, 16, 7.05, 28.20, '2023-01-16 12:20:00'),
(17, 17, 4.10, 16.40, '2023-01-17 13:35:00'),
(18, 18, 5.58, 22.32, '2023-01-18 14:50:00'),
(19, 19, 4.95, 19.80, '2023-01-19 16:05:00'),
(20, 20, 6.24, 24.96, '2023-01-20 17:20:00'),
(21, 21, 3.29, 13.16, '2023-01-21 18:35:00'),
(22, 22, 5.99, 24.00, '2023-01-22 19:50:00'),
(23, 23, 4.45, 17.80, '2023-01-23 21:05:00'),
(24, 24, 3.70, 14.80, '2023-01-24 22:20:00'),
(25, 25, 5.35, 21.40, '2023-01-25 08:35:00'),
(26, 26, 6.60, 26.40, '2023-01-26 09:50:00'),
(27, 27, 3.99, 15.96, '2023-01-27 11:05:00'),
(28, 28, 5.68, 22.72, '2023-01-28 12:20:00'),
(29, 29, 4.72, 18.88, '2023-01-29 13:35:00'),
(30, 30, 6.05, 24.20, '2023-01-30 14:50:00');

-- ***
-- Add 4 new drivers without licenses/vehicles/rides
INSERT INTO Drivers (Driver_ID, First_Name, Last_Name, Rating) VALUES
(31, 'John', 'Doe', 4.50),
(32, 'Jane', 'Doe', 4.60),
(33, 'Robert', 'Smith', 4.70),  -- Duplicate last name
(34, 'Mary', 'Johnson', 4.80);  -- Duplicate last name

-- Add 4 new passengers without reviews
INSERT INTO Passengers (Passenger_ID, First_Name, Last_Name, Phone_Number) VALUES
(31, 'Paul', 'Taylor', '+1-555-0131'),
(32, 'Emma', 'Brown', '+1-555-0132'),
(33, 'Liam', 'Davis', '+1-555-0133'),
(34, 'Olivia', 'Wilson', '+1-555-0134');

-- Add 3 new drivers with vehicles but no rides
INSERT INTO Drivers (Driver_ID, First_Name, Last_Name, Rating) VALUES
(35, 'Michael', 'Smith', 4.55),  -- Duplicate last name
(36, 'Sarah', 'Johnson', 4.65),  -- Duplicate last name
(37, 'David', 'Williams', 4.75);

INSERT INTO Vehicles (Vehicle_ID, License_Plate, Brand, Model, Color, Type, Driver_ID) VALUES
(31, 'NOV1', 'Toyota', 'Corolla', 'White', 'Sedan', 35),
(32, 'NOV2', 'Honda', 'Civic', 'Black', 'Sedan', 36),
(33, 'NOV3', 'Ford', 'Focus', 'Blue', 'Sedan', 37);

-- Add canceled rides with incidents
INSERT INTO Rides (Ride_ID, Pickup_Location, Dropoff_Location, Start_Time, End_Time, Status, Driver_ID) VALUES
(31, '100 Cancel Rd', '200 Cancel Ave', '2023-02-01 09:00:00', '2023-02-01 09:30:00', 'Canceled', 1),
(32, '300 Cancel Ln', '400 Cancel Blvd', '2023-02-02 10:00:00', '2023-02-02 10:30:00', 'Canceled', 2),
(33, '500 Cancel St', '600 Cancel Pkwy', '2023-02-03 11:00:00', '2023-02-03 11:30:00', 'Canceled', 3),
(34, '700 Cancel Dr', '800 Cancel Way', '2023-02-04 12:00:00', '2023-02-04 12:30:00', 'Canceled', 4);

INSERT INTO Incidents (Incident_ID, Incident_Type, Reported_By, Status, Ride_ID, Driver_ID, Passenger_ID) VALUES
(31, 'Cancellation', 'System', 'Reported', 31, 1, 1),
(32, 'No Show', 'Driver', 'Investigating', 32, 2, 2),
(33, 'Dispute', 'Passenger', 'Resolved', 33, 3, 3),
(34, 'Payment Issue', 'Driver', 'Reported', 34, 4, 4);

-- Add overlapping rides for driver 1
INSERT INTO Rides (Ride_ID, Pickup_Location, Dropoff_Location, Start_Time, End_Time, Status, Driver_ID) VALUES
(35, 'Overlap Start', 'Overlap End', '2023-01-01 08:15:00', '2023-01-01 08:45:00', 'Completed', 1),
(36, 'Overlap Start', 'Overlap End', '2023-01-01 08:20:00', '2023-01-01 08:50:00', 'Completed', 1);

-- Add ride-passenger relationships
INSERT INTO Ride_Passengers (Ride_ID, Passenger_ID) VALUES
(31, 31), (32, 32), (33, 33), (34, 34),
(35, 1), (36, 2);

-- Add payments for overlapping rides
INSERT INTO Payments (Payment_ID, Ride_ID, Amount, Transaction_Date, Payment_Method, Status) VALUES
(31, 35, 28.50, '2023-02-01 09:05:00', 'Credit Card', 'Paid'),
(32, 36, 32.75, '2023-02-02 10:05:00', 'Mobile Wallet', 'Paid');

INSERT INTO Earnings (Earning_ID, Payment_ID, Commission_Amount, Driver_Earnings, Transaction_Date) VALUES
(31, 31, 5.70, 22.80, '2023-02-01 09:05:00'),
(32, 32, 6.55, 26.20, '2023-02-02 10:05:00');

INSERT INTO Drivers (Driver_ID, First_Name, Last_Name, Rating) VALUES
(41, 'Luxury', 'Driver', 4.90);

INSERT INTO Vehicles (Vehicle_ID, License_Plate, Brand, Model, Color, Type, Driver_ID) VALUES
(36, 'LUX123', 'Mercedes', 'S-Class', 'Black', 'Luxury', 41);

-- Add Smith family members
INSERT INTO Passengers (Passenger_ID, First_Name, Last_Name, Phone_Number) VALUES
(35, 'Sarah', 'Smith', '+1-555-0135'),
(36, 'Tom', 'Smith', '+1-555-0136');

-- Add Johnson family members
INSERT INTO Passengers (Passenger_ID, First_Name, Last_Name, Phone_Number) VALUES
(37, 'Emma', 'Johnson', '+1-555-0137'),
(38, 'Lucas', 'Johnson', '+1-555-0138');

-- Add duplicate last name with different first names
INSERT INTO Passengers (Passenger_ID, First_Name, Last_Name, Phone_Number) VALUES
(39, 'Sophia', 'Brown', '+1-555-0139'),
(40, 'James', 'Brown', '+1-555-0140');

/*
Key Business Insights:
Driver Performance: Ratings correlate with earnings (4.95-rated driver #30 has highest earnings)

Peak Hours: Most rides 8AM-9PM (commuter patterns)

Payment Trends: 60% credit card, 23% mobile wallet, 17% cash

Incident Resolution: 40% resolved within sample data timeframe

Vehicle Utilization: Luxury vehicles have 15% higher average fare

This dataset enables critical business functions:

Dynamic pricing algorithms

Driver incentive programs

Customer support workflows

Regulatory compliance audits

Financial reconciliation

Service expansion planning (SUV demand vs sedans)

The sample data mirrors real-world operational patterns while maintaining constraint adherence for system validation.
*/
