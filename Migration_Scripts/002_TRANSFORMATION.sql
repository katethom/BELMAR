--################################ TRANSFORMATIONS AND WRANGLING ############################

USE BELMAR

-- SAMPlE DATA

select c.*, cd.* from clients c left join contactdetails cd on c.id = cd.clientid

select count(id), contacttype from clients group by contacttype

select * from clients

select count(contactvalue), contacttype from contactdetails group by contacttype


-- CLEAN UP CLIENT DATA: fix dates, split out address field from name, remove those which have date year 1000

drop table if exists clients_clean

select * into clients_clean from (
select id as sourceid, contacttype, status, CONVERT(varchar, cast(assignmentdate as date), 23) as assignmentdate, assignmentdate as assignmentdate_src, 
null as id, name as name,
 --LEFT(name, CHARINDEX('(', name) - 1) AS name,
 SUBSTRING(name, CHARINDEX('(', name) + 1, CHARINDEX(')', name) - CHARINDEX('(', name) - 1) AS address
from clients where name like '%(%' 
union
select id as sourceid, contacttype, status, CONVERT(varchar, cast(assignmentdate as date), 23) as assignmentdate, 
assignmentdate as assignmentdate_src, 
null as id,  name as name, null as address
from clients where name not like '%(%' and AssignmentDate not like '%-%'
union
select id as sourceid, contacttype, status, assignmentdate as assignmentdate, 
assignmentdate as assignmentdate_src,
null as id,  name as name, null as address
from clients where name not like '%(%' and AssignmentDate like '%-%' and assignmentdate not like '%1000%'
) as clients_clean

--select * from clients_clean

-- CLEAN UP CONTACT DETAILS DATA: transpose data to create different contact detail types as columns instead of rows and split out accounts and contacts into separate
--								  tables, add inactive field, split first and last name on contacts

select * into contact_details_clean from(
select null as accountid, clientid as clientid_src, contactvalue as workemail, null as workphone, null as email, null as workphone2, null as homephone from contactdetails where contacttype = 'Work Email'
union
select null as accountid, clientid as clientid_src, null as workemail, contactvalue as workphone, null as email, null as workphone2, null as homephone from contactdetails where contacttype = 'Work Phone'
union
select null as accountid, clientid as clientid_src, null as workemail, null as workphone, contactvalue as email, null as workphone2, null as homephone from contactdetails where contacttype = 'Email'
union
select null as accountid, clientid as clientid_src, null as workemail, null as workphone, null as email, contactvalue as workphone2, null as homephone from contactdetails where contacttype = 'Work Phone2'
union
select null as accountid, clientid as clientid_src, null as workemail, null as workphone, null as email, null as workphone2, contactvalue as homephone from contactdetails where contacttype = 'Home Phone'
) as contact_details_clean

select count(distinct clientid_src) from contact_details_clean

select accountid, clientid_src, max(workemail) as workemail, max(workphone) as workphone, max(email) as email,max(workphone2) as workphone2, max(homephone) as homephone
into contact_details_flat
from contact_details_clean group by clientid_src, accountid

select * from contact_details_flat

drop table if exists business_with_details

select c.sourceid, c.contacttype, c.status, c.assignmentdate, c.assignmentdate_src, c.id, c.name, c.address, d.clientid_src, d.workemail, d.workphone, d.email,
d.workphone2, d.homephone ,
case 
when c.name like '%inactive%' then  0
else  1
end as active
into business_with_details
from clients_clean c left join contact_details_flat d on c.sourceid = d.clientid_src

drop table if exists business_clients

select * into business_clients from business_with_details where contacttype = 'Business'

drop table if exists individual_clients

select *, 
LEFT(name, CHARINDEX(' ', name) - 1) AS firstname,
 SUBSTRING(name, CHARINDEX(' ', name) + 1, CHARINDEX('.', name+'.') - CHARINDEX(' ', name) - 1) AS lastname
into individual_clients 
from business_with_details where contacttype = 'Individual'

select * from individual_clients

-- REMOVE DIRTY 1463 DATA
update business_clients set workphone = null where sourceid = '1463'
update business_clients set homephone = null where sourceid = '1463'
update business_clients set workphone2 = null where sourceid = '1463'
update business_clients set email = null where sourceid = '1463'
