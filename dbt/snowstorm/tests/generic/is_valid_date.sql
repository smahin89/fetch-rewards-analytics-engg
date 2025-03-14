{% test is_valid_date(model, column_name) %}

select * 
from {{ model }}
where {{ column_name }} < '1900-01-01'
and {{ column_name }} is not null

{% endtest %}