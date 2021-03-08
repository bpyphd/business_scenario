--SQL Queries

-- Sales of ebook by country
CREATE TABLE ebook_sales_by_country AS (
SELECT country, sales_of_ebook FROM (
SELECT country, COUNT(*) AS sales_of_ebook FROM (
SELECT purchase.user_id, purchase.price, first_visit.country FROM purchase
LEFT JOIN first_visit
ON purchase.user_id = first_visit.user_id
WHERE price = '8'
GROUP BY purchase.user_id, purchase.price, first_visit.country) AS sales_table
GROUP BY sales_table.country) AS sales_table_two
GROUP BY sales_table_two.country, sales_table_two.sales_of_ebook
ORDER BY sales_table_two.sales_of_ebook DESC);

-- Sales of video by county
CREATE TABLE video_sales_by_country AS (
SELECT country, sales_of_video FROM (
SELECT country, COUNT(*) AS sales_of_video FROM (
SELECT purchase.user_id, purchase.price, first_visit.country FROM purchase
LEFT JOIN first_visit
ON purchase.user_id = first_visit.user_id
WHERE price = '80'
GROUP BY purchase.user_id, purchase.price, first_visit.country) AS sales_table
GROUP BY sales_table.country) AS sales_table_two
GROUP BY sales_table_two.country, sales_table_two.sales_of_video
ORDER BY sales_table_two.sales_of_video DESC);

-- Total revenue by country
-- Query used to place ebook and video revenue by country side by side 
SELECT * FROM ebook_sales_by_country
FULL OUTER JOIN video_sales_by_country
ON ebook_sales_by_country.country = video_sales_by_country.country
ORDER BY ebook_sales_by_country.sales_of_ebook DESC;

-- Creating table to show all ebook purchases by country
CREATE TABLE all_ebook_purchases_by_country AS
(SELECT purchase.the_date, purchase.the_time, purchase.user_id, purchase.price, first_visit.country FROM purchase
LEFT JOIN first_visit
ON purchase.user_id = first_visit.user_id
WHERE price = '8');

-- Creating table ordered by date to show three month trend for ebook sales X country
CREATE TABLE three_month_trend_ebook AS
(SELECT the_date, country, COUNT (price) AS sales FROM all_ebook_purchases_by_country 
WHERE price = '8' 
GROUP BY the_date, country
ORDER BY the_date);

-- Creating table to show all video purchases by country
CREATE TABLE all_video_purchases_by_country AS
(SELECT purchase.the_date, purchase.the_time, purchase.user_id, purchase.price, first_visit.country FROM purchase
LEFT JOIN first_visit
ON purchase.user_id = first_visit.user_id
WHERE price = '80');

-- Creating table ordered by date to show three month trend for video sales by country
CREATE TABLE three_month_trend_video AS
(SELECT the_date, country, COUNT (price) AS sales FROM all_video_purchases_by_country 
WHERE price = '80' 
GROUP BY the_date, country
ORDER BY the_date);

-- Creating table that shows all purchases by country
CREATE TABLE purchases_by_country AS (
SELECT purchase.the_date, purchase.the_time, purchase.user_id, purchase.price, first_visit.country FROM purchase
LEFT JOIN first_visit
ON purchase.user_id = first_visit.user_id);

-- Provides number of sales of e-book and video for each combination of country and source
-- In the second to last line, you manually change the country and source according to what combination you want
SELECT price, COUNT (*) FROM 
(SELECT * FROM purchases_by_country
LEFT JOIN first_visit
ON purchases_by_country.user_id = first_visit.user_id
WHERE purchases_by_country.country = 'country_1' AND source = 'AdWords') AS country_by_source
GROUP BY country_by_source.price;

-- Query meant to find information on what sources were used by subscribers when first encountering the site
-- Manually changing the source to either Reddit, SEO or AdWords
SELECT subscribe.the_date, subscribe.the_time, subscribe.user_id, first_visit.source FROM subscribe
LEFT JOIN first_visit
ON subscribe.user_id = first_visit.user_id
WHERE source = 'AdWords'
GROUP BY subscribe.the_date, subscribe.the_time, subscribe.user_id, first_visit.source;

-- Reveals that 7618 people became subscribers
SELECT COUNT(*)FROM(
SELECT * FROM subscribe) AS number_of_subscribers;

-- This query reveals all of the subscribers that never purchased anything, which is used to show how many
-- subscribers ultimately became consumers - (specifically, 2542/7618 = 33.3% weren't consumers, 2/3rd were consumers)
SELECT COUNT(*) FROM (
SELECT DISTINCT (subscribe.user_id), purchase.price FROM subscribe
LEFT JOIN purchase
ON subscribe.user_id = purchase.user_id
WHERE price IS NULL) AS number_of_subscribers_who_didnt_buy_anything;

-- Subscribers by country
SELECT sub_country.country, COUNT(*) FROM (
SELECT * FROM subscribe
LEFT JOIN first_visit
ON subscribe.user_id = first_visit.user_id) AS sub_country
GROUP BY sub_country.country
ORDER BY COUNT DESC;

-- Subscribers by source
SELECT sub_source.source, COUNT(*) FROM (
SELECT * FROM subscribe
LEFT JOIN first_visit
ON subscribe.user_id = first_visit.user_id) AS sub_source
GROUP BY sub_source.source
ORDER BY COUNT DESC;

-- Reveals that there were 210023 first time visitors/readers to the site 
SELECT COUNT(*) FROM (
SELECT DISTINCT(user_id) FROM first_visit) AS first_time_readers;

-- Reveals that 143792 visited the site only once (did not return), leaving 66231 (210023 - 143792) as returning readers
SELECT COUNT(*) FROM (
SELECT * FROM first_visit
LEFT JOIN return_visits
ON first_visit.user_id = return_visits.user_id 
WHERE return_visits.user_id IS NULL) AS visited_only_once;

-- This query confirms that there are 66231 returning readers
SELECT DISTINCT (user_id), country FROM return_visits;

-- Created table containing all returning readers
CREATE TABLE returning_readers AS
(SELECT DISTINCT (user_id) FROM return_visits);

-- Reveals that 59585 (~90%) of returning readers were not consumers
SELECT COUNT(*) FROM (
SELECT * FROM returning_readers
LEFT JOIN purchase
ON returning_readers.user_id = purchase.user_id
WHERE purchase.user_id IS NULL) AS rr_not_purchase;

-- Reveals which countries returning readers are coming from
SELECT rr_country.country, COUNT(*) FROM (
SELECT * FROM returning_readers
LEFT JOIN first_visit
ON returning_readers.user_id = first_visit.user_id) AS rr_country
GROUP BY rr_country.country
ORDER BY COUNT DESC;

-- Reveals which sources returning readers came from in their first visit
SELECT rr_source.source, COUNT(*) FROM (
SELECT * FROM returning_readers
LEFT JOIN first_visit
ON returning_readers.user_id = first_visit.user_id) AS rr_source
GROUP BY rr_source.source
ORDER BY COUNT DESC;

-- All ebook purchases
CREATE TABLE eb_purch AS
(SELECT * FROM purchase
WHERE price = '8');

-- All video purchases
CREATE TABLE video_purch AS
(SELECT * FROM purchase
WHERE price = '80');

-- Consumers who only bought the ebook
CREATE TABLE eb_only AS (
SELECT eb_purch.the_date, eb_purch.the_time, eb_purch.user_id, eb_purch.price FROM eb_purch
LEFT JOIN video_purch
ON eb_purch.user_id = video_purch.user_id
WHERE video_purch.user_id is null);

-- Consumers who only bought the video
CREATE TABLE video_only AS (
SELECT video_purch.the_date, video_purch.the_time, video_purch.user_id, video_purch.price FROM video_purch
LEFT JOIN eb_purch
ON video_purch.user_id = eb_purch.user_id
WHERE eb_purch.user_id is null);

-- Table where people who only bought the ebook are removed from the total purchase table
CREATE TABLE eb_only_removed AS (
SELECT purchase.the_date, purchase.the_time, purchase.user_id, purchase.price FROM purchase
LEFT JOIN eb_only
ON purchase.user_id = eb_only.user_id
WHERE eb_only.user_id is null);

-- Taking that table and removing people who only bought the video, and creating a new table called both_items_purchased
CREATE TABLE both_items_purchased AS (
SELECT eb_only_removed.the_date, eb_only_removed.the_time, eb_only_removed.user_id, eb_only_removed.price FROM eb_only_removed
LEFT JOIN video_only
ON eb_only_removed.user_id = video_only.user_id
WHERE video_only.user_id is null);

-- Now there are three tables: eb_only, video_only, and both_item_purchased

-- Combined the topic viewed during first visit for consumers only buying the e-book, with all of the topics they viewed when returning
-- Revealed number of visits to each topic for consumers of e-book only
SELECT topic_count.topic AS topic, COUNT(*) FROM (
(SELECT eb_only.the_date, eb_only.the_time, eb_only.user_id, eb_only.price, first_visit.topic FROM eb_only
LEFT JOIN first_visit
ON eb_only.user_id = first_visit.user_id
ORDER BY eb_only.the_date)
UNION all
(SELECT eb_only.the_date, eb_only.the_time, eb_only.user_id, eb_only.price, return_visits.topic FROM eb_only
LEFT JOIN return_visits
ON eb_only.user_id = return_visits.user_id
ORDER BY eb_only.the_date)) AS topic_count
GROUP BY topic_count.topic
ORDER BY COUNT DESC;

-- Combined the topic viewed during first visit for consumers of both items, with all of the topics they viewed when returning
-- Revealed number of visits to each topic for consumers of both items
SELECT topic_count.topic AS topic, COUNT(*) FROM (
(SELECT both_items_purchased.the_date, both_items_purchased.the_time, both_items_purchased.user_id, both_items_purchased.price, first_visit.topic FROM both_items_purchased
LEFT JOIN first_visit
ON both_items_purchased.user_id = first_visit.user_id
ORDER BY both_items_purchased.the_date)
UNION ALL
(SELECT both_items_purchased.the_date, both_items_purchased.the_time, both_items_purchased.user_id, both_items_purchased.price, return_visits.topic FROM both_items_purchased
LEFT JOIN return_visits
ON both_items_purchased.user_id = return_visits.user_id
ORDER BY both_items_purchased.the_date)) AS topic_count
GROUP BY topic_count.topic
ORDER BY COUNT DESC;

-- Combined the topic viewed during first visit for consumers of the video only, with all of the topics they viewed when returning
-- Revealed number of visits to each topic for consumers of the video only
SELECT topic_count.topic AS topic, COUNT(*) FROM (
(SELECT video_only.the_date, video_only.the_time, video_only.user_id, video_only.price, first_visit.topic FROM video_only
LEFT JOIN first_visit
ON video_only.user_id = first_visit.user_id
ORDER BY video_only.the_date)
UNION ALL
(SELECT video_only.the_date, video_only.the_time, video_only.user_id, video_only.price, return_visits.topic FROM video_only
LEFT JOIN return_visits
ON video_only.user_id = return_visits.user_id
ORDER BY video_only.the_date)) AS topic_count
GROUP BY topic_count.topic
ORDER BY COUNT DESC;

-- Created table showing the number of reading sessions (from their return visits plus their first visit) for each user
CREATE TABLE read_sessions AS (
SELECT distinct (user_id), event_type, COUNT(*) + 1 AS reading_sessions FROM return_visits
GROUP BY user_id, event_type
ORDER BY user_id);

-- Created table showing the number of total purchases from each consumer
CREATE TABLE total_purchases AS (
SELECT distinct (user_id), event_type, COUNT(*) AS purchases FROM purchase
GROUP BY user_id, event_type
ORDER BY user_id);

-- Created table for measuring correlation between number of reading sessions and number of items purchased
CREATE TABLE reading_purchase_correlation AS (
SELECT total_purchases.user_id, read_sessions.reading_sessions, total_purchases.purchases
FROM total_purchases
LEFT JOIN read_sessions
ON total_purchases.user_id = read_sessions.user_id
GROUP BY total_purchases.user_id, read_sessiONs.reading_sessions, total_purchases.purchases);

-- Exported this query into a text file
SELECT * FROM reading_purchase_correlation;

-- Calucating revenue from prediction/regression
-- Created table showing daily revenue from e-book sales
CREATE TABLE ebook_daily_revenue AS (
SELECT the_date, price, sales, (price * sales) AS ebook_revenue FROM (
SELECT purchase.the_date, purchase.price, COUNT (price) AS sales FROM purchase
WHERE price = '8'
GROUP BY purchase.the_date, purchase.price
ORDER BY purchase.the_date) AS ebook_rev_table);

-- Created table showing daily revenue from video sales
CREATE TABLE video_daily_revenue AS (
SELECT the_date, price, sales, (price * sales) AS video_revenue FROM (
SELECT purchase.the_date, purchase.price, COUNT (price) AS sales FROM purchase
WHERE price = '80'
GROUP BY purchase.the_date, purchase.price
ORDER BY purchase.the_date) AS video_rev_table);

-- This query provides the total revenue earned each day for the past 3 months
SELECT *, (ebook_revenue + video_revenue) AS daily_revenue FROM (
SELECT * FROM ebook_daily_revenue
JOIN video_daily_revenue
ON ebook_daily_revenue.the_date = video_daily_revenue.the_date
) AS overall_rev_table;

