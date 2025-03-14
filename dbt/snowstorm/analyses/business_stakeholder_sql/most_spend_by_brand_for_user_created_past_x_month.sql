/*
Q5: Which brand has the most spend among users who were created within the past 6 months?

Analysis: The sample data had old dates from 2021 and before, so I am assuming that the maximum date within this sample is the most recent date at the time of analysis. 
Following along, I am looking back 6 months from that maximum date to consider the window. If this table get populated with fresh dates, still the max logic will hold true
and retrieve the current date or newer date whichever is most recent. Based on that, Cracker Barrel Cheese was found to be the brand name with highest spend.
*/
with 
users_created_last_x_months as (
select user_id
from dim_user
where 
created_date between dateadd(month,-6, (select max(created_date) from dim_user)) and (select max(created_date) from dim_user)
)
,spend_by_brand_and_user as (
select 
    dim_brand.brand_name
    ,sum(fact_receipt_item.finalprice) as total_spent
from fact_receipt_item
join users_created_last_x_months
    on fact_receipt_item.user_id = users_created_last_x_months.user_id
join dim_brand
    on fact_receipt_item.barcode = dim_brand.barcode
group by 1
)
select 
    brand_name
from spend_by_brand_and_user
where total_spent = (select max(total_spent) from spend_by_brand_and_user)