{{
    config(
        materialized='table'
        ,transient=false
        ,description='Transformation from semi-structured to relational-structured format'
    )
}}
select 
    vdt:"_id":"$oid"::varchar as id
    ,vdt:"barcode"::varchar as barcode
    ,vdt:"brandCode"::varchar as brandCode
    ,vdt:"category"::varchar as category
    ,vdt:"categoryCode"::varchar as categoryCode
    ,vdt:"cpg":"$id":"$oid"::varchar as cpg_id
    ,vdt:"cpg":"$ref"::varchar as cpg_ref
    ,vdt:"topBrand"::varchar as topBrand
    ,vdt:"name"::varchar as name
from {{ source('landing','ldg_brands') }}