{% test is_boolean(model, column_name) %}

select * 
from {{ model }}
where is_boolean({{ column_name }}) <> true

{% endtest %}