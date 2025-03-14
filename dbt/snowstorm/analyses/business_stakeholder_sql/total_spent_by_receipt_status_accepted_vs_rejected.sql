/*
Q3: When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

Analysis: There is no 'Accepted' status in rewardsReceiptStatus field, but if 'Finished' is assumed to be 'Accepted', then 'Accepted' or 'Finished' is greater than 'Rejected'.
*/
select 
    rewards_receipt_status
    ,coalesce(avg(total_spent),0) as average_spend
from fact_receipt
group by 1
order by 2 desc