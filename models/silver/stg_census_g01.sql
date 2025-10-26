{{ config(materialized='table') }}

with g01 as (
  select
    trim(lga_code_2016)::text as lga_code,


    tot_p_p::int as total_persons,

    age_0_4_yr_p::int   as age_0_4,
    age_5_14_yr_p::int  as age_5_14,
    age_15_19_yr_p::int as age_15_19,
    age_20_24_yr_p::int as age_20_24,
    age_25_34_yr_p::int as age_25_34,
    age_35_44_yr_p::int as age_35_44,
    age_45_54_yr_p::int as age_45_54,
    age_55_64_yr_p::int as age_55_64,
    age_65_74_yr_p::int as age_65_74,
    age_75_84_yr_p::int as age_75_84,
    age_85ov_p::int     as age_85_plus
  from {{ source('bronze','census_g01_raw') }}
),

pct as (
  select
    lga_code,
    total_persons,
    age_0_4,  age_5_14, age_15_19, age_20_24, age_25_34, age_35_44,
    age_45_54, age_55_64, age_65_74, age_75_84, age_85_plus,

    age_0_4     / nullif(total_persons,0)::numeric as pct_age_0_4,
    age_5_14    / nullif(total_persons,0)::numeric as pct_age_5_14,
    age_15_19   / nullif(total_persons,0)::numeric as pct_age_15_19,
    age_20_24   / nullif(total_persons,0)::numeric as pct_age_20_24,
    age_25_34   / nullif(total_persons,0)::numeric as pct_age_25_34,
    age_35_44   / nullif(total_persons,0)::numeric as pct_age_35_44,
    age_45_54   / nullif(total_persons,0)::numeric as pct_age_45_54,
    age_55_64   / nullif(total_persons,0)::numeric as pct_age_55_64,
    age_65_74   / nullif(total_persons,0)::numeric as pct_age_65_74,
    age_75_84   / nullif(total_persons,0)::numeric as pct_age_75_84,
    age_85_plus / nullif(total_persons,0)::numeric as pct_age_85_plus
  from g01
)

select
  p.*,
  lc.lga_name
from pct p
left join {{ ref('stg_lga_code') }} lc using (lga_code)
