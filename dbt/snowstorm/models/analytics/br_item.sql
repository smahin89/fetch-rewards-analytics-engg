{{
    config(
        materialized='table'
        ,transient=false
        ,description='Bridge between item dimension and receipt_item fact table representing many-to-many relationship'
    )
}}
with 
item_list_flatten_n_dedup as (
select 
    distinct 
    id as receipt_uuid
    ,t.value:"partnerItemId"::number as partner_item_id
    ,t.value:"barcode"::varchar as barcode
    ,t.value:"description"::varchar as description
    ,try_to_boolean(t.value:"competitiveProduct"::varchar) as competitive_product_flag
from {{ ref('raw_receipt') }},
    lateral flatten(input => rewardsReceiptItemList, outer => true) t
)
select 
    itemlist_dedup.receipt_uuid
    ,dim_item.item_key
    ,itemlist_dedup.partner_item_id
from item_list_flatten_n_dedup
left join {{ ref('dim_item') }}
    on coalesce(itemlist_dedup.barcode, 'Unknown') = dim_item.barcode
    and coalesce(itemlist_dedup.description, 'Unknown') = dim_item.description
    and coalesce(itemlist_dedup.competitive_product_flag, FALSE) = dim_item.competitive_product_flag
order by receipt_uuid, partner_item_id, item_key