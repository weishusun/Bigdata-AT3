{{ config(materialized='view') }}

with f as (
    select
        f.listing_id,
        f.host_id,
        f.suburb,
        f.price::numeric as price,
        f.has_availability,
        f.availability_30::int as availability_30,
        d.date_id,
        date_trunc('month', d.date_id::date)::date as month_start,
        s.suburb as listing_neighbourhood
    from {{ ref('fact_listings') }} f
    join {{ ref('dim_date') }} d on d.date_id = f.date_id
    left join {{ ref('dim_suburb') }} s on s.suburb = f.suburb
),

agg as (
    select
        listing_neighbourhood,
        month_start,
        count(*)::numeric as total_listings,
        sum(case when coalesce(has_availability,'f') in ('t','true','1') then 1 else 0 end)::numeric as active_listings,
        sum(case when coalesce(has_availability,'f') in ('t','true','1') then 0 else 1 end)::numeric as inactive_listings,
        min(case when coalesce(has_availability,'f') in ('t','true','1') then price end) as min_price_active,
        max(case when coalesce(has_availability,'f') in ('t','true','1') then price end) as max_price_active,
        avg(case when coalesce(has_availability,'f') in ('t','true','1') then price end) as avg_price_active,
        count(distinct host_id) as distinct_hosts,
        sum(case when coalesce(has_availability,'f') in ('t','true','1')
                 then greatest(30 - coalesce(availability_30,0), 0) else 0 end) as total_stays_active,
        sum(case when coalesce(has_availability,'f') in ('t','true','1')
                 then greatest(30 - coalesce(availability_30,0), 0) * coalesce(price,0) else 0 end) as total_estimated_revenue_active
    from f
    group by 1,2
),

final as (
    select
        listing_neighbourhood,
        month_start,
        total_listings,
        active_listings,
        inactive_listings,
        case when total_listings > 0 then active_listings / total_listings else 0 end as active_listings_rate,
        min_price_active,
        max_price_active,
        avg_price_active,
        distinct_hosts,
        total_stays_active,
        case when active_listings > 0
             then total_estimated_revenue_active / active_listings
             else 0 end as avg_estimated_revenue_per_active_listing,
        case when distinct_hosts > 0
             then total_estimated_revenue_active / distinct_hosts
             else 0 end as estimated_revenue_per_host,
        lag(active_listings)  over (partition by listing_neighbourhood order by month_start) as prev_active,
        lag(inactive_listings) over (partition by listing_neighbourhood order by month_start) as prev_inactive
    from agg
)

select
    listing_neighbourhood,
    to_char(month_start, 'YYYY-MM-01')::date as month_start,
    active_listings_rate,
    min_price_active,
    max_price_active,
    avg_price_active,
    distinct_hosts,
    case when prev_active is null or prev_active = 0 then null 
         else (active_listings - prev_active)::numeric / prev_active end as pct_change_active_listings,
    case when prev_inactive is null or prev_inactive = 0 then null 
         else (inactive_listings - prev_inactive)::numeric / prev_inactive end as pct_change_inactive_listings,
    total_stays_active as total_number_of_stays,
    avg_estimated_revenue_per_active_listing,
    estimated_revenue_per_host
from final
