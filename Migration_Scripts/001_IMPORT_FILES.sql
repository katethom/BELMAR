--################################ load data into SQL Server ############################

USE BELMAR

--create table
drop table if exists dbo.clients

CREATE TABLE clients
( Id nvarchar(255),
Name nvarchar(255),
ContactType nvarchar(255),
Status nvarchar(255),
AssignmentDate nvarchar(255)
) 

TRUNCATE TABLE dbo.clients;
GO
 
-- import the file
BULK INSERT dbo.clients
FROM 'C:\Users\k_thomson\Desktop\clients.csv'
WITH
(
        FORMAT='CSV',
        FIRSTROW=2
)
GO

--create table
drop table if exists dbo.contactdetails

CREATE TABLE contactdetails
( ClientId nvarchar(255),
ContactType nvarchar(255),
ContactValue nvarchar(255)
) 

TRUNCATE TABLE dbo.contactdetails;
GO
 
-- import the file
BULK INSERT dbo.contactdetails
FROM 'C:\Users\k_thomson\Desktop\contact_details.csv'
WITH
(
        FORMAT='CSV',
        FIRSTROW=2
)
GO

select * from contactdetails

select * from clients

