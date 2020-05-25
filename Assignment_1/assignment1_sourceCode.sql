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

-- Checks to see if tables exist already or not. If they do, drop tables
DROP TABLE IF EXISTS HasAGenre;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS taginfo;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS users;

-- Table for Users
CREATE TABLE users (
    userid INT PRIMARY KEY,
    name VARCHAR(50)
);

-- Table for Movies
CREATE TABLE movies (
    movieid INT PRIMARY KEY,
    title VARCHAR(50)
);

-- Table for Tag Info
CREATE TABLE taginfo(
    tagid INT PRIMARY KEY,
    content VARCHAR(200)
);

-- Table for Genres
CREATE TABLE genres(
    genreid INT PRIMARY KEY,
    name VARCHAR(200) 
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
    tagid INT,
    FOREIGN KEY(userid) REFERENCES users(userid),
    FOREIGN KEY(movieid) REFERENCES movies(movieid),
    FOREIGN KEY(tagid) REFERENCES taginfo(tagid),
    timestamp bigint
);

-- Table for Having a Genre
CREATE TABLE HasAGenre(
    movieid INT,
    genreid INT,
    FOREIGN KEY(movieid) REFERENCES movies(movieid),
    FOREIGN KEY(genreid) REFERENCES genres(genreid)
);