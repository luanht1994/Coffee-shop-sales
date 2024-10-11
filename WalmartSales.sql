use Walmart;
/* adding a new column to classify shift day*/
ALTER TABLE WalmartSales
	Add Time_of_day varchar(20) ;
Update WalmartSales
	Set Time_of_day = 
	(Case
		When Time between '00:00:00' and '12:00:00' Then 'Morning'
		When Time between '12:01:00' and '16:00:00' Then 'Afteroon'
		Else 'Evenining'
	End );
/* adding a new column to classify weekday*/
ALTER TABLE WalmartSales
	ADD day_name varchar(10);
UPDATE WalmartSales
	SET day_name = DATENAME( WEEKDAY, Date);
----------------Exploratory Data Analysis (EDA)----------------------
/* Product analysis */
-- Which are products in the dataset
SELECT
	DISTINCT [Product line] AS Product
FROM WalmartSales;
-- Total sales per product
 SELECT
	[Product line] as product,
	SUM(Total) as total_revenue,
	SUM(Quantity) as total_qty
 FROM WalmartSales
 GROUP BY [Product line]
 ORDER BY SUM(Total) DESC, SUM(Quantity) DESC;

 -- Total revenue per month
 SELECT
	FORMAT([Date],'MMM-yyyy') as month_name,
	SUM(Total) as total_revenue
FROM WalmartSales
GROUP BY FORMAT([Date],'MMM-yyyy')
ORDER BY MIN(Date) ASC;

-- Rating sale per city
 SELECT
	City,
	ROUND(SUM(Total) * 100/ SUM(SUM(Total)) OVER(), 1) as percent_revenue
 FROM WalmartSales
 GROUP BY City; 
 --Rating sales per customer type
 SELECT
	[Customer type],
	ROUND(SUM(Total) * 100/ SUM(SUM(Total)) OVER(), 1) as percent_revenue
 FROM WalmartSales
 GROUP BY [Customer type]; 
 -- Rating sales per gender
 SELECT
	[Gender],
	ROUND(SUM(Total) * 100/ SUM(SUM(Total)) OVER(), 1) as percent_revenue
 FROM WalmartSales
 GROUP BY [Gender];
 --Total order
 SELECT
	COUNT([Invoice ID]) as total_order
FROM WalmartSales;
--Total order by month
SELECT
	FORMAT([Date],'MMM-yyyy') as month,
	COUNT([Invoice ID]) as total_order
FROM WalmartSales
GROUP BY FORMAT([Date],'MMM-yyyy')
ORDER BY MIN([Date]) ASC;
--Total order per month per city
SELECT
	*
FROM(
	SELECT
		City,
		FORMAT([Date],'MMM-yyyy') as month,
		COUNT([Invoice ID]) as total_order
	FROM WalmartSales
	GROUP BY City,FORMAT(Date, 'MMM-yyyy')) as order_summary
PIVOT (
	SUM(total_order)
	FOR month IN ([Jan-2019],[Feb-2019],[Mar-2019])
	)as pivot_table;
-- Dynamically pivot data without having the list in IN clause explicitly
DECLARE @col AS NVARCHAR(MAX);
DECLARE @query AS NVARCHAR(MAX);

-- Get distinct months
SELECT 
    @col = STRING_AGG(QUOTENAME(month_name, '[]'), ', ') WITHIN GROUP (ORDER BY month_date)
FROM (SELECT DISTINCT 
			FORMAT(Date, 'MMM-yyyy') AS month_name,
			CAST(DATEFROMPARTS(YEAR(Date), MONTH(Date), 1) AS DATE) AS month_date 
		FROM WalmartSales) AS month_list;

-- Construct the dynamic SQL query
SET @query = '
SELECT 
    City,
    ' + @col + '
FROM (
    SELECT
        City,
        FORMAT(Date, ''MMM-yyyy'') AS month_name,
        COUNT([Invoice ID]) AS total_order
    FROM WalmartSales
    GROUP BY City, FORMAT(Date, ''MMM-yyyy'')
) AS sourcetable
PIVOT 
(
    SUM(total_order)
    FOR month_name IN (' + @col + ')
) AS pivot_table;';

-- Execute the dynamic SQL
EXEC sp_executesql @query;

--Average transaction per day
SELECT
	day_name,
	COUNT([Invoice ID]) as total_transaction
FROM (
	SELECT
		day_name,
		[Invoice ID],
		DATEPART(W,Date) as day_no
	FROM WalmartSales) as sourcetable
GROUP BY day_name, day_no
ORDER BY day_no;
--Average transaction per shift
SELECT
	[Time_of_day],
	COUNT([Invoice ID]) as total_transaction
FROM WalmartSales
GROUP BY Time_of_day;
--Average transaction per city per day
DECLARE @col1 nvarchar(Max);
DECLARE @query1 nvarchar(Max);
-- get distinct day
SELECT
	@col1 = STRING_AGG(QUOTENAME([day_name],'[]'),',') WITHIN GROUP( ORDER BY date_no)
FROM (
		SELECT DISTINCT
			[day_name],
			DATEPART(W,[Date]) as date_no
		FROM WalmartSales
		) AS list_day
--construct dynamic query
SET @query1 = 
'SELECT
	[City],
	'+@col1+'
FROM (
		SELECT
			[City],
			[day_name],
			COUNT([Invoice ID]) as total_order
		FROM WalmartSales
		GROUP BY [City], [day_name]
		) as sourcetable
PIVOT(
	SUM(total_order)
	FOR [day_name] IN('+@col1+')
	) AS pivottable;';
-- Execute the dynamic SQL
EXEC sp_executesql @query1;
-- average transaction per hour
WITH floorhour as (
SELECT
	[City],
	[Date],
	[Time],
	CAST(DATEADD(HOUR,DATEDIFF(HOUR,0,[Time]),0) AS TIME(0)) as hour_no,
	[Invoice ID]
FROM WalmartSales),
grouptable as
(SELECT 
	[City],
	hour_no,
	COUNT([Invoice ID]) AS total_transaction
FROM floorhour
GROUP BY [City], [Date], hour_no)
SELECT * FROM grouptable
PIVOT (
	SUM(total_transaction)
	FOR [City] IN ([Yangon],[Mandalay],[Naypyitaw])) as pivottabl2;

 SELECT 
	distinct City
 FROM WalmartSales;

