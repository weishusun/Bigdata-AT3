{{ config(materialized='table') }}

with g02 as (
  select
    trim(lga_code_2016)::text as lga_code,

    median_age_persons::numeric            as median_age_persons,
    average_household_size::numeric        as avg_household_size,

    median_mortgage_repay_monthly::numeric as median_mortgage_monthly,
    median_rent_weekly::numeric            as median_rent_weekly,
    median_tot_prsnl_inc_weekly::numeric   as median_income_weekly,
    median_tot_fam_inc_weekly::numeric     as median_family_income_weekly,
    median_tot_hhd_inc_weekly::numeric     as median_household_income_weekly
  from {{ source('bronze','census_g02_raw') }}
)

select
  g02.*,
  lc.lga_name
from g02
left join {{ ref('stg_lga_code') }} lc using (lga_code)
