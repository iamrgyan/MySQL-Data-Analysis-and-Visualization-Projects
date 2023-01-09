create database project;
show databases;
use project;

-- import csv file amazon sales report
-- https://www.kaggle.com/datasets/thedevastator/unlock-profits-with-e-commerce-sales-data
-- csv file trimmed to get it upload on MySQL workbench

show tables;
select * from amazon;
desc amazon;

# 1. Data Cleaning

-- Alter column name as per SQL standard.
-- Change the database type for required columns

alter table amazon
change column `S No` s_no int not null;
select * from amazon;

alter table amazon
change column `sales channel` sales_channel varchar(30),
change column `courier status` courier_status varchar(30),
change column `ship-city` ship_city varchar(50),
change column `ship-state` ship_state varchar(50),
change column `ship-postal-code` ship_postal_code int,
change column `ship-country` ship_country varchar(5),
drop column `promotion-ids`,
drop column b2b,
drop column `fulfilled-by`,
drop column `unnamed: 22`;

alter table amazon
change column `status` order_status varchar(50),
modify fulfilment varchar(30),
change column `ship-service-level` ship_service_level varchar(30),
modify style varchar(30),
modify sku varchar(50),
modify category varchar(50),
modify size varchar(5),
drop column asin,
modify currency varchar(5);

update amazon
set report_date = '2022-04-30';

alter table amazon
modify report_date date;

select * from amazon;
desc amazon;

# 1.1 Find Duplicate Values and assign a sequence as sl_no (row number)

select count(order_id) from amazon;
	-- result - 96
select count(s_no) from amazon;
	-- result - 96
select count(distinct order_id) from amazon;
	-- result 92
select count(distinct s_no) from amazon;
	-- result - 96

# It's clear order_id has duplicate values in the column.
## Identify the duplicate values presence in the record.

select order_id, s_no, count(*) from amazon
group by order_id having count(*)>1;
	-- result count is 3, there are 3 rows which have total 7 presence.

# Get the details of duplicate values

select * from amazon where order_id in ('403-4367956-2849158','404-2262140-4696366','408-4069830-3819562');
	-- result 7 rows, there are variations under the s_no, style, sku, and amount column, everthing else is duplicate.

/*As per my individual perception order_id should be unique in terms of e-commerce business
So I will remove the duplicate value,
However I will keep all the duplicate results into another table in a doubt what if my perception is wrong.
*/

# Create table for dulipcate values, and insert values into it.

desc amazon;
use project;
create table amazon_duplicate
(
s_no	int,
order_id	varchar(30),
report_date	date,
order_status	varchar(50),
fulfilment	varchar(30),
sales_channel	varchar(30),
ship_service_level	varchar(30),
style	varchar(30),
sku	varchar(50),
category	varchar(50),
size	varchar(5),
courier_status	varchar(30),
Qty	int,
currency	varchar(5),
Amount	double,
ship_city	varchar(50),
ship_state	varchar(50),
ship_postal_code	int,
ship_country	varchar(5)
);

insert into amazon_duplicate
select * from amazon where order_id in ('403-4367956-2849158','404-2262140-4696366','408-4069830-3819562');

select * from amazon_duplicate;

commit;
# Remove duplicate values from main table amazon.

delete from amazon where s_no in (38,62,80,81);

# Cross Check

select count(order_id) from amazon;
select count(s_no) from amazon;
select count(distinct order_id) from amazon;
select count(distinct s_no) from amazon;
	-- result - all 92. No Duplicate Values Found

select * from amazon;

# rearrange  the s_no as sl_no in ascending order starting from 1

alter table amazon add column serial_number int first;
alter table amazon drop column serial_number;
select *, row_number() over (order by s_no asc) as sl_no from amazon;

create table amazon_new
select *, row_number() over (order by s_no asc) as sl_no from amazon;

alter table amazon_new rename amazon;
show tables;
select * from amazon;
desc amazon;
alter table amazon drop column s_no;
alter table amazon modify sl_no int first;
alter table amazon modify column sl_no int not null unique;
alter table amazon modify column order_id varchar(30) unique;

select * from amazon;
desc amazon;