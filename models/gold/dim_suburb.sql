{{ config(materialized='table') }}

select distinct
  s.suburb,
  lc.lga_code,
  lc.lga_name
from {{ ref('stg_lga_suburb') }} s
left join {{ ref('stg_lga_code') }} lc using (lga_code)
where s.suburb is not null and s.suburb <> ''
