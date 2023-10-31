# Event Queries

Products purchased by customers who purchased a certain product
```sql
-- Example: Products purchased by customers who purchased a specific product.
--
-- `Params` is used to hold the value of the selected product and is referenced
-- throughout the query.

WITH
  Params AS (
    -- Replace with selected item_name or item_id.
    SELECT 'Google Navy Speckled Tee' AS selected_product
  ),
  PurchaseEvents AS (
    SELECT
      user_pseudo_id,
      items
    FROM
      -- Replace table name.
      `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE
      -- Replace date range.
      _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
      AND event_name = 'purchase'
  ),
  ProductABuyers AS (
    SELECT DISTINCT
      user_pseudo_id
    FROM
      Params,
      PurchaseEvents,
      UNNEST(items) AS items
    WHERE
      -- item.item_id can be used instead of items.item_name.
      items.item_name = selected_product
  )
SELECT
  items.item_name AS item_name,
  SUM(items.quantity) AS item_quantity
FROM
  Params,
  PurchaseEvents,
  UNNEST(items) AS items
WHERE
  user_pseudo_id IN (SELECT user_pseudo_id FROM ProductABuyers)
  -- item.item_id can be used instead of items.item_name
  AND items.item_name != selected_product
GROUP BY 1
ORDER BY item_quantity DESC;
```

Average amount of money spent per purchase session by user

```sql
-- Example: Average amount of money spent per purchase session by user.

WITH
  events AS (
    SELECT
      session.value.int_value AS session_id,
      COALESCE(spend.value.int_value, spend.value.float_value, spend.value.double_value, 0.0)
        AS spend_value,
      event.*

    -- Replace table name
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` AS event
    LEFT JOIN UNNEST(event.event_params) AS session
      ON session.key = 'ga_session_id'
    LEFT JOIN UNNEST(event.event_params) AS spend
      ON spend.key = 'value'

    -- Replace date range
    WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  )
SELECT
  user_pseudo_id,
  COUNT(DISTINCT session_id) AS session_count,
  SUM(spend_value) / COUNT(DISTINCT session_id) AS avg_spend_per_session_by_user
FROM events
WHERE event_name = 'purchase' and session_id IS NOT NULL
GROUP BY user_pseudo_id
```

Latest Session Id and Session Number for users

```sql
-- Get the latest ga_session_id and ga_session_number for specific users during last 4 days.

-- Replace timezone. List at https://en.wikipedia.org/wiki/List_of_tz_database_time_zones.
DECLARE REPORTING_TIMEZONE STRING DEFAULT 'America/Los_Angeles';

-- Replace list of user_pseudo_id's with ones you want to query.
DECLARE USER_PSEUDO_ID_LIST ARRAY<STRING> DEFAULT
  [
    '1005355938.1632145814', '979622592.1632496588', '1101478530.1632831095'];

CREATE TEMP FUNCTION GetParamValue(params ANY TYPE, target_key STRING)
AS (
  (SELECT `value` FROM UNNEST(params) WHERE key = target_key LIMIT 1)
);

CREATE TEMP FUNCTION GetDateSuffix(date_shift INT64, timezone STRING)
AS (
  (SELECT FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE(timezone), INTERVAL date_shift DAY)))
);

SELECT DISTINCT
  user_pseudo_id,
  FIRST_VALUE(GetParamValue(event_params, 'ga_session_id').int_value)
    OVER (UserWindow) AS ga_session_id,
  FIRST_VALUE(GetParamValue(event_params, 'ga_session_number').int_value)
    OVER (UserWindow) AS ga_session_number
FROM
  -- Replace table name.
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
  user_pseudo_id IN UNNEST(USER_PSEUDO_ID_LIST)
  AND RIGHT(_TABLE_SUFFIX, 8)
    BETWEEN GetDateSuffix(-3, REPORTING_TIMEZONE)
    AND GetDateSuffix(0, REPORTING_TIMEZONE)
WINDOW UserWindow AS (PARTITION BY user_pseudo_id ORDER BY event_timestamp DESC);
```

