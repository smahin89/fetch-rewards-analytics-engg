/*
Q4: When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

Analysis: There is no 'Accepted' status in rewardsReceiptStatus field, but if 'Finished' is assumed to be 'Accepted', then 'Accepted' or 'Finished' is greater than 'Rejected'.
*/
select 
    rewards_receipt_status
    ,coalesce(sum(purchased_item_count),0) as total_number_of_items_purchased
from fact_receipt
group by 1
order by 2 desc