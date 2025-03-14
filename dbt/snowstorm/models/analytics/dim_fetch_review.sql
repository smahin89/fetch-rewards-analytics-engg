{{
    config(
        materialized='table'
        ,transient=false
        ,description='Fetch review dimension table with needs_fetch_review_key representing unique record'
    )
}}
with 
fetch_review_flatten_n_dedup as (
select 
    distinct 
    coalesce(try_to_boolean(t.value:"needsFetchReview"::varchar), FALSE) as needsFetchReview
    ,t.value:"needsFetchReviewReason"::varchar as needsFetchReviewReason
from {{ ref('raw_receipt')}},
    lateral flatten(input => rewardsReceiptItemList, outer => true) t
)
select 
    row_number() over (order by needsFetchReview, needsFetchReviewReason nulls last) as needs_fetch_review_key
    ,needsFetchReview as needs_fetch_review_flag
    ,needsFetchReviewReason as needs_fetch_review_reason
from fetch_review_flatten_n_dedup
where needsFetchReview = TRUE
union all
select 
    -9 as needs_fetch_review_key
    ,FALSE as needs_fetch_review_flag
    ,'Not Applicable' as needs_fetch_review_reason