CREATE DATABASE netflix_p3;
USE netflix_p3;

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * from netflix;

-- 1. Count the number of Movies vs TV Shows
SELECT type, COUNT(*) AS num
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
WITH rating_counts AS (
    SELECT type, rating, COUNT(*) AS count_rating
    FROM netflix
    GROUP BY type, rating
)
SELECT type, rating, count_rating
FROM rating_counts
WHERE (type, count_rating) IN (
    SELECT type, MAX(count_rating)
    FROM rating_counts
    GROUP BY type
);

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT title as movies_2020
FROM netflix
WHERE release_year = '2020' AND type ='Movie';

-- Yearwise dist of movies
SELECT release_year, count(*) AS num_movies
FROM netflix
WHERE type='Movie'
GROUP BY release_year
ORDER BY release_year DESC ;

-- Yearwise dist of TV SHOWS
SELECT release_year, count(*) AS num_shows
FROM netflix
WHERE type='TV Show'
GROUP BY release_year
ORDER BY release_year DESC;

-- 4. Find the top 5 countries with the most content on Netflix
WITH RECURSIVE numbers AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM numbers WHERE n < 10
),
split_countries AS (
  SELECT
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n), ',', -1)) AS country
  FROM
    netflix, numbers
  WHERE
    n <= CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) + 1
)
SELECT country, COUNT(*) AS total_content
FROM split_countries
WHERE country IS NOT NULL AND country <> ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT title AS longest_movie, duration
FROM netflix
WHERE type = 'Movie' AND 
duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM netflix
WHERE director = 'Rajiv Chilaka';

-- 8.  List all TV shows with more than 5 seasons
SELECT title, duration
FROM netflix
	WHERE type= 'Tv Show' AND duration > '5 Seasons'
    ORDER BY duration DESC;

-- 9. Count the number of content items in each genre
WITH RECURSIVE numbers AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM numbers WHERE n < 10
),
split_genres AS (
  SELECT
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n), ',', -1)) AS genre
  FROM
    netflix, numbers
  WHERE
    n <= CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) + 1
)
SELECT 
  genre, 
  COUNT(show_id) AS total_shows
FROM split_genres
WHERE genre IS NOT NULL AND genre <> ''
GROUP BY genre
ORDER BY total_shows DESC;

-- 10. Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 11. List all movies that are documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- 12. Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Year
SELECT *
FROM netflix
WHERE 
    casts LIKE 'Salman Khan' OR
    casts LIKE 'Salman Khan,%' OR
    casts LIKE '%, Salman Khan' OR
    casts LIKE '%, Salman Khan,%';
    
-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 20
),
split_casts AS (
    SELECT
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(casts, ',', n), ',', -1)) AS actor
    FROM netflix, numbers
    WHERE country = 'India'
      AND type = 'Movie'
      AND casts IS NOT NULL
      AND n <= CHAR_LENGTH(casts) - CHAR_LENGTH(REPLACE(casts, ',', '')) + 1
)
SELECT 
    actor,
    COUNT(*) AS appearances
FROM split_casts
WHERE actor <> ''
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
    WHERE description IS NOT NULL
) AS categorized_content
GROUP BY category;