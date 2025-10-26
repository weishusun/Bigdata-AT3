{{ config(materialized='table') }}

select
  trim(lga_code)::text as lga_code,
  trim(lga_name)       as lga_name
from {{ source('bronze', 'lga_code_raw') }}
