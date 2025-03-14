/* 
Q1: What are the top 5 brands by receipts scanned for most recent month?

Analysis: The sample dataset has max scanned date of 2021-03 for which none of the barcodes match with brand dataset, hence the answer to the exact question will return no records.
But if the date filter is removed, a result can be found for 2021-01 where few barcodes match and a result is obtained. 
    Note: The ranking logic used is dense_rank() to accommodate edge-case scenarios where two brands may share the same number of receipts for that month and top N rank will consider all the brands that share the same X rank, without skipping.
*/
with 
brand_by_receipts as (
select 
    dim_brand.brand_name
    ,count(distinct fact_receipt.receipt_uuid) as receipt_scanned
from fact_receipt 
join fact_receipt_item
    on fact_receipt.receipt_uuid = fact_receipt_item.receipt_uuid
join dim_brand
    on fact_receipt_item.barcode = dim_brand.barcode
where 1=1
and to_char(fact_receipt.scanned_date,'YYYY-MM') = (select to_char(MAX(scanned_date), 'YYYY-MM') from fact_receipt)
group by 1
)
,top_x_brand_by_receipt as (
select 
    brand_name
    ,receipt_scanned
    ,dense_rank() over (order by receipt_scanned desc) as ranking_order
from brand_by_receipts
)
select 
    brand_name
from top_x_brand_by_receipt
where ranking_order <= 5