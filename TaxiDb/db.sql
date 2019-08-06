create schema [data];
go
create schema [stage];
go

-- STAGE
create table stage.dim_payment_type
(
	payment_type_id int null,
	abbreviation varchar(50) null,
	description varchar(50) null,
	date_start datetime2 null,
	date_end datetime2 null,
	date_created datetime2 null
);
go

alter table stage.dim_payment_type add constraint [DF_stage_dim_payment_type_date_created] default (getutcdate()) for [date_created];
go

create table stage.dim_rate_code
(
	rate_code_id int null,
	description varchar(50) null,
	date_start datetime2 null,
	date_end datetime2 null,
	date_created datetime2 null
);
go

alter table stage.dim_rate_code add constraint [DF_stage_dim_rate_code_date_created] default (getutcdate()) for [date_created];
go

create table stage.dim_taxi_zone
(
	location_id int null,
	borough varchar(50) null,
	zone varchar(50) null,
	service_zone varchar(50) null,
	date_start datetime2 null,
	date_end datetime2 null,
	date_created datetime2 null
);
go

alter table stage.dim_taxi_zone add constraint [DF_stage_dim_taxi_zone_date_created] default (getutcdate()) for [date_created];
go

create table stage.dim_trip_month
(
	trip_month_id int null,
	trip_month varchar(50) null,
	month_name_short varchar(50) null,
	month_name_full varchar(50) null,
	date_start datetime2 null,
	date_end datetime2 null,
	date_created datetime2 null
);
go

alter table stage.dim_trip_month add constraint [DF_stage_dim_trip_month_date_created] default (getutcdate()) for [date_created];
go

create table stage.dim_trip_type
(
	trip_type_id int null,
	description varchar(50) null,
	date_start datetime2 null,
	date_end datetime2 null,
	date_created datetime2 null
);
go

alter table stage.dim_trip_type add constraint [DF_stage_dim_trip_type_date_created] default (getutcdate()) for [date_created];
go

create table stage.dim_vendor
(
	vendor_id int null,
	abbreviation varchar(50) null,
	description varchar(50) null,
	date_start datetime2 null,
	date_end datetime2 null,
	date_created datetime2 null
);
go

alter table stage.dim_vendor add constraint [DF_stage_dim_vendor_date_created] default (getutcdate()) for [date_created];
go


-- DATA
create table data.dim_payment_type
(
	payment_type_id int null,
	abbreviation varchar(50) null,
	description varchar(50) null,
	date_start datetime2 null,
	date_end datetime2 null,
	date_created datetime2 null
);
go

alter table data.dim_payment_type add constraint [DF_data_dim_payment_type_date_created] default (getutcdate()) for [date_created];
go

create index ix_payment_type_id
on data.dim_payment_type 
(
	payment_type_id
);
go

create index ix_v
on data.dim_payment_type 
(
	payment_type_id,
	abbreviation,
	description
);
go


create table data.dim_rate_code
(
	rate_code_id int null,
	description varchar(50) null,
	date_start datetime2 null,
	date_end datetime2 null,
	date_created datetime2 null
);
go

alter table data.dim_rate_code add constraint [DF_data_dim_rate_code_date_created] default (getutcdate()) for [date_created];
go

create index ix_rate_code_id
on data.dim_rate_code 
(
	rate_code_id
);
go

create index ix_v
on data.dim_rate_code 
(
	rate_code_id,
	description
);
go


create table data.dim_taxi_zone
(
	location_id int null,
	borough varchar(50) null,
	zone varchar(50) null,
	service_zone varchar(50) null,
	date_start datetime2 null,
	date_end datetime2 null,
	date_created datetime2 null
);
go

alter table data.dim_taxi_zone add constraint [DF_data_dim_taxi_zone_date_created] default (getutcdate()) for [date_created];
go

create index ix_location_id
on data.dim_taxi_zone 
(
	location_id
);
go

create index ix_v
on data.dim_taxi_zone 
(
	location_id,
	borough,
	service_zone,
	zone
);
go


create table data.dim_trip_month
(
	trip_month_id int null,
	trip_month varchar(50) null,
	month_name_short varchar(50) null,
	month_name_full varchar(50) null,
	date_start datetime2 null,
	date_end datetime2 null,
	date_created datetime2 null
);
go

alter table data.dim_trip_month add constraint [DF_data_dim_trip_month_date_created] default (getutcdate()) for [date_created];
go

create index ix_trip_month_id
on data.dim_trip_month 
(
	trip_month_id
);
go

create index ix_v
on data.dim_trip_month 
(
	trip_month_id,
	trip_month,
	month_name_short,
	month_name_full
);
go



create table data.dim_trip_type
(
	trip_type_id int null,
	description varchar(50) null,
	date_start datetime2 null,
	date_end datetime2 null,
	date_created datetime2 null
);
go

alter table data.dim_trip_type add constraint [DF_data_dim_trip_type_date_created] default (getutcdate()) for [date_created];
go

create index ix_trip_type_id
on data.dim_trip_type 
(
	trip_type_id
);
go

create index ix_v
on data.dim_trip_type 
(
	trip_type_id,
	description
);
go


create table data.dim_vendor
(
	vendor_id int null,
	abbreviation varchar(50) null,
	description varchar(50) null,
	date_start datetime2 null,
	date_end datetime2 null,
	date_created datetime2 null
);
go

alter table data.dim_vendor add constraint [DF_data_dim_vendor_date_created] default (getutcdate()) for [date_created];
go

create index ix_vendor_id
on data.dim_vendor 
(
	vendor_id
);
go

create index ix_v
on data.dim_vendor 
(
	vendor_id,
	abbreviation,
	description
);
go



create table data.fact_trips_all
(
	trip_guid uniqueidentifier default newsequentialid() not null,
	trip_type int null,
	trip_year varchar(4) null,
	trip_month varchar(2) null,
	taxi_type varchar(100) null,
	vendor_id int null,
	pickup_datetime datetime null,
	dropoff_datetime datetime null,
	passenger_count int null,
	trip_distance float null,
	rate_code_id int null,
	store_and_fwd_flag varchar(100) null,
	pickup_location_id int null,
	dropoff_location_id int null,
	pickup_longitude varchar(100) null,
	pickup_latitude varchar(100) null,
	dropoff_longitude varchar(100) null,
	dropoff_latitude varchar(100) null,
	payment_type int null,
	fare_amount float null,
	extra float null,
	mta_tax float null,
	tip_amount float null,
	tolls_amount float null,
	improvement_surcharge float null,
	ehail_fee float null,
	total_amount float null,
	date_created datetime2 null,
	date_updated datetime2 null
);
go

alter table data.fact_trips_all add constraint [DF_data_fact_trips_all_date_created] default (getutcdate()) for [date_created];
alter table data.fact_trips_all add constraint [DF_data_fact_trips_all_date_updated] default (getutcdate()) for [date_updated];
go

create unique index ix_trip_guid
on data.fact_trips_all 
(
	trip_guid
);
go

create index ix_trip_year_trip_month
on data.fact_trips_all 
(
	trip_year, trip_month
);
go

create index ix_v
on data.fact_trips_all 
(
	date_updated
)
include
(
	trip_guid,
	trip_type,
	trip_year,
	trip_month,
	taxi_type,
	vendor_id,
	pickup_datetime,
	dropoff_datetime,
	passenger_count,
	trip_distance,
	rate_code_id,
	store_and_fwd_flag,
	pickup_location_id,
	dropoff_location_id,
	pickup_longitude,
	pickup_latitude,
	dropoff_longitude,
	dropoff_latitude,
	payment_type,
	fare_amount,
	extra,
	mta_tax,
	tip_amount,
	tolls_amount,
	improvement_surcharge,
	ehail_fee,
	total_amount,
	date_created
)
;
go



create table data.fact_trips_new
(
	trip_guid uniqueidentifier default newsequentialid() not null,
	trip_type int null,
	trip_year varchar(4) null,
	trip_month varchar(2) null,
	taxi_type varchar(100) null,
	vendor_id int null,
	pickup_datetime datetime null,
	dropoff_datetime datetime null,
	passenger_count int null,
	trip_distance float null,
	rate_code_id int null,
	store_and_fwd_flag varchar(100) null,
	pickup_location_id int null,
	dropoff_location_id int null,
	pickup_longitude varchar(100) null,
	pickup_latitude varchar(100) null,
	dropoff_longitude varchar(100) null,
	dropoff_latitude varchar(100) null,
	payment_type int null,
	fare_amount float null,
	extra float null,
	mta_tax float null,
	tip_amount float null,
	tolls_amount float null,
	improvement_surcharge float null,
	ehail_fee float null,
	total_amount float null,
	textanalytics_customer_sentiment_score float null,
	customer_comments nvarchar(max) null,
	date_created datetime2 null,
	date_updated datetime2 null
);
go

alter table data.fact_trips_new add constraint [DF_data_fact_trips_new_date_created] default (getutcdate()) for [date_created];
alter table data.fact_trips_new add constraint [DF_data_fact_trips_new_date_updated] default (getutcdate()) for [date_updated];
go

create unique index ix_trip_guid
on data.fact_trips_new 
(
	trip_guid
);
go

create index ix_trip_year_trip_month
on data.fact_trips_new 
(
	trip_year, trip_month
);
go

create index ix_date_updated
on data.fact_trips_new 
(
	date_updated
);
go

create index ix_v
on data.fact_trips_new
(
	date_updated
)
include
(
	trip_guid,
	trip_type,
	trip_year,
	trip_month,
	taxi_type,
	vendor_id,
	pickup_datetime,
	dropoff_datetime,
	passenger_count,
	trip_distance,
	rate_code_id,
	store_and_fwd_flag,
	pickup_location_id,
	dropoff_location_id,
	pickup_longitude,
	pickup_latitude,
	dropoff_longitude,
	dropoff_latitude,
	payment_type,
	fare_amount,
	extra,
	mta_tax,
	tip_amount,
	tolls_amount,
	improvement_surcharge,
	ehail_fee,
	total_amount,
	date_created
)
;
go



create view data.v_trips as
select
	t.trip_guid,
	t.trip_type,
	t.trip_year,
	t.trip_month,
	t.taxi_type,
	t.vendor_id,
	t.pickup_datetime,
	t.dropoff_datetime,
	t.passenger_count,
	t.trip_distance,
	t.rate_code_id,
	t.store_and_fwd_flag,
	t.pickup_location_id,
	t.dropoff_location_id,
	t.pickup_longitude,
	t.pickup_latitude,
	t.dropoff_longitude,
	t.dropoff_latitude,
	t.payment_type,
	t.fare_amount,
	t.extra,
	t.mta_tax,
	t.tip_amount,
	t.tolls_amount,
	t.improvement_surcharge,
	t.ehail_fee,
	t.total_amount,
	textanalytics_customer_sentiment_score = null,
	customer_comments = null,
	t.date_created,
	t.date_updated,
	pt.abbreviation as payment_type_abbreviation,
	pt.description as payment_type_description,
	rc.description as rate_code_description,
	tzpu.borough as pickup_borough,
	tzpu.service_zone as pickup_service_zone,
	tzpu.zone as pickup_zone,
	tzdo.borough as dropoff_borough,
	tzdo.service_zone as dropoff_service_zone,
	tzdo.zone as dropoff_zone,
	tt.description as trip_type_description,
	v.description as vendor_description,
	v.abbreviation as vendor_abbreviation
from
	data.fact_trips_all t
	left outer join data.dim_payment_type pt on t.payment_type = pt.payment_type_id
	left outer join data.dim_rate_code rc on t.rate_code_id = rc.rate_code_id
	left outer join data.dim_taxi_zone tzpu on t.pickup_location_id = tzpu.location_id
	left outer join data.dim_taxi_zone tzdo on t.dropoff_location_id = tzdo.location_id
	left outer join data.dim_trip_type tt on t.trip_type = tt.trip_type_id
	left outer join data.dim_vendor v on t.vendor_id = v.vendor_id
union all
select
	t.trip_guid,
	t.trip_type,
	t.trip_year,
	t.trip_month,
	t.taxi_type,
	t.vendor_id,
	t.pickup_datetime,
	t.dropoff_datetime,
	t.passenger_count,
	t.trip_distance,
	t.rate_code_id,
	t.store_and_fwd_flag,
	t.pickup_location_id,
	t.dropoff_location_id,
	t.pickup_longitude,
	t.pickup_latitude,
	t.dropoff_longitude,
	t.dropoff_latitude,
	t.payment_type,
	t.fare_amount,
	t.extra,
	t.mta_tax,
	t.tip_amount,
	t.tolls_amount,
	t.improvement_surcharge,
	t.ehail_fee,
	t.total_amount,
	t.textanalytics_customer_sentiment_score,
	t.customer_comments,
	t.date_created,
	t.date_updated,
	pt.abbreviation as payment_type_abbreviation,
	pt.description as payment_type_description,
	rc.description as rate_code_description,
	tzpu.borough as pickup_borough,
	tzpu.service_zone as pickup_service_zone,
	tzpu.zone as pickup_zone,
	tzdo.borough as dropoff_borough,
	tzdo.service_zone as dropoff_service_zone,
	tzdo.zone as dropoff_zone,
	tt.description as trip_type_description,
	v.description as vendor_description,
	v.abbreviation as vendor_abbreviation
from
	data.fact_trips_new t
	left outer join data.dim_payment_type pt on t.payment_type = pt.payment_type_id
	left outer join data.dim_rate_code rc on t.rate_code_id = rc.rate_code_id
	left outer join data.dim_taxi_zone tzpu on t.pickup_location_id = tzpu.location_id
	left outer join data.dim_taxi_zone tzdo on t.dropoff_location_id = tzdo.location_id
	left outer join data.dim_trip_type tt on t.trip_type = tt.trip_type_id
	left outer join data.dim_vendor v on t.vendor_id = v.vendor_id
;
go

