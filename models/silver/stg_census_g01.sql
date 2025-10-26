{{ config(materialized='table') }}

with g01 as (
  select
    trim(lga_code_2016)::text                 as lga_code,
    median_mortgage_repay_monthly::numeric    as median_mortgage_monthly,
    median_rent_weekly::numeric               as median_rent_weekly,
    median_tot_prsnl_inc_weekly::numeric      as median_income_weekly,
    median_tot_fam_inc_weekly::numeric        as median_family_income_weekly,
    median_tot_hhd_inc_weekly::numeric        as median_household_income_weekly,
    average_num_psns_per_bedroom::numeric     as avg_persons_per_bedroom
  from {{ source('bronze', 'census_g02_raw') }} 
)

select
  g01.lga_code,
  lc.lga_name,
  g01.median_mortgage_monthly,
  g01.median_rent_weekly,
  g01.median_income_weekly,
  g01.median_family_income_weekly,
  g01.median_household_income_weekly,
  g01.avg_persons_per_bedroom
from g01
left join {{ ref('stg_lga_code') }} lc using (lga_code)
