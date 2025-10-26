{{ config(materialized='table') }}

select distinct
  s.suburb,
  c.lga_code,
  c.lga_name
from {{ ref('stg_lga_suburb') }} s
left join {{ ref('stg_lga_code') }}  c using (lga_code)
where s.suburb is not null and s.suburb <> ''
order by 1
