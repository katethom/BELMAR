--################################ LOAD AND POPULATE LOOKUPS ##########################

USE BELMAR

-- create lookup tables

if object_id(N'dbo.account_lookup', N'U') is null
create table account_lookup(
id  nvarchar(18), 
sourceid  nvarchar(255)
)


drop table if exists account_pre_load

select 
cast(l.id as nvarchar(18)) as id
,m.sourceid
,m.name
,m.createddate
,m.active__c
,m.billingaddress
,m.phone
into account_pre_load from account_mapped m left join account_lookup l on m.sourceid = l.sourceid

-- LOAD

drop table if exists account_load
 
select * into account_load from account_pre_load where id is null

exec SF_TableLoader 'insert', 'BELMAR', 'Account_load'

insert into account_lookup select id, sourceid from account_load_result where error = 'Operation Successful.' and id is not null
 
select count(sourceid) as'count of records', error from Account_load_Result group by error

--update account 

drop table if exists account_update

select * into account_update from account_load where id is not null

exec SF_TableLoader 'update', 'BELMAR', 'Account_update'

select count(sourceid) as 'count of records', error from Account_update_Result group by error

