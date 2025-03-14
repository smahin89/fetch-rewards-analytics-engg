/*
Q6: Which brand has the most transactions among users who were created within the past 6 months?

Analysis: Each receipt with its unique uuid is the transaction, within which, one or more brands can be sold. So, a unique count of the receipt
per brand name will provide insight on the total transaction per brand and then it can be filtered by the user data for the requested date period.
*/
with 
users_created_last_x_months as (
select user_id
from dim_user
where 
created_date between dateadd(month,-6, (select max(created_date) from dim_user)) and (select max(created_date) from dim_user)
)
,txn_by_brand_and_user as (
select 
    dim_brand.brand_name
    ,count(distinct fact_receipt_item.receipt_uuid) as total_transaction
from fact_receipt_item
join users_created_last_x_months
    on fact_receipt_item.user_id = users_created_last_x_months.user_id
join dim_brand
    on fact_receipt_item.barcode = dim_brand.barcode
group by 1
)
select 
    brand_name
from txn_by_brand_and_user
where total_transaction = (select max(total_transaction) from txn_by_brand_and_user)
