use final_project;

#### Table Creation and Data Import ---- VERY IMPORTANT

## Customers
CREATE TABLE IF NOT EXISTS customers (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Email VARCHAR(150),
    City VARCHAR(50),
    Signup_Date DATE
);
## Import data 
LOAD DATA LOCAL INFILE 'PATH TO CSV'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Customer_ID, Customer_Name, Email, City, Signup_Date);


## Order Items
CREATE TABLE IF NOT EXISTS order_items (
    Order_Item_ID VARCHAR(20) PRIMARY KEY,
    Order_ID VARCHAR(20),
    Product_ID VARCHAR(20),
    Quantity INT,
    Original_Unit_Price DECIMAL(10,2),
    Discount_Percentage DECIMAL(5,2),
    Total_Amount DECIMAL(12,2)
);
## Import Data
LOAD DATA LOCAL INFILE 'PATH TO CSV'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_Item_ID, Order_ID, Product_ID, Quantity, Original_Unit_Price, Discount_Percentage, Total_Amount);


## Orders
CREATE TABLE orders (
    Order_ID VARCHAR(20) PRIMARY KEY,
    Customer_ID VARCHAR(20),
    Order_Date DATE,
    Order_Status VARCHAR(30)
);
## Import Data
LOAD DATA LOCAL INFILE 'PATH TO CSV'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_ID, Customer_ID, Order_Date, Order_Status);


## Payments
CREATE TABLE IF NOT EXISTS payments (
    Payment_ID VARCHAR(20) PRIMARY KEY,
    Order_ID VARCHAR(20),
    Payment_Method VARCHAR(50),
    Payment_Status VARCHAR(30)
);
## Import Data
LOAD DATA LOCAL INFILE 'PATH TO CSV'
INTO TABLE payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Payment_ID, Order_ID, Payment_Method, Payment_Status);


## Products
CREATE TABLE IF NOT EXISTS products (
    Product_ID VARCHAR(20) PRIMARY KEY,
    Product_Name VARCHAR(150),
    Category VARCHAR(50),
    Subcategory VARCHAR(50),
    Base_Price DECIMAL(10,2)
);
## Import Data
LOAD DATA LOCAL INFILE 'PATH TO CSV'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Product_ID, Product_Name, Category, Subcategory, Base_Price);


## Returns
CREATE TABLE IF NOT EXISTS returns (
    Return_ID VARCHAR(20) PRIMARY KEY,
    Order_ID VARCHAR(20),
    Return_Date DATE,
    Return_Reason VARCHAR(100),
    Refund_Status VARCHAR(30)
);
## Import Data
LOAD DATA LOCAL INFILE 'PATH TO CSV'
INTO TABLE returns
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Return_ID, Order_ID, Return_Date, Return_Reason, Refund_Status);


###################################################################################################################################################################

#### Data Cleaning and Preprocessing

#### Database Validation 
DESCRIBE customers;
DESCRIBE products;
DESCRIBE orders;
DESCRIBE order_items;
DESCRIBE payments;
DESCRIBE returns;


#### Check Duplicates

SELECT Customer_ID, COUNT(*) FROM customers GROUP BY Customer_ID HAVING COUNT(*) > 1;
SELECT order_item_id, COUNT(*) FROM order_items GROUP BY order_item_id HAVING COUNT(*) > 1;
SELECT order_id, COUNT(*) FROM orders GROUP BY order_id HAVING COUNT(*) > 1;
SELECT payment_id, COUNT(*) FROM payments GROUP BY payment_id HAVING COUNT(*) > 1;
SELECT product_id, COUNT(*) FROM products GROUP BY product_id HAVING COUNT(*) > 1;
SELECT return_id, COUNT(*) FROM returns GROUP BY return_id HAVING COUNT(*) > 1;

# As checked there are no duplicates



#### Null values

# Customers
SELECT COUNT(*) AS total_rows, SUM(Customer_ID IS NULL) AS n_cid,SUM(Customer_Name IS NULL) AS n_cn,
SUM(Gender IS NULL) AS n_g, Sum(Age is null) as n_age, sum(city is null) as n_c, sum(state is null) as n_s, sum(registration_date is null) as n_rd
FROM customers;

# Order_items
select count(*), sum(order_item_id is null) as n_otid, sum(order_id is null) as n_oid, sum(product_id is null) as n_pid,
sum(quantity is null) as n_q, sum(original_unit_price is null) as n_oup, sum(discount_percentage is null) as n_dp,
sum(total_amount is null) as n_ta from order_items;   

# Orders
select count(*), sum(order_id is null) as n_oid, sum(customer_id is null) as n_cid, sum(order_date is null) as n_od, sum(order_status is null) as n_os
from orders;
    
# Payments
select count(*), sum(payment_id is null) as n_pid, sum(order_id is null) as n_oid, sum(payment_method is null) as n_pm,
sum(payment_status is null) as n_ps from payments;

# Products
select count(*), sum(product_id is null) as n_pid, sum(product_name is null) as n_pn, sum(category is null) as n_c,
sum(subcategory is null) as n_sc, sum(base_price is null) as n_bp from products;

# Returns
select count(*), sum(return_id is null) as n_rid, sum(order_id is null) as n_oid, sum(return_date is null) as n_rd,
sum(return_reason is null) as n_rr from returns;

## As checked there are no null values


#### Refrential Integrity

## Check whether every order belongs to an existing customer.
select COUNT(*) as orphan_orders from orders o left join customers c on o.Customer_ID = c.Customer_ID
where c.Customer_ID is null;

## Check whether every order belongs to an existing order_item
select COUNT(*) as orphan_order_items from order_items oi left join orders o on oi.Order_ID = o.Order_ID where o.Order_ID is null;

## Check whether every order_item refers to a product
select COUNT(*) as orphan_product_items from order_items oi left join products p on oi.Product_ID = p.Product_ID where p.Product_ID is null;

## Check whether every payment refers to a order
select COUNT(*) as orphan_payments from payments p left join orders o on p.Order_ID = o.Order_ID where o.Order_ID is null;

## Check whether every return refers to an order
select COUNT(*) as orphan_returns from returns r left join orders o on r.Order_ID = o.Order_ID where o.Order_ID is null;

# As Checked every table has reference to other tables


#### Adding Foreign Keys

ALTER TABLE orders ADD CONSTRAINT fk_orders_customer FOREIGN KEY (Customer_ID) REFERENCES customers(Customer_ID);
ALTER TABLE order_items ADD CONSTRAINT fk_order_items_order FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID);
ALTER TABLE order_items ADD CONSTRAINT fk_order_items_product FOREIGN KEY (Product_ID) REFERENCES products(Product_ID);
ALTER TABLE payments ADD CONSTRAINT fk_payments_order FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID);
ALTER TABLE returns ADD CONSTRAINT fk_returns_order FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID);


######################################################################################################################################################

#### Business KPI's

## Total Revenue
select round(sum(total_amount),2) as Total_Revenue from order_items;

## Total Orders
select count(*) as Total_Orders from orders;

## Total Customers
select count(*) as Total_Customers from customers;

## Total Products
select count(*) as Total_Products from products;

## Total Units Sold
select sum(quantity) as Total_Units_Sold from order_items;

## Average Order Value
select round(sum(oi.total_amount)/count(distinct o.order_id),2) as Avg_Order_Value from orders o join order_items oi on o.order_id = oi.order_id;

## Returned Orders 
select count(distinct order_id) as Returned_Orders from returns;

## Return Rate %
select round(count(distinct r.order_id)*100/count(distinct o.order_id),2) as 'RR%' from orders o left join returns r on o.order_id = r.order_id;


#####################################################################################################################################################


#### Sales Analysis

## Monthly Revenue Trend
select date_format(o.order_date, '%Y-%m') as month, round(sum(oi.total_amount),2) as Revenue from orders o join order_items oi
on o.order_id = oi.order_id group by date_format(o.order_date,'%Y-%m') order by month;

## Monthly Orders 
select date_format(order_date,'%Y-%m') as month, count(*) as total_orders from orders group by date_format(order_date,'%Y-%m') order by month; 

## Revenue by Categories
select p.Category, round(sum(oi.total_amount),2) as Revenue from products p join order_items oi on p.product_id = oi.product_id group by p.Category
order by Revenue desc;

## Revenue by Subcategories
select p.subcategory, round(sum(oi.total_amount),2) as Revenue from products p join order_items oi on p.product_id = oi.product_id group by p.subcategory
order by Revenue desc;

## Revenue by City
select c.City, round(sum(oi.total_amount),2) as Revenue from customers c join orders o on c.customer_id = o.customer_id join order_items oi
on o.order_id = oi.order_id group by c.City ;

## Top 10 Products by Revenue
select p.Product_id, p.Product_name, round(sum(oi.total_amount),2) as Revenue from products p join order_items oi on p.product_id = oi.product_id 
group by p.product_id,p.product_name order by revenue desc limit 10;

## Top 10 Products by Units Sold
select p.Product_id, p.Product_name, sum(oi.quantity) as Units_Sold from products p join order_items oi on p.product_id = oi.product_id 
group by  p.product_id,p.product_name order by Units_Sold desc limit 10;

## Revenue by Order Status
select o.Order_Status, round(sum(oi.total_amount),2) as Revenue from orders o join order_items oi on o.order_id = oi.order_id
group by o.Order_Status ;

## Payment Mode Performance
select p.Payment_Method, count(distinct p.order_id) as Total_Orders, round(sum(oi.total_amount),2) as Revenue 
from payments p join order_items oi on p.order_id = oi.order_id
group by p.payment_method order by Revenue desc;

## Monthly Revenue Growth
with monthly_sales as (select date_format(o.order_date, '%Y-%m') as month, round(sum(oi.total_amount),2) as Revenue from orders o join order_items oi
on o.order_id = oi.order_id group by date_format(o.order_date,'%Y-%m'))
select month, round(revenue,2) as revenue, round(lag(revenue) over (order by month),2) as prev_month_revenue,
round((revenue - lag(revenue) over (order by month))/nullif(lag(revenue) over (order by month),0)*100,2) as 'mom_%' from monthly_sales order by month;


#############################################################################################################################################################


#### Customer Analysis


## Customers who have placed Orders
select count(distinct customer_id) as Active_Customers from orders;

## Customers who haven't placed any order
select count(*) as Inactive_Customers from customers c left join orders o on c.customer_id = o.customer_id where o.order_id is null;

## Orders per Customer
select c.Customer_id, c.Customer_name, count(o.order_id) as Total_Orders from customers c join orders o on c.customer_id = o.customer_id
group by c.Customer_id, c.Customer_name order by total_orders desc;

## Top 10 Customers by Revenue
select c.Customer_id, c.Customer_name, round(sum(oi.total_amount),2) as Revenue from customers c join orders o on c.customer_id = o.customer_id 
join order_items oi on o.order_id = oi.order_id group by c.Customer_id, c.Customer_name order by Revenue desc limit 10;

## Top 10 Customers by No. of Orders
select c.Customer_id, c.Customer_name , count(o.order_id) as Total_Orders from customers c join orders o on c.customer_id = o.customer_id
group by c.Customer_id, c.Customer_name order by Total_orders desc limit 10;

## Average Spending per Customer
select round(sum(oi.Total_Amount)/ count(distinct o.Customer_id),2) as Avg_Sp_Per_Cust from orders o join order_items oi on o.order_id = oi.order_id;

## Repeat Customers
select count(*) as Repeat_Customers from (select customer_id from orders group by customer_id having count(distinct order_id) > 1) as df;

## One-Time Customers
select count(*) as one_time_Customers from (select customer_id from orders group by customer_id having count(distinct order_id) = 1) as df;

## Repeat Customer Rate
select round(count(case when order_count > 1 then 1 end)*100/count(*),2) as RC_Rate from 
(select customer_id,count(distinct order_id) as order_count from orders group by customer_id) as df;

## Customer Segmentation
with customer_orders as (select Customer_ID,count(distinct Order_ID) as total_orders from orders group by Customer_ID)
select Customer_ID,total_orders,case
when total_orders >= 5 then 'High Value'
when total_orders between 2 and 4 then 'Regular'
else 'One-Time' end as customer_segment from customer_orders
order by total_orders desc ;

## Customer Segment Distribution
with customer_orders as (select Customer_ID,count(distinct Order_ID) as total_orders from orders group by Customer_ID),
segmented_customers as (select Customer_ID,total_orders,case
when total_orders >= 5 then 'High Value'
when total_orders between 2 and 4 then 'Regular'
else 'One-Time' end as customer_segment from customer_orders) 
select customer_segment,count(*) as customers from segmented_customers group by customer_segment order by customers desc;

## Customer Lifetime Value 
select c.Customer_id, c.Customer_name, count(distinct o.order_id) as total_orders, round(sum(oi.Total_amount),2) as lifetime_value
from customers c join orders o on c.customer_id = o.customer_id join order_items oi on o.order_id = oi.order_id
group by c.Customer_id, c.Customer_name order by lifetime_value desc;

## Rank Customers by Revenue
with customer_revenue as 
(select c.Customer_id, c.Customer_name, round(sum(oi.total_amount),2) as Revenue from customers c join orders o on c.customer_id = o.customer_id 
join order_items oi on o.order_id = oi.order_id group by c.Customer_id, c.Customer_name)
select Customer_id, Customer_name, round(revenue,2) as Revenue, Rank() over (order by Revenue desc) as Revenue_Rank from customer_revenue order by revenue_rank;


########################################################################################################################################################################

#### Product Analysis

## Product-Wise Sales Performance
select p.Product_id, p.Product_name, count(distinct oi.Order_id) as Total_orders, sum(oi.Quantity) as Units_Sold, round(avg(oi.Original_Unit_Price),2) as Avg_Unit_Price,
round(avg(oi.Discount_Percentage),2) as 'Avg_Disc_%', sum(oi.Total_Amount) as Total_Revenue
from products p join order_items oi on p.Product_id = oi.Product_id 
group by p.Product_id, p.Product_name order by Total_Revenue desc;

## Top 10 Products by Revenue	
select p.Product_id, p.Product_name, sum(oi.Total_Amount) as Total_Revenue
from products p join order_items oi on p.Product_id = oi.Product_id 
group by p.Product_id, p.Product_name order by Total_Revenue desc limit 10;

## Top 10 Products by Units Sold
select p.Product_id, p.Product_name, sum(oi.Quantity) as Units_Sold
from products p join order_items oi on p.Product_id = oi.Product_id 
group by p.Product_id, p.Product_name order by Units_Sold desc limit 10;

## Category-Wise Product Performance
select p.Category,count(distinct p.Product_id) as Total_Products,count(distinct oi.Order_id) as Total_orders, sum(oi.Quantity) as Units_Sold,
round(avg(oi.Discount_Percentage),2) as 'Avg_Disc_%', sum(oi.Total_Amount) as Total_Revenue
from products p join order_items oi on p.Product_id = oi.Product_id 
group by p.Category order by Total_Revenue desc;

## Subcategory-Wise Product Performance
select p.Category,p.Subcategory,count(distinct p.Product_id) as Total_Products,count(distinct oi.Order_id) as Total_orders, sum(oi.Quantity) as Units_Sold,
round(avg(oi.Discount_Percentage),2) as 'Avg_Disc_%', sum(oi.Total_Amount) as Total_Revenue
from products p join order_items oi on p.Product_id = oi.Product_id 
group by p.Category,p.Subcategory order by Total_Revenue desc;

## Discount Impact on Product Sales
select case when discount_percentage = 0 then 'No Discount'
when discount_percentage <= 0.10 then '0-10%'
when discount_percentage <= 0.20 then '10-20%'
when discount_percentage <= 0.30 then '20-30%'
else '30% +' end as Discount_Range,count(*) as Total_Items_Sold,
sum(quantity) as Units_Sold,round(sum(Total_Amount),2) as Total_Revenue,
round(avg(Total_Amount),2) as Avg_Item_Revenue from order_items
group by Discount_Range order by Total_Revenue desc;

## Discount Impact by Category
select p.Category, sum(oi.Quantity) as Units_Sold,round(avg(oi.Discount_Percentage),2) as 'Avg_Disc_%', round(sum(oi.Total_Amount),2) as Total_Revenue,
round(avg(oi.Total_Amount),2) as Avg_Item_Revenue
from products p join order_items oi on p.Product_id = oi.Product_id 
group by p.Category order by Total_Revenue desc;

## Product Price VS Sales Performance
select case when p.Base_Price<10000 then 'Below 10K'
when p.Base_Price<25000 then 'Below 25K'
when p.Base_Price<50000 then 'Below 50K'
when p.Base_Price<75000 then 'Below 75K'
else '75K+' end as Price_Range,
count(distinct p.Product_id) as Total_Products, sum(oi.Quantity) as Units_Sold, count(distinct oi.order_id) as Total_Orders,
round(sum(oi.Total_Amount),2) as Total_Revenue from products p join order_items oi on p.Product_id = oi.Product_id
group by Price_Range order by Total_Revenue desc;

## Unsold Products
select p.Product_id,p.Product_name, p.Category, p.Subcategory,p.Base_Price from products p left join order_items oi on p.Product_id = oi.Product_id
where oi.product_id is null order by p.Base_Price desc;

## Product Revenue Contribution %
select p.Product_id,p.Product_name, round(sum(oi.Total_Amount),2) as Product_Revenue, 
round(sum(oi.Total_Amount)/(select sum(Total_Amount) from order_items)*100,2) as Revenue_Contribution_Perc
from products p join order_items oi on p.Product_id = oi.Product_id
group by p.Product_id,p.Product_Name order by Revenue_Contribution_Perc desc;


################################################################################################################################################################

#### Return/Payments Analysis

## Total Returned Orders
select count(distinct order_id) as Returned_Orders from returns;

## Return Rate
select round(count(distinct r.order_id)*100/count(distinct o.order_id),2) as 'Return%' from returns r right join orders o on r.order_id = o.order_id;

## Return by Reasons
select Return_Reason, count(*) as Total_Returns from returns group by Return_Reason order by Total_Returns desc;

## Returns by Refund Status
select Refund_Status, count(*) as Total_Returns from returns group by Refund_Status order by Total_Returns desc;

## Monthly Return Trend
select date_format(return_date,'%Y-%m') as Month, count(*) as Total_Orders from returns group by Month order by Month;

## Returned Revenue
select round(sum(oi.Total_Amount),2) as Returned_Revenue from returns r join order_items oi on r.order_id = oi.order_id;

## Return Rate by Category
select p.Category, count(distinct r.order_id) as Total_Returns, count(distinct o.order_id) as Total_Orders,
round(count(distinct r.order_id)*100/count(distinct o.order_id),2) as Return_Rate from orders o join order_items oi on o.order_id = oi.order_id join
products p on oi.product_id = p.product_id left join returns r on o.order_id = r.order_id
group by p.Category order by Return_Rate desc;

## Products with Most Returns
select p.Product_id, p.Product_name, count(distinct r.order_id) as Returned_orders from returns r join order_items oi on r.order_id = oi.order_id join
products p on oi.product_id = p.product_id group by p.Product_id, p.Product_name order by Returned_orders desc;

### Payment Analysis

## Orders by Payment Method
select Payment_Method, count(distinct order_id) as Total_Orders from payments group by Payment_Method order by Total_Orders desc;

## Revenue by Payment Method
select p.Payment_Method, round(sum(oi.Total_Amount),2) as Total_Revenue from payments p join order_items oi on p.order_id = oi.order_id 
group by  p.Payment_Method order by Total_Revenue desc;

## Payment Status Distribution
select Payment_Status, count(*) as Total_Payments from payments group by Payment_Status order by Total_Payments desc;

## Payment Method X Payment Status
select Payment_Method, Payment_Status, count(*) as Total_Payments from payments group by Payment_Method, Payment_Status order by Payment_Method,Total_Payments desc;

## Cancelled Orders by Payment Method
select p.Payment_Method, count(distinct o.order_id) as Cancelled_Orders from payments p join orders o on p.order_id = o.order_id where o.order_status = 'Cancelled'
group by p.Payment_Method order by Cancelled_orders desc;

## Payment Method Revenue Contribuition % 
with payment_revenue as 
(select p.Payment_Method, round(sum(oi.Total_Amount),2) as Revenue from payments p join order_items oi on p.order_id = oi.order_id 
group by  p.Payment_Method )
select Payment_Method, round(revenue,2) as Revenue, round(revenue*100/sum(revenue) over(),2) as Revenue_Contri_Percent from payment_revenue order by revenue desc;


#########################################################################################################################################################################

#### Advanced SQL Analysis ------ ( CTE's, Window Functions, Rankings, Running Totals, etc )

## Top 10 Customers by Revenue using RANK()
with customer_revenue as 
(select c.Customer_id,c.Customer_name, round(sum(oi.Total_Amount),2) as Revenue from customers c join orders o on c.customer_id = o.customer_id join order_items oi
on o.order_id = oi.order_id group by c.Customer_id,c.Customer_name),
ranked_customers as 
(select Customer_id, Customer_name, Revenue, rank() over(order by revenue desc) as revenue_rnk from customer_revenue)
select * from ranked_customers where revenue_rnk<=10 order by revenue_rnk;


## Top 3 Products in each Category
with product_sales as
(select p.Category,p.Product_id,p.Product_name,sum(oi.quantity) as Units_Sold, round(sum(oi.Total_Amount),2) as Revenue from products p join order_items oi 
on p.product_id = oi.product_id group by p.Category,p.Product_id,p.Product_name),
ranked_products as
(select *, Rank() over(partition by Category order by Revenue desc) as Category_Rnk from product_sales)
select * from ranked_products where Category_Rnk<=3 order by Category,Category_Rnk;


## Monthly Revenue + Previous Month Revenue
with monthly_revenue as
(select date_format(o.order_date,'%Y-%m') as Month, round(sum(oi.Total_Amount),2) as revenue from orders o join order_items oi on o.order_id = oi.order_id
group by Month)
select Month, Revenue, lag(Revenue) over(order by Month) as Prev_Month_Revenue from monthly_revenue group by Month;


## MOM Revenue Growth
with monthly_revenue as
(select date_format(o.order_date,'%Y-%m') as Month, round(sum(oi.Total_Amount),2) as revenue from orders o join order_items oi on o.order_id = oi.order_id
group by Month),
revenue_comp as
(select Month, Revenue, lag(Revenue) over(order by Month) as Prev_Month_Revenue from monthly_revenue )
select Month, round(Revenue,2) as Revenue, round(Prev_Month_Revenue,2) as Prev_Revenue, 
round((revenue-Prev_Month_Revenue)*100/nullif(Prev_Month_Revenue,0),2) as 'MOM%_Change'
from revenue_comp order by Month;


## Running Revenue Total
with monthly_revenue as
(select date_format(o.order_date,'%Y-%m') as Month, round(sum(oi.Total_Amount),2) as revenue from orders o join order_items oi on o.order_id = oi.order_id
group by Month)
select Month, round(revenue,2) as Monthly_Revenue ,round(sum(revenue) over(order by Month Rows between unbounded preceding and current row),2) as Running_Revenue
from monthly_revenue order by Month;


## Customer Revenue Ranking by City
with customer_revenue as 
(select c.City, c.Customer_id,c.Customer_name, round(sum(oi.Total_Amount),2) as Revenue from customers c join orders o on c.customer_id = o.customer_id join order_items oi
on o.order_id = oi.order_id group by c.City,c.Customer_id,c.Customer_name),
ranked_customers as 
(select *, rank() over(partition by City order by revenue desc) as city_rnk from customer_revenue)
select City,Customer_id,Customer_Name,round(revenue,2) as Revenue, city_rnk from ranked_customers where city_rnk<=3 order by City,city_rnk;


## Category Revenue Contribution
with category_revenue as
(select p.Category, round(sum(oi.Total_Amount),2) as Revenue from products p join order_items oi on p.product_id = oi.product_id group by p.Category)
select Category,round(revenue,2) as Revenue, round(revenue*100/sum(revenue) over(),2) as Revenue_Perc from category_revenue group by Category order by revenue_perc desc;


## Customers above Average Spending
with customer_spending as 
(select o.Customer_id, sum(oi.total_amount) as Total_Spending from orders o join order_items oi on o.order_id = oi.order_id group by o.Customer_id)
select Customer_id, round(total_spending,2) as Total_Spending from customer_spending where total_spending >
 ( select avg(total_spending) from customer_spending) order by total_spending desc;
 
 
 ## High-Value Customers
 with customer as 
 (select o.Customer_id,count(distinct o.order_id) as Total_Orders, sum(oi.Total_Amount) as Total_Spending from orders o join order_items oi on o.order_id = oi.order_id
 group by o.Customer_Id)
 select Customer_id, total_orders, round(total_spending,2) as Total_Spending from customer 
 where total_orders >= 3 and total_spending >= 50000 order by total_spending desc;
 
 
 ## Most Valuable Category Per City
 with city_cat as
 (select c.City, p.Category, sum(oi.Total_Amount) as revenue from customers c join orders o on c.customer_id = o.customer_id join order_items oi on
 o.order_id = oi.order_id join products p on oi.product_id = p.product_id group by c.City, p.Category),
 ranked_cat as 
 (select City,Category, round(revenue,2) as Revenue, Rank() over(partition by City order by revenue desc) as cat_rnk from city_cat)
 select City,Category, round(revenue,2) as Revenue, cat_rnk from ranked_cat where cat_rnk = 1 order by City;
 

