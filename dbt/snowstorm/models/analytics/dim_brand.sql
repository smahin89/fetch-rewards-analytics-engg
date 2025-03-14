{{
    config(
        materialized='table'
        ,transient=false
        ,description='Brand dimension table with brand_key representing unique record'
    )
}}
with brand_stage_1 as (
select 
    id as brand_uuid
    ,barcode
    ,brandCode as brand_code
    ,category as brand_category
    ,categoryCode as brand_category_code
    ,cpg_id
    ,cpg_ref
    ,topBrand as top_brand_flag
    ,name as brand_name
from {{ ref('raw_brand') }}
)
select 
    row_number() over (order by brand_uuid, barcode) as brand_key
    ,*
from brand_stage_1