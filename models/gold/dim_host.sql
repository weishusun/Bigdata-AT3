{{ config(materialized='table') }}


select distinct on (a.host_id)
  a.host_id,
  a.host_name,
  a.host_since,
  a.host_is_superhost,
  a.host_neighbourhood
from {{ ref('stg_airbnb') }} a
where a.host_id is not null
order by a.host_id, a.scraped_date desc
