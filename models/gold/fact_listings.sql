{{ config(materialized='table') }}

with f as (
  select
    a.listing_id,
    a.host_id,
    upper(trim(regexp_replace(a.suburb, '\s+', ' ', 'g'))) as suburb,
    a.property_type,
    a.room_type,
    a.accommodates,
    a.price,
    a.has_availability,
    a.availability_30,
    a.number_of_reviews,
    a.review_rating,
    a.date_id::date as date_id        
  from {{ ref('stg_airbnb') }} a
  where a.listing_id is not null
)
select
  f.listing_id,
  f.host_id,
  f.suburb,
  f.property_type,
  f.room_type,
  f.accommodates,
  f.price,
  f.has_availability,
  f.availability_30,
  f.number_of_reviews,
  f.review_rating,
  f.date_id
from f

