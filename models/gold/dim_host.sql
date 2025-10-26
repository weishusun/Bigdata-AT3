{{ config(materialized='table') }}

with latest as (
  select
    host_id,
    max(scraped_date) as latest_scraped_date
  from {{ ref('stg_airbnb') }}
  where host_id is not null
  group by host_id
)
select
  a.host_id,
  a.host_name,
  a.host_since,
  a.host_is_superhost,
  a.host_neighbourhood
from latest l
join {{ ref('stg_airbnb') }} a
  on a.host_id = l.host_id
 and a.scraped_date = l.latest_scraped_date
group by 1,2,3,4,5
