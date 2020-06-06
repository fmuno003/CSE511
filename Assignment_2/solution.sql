/***********************************************************************
** File: Assignment 2: SQL Query for Movie Recommendation   
** Name: Francisco Muñoz
** Date: 05/25/2020
**************************
** Change History
**************************
** PR   Date        Author  Description 
** --   --------   -------   ------------------------------------
** 1    05/25/2020 fmuno003  Initial Creation
** 2    06/05/2020 fmuno003  Working on the rest of the queries. Assignment 2 has been complete
*********************************************************************/
-- Checks to see if tables exist already or not. If they do, drop tables
DROP TABLE IF EXISTS hasagenre;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS taginfo;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS users;

DROP TABLE IF EXISTS query1;
DROP TABLE IF EXISTS query2;
DROP TABLE IF EXISTS query3;
DROP TABLE IF EXISTS query4;
DROP TABLE IF EXISTS query5;
DROP TABLE IF EXISTS query6;
DROP TABLE IF EXISTS query7;
DROP TABLE IF EXISTS query8;
DROP TABLE IF EXISTS query9;
DROP TABLE IF EXISTS recommendation;

DROP TABLE IF EXISTS temp;
DROP TABLE IF EXISTS similarity;
DROP TABLE IF EXISTS moviesUserHasSeen;
DROP TABLE IF EXISTS prediction;

-- Table for Users
CREATE TABLE users (
    userid INTEGER PRIMARY KEY,
    name text NOT NULL
);

-- Table for Movies
CREATE TABLE movies (
    movieid INTEGER PRIMARY KEY,
    title text NOT NULL
);

-- Table for Tag Info
CREATE TABLE taginfo(
    tagid INTEGER PRIMARY KEY,
    content text NOT NULL
);

-- Table for Genres
CREATE TABLE genres(
    genreid INTEGER PRIMARY KEY,
    name text NOT NULL
);

-- Table for Ratings
CREATE TABLE ratings(
    userid INTEGER,
    movieid INTEGER,
    PRIMARY KEY(userid, movieid),
    rating NUMERIC CHECK(rating >= 0.0 and rating <= 5.0),
    timestamp bigint NOT NULL,
    FOREIGN KEY(userid) REFERENCES users(userid),
    FOREIGN KEY(movieid) REFERENCES movies(movieid)
);

-- Table for Tags
CREATE TABLE tags(
    userid INTEGER,
    movieid INTEGER,
    tagid INTEGER,
    timestamp bigint NOT NULL,
    FOREIGN KEY(userid) REFERENCES users(userid),
    FOREIGN KEY(movieid) REFERENCES movies(movieid),
    FOREIGN KEY(tagid) REFERENCES taginfo(tagid)
);

-- Table for Having a Genre
CREATE TABLE hasagenre(
    movieid INTEGER,
    genreid INTEGER,
    FOREIGN KEY(movieid) REFERENCES movies(movieid),
    FOREIGN KEY(genreid) REFERENCES genres(genreid)
);

-- This will only be used for testing purposes only
\copy users from 'C:/Users/Francisco/Desktop/CSE511_DataProcessingAtScale/CSE511/Assignment_1/TestData/users.dat' DELIMITERS '%';

\copy movies from 'C:/Users/Francisco/Desktop/CSE511_DataProcessingAtScale/CSE511/Assignment_1/TestData/movies.dat' DELIMITERS '%';

\copy taginfo from 'C:/Users/Francisco/Desktop/CSE511_DataProcessingAtScale/CSE511/Assignment_1/TestData/taginfo.dat' DELIMITERS '%';

\copy genres from 'C:/Users/Francisco/Desktop/CSE511_DataProcessingAtScale/CSE511/Assignment_1/TestData/genres.dat' DELIMITERS '%';

\copy ratings from 'C:/Users/Francisco/Desktop/CSE511_DataProcessingAtScale/CSE511/Assignment_1/TestData/ratings.dat' DELIMITERS '%';

\copy tags from 'C:/Users/Francisco/Desktop/CSE511_DataProcessingAtScale/CSE511/Assignment_1/TestData/tags.dat' DELIMITERS '%';

\copy hasagenre from 'C:/Users/Francisco/Desktop/CSE511_DataProcessingAtScale/CSE511/Assignment_1/TestData/hasagenre.dat' DELIMITERS '%';

--#################################################################################################
-- Query 1
-- Write a SQL query to return the total number of movies for each genre
CREATE TABLE query1(name, moviecount) as
SELECT genres.name, count(genres.name)
FROM hasagenre
NATURAL JOIN genres
NATURAL JOIN movies
GROUP BY genres.name;

-- Query 2
-- Write a SQL query to return the average rating per genre
CREATE TABLE query2(name, rating) as
SELECT genres.name, avg(ratings.rating)
FROM movies
NATURAL JOIN genres
NATURAL JOIN ratings
NATURAL JOIN hasagenre
GROUP BY genres.name;

-- Query 3
-- Write a SQL query to return the movies which have at least 10 ratings.
CREATE TABLE query3(title, CountOfRatings) as
SELECT movies.title, count(rating)
FROM movies
NATURAL JOIN ratings 
GROUP BY movies.title
HAVING COUNT(*) >= 10;

-- Query 4
-- Write a SQL query to return all “Comedy” movies, including movieid and title.
CREATE TABLE query4(movieid, title) as
SELECT movieid, title
FROM movies
NATURAL JOIN genres
NATURAL JOIN hasagenre
WHERE genres.name = 'Comedy'
GROUP BY movieid;

-- Query 5
-- Write a SQL query to return the average rating per movie
CREATE TABLE query5(title, average) as
SELECT movies.title, avg(ratings.rating)
FROM movies
NATURAL JOIN ratings
GROUP BY movies.title;

-- Query 6
-- Write a SQL query to return the average rating for all “Comedy” movies.
CREATE TABLE query6(average) as
SELECT avg(ratings.rating)
FROM movies
NATURAL JOIN genres
NATURAL JOIN ratings
NATURAL JOIN hasagenre
WHERE genres.name = 'Comedy';

-- Query 7
-- Write a SQL query to return the average rating for all movies and each of these movies is both "Comedy" and "Romance"
CREATE TABLE query7(average) as
SELECT avg(ratings.rating)
FROM ratings
INNER JOIN (SELECT hasagenre.movieid
            FROM hasagenre  
            NATURAL JOIN genres
            WHERE genres.name IN ('Comedy', 'Romance')
            GROUP BY hasagenre.movieid
            HAVING COUNT(DISTINCT genres.name) = 2
) m ON ratings.movieid = m.movieid;

-- Query 8
-- Write a SQL query to return the average rating for all movies and each of these movies is "Romance" but not "Comedy"
CREATE TABLE query8(average) as
SELECT avg(ratings.rating)
FROM ratings
WHERE movieid in (SELECT movieid
                    FROM hasagenre
                    NATURAL JOIN genres
                    GROUP BY movieid
                    HAVING COUNT(CASE WHEN genres.name = 'Comedy' THEN 1 END) = 0
                    AND COUNT(CASE WHEN genres.name = 'Romance' THEN 1 END) = 1
);


-- Query 9
-- Find all movies that are rated by a user such that the userId is equal to v1
CREATE TABLE query9(movieid, rating) as 
SELECT movieid, rating
FROM movies
NATURAL JOIN users
NATURAL JOIN ratings
WHERE userid = :v1;

-- Query 10
-- Write an SQL query to create a recommendation table for a given user.
CREATE TABLE temp(movieid, average) as
SELECT movies.movieid, avg(ratings.rating)
FROM movies
NATURAL JOIN ratings
GROUP BY movies.movieid;

CREATE TABLE similarity(movieid1, movieid2, sim) as
SELECT t1.movieid, t2.movieid, (1 - (abs(t1.average - t2.average) / 5))
FROM temp t1, temp t2
WHERE t1.movieid <> t2.movieid;

CREATE TABLE moviesuserhasseen(movieid, rating) as
SELECT movieid, rating
FROM ratings
WHERE userid = :v1;

CREATE TABLE prediction(movieId, predictionValue) as
SELECT movieid1, (SUM(sim * rating) / SUM(sim))
FROM similarity, moviesuserhasseen
WHERE movieid1 <> movieid
GROUP BY similarity.movieid1;

CREATE TABLE recommendation(title) as
SELECT movies.title
FROM prediction, movies
WHERE movies.movieid = prediction.movieId AND predictionValue > 3.9;
