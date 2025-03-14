{{
    config(
        materialized='table'
        ,transient=false
        ,description='Receipt fact table representing header-level information of transactions'
    )
}}
select 
    id as receipt_uuid
    ,bonusPointsEarned as bonus_points_earned
    ,bonusPointsEarnedReason as bonus_points_earned_reason
    ,createDate as created_date
    ,dateScanned as scanned_date
    ,finishedDate as finished_date
    ,modifyDate as modified_date
    ,pointsAwardedDate as points_awarded_date
    ,purchaseDate as purchased_date
    ,pointsEarned as points_earned
    ,purchasedItemCount as purchased_item_count
    ,rewardsReceiptItemList as rewards_receipt_item_list
    ,rewardsReceiptStatus as rewards_receipt_status
    ,totalSpent as total_spent
    ,userId as user_id
from {{ ref('raw_receipt') }}
order by 1