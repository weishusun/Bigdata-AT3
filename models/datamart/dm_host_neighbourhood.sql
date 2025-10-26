{{ config(materialized='view') }}

with base as (
    select
        d.date_id,
        date_trunc('month', d.date_id::date)::date as month_start,
        h.host_id,
        h.host_is_superhost,
        upper(trim(regexp_replace(h.host_neighbourhood, '\s+', ' ', 'g'))) as host_neigh_std,
        upper(trim(regexp_replace(f.suburb, '\s+', ' ', 'g'))) as listing_suburb_std,
        f.price::numeric as price,
        f.has_availability,
        f.availability_30::int as availability_30
    from {{ ref('fact_listings') }} f
    join {{ ref('dim_date') }} d on d.date_id = f.date_id
    join {{ ref('dim_host') }} h on h.host_id = f.host_id
),

lga_by_host as (
    select
        b.*,
        s.lga_name as lga_from_host
    from base b
    left join {{ ref('dim_suburb') }} s
      on upper(trim(regexp_replace(s.suburb, '\s+', ' ', 'g'))) = b.host_neigh_std
),

lga_by_listing as (
    select
        h.*,
        s2.lga_name as lga_from_listing
    from lga_by_host h
    left join {{ ref('dim_suburb') }} s2
      on upper(trim(regexp_replace(s2.suburb, '\s+', ' ', 'g'))) = h.listing_suburb_std
),

final_base as (
    select
        date_id,
        month_start,
        host_id,
        host_is_superhost,
        coalesce(lga_from_host, lga_from_listing, 'UNKNOWN') as host_neighbourhood_lga,
        price,
        has_availability,
        availability_30
    from lga_by_listing
),

agg as (
    select
        host_neighbourhood_lga,
        month_start,
        count(distinct host_id) as distinct_hosts,
        sum(case when coalesce(has_availability,'f') in ('t','true','1')
                 then greatest(30 - coalesce(availability_30,0), 0) * coalesce(price,0)
                 else 0 end) as total_estimated_revenue_active,
        sum(case when coalesce(has_availability,'f') in ('t','true','1') then 1 else 0 end) as active_listings
    from final_base
    group by 1,2
)

select
    host_neighbourhood_lga,
    to_char(month_start, 'YYYY-MM-01')::date as month_start,
    distinct_hosts,
    case when active_listings > 0
         then total_estimated_revenue_active / active_listings
         else 0 end as avg_estimated_revenue_per_active_listing,
    case when distinct_hosts > 0
         then total_estimated_revenue_active::numeric / distinct_hosts
         else 0 end as estimated_revenue_per_host
from agg
