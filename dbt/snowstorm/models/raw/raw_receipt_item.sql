{{
    config(
        materialized='table'
        ,transient=false
        ,description='Transformation from semi-structured to relational-structured format'
    )
}}
with receipt_stage_1 as (
select 
    vdt:"_id":"$oid"::varchar as receipt_uuid
    ,vdt:"rewardsReceiptItemList"::variant as rewardsReceiptItemList
    ,vdt:"userId"::varchar as user_id
from {{ source('landing','ldg_receipts') }}
)
,receipt_stage_2 as (
select
    receipt_uuid
    ,user_id
    ,coalesce(t.value:"partnerItemId"::number,0) as partnerItemId
    ,t.value:"barcode"::varchar as barcode
    ,t.value:"description"::varchar as description
    ,t.value:"finalPrice"::float as finalPrice
    ,t.value:"itemPrice"::float as itemPrice
    ,try_to_boolean(t.value:"needsFetchReview"::varchar) as needsFetchReview
    ,t.value:"needsFetchReviewReason"::varchar as needsFetchReviewReason
    ,t.value:"pointsNotAwardedReason"::varchar as pointsNotAwardedReason
    ,t.value:"pointsPayerId"::varchar as pointsPayerId
    ,try_to_boolean(t.value:"preventTargetGapPoints"::varchar) as preventTargetGapPoints
    ,t.value:"quantityPurchased"::number as quantityPurchased
    ,t.value:"rewardsGroup"::varchar as rewardsGroup
    ,t.value:"rewardsProductPartnerId"::varchar as rewardsProductPartnerId
    ,t.value:"userFlaggedBarcode"::varchar as userFlaggedBarcode
    ,t.value:"userFlaggedDescription"::varchar as userFlaggedDescription
    ,try_to_boolean(t.value:"userFlaggedNewItem"::varchar) as userFlaggedNewItem
    ,t.value:"userFlaggedPrice"::float as userFlaggedPrice
    ,t.value:"userFlaggedQuantity"::number as userFlaggedQuantity
    ,try_to_boolean(t.value:"competitiveProduct"::varchar) as competitiveProduct
from receipt_stage_1,
    lateral flatten(input => rewardsReceiptItemList, outer => true) t
)
select 
    md5(concat(receipt_uuid, '|',partneritemid)) as receipt_item_key
    ,*
from receipt_stage_2