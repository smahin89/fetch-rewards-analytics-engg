{{
    config(
        materialized='table'
        ,transient=false
        ,description='Receipt item fact table representing detail-level information of transaction line-items'
    )
}}
select
    receipt_item_key
    ,receipt_uuid
    ,user_id
    ,partnerItemId as partner_item_id
    ,barcode
    ,description
    ,finalPrice as final_price
    ,itemPrice as item_price
    ,needsFetchReview as needs_fetch_review
    ,needsFetchReviewReason as needs_fetch_review_reason
    ,pointsNotAwardedReason as points_not_awarded_reason
    ,pointsPayerId as points_payer_id
    ,preventTargetGapPoints as prevent_target_gap_points
    ,quantityPurchased as quantity_purchased
    ,rewardsGroup as rewards_group
    ,rewardsProductPartnerId as rewards_product_partner_id
    ,userFlaggedBarcode as user_flagged_barcode
    ,userFlaggedDescription as user_flagged_description
    ,userFlaggedNewItem as user_flagged_new_item
    ,userFlaggedPrice as user_flagged_price
    ,userFlaggedQuantity as user_flagged_quantity
    ,competitiveProduct as competitive_product_flag
from {{ ref('raw_receipt_item') }}