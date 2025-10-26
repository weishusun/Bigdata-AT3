{{ config(materialized='table') }}

with g02 as (
  select
    trim(lga_code_2016)::text       as lga_code,
    median_age_persons::numeric     as median_age_persons,
    average_household_size::numeric as avg_household_size
  from {{ source('bronze', 'census_g02_raw') }}
)

select
  g02.lga_code,
  lc.lga_name,
  g02.median_age_persons,
  g02.avg_household_size
from g02
left join {{ ref('stg_lga_code') }} lc using (lga_code)
