use pzadfdb;

/**
drop table [stage].[dim_payment_type];
drop table [stage].[dim_rate_code];
drop table [stage].[dim_taxi_zone];
drop table [stage].[dim_trip_month];
drop table [stage].[dim_trip_type];
drop table [stage].[dim_vendor];

drop table [data].[dim_payment_type];
drop table [data].[dim_rate_code];
drop table [data].[dim_taxi_zone];
drop table [data].[dim_trip_month];
drop table [data].[dim_trip_type];
drop table [data].[dim_vendor];

drop table [data].[fact_trips_all];
drop table [data].[fact_trips_new];

drop view [data].[v_trips];

drop schema [data];
drop schema [stage];
**/

select * from [stage].[dim_payment_type];
select * from [stage].[dim_rate_code];
select * from [stage].[dim_taxi_zone];
select * from [stage].[dim_trip_month];
select * from [stage].[dim_trip_type];
select * from [stage].[dim_vendor];

select * from [data].[dim_payment_type];
select * from [data].[dim_rate_code];
select * from [data].[dim_taxi_zone];
select * from [data].[dim_trip_month];
select * from [data].[dim_trip_type];
select * from [data].[dim_vendor];

/**
truncate table [data].[dim_payment_type];
insert into [data].[dim_payment_type] (payment_type_id, abbreviation, description) values (9999, 'foo', 'bar');
**/