USE imdb;
SELECT COUNT(*) as Total_Rows FROM director_mapping; 
SELECT COUNT(*) as Total_Rows FROM genre;
SELECT COUNT(*) as Total_Rows FROM movie; 
SELECT COUNT(*) as Total_Rows FROM names;
SELECT COUNT(*) as Total_Rows FROM ratings; 
SELECT COUNT(*) as Total_Rows FROM role_mapping;


SELECT
SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS ID_NULL,
SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS Title_NULL,
SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS Year_NULL,
SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS DatePublished_NULL,
SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS Duration_NULL,
SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS Country_NULL,
SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS WorldWide_NULL,
SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS Language_NULL,
SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_NULL
FROM movie;

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format 2:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

/* yearwise*/

SELECT year, COUNT(id) AS number_of_movies
FROM movie
GROUP BY year;

/* Monthwise*/

SELECT MONTH(date_published) AS month_num, COUNT(id) AS number_of_movies
FROM movie
GROUP BY MONTH(date_published)
ORDER By MONTH(date_published);


/*The highest number of movies is produced in March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know the USA and India produce a huge number of movies each year.  

SELECT Count(DISTINCT id) AS number_of_movies, year
FROM movie
WHERE ( country LIKE '%INDIA%' OR country LIKE '%USA%' ) AND year = 2019;


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring Table Genre would be fun!! 


SELECT DISTINCT(genre) from genre;

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

SELECT g.genre, COUNT(m.id) AS num_of_movie
FROM genre g
INNER JOIN movie m ON m.id = g.movie_id
GROUP BY genre
ORDER BY COUNT(id) DESC
LIMIT 1;

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 

WITH movies_with_only_one_genre AS 
(
SELECT movie_id 
FROM genre 
GROUP BY movie_id 
HAVING Count(DISTINCT genre) = 1
) 
SELECT Count(*) AS movies_with_only_one_genre 
FROM movies_with_only_one_genre;

/* There are more than three thousand movies which have only one genre associated with them.
-- (Note: The same movie can belong to multiple genres.)

/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT g.genre, ROUND(AVG(m.duration),2) AS avg_Duration
FROM movie m
INNER JOIN genre g ON g.movie_id = m.id
GROUP BY genre
ORDER BY AVG(m.duration) DESC;

Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- Use the Rank function

/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH c_t_genre_rank
AS
(
SELECT genre, COUNT(movie_id) as movie_count,
RANK() OVER(ORDER BY COUNT(movie_id) DESC) genre_rank
FROM genre
GROUP BY genre
)
SELECT * FROM c_t_genre_rank
WHERE genre="Thriller";

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


-- Segment 2:
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|max_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/

SELECT
MIN(avg_rating) AS min_avg_rating,
MAX(avg_rating) AS max_avg_rating,
MIN(total_votes) as min_total_votes,
MAX(total_votes) AS max_total_votes,
MIN(median_rating) AS min_median_rating,
MAX(median_rating) AS max_median_rating
FROM ratings;

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

SELECT title, avg_rating, 
DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS movie_rank 
FROM movie AS m 
INNER JOIN ratings as r ON r.movie_id = m.id 
LIMIT 10;


-- Summarise the rating table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Order by is good to have

SELECT median_rating, COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY movie_count DESC;


/* Movies with a median rating of 7 is highest in number. 

/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT production_company, COUNT(id) AS movie_count,
DENSE_RANK() OVER(ORDER BY COUNT(id) DESC) prod_company_rank
FROM movie m
INNER JOIN ratings r ON r.movie_id = m.id 
WHERE r.avg_rating > 8 AND m.production_company IS NOT NULL
GROUP BY m.production_company;


-- It's ok if RANK() or DENSE_RANK() is used too

/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT g.genre, COUNT(m.id) AS movie_count
FROM genre g
INNER JOIN movie m ON m.id = g.movie_id
INNER JOIN ratings r ON r.movie_id = m.id
WHERE m.year = 2017 AND MONTH(m.date_published) = 3 AND m.country LIKE'%USA%' AND r.total_votes>1000
GROUP BY genre
ORDER BY COUNT(m.id) DESC;

-- Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

SELECT title, avg_rating, genre
FROM movie m
INNER JOIN ratings r ON r.movie_id = m.id
INNER JOIN genre g ON g.movie_id = m.id
WHERE title LIKE'The%' AND avg_rating>8
ORDER BY avg_rating DESC;

-- Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

SELECT COUNT(id) as movie_released, median_rating
FROM movie m
INNER JOIN ratings r ON r.movie_id = m.id
WHERE median_rating = 8 AND date_published BETWEEN '2018-04-01' AND '2019-04-01'
GROUP BY median_rating;

-- Do German movies get more votes than Italian movies? 

SELECT country, sum(total_votes) AS votes_count
FROM movie as m
INNER JOIN ratings as r ON r.movie_id=m.id
WHERE country = 'germany' OR country = 'italy'
GROUP BY country;

Let’s begin by searching for null values in the tables.*/

-- Segment 3:


-- Which columns in the names table have null values??
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/

SELECT
SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM names;

/* There are no Null value in the column 'name'.

--  Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- /* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

WITH top_genres
AS
(
SELECT g.genre, COUNT(g.movie_id) as movie_count
FROM genre g
INNER JOIN ratings r ON r.movie_id = g.movie_id
WHERE avg_rating>8
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 3
),
top_directors
AS
(
SELECT n.name as director_name,
COUNT(d.movie_id) as movie_count,
RANK() OVER(ORDER BY COUNT(d.movie_id) DESC) director_rank
FROM names n
INNER JOIN director_mapping d ON d.name_id = n.id
INNER JOIN ratings r ON r.movie_id = d.movie_id
INNER JOIN genre g ON g.movie_id = d.movie_id, 
top_genres
WHERE r.avg_rating > 8 AND g.genre IN (top_genres.genre)
GROUP BY n.name
ORDER BY movie_count DESC
)
SELECT director_name, movie_count
FROM top_directors
WHERE director_rank <= 3
LIMIT 3;

-- Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT n.name AS actor_name, COUNT(rm.movie_id) AS movie_count
FROM role_mapping rm
INNER JOIN names n ON n.id = rm.name_id
INNER JOIN ratings r ON r.movie_id = rm.movie_id
WHERE category="actor" AND r.median_rating >= 8
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 2;


RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
 
SELECT production_company, SUM(total_votes) AS vote_count,
DENSE_RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM movie m
INNER JOIN ratings r ON r.movie_id = m.id
GROUP BY production_company
ORDER BY vote_count DESC
LIMIT 3;


-- Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

select n.name as actor_name, sum(r.total_votes) as total_votes, 
	count(r.movie_id) as movie_count,
    ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) AS actor_avg_rating,
    rank() over (order by ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) desc) as actor_ranking
from names n 
inner join role_mapping rm on n.id = rm.name_id
inner join movie m on m.id = rm.movie_id
inner join ratings r on r.movie_id = m.id
where m.country = "India" and rm.category = "actor"
group by n.name
having count(r.movie_id)>=5;

-- Top actor is Vijay Sethupathi

Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

SELECT n.name as actress_name, sum(r.total_votes) as total_votes, 
COUNT(m.id) AS movie_count,
ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) AS actress_avg_rating,
rank() over (order by ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) desc) as actress_rank
FROM names n
inner join role_mapping rm on n.id = rm.name_id
inner join movie m on m.id = rm.movie_id
inner join ratings r on r.movie_id = m.id
WHERE rm.category = "actress" AND  m.languages LIKE "%Hindi%" AND m.country = "India"
GROUP BY n.name
HAVING COUNT(m.id) >=3
LIMIT 5;


/* Taapsee Pannu tops with average rating 7.74. 
-- Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/*  Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
SELECT title, avg_rating,
CASE
WHEN avg_rating > 8 THEN "Superhit movies"
WHEN avg_rating BETWEEN 7 AND 8 THEN "Hit movies"
WHEN avg_rating BETWEEN 5 AND 7 THEN "One-time-watch movies"
ELSE "Flop Movies"
END AS avg_rating_category
FROM movie m
INNER JOIN genre g ON g.movie_id = m.id
INNER JOIN ratings r ON r.movie_id = m.id
WHERE genre="thriller";

-- Segment 4:

--  What is the genre-wise running total and moving average of the average movie duration? 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/

SELECT genre,
ROUND(AVG(duration),2) AS avg_duration,
ROUND(SUM(AVG(duration)) OVER(ORDER BY genre),2) AS running_total_duration,
ROUND(AVG(AVG(duration)) OVER(ORDER BY genre),2) AS moving_avg_duration
FROM movie m
INNER JOIN genre g ON g.movie_id = m.id
GROUP BY genre;

-- Which are the five highest-grossing movies of each year that belong to the top three genres? 

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

-- Top 3 Genres based on most number of movies

WITH top3_genres
AS
(
SELECT genre, COUNT(movie_id) as movie_count
FROM genre
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 3
),
top5_movies
AS
(
SELECT genre, year, title as movie_name, worlwide_gross_income,
DENSE_RANK() OVER(PARTITION BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
FROM movie m
INNER JOIN genre g ON g.movie_id = m.id
WHERE genre IN(SELECT genre FROM top3_genres)
)
SELECT * 
FROM top5_movies
WHERE movie_rank<=5;

-- Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/

Select production_company, COUNT(id) as movie_count,
ROW_NUMBER() OVER(ORDER BY COUNT(id) DESC) AS prod_comp_rank
FROM movie m
INNER JOIN ratings r ON r.movie_id = m.id
WHERE median_rating>=8
AND production_company IS NOT NULL
AND POSITION(',' IN languages)>0
GROUP BY production_company
LIMIT 2;


-- Who are the top 3 actresses based on the number of Super Hit movies (average rating >8) in the drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

SELECT name as actress_name, SUM(total_votes) AS total_votes, 
COUNT(rm.movie_id) as movie_count, 
Round(Sum(avg_rating * r.total_votes)/Sum(total_votes),2) AS actress_avg_rating,
RANK() OVER(ORDER BY COUNT(rm.movie_id) DESC) AS actress_rank
FROM names n
INNER JOIN role_mapping rm ON rm.name_id = n.id
INNER JOIN ratings r ON r.movie_id = rm.movie_id
INNER JOIN genre g ON g.movie_id = r.movie_id
WHERE category="actress" AND avg_rating>8 AND g.genre="Drama"
GROUP BY name
LIMIT 3;


/* Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
WITH ctf_date_summary AS
(
SELECT d.name_id, NAME, d.movie_id, duration, r.avg_rating, total_votes, m.date_published,
Lead(date_published,1) OVER(PARTITION BY d.name_id ORDER BY date_published,movie_id ) AS next_date_published
FROM director_mapping AS d
INNER JOIN names AS n ON n.id = d.name_id
INNER JOIN movie AS m ON m.id = d.movie_id
INNER JOIN ratings AS r ON r.movie_id = m.id ),
top_directors_summary AS
(
SELECT *,
Datediff(next_date_published, date_published) AS date_difference
FROM ctf_date_summary
)
SELECT name_id AS director_id, NAME AS director_name,
COUNT(movie_id) AS number_of_movies,
ROUND(AVG(date_difference),2) AS avg_inter_movie_days,
ROUND(AVG(avg_rating),2) AS avg_rating,
SUM(total_votes) AS total_votes,
MIN(avg_rating) AS min_rating,
MAX(avg_rating) AS max_rating,
SUM(duration) AS total_duration
FROM top_directors_summary
GROUP BY director_id
ORDER BY COUNT(movie_id) DESC
limit 9;
