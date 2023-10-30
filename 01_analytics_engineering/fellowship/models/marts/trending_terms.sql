with source as (

    select * from {{ ref('int_top_per_country') }}

),

final as (

    select

        week_start_date,
        country_code,
        ranking,
        search_term,
        max_score as score

    from
        source

)

select * from final