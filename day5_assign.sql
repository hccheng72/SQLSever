-- Part 1
-- 1
--- An object is any SQL Server resource. SQL objects are schemas, journals, catalogs, tables, aliases, views, indexes, constraints, 
--- triggers, sequences, stored procedures, user-defined functions, user-defined types, global variables, and SQL packages. SQL creates 
--- and maintains these objects as system objects.
-- 2
--- An index is an on-disk structure associated with a table or view that speeds retrieval of rows from the table or view.
--- Index enables SQL Server to find the row or rows associated with the key values quickly and efficiently. On the contrary, 
--- it decreases performance when finding data with non-index columns and occupies more memory space.
-- 3
--- Clustered index: data in a table are sorted by it. There can ba only one clustered index per table.
--- Nonclustered index: there can be more than one per table. Data rows are not sorted.
--- https://docs.microsoft.com/en-us/sql/relational-databases/indexes/clustered-and-nonclustered-indexes-described?view=sql-server-ver15
-- 4
--- No, but the clustered and nonclustered index will be created automatically with primary key and foreign key respectively.
-- 5
--- No, There can ba only one clustered index per table. Data only can be sorted based on a single index.
-- 6
--- Index can be created on multiple columns and the order of columns matters. The most likely column that would be used as specified 
--- column when finding data should be put as leftmost as possible.
-- 7
--- Yes, the first index created on a view must be a unique clustered index. After the unique clustered index has been created, 
--- you can create more nonclustered indexes. 
--- https://docs.microsoft.com/en-us/sql/relational-databases/views/create-indexed-views?view=sql-server-ver15
-- 8
--- Normalization is a process used to organize a database into tables and columns.
--- First Normal Form: There are no repeating groups of columns.
--- Second Normal Form: Above form is applied and all the columns depend on the table’s primary key.
--- Third Normal Form: Above form is applied and all of its columns are not transitively dependent on the primary key.
--- https://www.essentialsql.com/database-normalization/
-- 9
--- Denormalization is a database optimization technique in which we add redundant data to one or more tables to avoid costly joins.
--- https://www.geeksforgeeks.org/denormalization-in-databases/
-- 10
--- Using foreign key that references to a primary key in another table, or CHECK constraint on a column to make sure the data in a row
--- satisfying some business rules.
-- 11
--- primary key, foreign key, null, not null, unique, check, default
-- 12
--- A table only has one primary key, but can have multiple columns with unique constraint. Primary key doesn't accept null value while 
--- unique key does. By default, primary key will create clustered index while unique key will create nonclustered index.
-- 13
--- Foreign Key is a column or combination of columns that is used to establish and enforce a link between the data in two tables. 
--- It has to connect with a column of unique constraint in another table.
-- 14
--- Yes, a table can have multiple foreign keys.
-- 15
--- Foreign Key has to be unique and accepts null value since it refers to a column of unique constraint.
-- 16
--- SQL temp tables support adding clustered and non-clustered indexes after the SQL Server temp table creation and implicitly by 
--- defining Primary key constraint or Unique Key constraint during the tables creation, but table variables support only adding such 
--- indexes implicitly by defining Primary key constraint or Unique key constraint during tables creation.
--- https://www.sqlshack.com/indexing-sql-server-temporary-tables/

-- 17
--- Transaction is a single recoverable unit of SQL statements. 
--- Types of transaction level include read uncommitted, read committed, repeated read, serializable, and snapshot.

-- Part 2
-- 1
Create table customers (cust_id int primary key, cname varchar (50)); 
create table orders (order_id int primary key, cust_id int foreign key references customers(cust_id), 
	amount money, order_date smalldatetime);
create index non_clustered_order_date on orders(order_date);

with orders_2002
as (  
select o.cust_id, o.amount
from orders o
where year(order_date) = 2002) --set index to date

select c.cname, dt.totalAmount
from (select sum(o2.amount) "totalAmount", o2.cust_id
	from orders_2002 o2
	group by o2.cust_id) dt
left join customers c on dt.cust_id = c.cust_id;
-- 2
Create table person (id int, firstname varchar(100), lastname varchar(100));
create index non_clustered_lastname_person on person(lastname);

select lastname
from person
where lastname like 'A%';
-- 3
Create table persons (person_id int primary key, manager_id int null, name varchar(100)not null);
with manager (person_id, name, manager_id)
as (
	select p.person_id, p.name, p.manager_id from persons p where manager_id is null
	UNION ALL
	select p.person_id, p.name, p.manager_id from persons p
	inner join manager m on p.manager_id = m.person_id)
select count(person_id)
from manager
group by manager_id;
-- 4
-- DML operations, DDL operations, LOGON events. Logon triggers fire after 
-- the authentication phase of logging in finishes, but before the user session is established
-- 5
create table Companies (c_id int primary key, c_name varchar(10))
create table Divisions (d_id int primary key, d_name varchar(10), l_id int foreign key references Locations(l_id))
create table Contacts ( window_id int primary key, name varchar(10), suite varchar(10), mail_address varchar(20), zipcode varchar(5))
create table Locations (l_id int primary key, physical_address varchar(20), zipCode varchar(5))
create table CompanyDivision (c_id int foreign key references Companies(c_id), 
							  d_id int foreign key references Divisions(d_id),
							  window_id int foreign key references Contacts(window_id))