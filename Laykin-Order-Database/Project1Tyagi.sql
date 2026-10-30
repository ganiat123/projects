-- 10/29/2026
-- Project 1 
-- Gania Tyagi 

-- I imported the data and created the schema in another table
-- I will now create the new tables and create my relational schemas here 
use LaykinOrderTyagi;

-- creating tables 
CREATE TABLE company (
companyid int auto_increment,
companyname varchar(100) not null,
sector varchar(50),
industry varchar(80),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
Primary Key (companyid)
);
CREATE TABLE product (
productid int auto_increment,
product varchar(80) not null,
productcategory varchar(45) not null,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
Primary Key (productid)
);
CREATE TABLE consultant (
consultantid int auto_increment,
consultant varchar(80) not null,
hourlywage int not null,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
Primary Key (consultantid)
);
CREATE TABLE location (
stateid int auto_increment,
state varchar(45) not null,
region varchar(45) not null,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
Primary Key (stateid)
);
CREATE TABLE orders (
orderid int,
orderdate date not null,
customername varchar(80) not null,
companyname varchar(100) not null,
companyid int not null,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
Primary Key (orderid)
);
CREATE TABLE orderline (
rowid int,
orderid int not null,
quantity int not null, 
quote int, 
discountpct double, 
rate int,
saleamount double,
productsubcategory varchar(45), 
wagemargin double,
manager varchar(60),
city varchar(60),
zipcode varchar(60),
productid int not null, 
consultantid int not null,
stateid int not null, 
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
Primary Key (rowid)
);

-- company insertion
insert into company (companyname,sector, industry) 
select DISTINCT companyname, sector, industry 
from orderdetails;

-- product insertion
insert into product (product, productcategory)
select distinct product, productcategory
from orderdetails;

-- consultant insertion 
insert into consultant (consultant, hourlywage)
select distinct consultant, hourlywage
from orderdetails;

-- location insertion
insert into location(state, region)
select distinct state, region
from orderdetails; 

-- need to change orderdate from date format to string version 
alter table orders
modify orderdate varchar(20) not null; 


-- orders insertion 
insert into orders (orderid, orderdate, customername, companyname, companyid)
select distinct orderid, orderdate, customername, companyname, 
(select companyid from company where company.companyname = orderdetails.companyname) 
from orderdetails;

-- orderline insertion
insert into orderline (rowid, orderid, quantity, quote, discountpct, rate, saleamount,
productsubcategory, wagemargin, manager, city, zipcode, productid, consultantid, stateid)
select rowid, orderid, quantity, quote, discountpct, rate, saleamount, productsubcategory, 
wagemargin, manager, city, zipcode,
(select productid from product where product.product = orderdetails.product),
(select consultantid from consultant where consultant.consultant = orderdetails.consultant),
(select stateid from location where location.state = orderdetails.state)
from orderdetails;

-- adding foreign keys: 
Alter table orders 
add constraint orders_company_fk Foreign key (companyid)
references company (companyid);

Alter table orderline
add constraint orderline_orders_fk Foreign key (orderid)
references orders (orderid);

Alter table orderline
add constraint orderline_product_fk Foreign key (productid)
references product (productid);

Alter table orderline
add constraint orderline_consultant_fk Foreign key (consultantid)
references consultant (consultantid);

Alter table orderline
add constraint orderline_location_fk Foreign key (stateid)
references location (stateid);


-- Questions
/* Q1: List the top company with their company name in terms of sales. 
-- Validate your code by  creating a pivot table in Excel. 
-- Show screenshots of the code, code results, and pivot table below. */
Select c.companyname, SUM(ol.saleamount) as totalsales
from orderline ol
join orders o on ol.orderid = o.orderid
join company c on o.companyid = c.companyid 
group by c.companyid, c.companyname
order by totalsales desc
limit 1; 

-- Q2 Which sector has the lowest sales?
Select c.sector, SUM(ol.saleamount) as totalsales
from orderline ol
join orders o on ol.orderid = o.orderid
join company c on o.companyid = c.companyid 
group by c.sector
order by totalsales
limit 1; 

-- Q3 Show the total sales by manager, with the highest ones showing first. 
Select manager, sum(saleamount) as TotalSales 
from orderline 
group by manager
order by totalsales desc;

-- Q4 Who are the ten best consultants in terms of sales? Show the hourly wage for each.
Select c.consultant, c.hourlywage, sum(ol.saleamount) as TotalSales
from orderline ol
join consultant c on ol.consultantid = c.consultantid
group by c.consultantid, c.consultant, c.hourlywage 
order by TotalSales desc 
limit 10;

-- Q5 Who are the customers with ordered products where the work is done 
-- to states with state names end in ee? Use REGEXP to filter the data.
Select distinct o.customername, p.product, l.state
from orderline ol
join orders o on ol.orderid = o.orderid
join product p on ol.productid = p.productid
join location l on ol.stateid = l.stateid
where l.state REGEXP 'ee$'
order by o.customername;

-- Q6 which orders that had a quantity of 40 or more were sold and by which consultant
select ol.orderid, p.product, c.consultant, ol.quantity
from orderline ol
join product p on ol.productid = p.productid
join consultant c on ol.consultantid = c.consultantid
where ol.quantity >= 40
order by ol.quantity desc;

-- Q7 what are the total sales by region
select l.region, sum(ol.saleamount) as TotalSales
from orderline ol
join location l on ol.stateid = l.stateid
group by l.region
order by totalsales desc;

-- Q8 which orderlines had a saleamount above the average
select rowid, orderid, saleamount
from orderline
where saleamount > (Select avg(saleamount) from orderline ) 
order by saleamount desc;

-- Q9 which products are training products
Select product, productcategory
from product 
where product like 'training%'
order by product; 

-- Q10 Order Summary View 
create view ordersummary as 
Select o.orderid, o.orderdate, c.companyname, o.customername, 
Count(ol.rowid) as numberoflines, sum(ol.saleamount) as ordertotal
from orders o
join company c on o.companyid = c.companyid
join orderline ol on o.orderid = ol.orderid
group by o.orderid, o.orderdate, c.companyname, o.customername;

select * from ordersummary 
order by ordertotal desc; 
 