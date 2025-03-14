{{
    config(
        materialized='table'
        ,transient=false
        ,description='Fetch review bridge table to connect the fetch review dimension with receipt_item fact table representing many-t-many relationship'
    )
}}
with 
fetch_review_flatten_n_dedup as (
select 
    distinct 
    id as receipt_uuid
    ,coalesce(try_to_boolean(t.value:"needsFetchReview"::varchar), FALSE) as needsFetchReview
    ,t.value:"needsFetchReviewReason"::varchar as needsFetchReviewReason
    ,coalesce(t.value:"partnerItemId"::number, 0) as partnerItemId
from {{ ref('raw_receipt')}},
    lateral flatten(input => rewardsReceiptItemList, outer => true) t
)
select 
    review_dedup.receipt_uuid
    ,partnerItemId as partner_item_id
    ,dim_fetch_review.needs_fetch_review_key
from fetch_review_flatten_n_dedup
left join {{ ref('dim_fetch_review') }}
    on coalesce(review_dedup.needsFetchReview, FALSE) = dim_fetch_review.needs_fetch_review_flag
    and coalesce(review_dedup.needsFetchReviewReason, 'Not Applicable') = dim_fetch_review.needs_fetch_review_reason
order by review_dedup.receipt_uuid, partnerItemId