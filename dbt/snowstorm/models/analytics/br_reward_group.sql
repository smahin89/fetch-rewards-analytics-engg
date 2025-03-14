{{
    config(
        materialized='table'
        ,transient=false
        ,description='Reward group bridge table to connect the reward group dimension with receipt_item fact table representing many-t-many relationship'
    )
}}
with 
rewards_group_dedup as (
select 
    distinct
    id as receipt_uuid
    ,t.value:"partnerItemId"::number as partnerItemId
    ,t.value:"rewardsGroup"::varchar as rewardsGroup
    ,t.value:"rewardsProductPartnerId"::varchar as rewardsProductPartnerId
from {{ ref('raw_receipt')}},
    lateral flatten(input => rewardsReceiptItemList, outer => true) t
)
,reward_group_cleanup_stage_1 as (
select 
    rewardsGroup
    ,rewardsProductPartnerId
from rewards_group_dedup
where rewardsProductPartnerId is not null
)
,reward_group_cleanup_stage_2 as (
select 
    receipt_uuid
    ,partnerItemId
    ,r1.rewardsGroup
    ,coalesce(r1.rewardsProductPartnerId,r2.rewardsProductPartnerId) as rewardsProductPartnerId
from rewards_group_dedup r1
left join reward_group_cleanup_stage_1 r2
    on r1.rewardsGroup = r2.rewardsGroup
)
,reward_group_cleanup_stage_3 as (
select 
    rewardsGroup
    ,rewardsProductPartnerId
from rewards_group_dedup
where rewardsGroup is not null
)
,reward_group_final as (
select 
    distinct
    receipt_uuid
    ,partnerItemId
    ,s2.rewardsProductPartnerId as rewards_product_partner_id
    ,coalesce(s2.rewardsGroup, s3.rewardsGroup) as rewards_group
from reward_group_cleanup_stage_2 as s2
left join reward_group_cleanup_stage_3 as s3
    on s2.rewardsProductPartnerId = s3.rewardsProductPartnerId
where 
rewards_product_partner_id is not null or rewards_group is not null
)
select 
    reward_group_final.receipt_uuid
    ,coalesce(reward_group_final.partnerItemId,0) as partner_item_id
    ,rewards_group_key
from reward_group_final
left join dim_reward_group
    on coalesce(reward_group_final.rewards_group, 'Unknown')  = dim_reward_group.REWARDS_GROUP
    and coalesce(reward_group_final.rewards_product_partner_id, 'Unknown') = dim_reward_group.rewards_product_partner_id
order by reward_group_final.receipt_uuid, partnerItemId, rewards_group_key