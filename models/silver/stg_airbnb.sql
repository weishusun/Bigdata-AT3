{{ config(materialized='table') }}

with base as (
  select
    listing_id::bigint                       as listing_id,
    host_id::bigint                          as host_id,

    host_name,
    host_since,
    host_is_superhost,
    host_neighbourhood,
    listing_neighbourhood                    as suburb,
    property_type,
    room_type,
    accommodates::int                        as accommodates,

    regexp_replace(price::text, '[^0-9\.]', '', 'g')::numeric    as price,

    has_availability,
    availability_30::int                     as availability_30,
    number_of_reviews::int                   as number_of_reviews,
    review_scores_rating::float              as review_rating,
    review_scores_accuracy::float            as review_scores_accuracy,
    review_scores_cleanliness::float         as review_scores_cleanliness,
    review_scores_checkin::float             as review_scores_checkin,
    review_scores_communication::float       as review_scores_communication,
    review_scores_value::float               as review_scores_value,

    to_date(scraped_date, 'YYYY-MM-DD')      as scraped_date,
    date_trunc('month', to_date(scraped_date, 'YYYY-MM-DD'))::date as date_id
  from {{ source('bronze', 'airbnb_raw') }}
)

select *
from base
where listing_id is not null
