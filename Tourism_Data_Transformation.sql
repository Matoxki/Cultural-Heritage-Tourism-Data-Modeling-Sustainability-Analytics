-- Data Modeling and Advanced Analytics Project
-- Dataset: Tourism Cultural Heritage Sustainability Data from Kaggle (https://www.kaggle.com/datasets/colabsss/tourism-cultural-heritage-sustainability-data?resource=download)

-- Note: I designed the architecture and the table relationships, and I used 
-- AI as a pair-programmer to help optimize the syntax and troubleshoot 
-- constraint errors. 

-- The tourism CSV file is imported into the 'Tourism_Sites' database as 'Tourism_Sites_raw' table. 

USE Tourism_Sites;
GO

-- Inspect data sample first 10 rows
SELECT TOP 10 *
FROM Tourism_Sites_raw;
GO

-- We can see that the raw data contains 48 columns and 15,000 rows. There is a need to model this data by breaking this single wide table into a Star Schema.
-- Imagine the original Tourism_Sites_raw table as a giant, messy filing cabinet. Every single time a visitor bought a ticket, a new piece of paper was added to the cabinet. 
-- But instead of just writing down the ticket price, someone handwrote the entire history of the heritage site, the exact weather description, and the region on every single piece of paper.

-- Data Modeling (The Transformation)
-- I created Dimension Tables (The Reference Books) that register site profiles, date information, and management details,
-- and The Fact Table (The Cash Register) for IDs and the actual metrics measured.


-- 1. Dim_Site_Profile: Junk dimension for Region + Heritage_Type + Heritage_Level
-- Learning Note: In my first draft, I tried to create a standard 'Dim_Site' by grouping by Heritage_Site_ID.
-- (e.g., SELECT Heritage_Site_ID, MAX(Region)... GROUP BY Heritage_Site_ID).
-- However, when profiling the data, I realized the dataset had variation where Region and Heritage_Type actually changed row-by-row for the same Site ID. 
-- To avoid collapsing this real variation into fake constants, I learned to use a "Junk Dimension" (Dim_Site_Profile) to group these changing categorical variables together.

CREATE TABLE Dim_Site_Profile (
    Site_Profile_ID INT IDENTITY(1,1) PRIMARY KEY, Region VARCHAR(50), Heritage_Type VARCHAR(50), Heritage_Level VARCHAR(50)
);

INSERT INTO Dim_Site_Profile (Region, Heritage_Type, Heritage_Level)
SELECT DISTINCT
    Region, Heritage_Type, Heritage_Level
FROM Tourism_Sites_raw;
GO

-- Sanity check - checking the distinct combinations.
-- It lands at 100 unique combinations, which is perfect for a dimension table (well under the 15,000 raw rows).
SELECT COUNT(*) AS Site_Profile_Combo_Count FROM Dim_Site_Profile;
GO


-- 2. Dim_Calendar: Creating a time dimension
-- Learning Note: I added standard Month and Quarter text columns using the CHOOSE() function. 
-- This translates the numeric month data into readable text, which enables much cleaner time-intelligence filtering in the final Power BI dashboard.
CREATE TABLE Dim_Calendar (
    Calendar_ID INT IDENTITY(1,1) PRIMARY KEY, Month INT, Tourism_Season VARCHAR(50), Day_Type VARCHAR(50), Month_Name VARCHAR(20), Month_Short VARCHAR(3), Quarter_Name VARCHAR(2)
);

-- Insert the unique combinations of time from the raw data, mapping the numeric month to text
INSERT INTO Dim_Calendar (Month, Tourism_Season, Day_Type, Month_Name, Month_Short, Quarter_Name)
SELECT DISTINCT Month, Tourism_Season, Day_Type,
    CHOOSE(Month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'),
    CHOOSE(Month, 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'),
    CHOOSE(Month, 'Q1', 'Q1', 'Q1', 'Q2', 'Q2', 'Q2', 'Q3', 'Q3', 'Q3', 'Q4', 'Q4', 'Q4')
FROM Tourism_Sites_raw;
GO


-- 3. Dim_Management: Extracting the categorical actions
CREATE TABLE Dim_Management (
    Management_ID INT IDENTITY(1,1) PRIMARY KEY, Management_Action VARCHAR(100)
);

INSERT INTO Dim_Management (Management_Action)
SELECT DISTINCT Management_Action
FROM Tourism_Sites_raw;
GO


-- 4. Fact_Site_Operations: The central metrics table
-- Note: Because Heritage_Site_ID and Site_Age_Years vary per row and don't connect to a fixed reference table, 
-- they now live as plain attributes (degenerate dimensions) directly on the fact table. 

SELECT 
    r.Record_ID,
    r.Heritage_Site_ID,                  -- Plain attribute, not a dimension key
    r.Site_Age_Years,                    -- Plain attribute
    sp.Site_Profile_ID,                  -- Connects to Dim_Site_Profile
    c.Calendar_ID,                       -- Connects to Dim_Calendar
    m.Management_ID,                     -- Connects to Dim_Management
    
    -- Visitor Metrics
    r.Daily_Visitor_Count, r.Domestic_Visitor_Count, r.International_Visitor_Count, r.Peak_Hour_Visitor_Count, r.Entry_Queue_Time_Min, r.Site_Capacity_Utilization, r.Overcrowding_Risk_Score, r.Visitor_Satisfaction_Score,
   
    -- Environmental Metrics
    r.Carbon_Emission_kg, r.Waste_Generation_kg, r.Water_Consumption_Liters, r.Environmental_Pressure_Index,
    
    -- Financial and Condition Metrics
    r.Tourism_Revenue, r.Maintenance_Cost, r.Heritage_Condition_Score, r.Structural_Damage_Index

INTO Fact_Site_Operations
FROM Tourism_Sites_raw r
JOIN Dim_Calendar c ON r.Month = c.Month AND r.Tourism_Season = c.Tourism_Season AND r.Day_Type = c.Day_Type
JOIN Dim_Management m ON r.Management_Action = m.Management_Action
JOIN Dim_Site_Profile sp ON r.Region = sp.Region AND r.Heritage_Type = sp.Heritage_Type AND r.Heritage_Level = sp.Heritage_Level;
GO


-- Make Record_ID the Primary Key of the Fact table
ALTER TABLE Fact_Site_Operations 
ALTER COLUMN Record_ID INT NOT NULL;

ALTER TABLE Fact_Site_Operations 
ADD PRIMARY KEY (Record_ID);

-- Standardize the data type in the Fact table 
ALTER TABLE Fact_Site_Operations 
ALTER COLUMN Heritage_Site_ID VARCHAR(50);


-- Apply the Foreign Key constraints to wire up the Star Schema
ALTER TABLE Fact_Site_Operations
ADD CONSTRAINT FK_Fact_SiteProfile
FOREIGN KEY (Site_Profile_ID) REFERENCES Dim_Site_Profile(Site_Profile_ID);

ALTER TABLE Fact_Site_Operations
ADD CONSTRAINT FK_Fact_Calendar
FOREIGN KEY (Calendar_ID) REFERENCES Dim_Calendar(Calendar_ID);

ALTER TABLE Fact_Site_Operations
ADD CONSTRAINT FK_Fact_Management
FOREIGN KEY (Management_ID) REFERENCES Dim_Management(Management_ID);
GO


-- Data Validation Block
-- My final check to ensure the joins didn't drop or duplicate any rows.

SELECT COUNT(*) AS Raw_Row_Count FROM Tourism_Sites_raw;
SELECT COUNT(*) AS Fact_Row_Count FROM Fact_Site_Operations;
-- Match exactly (15,000) rows. ✔️

-- Confirm all tables are ready for Power BI Import
SELECT TOP 10 * FROM Dim_Site_Profile;
SELECT TOP 10 * FROM Dim_Calendar;
SELECT TOP 10 * FROM Dim_Management;
SELECT TOP 10 * FROM Fact_Site_Operations;
GO