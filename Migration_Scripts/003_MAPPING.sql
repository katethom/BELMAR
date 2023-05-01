--################################ MAPPING AND LOOKUPS #############################

USE BELMAR

-- ACCOUNTS
select * from business_clients

drop table if exists account_mapped

select 
cast(id as nchar(18)) as id
, sourceid
, name
, assignmentdate as createddate
, active as active__c
, address as billingaddress
--, workemail as ??
, workphone as phone
--, email as ??
--, workphone2 as phone
--, homephone as
--, status as ??
into account_mapped
from business_clients

-- CONTACTS
select * from individual_clients

drop table if exists contact_mapped

select 
id
, sourceid
, assignmentdate as createddate
, firstname as firstname
, lastname as lastname
--, email as email
--, homephone as homephone
--, workphone2 as otherphone
--, workphone as phone
into contact_mapped
from individual_clients

