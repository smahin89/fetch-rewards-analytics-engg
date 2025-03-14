/*
Q2: How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?

Analysis: The sample dataset has max scanned date of 2021-03 for which none of the barcodes match with brand dataset, hence the answer to the exact question will return no records.
Likewise for the previous month 2021-02, there is no match. But assuming that there are records that match beyond the given sample dataset, then a comparitive analysis can be achieved by running this script.

*/
with 
brand_by_receipts_recent_month as (
select 
    dim_brand.brand_name
    ,count(distinct fact_receipt.receipt_uuid) as receipt_scanned
from fact_receipt 
join fact_receipt_item
    on fact_receipt.receipt_uuid = fact_receipt_item.receipt_uuid
join dim_brand
    on fact_receipt_item.barcode = dim_brand.barcode
where 1=1
and to_char(fact_receipt.scanned_date,'YYYY-MM') = (select to_char(max(scanned_date), 'YYYY-MM') from fact_receipt)
group by 1
)
,top_x_brand_by_receipts_recent_month as (
select 
    brand_name
    ,receipt_scanned
    ,dense_rank() over (order by receipt_scanned desc) as ranking_order
from brand_by_receipts_recent_month
)
,recent_month as (
select 
    brand_name
    ,ranking_order
from top_x_brand_by_receipts_recent_month
where ranking_order <= 5
)
-- repeat for previous month 
,brand_by_receipts_previous_month as (
select 
    dim_brand.brand_name
    ,count(distinct fact_receipt.receipt_uuid) as receipt_scanned
from fact_receipt 
join fact_receipt_item
    on fact_receipt.receipt_uuid = fact_receipt_item.receipt_uuid
join dim_brand
    on fact_receipt_item.barcode = dim_brand.barcode
where 1=1
and to_char(fact_receipt.scanned_date,'YYYY-MM') = (select to_char(dateadd(month, -1, max(scanned_date)), 'YYYY-MM') from fact_receipt)
group by 1
)
,top_x_brand_by_receipts_previous_month as (
select 
    brand_name
    ,receipt_scanned
    ,dense_rank() over (order by receipt_scanned desc) as ranking_order
from brand_by_receipts_previous_month
)
,previous_month as (
select 
    brand_name
    ,ranking_order
from top_x_brand_by_receipts_previous_month
where ranking_order <= 5
)
select 
    recent_month.ranking_order
    ,recent_month.brand_name
    ,'most recent month' as comparing_parameter
from recent_month 
union all
select
    previous_month.ranking_order
    ,previous_month.brand_name
    ,'previous month' as comparing_parameter
from previous_month