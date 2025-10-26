{% test no_unknown_lga(model, column_name) %}
select *
from {{ model }}
where {{ column_name }} = 'UNKNOWN'
{% endtest %}
