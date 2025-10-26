{{ config(materialized='view') }}

with f as (
    select
        f.listing_id,
        f.host_id,
        f.property_type,
        f.room_type,
        f.accommodates::int as accommodates,
        f.price::numeric as price,
        f.has_availability,
        f.availability_30::int as availability_30,
        d.date_id,
        date_trunc('month', d.date_id::date)::date as month_start
    from {{ ref('fact_listings') }} f
    join {{ ref('dim_date') }} d on d.date_id = f.date_id
),

agg as (
    select
        property_type,
        room_type,
        accommodates,
        month_start,
        count(*)::numeric as total_listings,
        sum(case when coalesce(has_availability,'f') in ('t','true','1') then 1 else 0 end)::numeric as active_listings,
        sum(case when coalesce(has_availability,'f') in ('t','true','1') then 0 else 1 end)::numeric as inactive_listings,
        min(case when coalesce(has_availability,'f') in ('t','true','1') then price end) as min_price_active,
        max(case when coalesce(has_availability,'f') in ('t','true','1') then price end) as max_price_active,
        avg(case when coalesce(has_availability,'f') in ('t','true','1') then price end) as avg_price_active,
        sum(case when coalesce(has_availability,'f') in ('t','true','1')
                 then greatest(30 - coalesce(availability_30,0), 0) else 0 end) as total_stays_active,
        sum(case when coalesce(has_availability,'f') in ('t','true','1')
                 then greatest(30 - coalesce(availability_30,0), 0) * coalesce(price,0) else 0 end) as total_estimated_revenue_active
    from f
    group by 1,2,3,4
),

final as (
    select
        property_type,
        room_type,
        accommodates,
        month_start,
        case when total_listings > 0 then active_listings / total_listings else 0 end as active_listings_rate,
        min_price_active,
        max_price_active,
        avg_price_active,
        total_stays_active,
        case when active_listings > 0
             then total_estimated_revenue_active / active_listings
             else 0 end as avg_estimated_revenue_per_active_listing,
        lag(active_listings)  over (partition by property_type, room_type, accommodates order by month_start) as prev_active,
        lag(inactive_listings) over (partition by property_type, room_type, accommodates order by month_start) as prev_inactive,
        active_listings,
        inactive_listings
    from agg
)

select
    property_type,
    room_type,
    accommodates,
    to_char(month_start, 'YYYY-MM-01')::date as month_start,
    active_listings_rate,
    min_price_active,
    max_price_active,
    avg_price_active,
    case when prev_active is null or prev_active = 0 then null 
         else (active_listings - prev_active)::numeric / prev_active end as pct_change_active_listings,
    case when prev_inactive is null or prev_inactive = 0 then null 
         else (inactive_listings - prev_inactive)::numeric / prev_inactive end as pct_change_inactive_listings,
    total_stays_active as total_number_of_stays,
    avg_estimated_revenue_per_active_listing
from final
