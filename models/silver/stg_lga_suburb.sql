{{ config(materialized='table') }}

with ls as (
  select
    trim(suburb_name) as suburb,
    trim(lga_name)    as lga_name
  from {{ source('bronze', 'lga_suburb_raw') }}
),
lc as (
  select
    trim(lga_code)::text as lga_code,
    trim(lga_name)       as lga_name
  from {{ ref('stg_lga_code') }}
)
select
  ls.suburb,
  lc.lga_code
from ls
left join lc
  on lower(ls.lga_name) = lower(lc.lga_name)
where ls.suburb is not null and ls.suburb <> ''
