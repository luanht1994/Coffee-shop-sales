CREATE DATABASE CoffeeShop;
USE CoffeeShop;
CREATE TABLE CoffeeShopSale (
	 transaction_id int primary key,
	 transaction_date date,
	 transaction_time  time(0),
	 transaction_qty int,
	 store_id int,
	 store_location varchar(50),
	 product_id int,
	 unit_price numeric(5,2),
	 product_category varchar(50),
	 product_type varchar(50),
	 product_detail varchar(50)
	 );
ALTER TABLE [Coffee Shop Sales]
	ADD total_sales numeric(5,2);
UPDATE [Coffee Shop Sales]
	SET [total_sales] =[transaction_qty]*[unit_price];
 ALTER TABLE [Coffee Shop Sales]
	ADD transaction_hour time(0);
UPDATE [Coffee Shop Sales]
	SET [transaction_hour] = DATEADD(HOUR,DATEDIFF(HOUR,0,[transaction_time]),0);
SELECT  * FROM [Coffee Shop Sales];
--total sale,total qty & total transaction
SELECT
	SUM([total_sales]) as total_sales,
	SUM([transaction_qty]) as total_qty,
	COUNT([transaction_id]) as total_transaction
FROM [Coffee Shop Sales];
--Total sales & totol_qty per month
SELECT
	FORMAT([transaction_date],'MMM yyyy') AS month,
	SUM([total_sales]) as total_sales,
	SUM([transaction_qty]) as total_qty,
	COUNT([transaction_id]) as total_transaction
FROM [Coffee Shop Sales]
GROUP BY FORMAT([transaction_date],'MMM yyyy')
ORDER BY MIN([transaction_date]);
--Percentage sales, qty & transaction per store location
SELECT
	[store_location] AS store_location,
	ROUND(SUM([total_sales]) * 100 / SUM(SUM([total_sales])) OVER(),2) as percent_total_sales,
	ROUND(SUM([transaction_qty]) * 100 / SUM(SUM([transaction_qty])) OVER(),2) as percent_total_qty,
	ROUND(COUNT([transaction_id]) * 100 / SUM(COUNT([transaction_id])) OVER(),2) as percent_total_transaction
FROM [Coffee Shop Sales]
GROUP BY [store_location];
--average transaction per hour per day
DECLARE @col as nvarchar(Max);
DECLARE @query as nvarchar(Max);
--get distinct column
SELECT
	@col = STRING_AGG(QUOTENAME(day_name,'[]'),',') WITHIN GROUP(ORDER BY date_no)
FROM (
		SELECT DISTINCT
			FORMAT([transaction_date],'ddd') as day_name,
			DATEPART(W,[transaction_date]) as date_no
		FROM [Coffee Shop Sales] ) as unique_day;
--construct automatically query 
SET @query ='
SELECT 
	[transaction_hour],
	'+@col+'
FROM (
		SELECT 
			[transaction_hour],
			FORMAT([transaction_date],''ddd'') as day_name,
			COUNT([transaction_id])/ COUNT(FORMAT([transaction_date],''ddd'')) OVER(PARTITION BY FORMAT([transaction_date],''ddd'')) as avg_transaction
		FROM [Coffee Shop Sales]
		GROUP BY [transaction_hour], FORMAT([transaction_date],''ddd'')
		)as sourcetable
PIVOT (
	SUM(avg_transaction)
	FOR day_name IN('+@col+')
	) as pivottable
ORDER BY [transaction_hour] ASC ;';
--execute quey
EXEC sp_executesql @query;
--top 5 sales product
SELECT TOP 5
	[product_type],
	SUM([total_sales]) as total_sales
FROM [Coffee Shop Sales]
GROUP BY [product_type]
ORDER BY SUM([total_sales]) DESC;
SELECT TOP 100 * FROM [Coffee Shop Sales];

