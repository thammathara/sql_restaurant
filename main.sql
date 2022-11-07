--dim customers (1)
CREATE TABLE dim_customers(
  customers_id int Primary Key,
  firstname text,
  lastname text,
  gender text,
  age int
);
INSERT INTO dim_customers VALUES
  (1, "Daeng", "Guitar", "Male", 72),
  (2, "Suay", "Pimalee", "Female", 24),
  (3, "Mary", "Mairoo", "Female", 32),
  (4, "Jane", "Yourly", "Female", 42);

--dim segment (2)
CREATE TABLE dim_segment(
  segment_id int Primary Key,
  segment_type text
);
INSERT INTO dim_segment VALUES
 (1, 'Loyalty'),
 (2, 'Occasion'),
 (3, 'First Time');

--dim payment method (3)
CREATE TABLE dim_payment_method(
  payment_method_id int Primary Key,
  payment_method_type text
);
INSERT INTO dim_payment_method VALUES
 (1, 'Cash'),
 (2, 'Mobile payments'),
 (3, 'Credit card');

--dim chef (4)
CREATE TABLE dim_chef(
  chef_id int Primary Key,
  chef_Fullname text
);
INSERT INTO dim_chef VALUES
 (1, 'Aroi Tongngai'),
 (2, 'Mai Aroiley');

--fact table (5)
CREATE TABLE fact_orders (
    order_id INT Primary Key,
    order_date date,
  customers_id int,
  segment_id int,
  payment_method_id int,
  chef_id int,
    amount REAL,
  FOREIGN KEY (customers_id) REFERENCES dim_customers(customers_id),
  FOREIGN KEY (segment_id) REFERENCES dim_segment(segment_id),
  FOREIGN KEY (payment_method_id) REFERENCES dim_payment_method (payment_method_id),
  FOREIGN KEY (chef_id) REFERENCES dim_chef(chef_id)
  );

INSERT INTO fact_orders VALUES 
(1, '2022-08-01',1,2,2,1, 200),
(2, '2022-08-02',3,1,3,1, 250),
(3, '2022-08-02',1,2,2,2, 450),
(4, '2022-08-03',4,1,1,2, 350),
(5, '2022-08-04',2,3,1,1, 300);


.mode markdown
.header on 

-- Top three spenders and their customer segment  (1)
SELECT 
  c.customers_id,
  c.firstname||' '||c.lastname as fullname,
  c.age,
  s.segment_type,
  sum(f.amount) as total_invoice
  FROM 
  fact_orders as f
  join dim_customers as c
  on f.customers_id=c.customers_id
  join dim_segment as s
  on f.segment_id=s.segment_id
  GROUP by 1,2,3
ORDER by 5 DESC
  limit 3;

--which day make the most money (2)
SELECT 
order_date,
 sum(amount) as total_revenue
from fact_orders
group by 1
order by 2 desc;

--What is the most popular payment method (3)
select 
p.payment_method_id,
  p.payment_method_type,
  count(f.payment_method_id) as num_of_usage_on_payment_method
from
fact_orders as f
join dim_payment_method as p
on f.payment_method_id=p.payment_method_id
group by 1,2
order by 3 desc;

--Which chef generates the most revenue (4)
select
c.chef_id,
  c.chef_Fullname,
  sum(f.amount) as total_revenue
from
fact_orders as f
join dim_chef as c
on f.chef_id=c.chef_id
group by 1,2
order by 3 desc;

-- Which gender pays the most and how much money is spent on average on each gender in our restaurants (5)
With sub AS (
  select
c.gender,
f.amount
  from
fact_orders as f
  join dim_customers as c
  on f.customers_id=c.customers_id
  )
  select
  gender,
  sum(amount) as total_spending,
  avg(amount) as avg_spending
  from sub
  group by 1
order by 2 desc;