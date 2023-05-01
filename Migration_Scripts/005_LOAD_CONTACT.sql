--################################ LOAD AND POPULATE LOOKUPS ##########################

USE BELMAR

-- create lookup table

create table contact_lookup(
id  nvarchar(18), 
sourceid  nvarchar(255),
name nvarchar(255)
)


-- create load table

select 
cast(id as nvarchar(18)) as id
, sourceid
, firstname
, lastname
,createddate
into contact_load from contact_mapped where sourceid not in (select sourceid from contact_lookup where id is not null)


-- LOAD

exec SF_TableLoader 'insert', 'BELMAR', 'Contact_load'

insert into contact_lookup select id, sourceid, firstname+lastname as name from contact_load_result where error = 'Operation Successful.' and id is not null

select * from contact_lookup