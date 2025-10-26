{{ config(materialized='table') }}

with d as (
  select distinct date_id
  from {{ ref('stg_airbnb') }}
  where date_id is not null
)
select
  d.date_id,
  extract(year  from d.date_id)::int  as year,
  extract(month from d.date_id)::int  as month,
  to_char(d.date_id, 'YYYY-MM')       as year_month
from d
order by d.date_id
