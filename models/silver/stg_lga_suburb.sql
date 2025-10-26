{{ config(materialized='table') }}

with ls as (
  select
    trim(suburb_name) as suburb,
    trim(lga_name)    as lga_name
  from {{ source('bronze', 'lga_suburb_raw') }}
  where suburb_name is not null and suburb_name <> ''
),
lc as (
  select
    trim(lga_code)::text as lga_code,
    trim(lga_name)       as lga_name
  from {{ ref('stg_lga_code') }}
)
select
  ls.suburb,
  lc.lga_code,
  lc.lga_name
from ls
left join lc
  on regexp_replace(lower(ls.lga_name), '[^a-z0-9]', '', 'g')
   = regexp_replace(lower(lc.lga_name), '[^a-z0-9]', '', 'g')
