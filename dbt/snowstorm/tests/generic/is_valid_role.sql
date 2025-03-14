{% test is_valid_role(model, column_name) %}

select * 
from {{ model }}
where lower({{ column_name }}) <> 'consumer'

{% endtest %}