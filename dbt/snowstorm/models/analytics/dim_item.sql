{{
    config(
        materialized='table'
        ,transient=false
        ,description='Item dimension table with item_key representing unique record'
    )
}}
with 
item_list_flatten_n_dedup as (
select 
    distinct 
    t.value:"barcode"::varchar as barcode
    ,t.value:"description"::varchar as description
    ,try_to_boolean(t.value:"competitiveProduct"::varchar) as competitiveProduct
from {{ ref('raw_receipt') }},
    lateral flatten(input => rewardsReceiptItemList, outer => true) t
)
select 
    row_number() over (order by barcode,description,competitiveProduct nulls last) as item_key
    ,coalesce(barcode, 'Unknown') as barcode
    ,coalesce(description, 'Unknown') as description
    ,coalesce(competitiveProduct, FALSE) as competitive_product_flag
from item_list_flatten_n_dedup
where 1=1
and (description is not null or barcode is not null)
union all
select 
    -9 as item_key
    ,'Unknown' as barcode
    ,'Unknown' as description
    ,FALSE as competitive_product_flag

