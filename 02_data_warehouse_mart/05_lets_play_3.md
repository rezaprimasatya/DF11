# User Data 

Query a specific date range

```sql
-- Example: Query a specific date range for users meeting a lifetime engagement criterion.
--
-- Counts unique users that are in the BigQuery user-data exports for a specific date range and have
-- a lifetime engagement of 5 minutes or more.

SELECT
  COUNT(DISTINCT user_id) AS user_count
FROM
  -- Uses a table suffix wildcard to define the set of daily tables to query.
  `PROJECT_ID.analytics_PROPERTY_ID.users_202308*`
WHERE
  -- Filters to users updated between August 1 and August 15.
  _TABLE_SUFFIX BETWEEN '01' AND '15'
  -- Filters by users who have a lifetime engagement of 5 minutes or more.
  AND user_ltv.engagement_time_millis >= 5 * 60 * 1000;
```


User IDs for recent user property changes

```sql
-- Example: Get the list of user_ids with recent changes to a specific user property.
DECLARE
  UPDATE_LOWER_BOUND_MICROS INT64;

-- Replace timezone. List at https://en.wikipedia.org/wiki/List_of_tz_database_time_zones.
DECLARE
  REPORTING_TIMEZONE STRING DEFAULT 'America/Los_Angeles';

-- Sets the variable for the earliest update time to include. This comes after setting
-- the REPORTING_TIMEZONE so this expression can use that variable.
SET UPDATE_LOWER_BOUND_MICROS = UNIX_MICROS(
    TIMESTAMP_SUB(
      TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, REPORTING_TIMEZONE),
      INTERVAL 14 DAY));

-- Selects users with changes to a specific user property since the lower bound.
SELECT
  users.user_id,
  FORMAT_TIMESTAMP('%F %T',
    TIMESTAMP_MICROS(
      MAX(properties.value.set_timestamp_micros)),
      REPORTING_TIMEZONE) AS max_set_timestamp
FROM
  -- Uses a table prefix to scan all data for 2023. Update the prefix as needed to query a different
  -- date range.
  `PROJECT_ID.analytics_PROPERTY_ID.users_2023*` AS users,
  users.user_properties properties
WHERE
  properties.value.user_property_name = 'job_function'
  AND properties.value.set_timestamp_micros >= UPDATE_LOWER_BOUND_MICROS
GROUP BY
  1;
```

Summary of updates
```sql
-- Summarizes data by change type.

-- Defines the export date to query. This must match the table suffix in the FROM
-- clause below.
DECLARE EXPORT_DATE DATE DEFAULT DATE(2023,6,16);

-- Creates a temporary function that will return true if a timestamp (in micros) is for the same
-- date as the specified day value.
CREATE TEMP FUNCTION WithinDay(ts_micros INT64, day_value DATE)
AS (
  (ts_micros IS NOT NULL) AND
  -- Change the timezone to your property's reporting time zone.
  -- List at https://en.wikipedia.org/wiki/List_of_tz_database_time_zones.
  (DATE(TIMESTAMP_MICROS(ts_micros), 'America/Los_Angeles') = day_value)
);

-- Creates a temporary function that will return true if a date string in 'YYYYMMDD' format is
-- for the same date as the specified day value.
CREATE TEMP FUNCTION SameDate(date_string STRING, day_value DATE)
AS (
  (date_string IS NOT NULL) AND
  (PARSE_DATE('%Y%m%d', date_string) = day_value)
);

WITH change_types AS (
SELECT user_id,
  WithinDay(user_info.last_active_timestamp_micros, EXPORT_DATE) AS user_activity,
  WithinDay(user_info.user_first_touch_timestamp_micros, EXPORT_DATE) AS first_touch,
  SameDate(user_info.first_purchase_date, EXPORT_DATE) as first_purchase,
  (EXISTS (SELECT 1 FROM UNNEST(audiences) AS aud
           WHERE WithinDay(aud.membership_start_timestamp_micros, EXPORT_DATE))) AS audience_add,
  (EXISTS (SELECT 1 FROM UNNEST(audiences) AS aud
           WHERE WithinDay(aud.membership_expiry_timestamp_micros, EXPORT_DATE))) AS audience_remove,
  (EXISTS (SELECT 1 FROM UNNEST(user_properties) AS prop
           WHERE WithinDay(prop.value.set_timestamp_micros, EXPORT_DATE))) AS user_property_change
FROM
  -- The table suffix must match the date used to define EXPORT_DATE above.
  `project_id.analytics_property_id.users_20230616`
)
SELECT
  user_activity,
  first_touch,
  first_purchase,
  audience_add,
  audience_remove,
  user_property_change,
  -- This field will be true if there are no changes for the other change types.
  NOT (user_activity OR first_touch OR audience_add OR audience_remove OR user_property_change) AS other_change,
  COUNT(DISTINCT user_id) AS user_id_count
FROM change_types
GROUP BY 1,2,3,4,5,6,7;
```

