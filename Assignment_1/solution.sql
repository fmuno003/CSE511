/***********************************************************************
** File: Assignment 1: Create Movie Recommendation Database    
** Name: Francisco Muñoz
** Date: 05/25/2020
**************************
** Change History
**************************
** PR   Date        Author  Description 
** --   --------   -------   ------------------------------------
** 1    05/25/2020 fmuno003  Initial Creation
*********************************************************************/
-- COMPLETE TEST CASE 1: Insert Normal Data.
-- TEST CASE 2: Insert non-exist foreign key.
-- TEST CASE 3: Insert duplicate rating.
-- TEST CASE 4: Insert a hasagenre record that contains wrong genre id.
-- TEST CASE 5: Insert a rating larger than 5.

-- Checks to see if tables exist already or not. If they do, drop tables
DROP TABLE IF EXISTS hasagenre;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS taginfo;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS users;

-- Table for Users
CREATE TABLE users (
    userid INT PRIMARY KEY,
    name text NOT NULL
);

-- Table for Movies
CREATE TABLE movies (
    movieid INT PRIMARY KEY,
    title text
);

-- Table for Tag Info
CREATE TABLE taginfo(
    tagid INT PRIMARY KEY,
    content text
);

-- Table for Genres
CREATE TABLE genres(
    genreid INT PRIMARY KEY,
    name text 
);

-- Table for Ratings
CREATE TABLE ratings(
    userid INT,
    movieid INT,
    FOREIGN KEY(userid) REFERENCES users(userid),
    FOREIGN KEY(movieid) REFERENCES movies(movieid),
    rating DECIMAL CHECK(rating > 0.0 and rating <= 5.0),
    timestamp bigint
);

-- Table for Tags
CREATE TABLE tags(
    userid INT,
    movieid INT,
    tagid INT PRIMARY KEY,
    FOREIGN KEY(userid) REFERENCES users(userid),
    FOREIGN KEY(movieid) REFERENCES movies(movieid),
    FOREIGN KEY(tagid) REFERENCES taginfo(tagid),
    timestamp bigint
);

-- Table for Having a Genre
CREATE TABLE hasagenre(
    movieid INT,
    genreid INT,
    FOREIGN KEY(movieid) REFERENCES movies(movieid),
    FOREIGN KEY(genreid) REFERENCES genres(genreid)
);




-- This will only be used for testing purposes only
\copy users from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/users.dat' DELIMITER '%' CSV;
SELECT COUNT(*) FROM users;

\copy movies from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/movies.dat' DELIMITER '%' CSV;
SELECT COUNT(*) FROM movies;

\copy taginfo from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/taginfo.dat' DELIMITER '%' CSV;
SELECT COUNT(*) FROM taginfo;

\copy genres from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/genres.dat' DELIMITER '%' CSV;
SELECT COUNT(*) FROM genres;

\copy ratings from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/ratings.dat' DELIMITER '%' CSV;
SELECT COUNT(*) FROM ratings;

\copy tags from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/tags.dat' DELIMITER '%' CSV;
SELECT COUNT(*) FROM tags;

\copy hasagenre from 'C:/Users/Francisco/Desktop/CSE511 - DataProcessingAtScale/CSE511/Assignment_1/TestData/hasagenre.dat' DELIMITER '%' CSV;
SELECT COUNT(*) FROM hasagenre;