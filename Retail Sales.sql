-- Retail Sales Analysis

-- Create Table

Create Table
    Retail_sales
           (transaction_id	INT,
            transaction_date DATE,	
            transaction_time TIME,
            customer_id	INT,
            product_id	INT,
            product_category VARCHAR(25),
            quantity INT,
            price	FLOAT,
            total_amount FLOAT,
            payment_method	VARCHAR(25),
            store_location  VARCHAR(25)
            );
            
Select*
from retail_sales;

select count(*)
   from retail_sales;
   
-- Data Cleaning

select * from retail_sales
where
    transaction_id is null
    or
    transaction_date is null
    or
	transaction_time is null
    or
    customer_id is null
    or
    product_id is null
    or
    product_category is null
    or
    quantity is null
    or
    price is null
    or
    total_amount is null
    or
    payment_method is null
    or
    store_location is null;

-- Data Exploration

-- Calculate a rolling total of sales (total_amount) per product_category ordered by transaction_date.

	select 
		transaction_Id,
		transaction_date,
		product_Category,
		total_amount,
		sum(total_amount)over(partition by product_Category order by transaction_date,transaction_id 
        ) as rolling_total
	from retail_sales
	order by product_category,transaction_date;
    
-- Find the top 3 transactions by total_amount for each store_location

select
	transaction_id,
    store_location,
    customer_id,
    product_category,
    total_amount
from(
	SELECT
	transaction_id,
    store_location,
    customer_id,
    product_category,
    total_amount,
    row_number()OVER(
    partition by store_location
    order by total_amount desc
    ) as rn
from retail_sales
) as ranked_sales
where rn <=3
order by store_location,rn;

-- List all transactions where the total_amount is greater than the average total_amount of the dataset.

select*
from retail_sales
where total_amount > (select
                      avg(total_amount)
                      from retail_sales);
                      
-- Show product categories with total sales > 10,000.

select
	product_category,
    sum(total_amount) as total_sales
from retail_sales
group by product_category
having sum(total_amount) > 10000;

-- Create a CTE that calculates monthly sales and then select the month with the highest sales

with monthly_sales as (
	select
    date_format(transaction_date,'%Y-%m')as month,
    sum(total_amount) as total_sales
from retail_sales
	group by date_format(transaction_date,'%Y-%m')
    )
select month,total_sales
 from monthly_Sales
 order by total_sales desc
 limit 1;
 
-- Add a Column sales_type in query - Keep'HIGH' If total amount > 500.'medium'if total amount is between 200 and 500,'low' if total amount < 500

select 
	case 
		when total_amount > 500 then 'HIGH'
        When total_amount between 200 and 500 then 'MEDIUM'
        else 'LOW'
	END AS sales_type,
count(*) as transaction_count
from retail_sales
	group by 
        case 
			when total_amount > 500 then 'HIGH'
			When total_amount between 200 and 500 then 'MEDIUM'
			else 'LOW'
	    end;
        
-- Categorize transactions by time: 'Morning' for 06:00:00–11:59:59,'Afternoon' for 12:00:00–17:59:59,'Evening' for 18:00:00–21:59:59,'Night' for 22:00:00–05:59:59
     
select 
	transaction_id,
    transaction_time,
	case
		when time(transaction_time) between '06:00:00' and'11:59:59' then 'MORNING'
        When time(transaction_time) between '12:00:00' and'17:59:59' then 'AFTERNOON'
        WHEN Time(transaction_time) between '18:00:00' and'21:59:59' then 'EVENING'
        else 'NIGHT'

	End AS Time_Of_The_Day
from retail_sales;

-- For each transaction, display transaction_id and the average total_amount of all transactions in the same store_location.

SELECT 
    transaction_id,
    store_location,
    total_amount,
    AVG(total_amount) OVER (PARTITION BY store_location) AS avg_store_sales
FROM retail_sales;

-- Show the store with the highest average transaction amount

select
	store_location,avg_transaction
from(
     select
		store_location,
        avg(total_amount) as avg_transaction
	 from retail_sales
     group by store_location
     )t
order by avg_transaction desc
limit 1;

-- Using a CTE for monthly totals, join it with store_locations to see which store contributes most each month

With monthly_Store_sales as (
	select 
		date_format(transaction_date,'%Y-%m') as Month,
        store_location,
        sum(total_amount)as total_sales
	from retail_sales
    group by date_format(transaction_date,'%Y-%m'),store_location
    )
select m.month,
	   m.store_location,
       m.total_sales
from(
	select
		month,
        store_location,
        total_sales,
        rank()over(partition by store_location order by total_sales desc) as sales_rank
	from monthly_Store_sales
    )m
where m.sales_rank =1;

-- Show each store's sales as a percentage of total sales.

select
	store_location,
    sum(total_amount) as store_sales,
    round(sum(total_amount)/(select sum(total_amount) from retail_sales) *100,2) as sales_percentage 
from retail_sales
group by store_location
order by sales_percentage desc;

-- Retrieve transactions where quantity > average quantity for that product category

select *
 from (
	select*,
    avg(quantity)over(partition by product_category)as avg_quantity
    from retail_sales
    )t
    where quantity > avg_quantity;
    
-- Find peak hour of transactions (hour with most transactions) across all days

select 
	hour(transaction_time) as transaction_hour,
    count(*) as transaction_count
from retail_sales
group by hour(transaction_time)
order by transaction_count desc
limit 1;

-- END OF PROJECT
    




					
	
    


            
       

     
			