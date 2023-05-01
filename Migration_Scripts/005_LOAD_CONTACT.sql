--################################ LOAD AND POPULATE LOOKUPS ##########################

USE BELMAR

-- create lookup table

if object_id(N'dbo.contact_lookup', N'U') is null
create table contact_lookup(
id  nvarchar(18), 
sourceid  nvarchar(255),
name nvarchar(255)
)


-- create load table

select 
cast(l.id as nvarchar(18)) as id
, m.sourceid
, m.firstname
, m.lastname
, m.createddate
into contact_pre_load from contact_mapped m left join contact_lookup l on m.firstname+lastname = l.name


-- LOAD
drop table if exists contact_load
 
select * into contact_load from contact_pre_load where id is null

exec SF_TableLoader 'insert', 'BELMAR', 'Contact_load'

insert into contact_lookup select id, sourceid, firstname+lastname as name from contact_load_result where error = 'Operation Successful.' and id is not null

select count(sourceid) as'count of records', error from contact_load_Result group by error

-- UPDATE

drop table if exists contact_update

select * into Contact_update from contact_load where id is not null

exec SF_TableLoader 'update', 'BELMAR', 'contact_update'

select count(sourceid) as 'count of records', error from contact_update_Result group by error

