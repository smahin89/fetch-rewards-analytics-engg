{{
    config(
        materialized='table'
        ,transient=false
        ,description='Transformation from semi-structured to relational-structured format'
    )
}}
select 
    vdt:"_id":"$oid"::varchar as id
    ,vdt:"bonusPointsEarned"::number as bonusPointsEarned
    ,vdt:"bonusPointsEarnedReason"::varchar as bonusPointsEarnedReason
    ,TO_TIMESTAMP_NTZ(vdt:"createDate":"$date"::varchar) as createDate
    ,TO_TIMESTAMP_NTZ(vdt:"dateScanned":"$date"::varchar) as dateScanned
    ,TO_TIMESTAMP_NTZ(vdt:"finishedDate":"$date"::varchar) as finishedDate
    ,TO_TIMESTAMP_NTZ(vdt:"modifyDate":"$date"::varchar) as modifyDate
    ,TO_TIMESTAMP_NTZ(vdt:"pointsAwardedDate":"$date"::varchar) as pointsAwardedDate
    ,TO_TIMESTAMP_NTZ(vdt:"purchaseDate":"$date"::varchar) as purchaseDate
    ,vdt:"pointsEarned"::number as pointsEarned
    ,vdt:"purchasedItemCount"::number as purchasedItemCount
    ,vdt:"rewardsReceiptItemList"::variant as rewardsReceiptItemList
    ,vdt:"rewardsReceiptStatus"::varchar as rewardsReceiptStatus
    ,vdt:"totalSpent"::number as totalSpent
    ,vdt:"userId"::varchar as userId
from {{ source('landing','ldg_receipts') }}