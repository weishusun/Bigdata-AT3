{{ config(materialized='table') }}

select distinct
  property_type,
  room_type,
  accommodates
from {{ ref('stg_airbnb') }}
where property_type is not null
  and room_type   is not null
  and accommodates is not null
order by 1,2,3
