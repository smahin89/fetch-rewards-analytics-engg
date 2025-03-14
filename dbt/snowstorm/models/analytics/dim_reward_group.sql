{{
    config(
        materialized='table'
        ,transient=false
        ,description='Reward group dimension table with rewards_group_key representing unique record'
    )
}}
with 
reward_group_flatten_n_dedup as (
select 
    distinct
    t.value:"rewardsGroup"::varchar as rewardsGroup
    ,t.value:"rewardsProductPartnerId"::varchar as rewardsProductPartnerId
from {{ ref('raw_receipt')}},
    lateral flatten(input => rewardsReceiptItemList, outer => true) t
)
/* Transformations to handle few data quality issues 
   Data issue #1: several rewardsGroup value is null but valid value exists for another row for the same rewardsproductpartnerid 
    Improvement: Reduction in null from 5% to 2% */
/* Begin */
,reward_group_cleanup_stage_1 as (
select 
    rewardsGroup
    ,rewardsProductPartnerId
from reward_group_flatten_n_dedup
where rewardsProductPartnerId is not null
)
,reward_group_cleanup_stage_2 as (
select 
    r1.rewardsGroup
    ,coalesce(r1.rewardsProductPartnerId,r2.rewardsProductPartnerId) as rewardsProductPartnerId
from reward_group_flatten_n_dedup r1
left join reward_group_cleanup_stage_1 r2
    on r1.rewardsGroup = r2.rewardsGroup
)
/* End */
/* Transformations to handle few data quality issues
   Data issue #2: several rewardsproductpartnerid value is null but the value exists for another row for the same rewardsGroup 
    Improvement: Reduction in null from 11% to 2% */
/* Begin */
,reward_group_cleanup_stage_3 as (
select 
    rewardsGroup
    ,rewardsProductPartnerId
from reward_group_flatten_n_dedup
where rewardsGroup is not null
)
,reward_group_final as (
select 
    distinct
    s2.rewardsProductPartnerId as rewards_product_partner_id
    ,coalesce(s2.rewardsGroup, s3.rewardsGroup) as rewards_group
from reward_group_cleanup_stage_2 as s2
left join reward_group_cleanup_stage_3 as s3
    on s2.rewardsProductPartnerId = s3.rewardsProductPartnerId
where 
rewards_product_partner_id is not null or rewards_group is not null
)
/* End */
select 
    row_number() over (order by rewards_product_partner_id, rewards_group) as rewards_group_key
    ,coalesce(rewards_product_partner_id, 'Unknown') as rewards_product_partner_id
    ,coalesce(rewards_group, 'Unknown') as rewards_group
from reward_group_final
union all
select 
    -9 as rewards_group_key
    ,'Unknown' as rewards_product_partner_id
    ,'Unknown' as rewards_group
order by 1,2,3