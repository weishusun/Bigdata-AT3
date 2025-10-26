{{ config(materialized='table') }}

select
  listing_date                                  as date_id,
  extract(year  from listing_date)::int         as year,
  extract(month from listing_date)::int         as month,
  to_char(listing_date, 'YYYY-MM')              as year_month
from {{ ref('stg_airbnb') }}
group by 1,2,3,4
