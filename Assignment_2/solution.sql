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
\copy users from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/users.dat' DELIMITERS '%';

\copy movies from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/movies.dat' DELIMITERS '%';

\copy taginfo from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/taginfo.dat' DELIMITERS '%';

\copy genres from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/genres.dat' DELIMITERS '%';

\copy ratings from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/ratings.dat' DELIMITERS '%';

\copy tags from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/tags.dat' DELIMITERS '%';

\copy hasagenre from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/hasagenre.dat' DELIMITERS '%';

--#################################################################################################
-- Query 1
CREATE TABLE query1(name, moviecount) as
SELECT genres.name, count(genres.name)
FROM hasagenre
NATURAL JOIN genres
NATURAL JOIN movies
GROUP BY genres.name;

SELECT *
FROM query1;

-- Query 2
--CREATE TABLE query2 as

--SELECT *
--FROM query2;

-- Query 3

-- Query 4

-- Query 5

-- Query 6

-- Query 7

-- Query 8

-- Query 9
