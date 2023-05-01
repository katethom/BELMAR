--################################ LOAD AND POPULATE LOOKUPS ##########################

USE BELMAR

-- create lookup tables

create table account_lookup(
id  nvarchar(18), 
sourceid  nvarchar(255)
)


drop table if exists account_load

select 
cast(id as nvarchar(18)) as id
,sourceid
,name
,createddate
,active__c
,billingstreet
,phone
into account_load from account_mapped where sourceid not in (select sourceid from account_lookup where id is not null)


-- LOAD
select * from account_load_result where sourceid = 
 
exec SF_TableLoader 'insert', 'BELMAR', 'Account_load'

insert into account_lookup select id, sourceid from account_load_result where error = 'Operation Successful.' and id is not null
 
select * from account_lookup

--update account with billing street

select l.id, a.billingaddress as billingstreet into account_update from account_insert a left join account_lookup l on a.sourceid = l.sourceid

exec SF_TableLoader 'update', 'BELMAR', 'Account_update'

