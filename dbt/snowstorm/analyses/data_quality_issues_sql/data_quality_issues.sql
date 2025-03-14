/********************************************************/
/* Data issue #1 */
/* Several rewardsproductpartnerid value is null within the receipts 
dataset's rewards_receipt_item_list collection but the value exists for 
another row for the same rewardsGroup */
/* 
| REWARDSGROUP             | REWARDSPRODUCTPARTNERID  |
|--------------------------|--------------------------|
| BEN AND JERRYS ICE CREAM | 5332f5f6e4b03c9a25efd0b4 |
| BEN AND JERRYS ICE CREAM | null                     |
| BEST FOODS MAYONNAISE    | 559c2234e4b06aca36af13c6 |
| BEST FOODS MAYONNAISE    | null                     |
*/
/* Query to find out sample example is given below */
with cte as (
select distinct 
    t.value:"rewardsGroup"::varchar as rewardsGroup
    ,t.value:"rewardsProductPartnerId"::varchar as rewardsProductPartnerId
from raw_receipt, lateral flatten(rewards_receipt_item_list, outer => true) t
) 
select 
    rewardsGroup
    ,rewardsProductPartnerId
from cte
where rewardsgroup in ('BEN AND JERRYS ICE CREAM','BEST FOODS MAYONNAISE');

/* Assuming that there are no controls or fixes that can be applied in the source, a 
potential improvement can be applied in the data pipeline responsible for deriving the 
analytical objects by doing a self-join/look-up and back-fill the missing entries, 
which can help achieve reduction in null within the dataset from 5% to 2% */
/* This issue has been addressed as part of the code-base being submitted and 
can be found as part of "dim_reward_group" sql logic which can be found 
in this path of the repo: "/dbt/snowstorm/models/analytics/dim_reward_group.sql" */

/********************************************************/
/* Data issue #2 */
/* Several rewardsGroup value within receipts dataset's rewards_receipt_item_list 
collection is null but the value exists for another row for the same rewardsproductpartnerid */
/*
| REWARDSGROUP        | REWARDSPRODUCTPARTNERID  |
|---------------------|--------------------------|
| MILLER LITE 24 PACK | 5332f709e4b03c9a25efd0f1 |
| null                | 5332f709e4b03c9a25efd0f1 |
 */
/* An improvement can be applied in the pipeline to back-fill and that can help in 
reduction in null from 11% to 2% */

/********************************************************/
/* Data issue #3 */
/* Some reward product partner id have more than 1 reward group association, which can 
cause issues in programmatic handling of the previously defined data issue #2. These would 
need to be reviewed with business stakeholders from a human-in-the-loop process and 
can undergo a potential entity resolution */
/* Query to retrieve such records is given below */
with cte as (
select distinct 
t.value:"rewardsGroup"::varchar as rewardsGroup
,t.value:"rewardsProductPartnerId"::varchar as rewardsProductPartnerId
from raw_receipt, lateral flatten(rewards_receipt_item_list, outer => true) t
) 
select 
    rewardsGroup
    ,rewardsProductPartnerId
from cte
where rewardsproductpartnerid in ('550b2565e4b001d5e9e4146f');

/********************************************************/
/* Data issue #4 */
/* There are about 117 user ids which are present in "receipts" data but missing in "user" data 
implying user records not in sync. These users would not be under Fetch review process
*/
select distinct 
    user_id 
from raw_receipt 
where user_id not in (select distinct user_id from raw_user); 

/********************************************************/
/* Data issue #5 */
/* Out of 495 records in "user" dataset, there are 283 duplicate entries, which 
upon cleanup becomes 212 unique records in total
*/
/* Query to find the list of user id which are duplicate */
select 
    user_id 
from raw_user 
group by 1 
having count(1)>1;
/* An improvement has been identified to perform this dedup in the 
data pipeline for processing the records from raw zone to analytics zone.
The updated dataset can be found in the following 
repo path: "/dbt/snowstorm/models/analytics/dim_cd_user.sql" */
