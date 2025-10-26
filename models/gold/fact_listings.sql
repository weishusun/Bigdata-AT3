{{ config(materialized='table') }}

with base as (
  select
    listing_id,
    host_id,
    suburb,
    property_type,
    room_type,
    accommodates,
    price,
    has_availability,
    availability_30,
    number_of_reviews,
    review_rating,
    listing_date
  from {{ ref('stg_airbnb') }}
  where listing_id is not null
),
dd as (
  select date_id from {{ ref('dim_date') }}
)
select
  b.listing_id,
  b.host_id,
  b.suburb,
  b.property_type,
  b.room_type,
  b.accommodates,
  b.price,
  b.has_availability,
  b.availability_30,
  b.number_of_reviews,
  b.review_rating,
  b.listing_date as date_id
from base b
join dd on b.listing_date = dd.date_id
