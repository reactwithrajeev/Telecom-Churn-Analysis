USE telecom_analysis;

-- QUERY 1 : Business Problem
/* Which 10 customers have brought in the most total revenue for the company 
over the last 6 months? These are the company's most valuable customers, 
and losing any of them would hurt the business the most. */

select * from usage_data;
SELECT 
	customer_id,
	round(SUM(recharge_amount),2) as Total_Revenue
FROM 
usage_data
GROUP BY 
customer_id 
ORDER BY 
Total_Revenue DESC
LIMIT 10;

/*
INSIGHT: Top 10 Highest-Revenue Customers

The highest-paying customer, CUST122743, brought in ₹15,829.28 over the 
last 6 months. All 10 customers in this list generated between ₹15,522 
and ₹15,829 -- a fairly tight range at the very top.

WHY THIS MATTERS FOR THE BUSINESS:
These 10 customers represent the company's most valuable relationships. 
Losing even one of them is a real, measurable revenue hit -- roughly 
₹15,500-15,800 per customer over 6 months, or about ₹2,600 per month each. 
The retention team should know exactly who these top customers are and 
protect them with priority support, personal account managers, or 
exclusive loyalty perks.
*/

/* 
Query 2 : Business Problem

Which type of complaint takes the longest to resolve, and does slow resolution actually 
push customers toward churning? The company needs to know if there's one specific 
complaint category causing the most damage. 
*/


SELECT * from complaints, churn_status;
SELECT 
 co.complaint_type,
 COUNT(*) as Total_Complaints,
 AVG(co.resolution_days) as Avg_Resolution_Days, 
 AVG(ch.is_churned)*100 as Churn_rate_Pct
 FROM 
 complaints co 
 JOIN 
 churn_status ch ON co.customer_id = ch.customer_id 
 GROUP BY co.complaint_type
 ORDER BY Avg_Resolution_Days DESC;


/*
INSIGHT: Complaint Resolution Time & Churn Rate by Complaint Type

Looking at all 5 complaint types, both average resolution time and churn 
rate turn out to be almost identical across the board. Average resolution 
days range narrowly from 5.44 (Data/Speed Issue) to 5.51 (Service Quality) 
-- a difference of less than half a day. Churn rate is just as flat, 
ranging from 39.35% (Network Issue) to 40.20% (Other).

WHY THIS MATTERS FOR THE BUSINESS:
Unlike contract type or usage decline, the specific TYPE of complaint does 
not appear to be a meaningful driver on its own -- no single category (like 
Billing or Network) is disproportionately slow to resolve or disproportion-
ately linked to churn. This tells the company that the real risk factor is 
not which complaint a customer files, but simply HOW MANY complaints they 
file and HOW LONG resolution takes overall (something we already confirmed 
earlier: churned customers wait 8.5 days on average vs 3.5 days for non-
churned). Fixing resolution speed in general will help more than targeting 
one specific complaint category.
*/


/* 
Query 3 : Business Problem

For each customer, how much did their data usage change from one month to the next? 
The company wants to spot customers whose usage is dropping 
sharply between consecutive months, not just comparing the first and last month.
*/

SELECT * FROM usage_data;

WITH data_used as (SELECT 
customer_id , 
month,
data_used_gb as current_month_data_used,
LAG(data_used_gb) OVER(PARTITION BY customer_id ORDER BY month ) as Prev_Month_Data_used
FROM 
usage_data)
SELECT 
customer_id, 
month,
current_month_data_used,
Prev_Month_Data_used,
ROUND((current_month_data_used - Prev_Month_Data_used),2) as Month_Over_Month_Change
FROM 
data_used
ORDER BY customer_id , month 
LIMIT 20;

/*
INSIGHT: Month-over-Month Usage Change (Sample Verification)

Looking at individual customers, the month-over-month change reveals two 
very different behavior patterns. CUST100000 and CUST100001 (non-churned) 
show small, random ups and downs each month -- sometimes usage goes up 
by 2-5 GB, sometimes down by 1-4 GB, with no consistent direction.

CUST100002, however, shows a completely different pattern -- the month- 
over-month change is negative in 4 out of 5 months (-0.94, -0.76, -0.87, 
-2.22), meaning usage kept falling nearly every single month rather than 
just having one bad month. This is a churned customer, and the steady, 
repeated decline (not just one random dip) is what separates a genuine 
at-risk customer from normal month-to-month fluctuation.

WHY THIS MATTERS FOR THE BUSINESS:
A single month of lower usage doesn't necessarily mean a customer is 
about to churn -- that could just be normal variation. But this row-by-row 
view shows that real at-risk customers usually have CONSECUTIVE months of 
decline, not just one. The company's early-warning system should look for 
customers with 2 or more consecutive months of negative change, rather 
than flagging anyone with a single down month, to avoid false alarms.
*/


/* 
Query 4 : Business Problem

Within each city, who are the top 3 highest-revenue customers? 
The company wants a city-wise VIP list, not just one single global top-10 list, 
so that local teams in each city know exactly who their most valuable customers are.
*/


WITH city_wise_revenue as (SELECT 
c.city,
u.customer_id,
ROUND(SUM(u.recharge_amount),2) as Total_Revenue
FROM 
usage_data u 
JOIN customers c ON u.customer_id = c.customer_id 
GROUP BY c.city , u.customer_id ),
city_rank as (SELECT 
city,
customer_id,
Total_Revenue,
RANK() OVER(PARTITION BY city ORDER BY Total_Revenue DESC) as Revenue_Rank
FROM 
city_wise_revenue)
SELECT 
city,
Customer_id,
Total_Revenue,
Revenue_Rank
FROM city_rank
WHERE Revenue_Rank <=3
ORDER BY city , Revenue_Rank;

/*
INSIGHT: Top 3 Highest-Revenue Customers Per City

I found the top 3 revenue-generating customers within each of the 6 cities. 
Interestingly, the top customer in every city falls in a fairly tight 
₹15,441 to ₹15,829 range -- Bangalore has the single highest earner 
overall (CUST122743 at ₹15,829.28), while Noida's top customer 
(CUST148543 at ₹15,522.62) is on the lower end, but still clearly a 
VIP compared to a typical customer.

WHY THIS MATTERS FOR THE BUSINESS:
A single global top-10 list (like we built in Query 1) can end up ignoring 
high-value customers in smaller cities like Pune or Noida, simply because 
bigger cities like Delhi or Gurgaon have more customers overall. This 
city-wise ranking makes sure every regional team has its own local VIP 
list to protect -- so a city manager in Noida knows exactly who their 
top 3 customers are, even if none of them would make it into a company-
wide top 10.
*/

/* Query 5 : Business Problem

The company wants to divide all customers into 4 equal-sized value tiers — like Platinum, 
Gold, Silver, Bronze — based on how much revenue they generate, 
so the marketing team can design different offers for each tier 
instead of treating every customer the same.

*/

SELECT * FROM usage_data;

WITH cust_Revenue as (SELECT 
customer_id ,
ROUND(SUM(recharge_amount),2) as Total_Revenue
FROM usage_data 
GROUP BY customer_id 
ORDER BY Total_Revenue DESC),
cust_grouping as (SELECT 
customer_id,
Total_Revenue,
NTILE(4) OVER(ORDER BY total_revenue DESC) as revenue_Group
FROM cust_Revenue)
SELECT 
CASE 
	WHEN Revenue_Group = 1 THEN "PLATINUM"
    WHEN Revenue_Group = 2 THEN "GOLD"
    WHEN Revenue_Group = 3 THEN "SILVER"
ELSE "BRONZE" 
END AS customer_Type,
COUNT(*) AS Num_customers,
ROUND(AVG(total_revenue), 2) AS avg_revenue,
ROUND(MIN(total_revenue), 2) AS min_revenue,
ROUND(MAX(total_revenue), 2) AS max_revenue
FROM 
cust_grouping
GROUP BY revenue_Group
ORDER BY revenue_Group;

/*
INSIGHT: Customer Value Segmentation (Platinum/Gold/Silver/Bronze)

I divided all 50,000 customers into 4 equal-sized revenue tiers of 12,500 
customers each. Platinum customers average ₹10,573.22 in revenue (ranging 
from ₹7,787 to ₹15,829), while Bronze customers average just ₹1,759.40 
(ranging from ₹1,139 to ₹2,318). That means the average Platinum customer 
is worth roughly 6x more than the average Bronze customer.

WHY THIS MATTERS FOR THE BUSINESS:
Treating all 50,000 customers the same way wastes resources. The Platinum 
segment (12,500 customers generating premium revenue) deserves dedicated 
retention effort -- priority support, exclusive offers, proactive check-ins 
-- since losing even a handful of them has an outsized revenue impact. 
Bronze customers, on the other hand, could be targeted with low-cost, 
automated engagement (like SMS offers or app notifications) rather than 
expensive personal outreach, since the revenue per customer doesn't 
justify the same investment. This segmentation gives marketing a clear, 
data-backed way to allocate their budget instead of a one-size-fits-all approach.
*/

/*
Query 6 : Business Problem

Which month sees the highest number of complaints coming in? 
The company wants to know if complaints spike around a specific time of year
(like a festival season or a billing cycle), 
so they can prepare extra support staff in advance.

*/
SELECT * FROM complaints;

SELECT 
    MONTHNAME(complaint_date) AS Complaint_Month,
	MONTH(complaint_date) AS month_number,
    COUNT(*) AS Total_Complaints
FROM
    complaints
GROUP BY Complaint_Month,month_number
ORDER BY month_number ;


/*
INSIGHT: Complaints by Month (Seasonality Check)

Complaints are fairly evenly spread across all 6 months, ranging from 
11,106 in August to 12,296 in October -- only about a 10% difference 
between the lowest and highest month. October, November, and December 
are slightly higher (12,296 / 11,999 / 12,245) compared to August and 
September (11,106 / 12,027), but the difference is not dramatic.

WHY THIS MATTERS FOR THE BUSINESS:
There isn't a single "complaint season" that stands out sharply -- the 
volume the company needs to handle is roughly consistent month to month, 
with a mild uptick in the Oct-Dec period. This means the company doesn't 
need to dramatically scale support staff up or down through the year; 
a small buffer of extra staff during October-December would be enough 
to handle the slight seasonal increase, rather than planning for a major spike.
*/

/*
Query 7 : Business Problem

Among customers who churned, how many complaints did they typically file in the 60 days
right before they left? The company wants to know if there's a 
"final trigger" period — a short window right before churn where 
complaints spike — so they can catch it in time.

*/
SELECT * FROM churn_status,complaints;

WITH churn_recent_complaints AS (
    SELECT 
        ch.customer_id,
        COUNT(co.complaint_id) AS complaints_last_60_days
    FROM churn_status ch
    LEFT JOIN complaints co 
        ON co.customer_id = ch.customer_id 
        AND co.complaint_date BETWEEN DATE_SUB(ch.churn_date, INTERVAL 60 DAY) AND ch.churn_date
    WHERE ch.is_churned = 1
    GROUP BY ch.customer_id
)
SELECT 
    ROUND(AVG(complaints_last_60_days), 2) AS avg_complaints_last_60_days,
    ROUND(100.0 * SUM(CASE WHEN complaints_last_60_days >= 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_with_at_least_1_complaint
FROM churn_recent_complaints;


/*
INSIGHT: Complaints in the 60 Days Before Churn

Churned customers filed an average of only 0.73 complaints in the 60 days 
immediately before they left, and just 50.17% of them filed even a single 
complaint in that window. This is proportional to their overall complaint 
average (2.6 complaints across the full 6 months) -- there's no unusual 
spike concentrated right before churn.

WHY THIS MATTERS FOR THE BUSINESS:
This tells us complaints build up gradually over a customer's tenure 
rather than spiking right before they decide to leave. This means a 
"last-60-days" complaint alert would only catch about half of at-risk 
customers -- the company needs a LONGER observation window (not just 
the final 2 months) to reliably use complaints as an early-warning 
signal, since half of churners don't complain again at all right before 
leaving; they may have already silently decided and just stopped engaging.
*/

/*
Query 8 : Business Problem

The company wants a revenue summary broken down by city AND plan type together, 
but also wants subtotals — total revenue for each city (across all plans), 
and a grand total for the entire company — all in a single report, 
without running separate queries for each level.
*/


SELECT * FROM customers,usage_data;
SELECT 
COALESCE(c.city,'GRAND TOTAL') as City,
COALESCE(c.plan_type,'All Plans') as Plan_Type,
ROUND(SUM(u.recharge_amount),2) as Total_revenue
FROM 
customers c 
JOIN usage_data u ON c.customer_id = u.customer_id 
GROUP BY c.city, c.plan_type WITH ROLLUP
ORDER BY c.city;

/*
INSIGHT: City + Plan Type Revenue Summary (with Subtotals)

The grand total revenue across all customers, cities, and plans over the 
6-month period is ₹27,17,69,677.98 (about ₹27.18 crore). Broadband is the 
single largest revenue contributor in every city, despite having fewer 
customers than Prepaid -- for example, in Gurgaon, Broadband alone brings 
in ₹2,60,57,759.91, more than double what Postpaid brings in and over 
3x what Prepaid brings in, even though Prepaid has the most customers.

Delhi and Gurgaon are the top two revenue-generating cities overall 
(₹5.49 crore and ₹5.50 crore respectively), while Pune generates the 
least (₹2.67 crore) -- consistent with Pune having the smallest customer 
base of all 6 cities.

WHY THIS MATTERS FOR THE BUSINESS:
Even though Broadband has the fewest customers in every city, it drives 
the most revenue everywhere -- confirming what we saw in the churn 
analysis (Broadband customers are the most valuable to retain). This 
single report gives management a city-wise AND plan-wise view in one 
place, so they can decide, for example, whether to push Broadband 
upgrades harder in high-revenue cities like Delhi and Gurgaon, or focus 
on growing the customer base in lower-revenue cities like Pune.
*/

/*
Query 9 : Business Problem

For each customer, how does their total revenue compare to the average revenue of customers 
in their own city? The company wants to identify customers who are significantly 
below their city's average — these customers might be under-utilizing their plan 
and could be upsold, or might be quietly at risk.

*/

SELECT * FROM usage_data, customers;

WITH customer_revenue AS (
    SELECT 
        c.customer_id,
        c.city,
        ROUND(SUM(u.recharge_amount), 2) AS total_revenue
    FROM customers c
    JOIN usage_data u ON c.customer_id = u.customer_id
    GROUP BY c.customer_id, c.city
),
with_city_avg AS (
    SELECT 
        customer_id,
        city,
        total_revenue,
        ROUND(AVG(total_revenue) OVER (PARTITION BY city), 2) AS city_avg_revenue
    FROM customer_revenue
)
SELECT 
    customer_id,
    city,
    total_revenue,
    city_avg_revenue,
    ROUND(total_revenue - city_avg_revenue, 2) AS diff_from_city_avg
FROM with_city_avg
ORDER BY diff_from_city_avg ASC
LIMIT 10;


/*
INSIGHT: Customers Furthest Below Their City's Average Revenue

I found the 10 customers whose total revenue is furthest below their own 
city's average. The city averages themselves are fairly close across 
cities (₹5,459 to ₹5,484), but these specific 10 customers are generating 
only ₹1,147 to ₹1,174 -- roughly ₹4,300-4,330 below what a typical 
customer in their city brings in. That's less than a quarter of their 
city's average.

Most of these customers (7 out of 10) are concentrated in just two cities 
-- Delhi and Bangalore -- which suggests this isn't random noise, but 
likely reflects these customers being on low-usage Prepaid plans with 
minimal recharge activity, while their city's average is pulled up by 
higher-paying Postpaid and Broadband customers.

WHY THIS MATTERS FOR THE BUSINESS:
These customers represent a clear upsell opportunity -- they're active 
enough to still be recharging, but at a much lower level than their peers 
in the same city. Rather than a retention campaign, this calls for a 
targeted upgrade campaign (e.g., "switch to a bigger plan and save") aimed 
specifically at low-revenue customers in Delhi and Bangalore, where the 
gap between low and average spenders is the widest.
*/


/*
Query 10 : Business Problem

Which complaints took the longest to resolve, relative to all other complaints? 
Instead of just looking at raw days, the company wants to know the percentile
for example, "this complaint took longer than 95% of all other complaints"
so they can identify the worst-handled cases for a service-quality review.

*/

SELECT * FROM complaints;

WITH complaint_percentiles AS (
    SELECT 
        complaint_id,
        customer_id,
        complaint_type,
        resolution_days,
        ROUND(PERCENT_RANK() OVER (ORDER BY resolution_days ASC), 4) AS resolution_percentile
    FROM complaints
)
SELECT 
    complaint_type,
    resolution_days,
    resolution_percentile
FROM complaint_percentiles
WHERE resolution_percentile >= 0.95
ORDER BY resolution_days DESC
LIMIT 15;

/*
INSIGHT: Slowest 5% of Complaints by Resolution Time

Every complaint in this "worst 5%" list has the same resolution_days value 
of 14 -- the maximum possible resolution time in the dataset -- and 
because of that, they all share the exact same percentile score (0.9671). 
The complaint types among these slowest cases are fairly evenly mixed 
across Billing Issue, Network Issue, Service Quality, Data/Speed Issue, 
and Other -- no single category dominates the worst-case list.

WHY THIS MATTERS FOR THE BUSINESS:
Two things stand out here. First, 14 days appears to be a hard ceiling in 
how slow resolution ever gets -- there's no single runaway case taking 
20+ days, which is a good sign that there's no completely broken process. 
Second, since the slowest cases are spread evenly across all complaint 
types rather than concentrated in one category, the root cause of the 
worst delays is likely a general operational bottleneck (e.g. short-staffed 
periods or backlog) rather than one specific complaint type being handled 
poorly. The service-quality review should focus on WHEN these 14-day 
cases happen (do they cluster around certain days/weeks?) rather than 
WHICH type of complaint they are.
*/


/*
The company wants a single, reusable summary — for every customer, 
their churn status, usage decline percentage, and total complaint 
count — all in one place, so that any team member (support, marketing, retention) 
can quickly check a customer's risk profile without writing a complex query every time.
*/


CREATE VIEW vw_customer_risk_summary AS
SELECT 
    c.customer_id,
    c.city,
    c.plan_type,
    c.contract_type,
    c.tenure_months,
    c.usage_decline_pct,
    ch.is_churned,
    COUNT(co.complaint_id) AS total_complaints
FROM customers c
JOIN churn_status ch ON c.customer_id = ch.customer_id
LEFT JOIN complaints co ON c.customer_id = co.customer_id
GROUP BY c.customer_id, 
		c.city,
        c.plan_type, 
        c.contract_type, 
        c.tenure_months, 
        c.usage_decline_pct, 
        ch.is_churned;

SELECT * FROM vw_customer_risk_summary LIMIT 10;

/*
INSIGHT: Customer Risk Summary View (vw_customer_risk_summary)

This view consolidates data from 3 separate tables (customers, churn_status, 
complaints) into a single, ready-to-query summary -- giving any team member 
instant access to a customer's churn status, usage decline percentage, and 
total complaint count without writing a multi-table JOIN every time.

WHY THIS MATTERS FOR THE BUSINESS:
This view essentially becomes a live "customer risk dashboard" at the 
database level. For example, the support team can quickly run 
SELECT * FROM vw_customer_risk_summary WHERE usage_decline_pct > 40 
to instantly see every at-risk customer, without needing to understand 
or rewrite the underlying JOIN logic. This saves time, reduces errors from 
people rewriting the same complex query differently, and keeps the "single 
source of truth" for customer risk in one place that can be reused across 
reports, dashboards, or future stored procedures.
*/



/* 
Business Problem

Different regional managers need to see churn statistics for their specific city 
and plan type, 
without writing a new SQL query every time. 
They should be able to just "call" a report with their city and plan as input, 
and get an instant summary.
*/

DELIMITER //
CREATE PROCEDURE sp_churn_report(
	IN p_city VARCHAR(50),
    IN p_plan_type VARCHAR(50)
)
BEGIN
	SELECT	
		city,
        plan_type,
        contract_type,
        COUNT(*) AS Total_customers,
        SUM(is_churned) AS churned_customers,
        ROUND(AVG(is_churned) * 100,2) AS churn_rate_pct
	FROM vw_customer_risk_summary
    WHERE (p_city = 'ALL' OR city = p_city)
		AND (p_plan_type = 'ALL' OR plan_type = p_plan_type)
	GROUP BY city , plan_type, contract_type
    ORDER BY churn_rate_pct DESC;
END //
DELIMITER ;


CALL sp_churn_report('Delhi','Prepaid');
CALL sp_Churn_Report('ALL', 'ALL');

/*
INSIGHT: Stored Procedure sp_Churn_Report

This procedure gives any team member instant, flexible access to churn 
statistics -- by city, by plan type, or both -- without needing to know 
SQL or write a query themselves. Testing confirmed it correctly filters 
down to a single city+plan combination (e.g., Delhi + Prepaid returned 
4,032 customers with a 23.81% churn rate) and also correctly returns the 
full dataset when 'ALL' is passed for either parameter.

WHY THIS MATTERS FOR THE BUSINESS:
Regional managers or the retention team can now self-serve their own 
reports on demand -- a Delhi manager can run CALL sp_Churn_Report('Delhi', 
'ALL') to see their city's full picture, while a company-wide analyst can 
run CALL sp_Churn_Report('ALL', 'ALL') for the big picture -- all using 
the exact same procedure. This removes the dependency on a data analyst 
being available every time someone needs a churn number, and ensures 
everyone is pulling from the same consistent logic (via the underlying view).
*/


/* 
The support team wants to analyze complaint trends for any custom date range they choose 
(e.g., "show me last month's complaints" or "show me complaints from the festival season"),
 without asking a data analyst to write a new query every time.
*/

DELIMITER //

CREATE PROCEDURE sp_Complaint_Analysis(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT 
        co.complaint_type,
        COUNT(*) AS total_complaints,
        ROUND(AVG(co.resolution_days), 2) AS avg_resolution_days,
        ROUND(AVG(ch.is_churned) * 100, 2) AS churn_rate_pct
    FROM complaints co
    JOIN churn_status ch ON co.customer_id = ch.customer_id
    WHERE co.complaint_date BETWEEN p_start_date AND p_end_date
    GROUP BY co.complaint_type
    ORDER BY total_complaints DESC;
END //

DELIMITER ;


CALL sp_Complaint_Analysis('2025-10-01', '2025-12-31');

/*
INSIGHT: Stored Procedure sp_Complaint_Analysis

I tested this procedure for the Oct-Dec 2025 period (the festival/year-end 
season). Network Issue was the most common complaint in this window 
(9,245 complaints), followed closely by Billing Issue (9,147). Resolution 
times and churn rates remain consistent with the overall pattern we saw 
earlier -- all around 5.4-5.5 days and 38-40% churn, regardless of 
complaint type or the specific date range chosen.

WHY THIS MATTERS FOR THE BUSINESS:
The support team can now pull complaint trends for ANY custom period on 
demand -- a specific month, a festival season, a billing cycle -- without 
waiting on a data analyst. This is especially useful for planning staffing: 
if the team wants to check whether Diwali season complaints spike, they 
can run this procedure for that exact date window and get an instant 
answer instead of requesting a one-off report.
*/

















