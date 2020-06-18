#!/usr/bin/python2.7
"""
/***********************************************************************
** File: Assignment 4: Query Processing
** Name: Francisco Munoz
** Date: 06/17/2020
**************************
** Change History
**************************
** PR   Date        Author  Description 
** --   --------   -------   ------------------------------------
** 1    06/17/2020 fmuno003  Initial Creation
** 
*********************************************************************/
"""

import psycopg2
import os
import sys

outputRangeFile = 'RangeQueryOut.txt'
outputPointFile = 'PointQueryOut.txt'
new_list = []

def RangeQuery(ratingsTableName, ratingMinValue, ratingMaxValue, openconnection):
    if(ratingMinValue < 0.0 or ratingMaxValue > 5.0):
        return

    new_list = []

    with openconnection.cursor() as cursor:
        sqlSelectCommand = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'"
        cursor.execute(sqlSelectCommand)
        tables = cursor.fetchall()

        for each_table in tables:
            if not (each_table[0] == 'rangeratingsmetadata' or each_table[0] == 'roundrobinratingsmetadata'):
                sqlSelectCommand = "SELECT * FROM {} WHERE Rating >= {} AND Rating <= {}".format(each_table[0] , ratingMinValue, ratingMaxValue)
                cursor.execute(sqlSelectCommand)
                values = cursor.fetchall()

                for each_value in values:
                    newRow = "{},{},{},{}".format(each_table[0], each_value[0], each_value[1], each_value[2])
                    new_list.append(newRow)

        writeToFile(outputRangeFile, new_list)
        cursor.close()

def PointQuery(ratingsTableName, ratingValue, openconnection):
    if(ratingValue > 5.0 or ratingValue < 0.0):
        return

    new_list = []

    with openconnection.cursor() as cursor:
        sqlSelectCommand = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'"
        cursor.execute(sqlSelectCommand)
        tables = cursor.fetchall()

        for eachTable in tables:
            if not (eachTable[0] == 'rangeratingsmetadata' or eachTable[0] == 'roundrobinratingsmetadata'):
                sqlSelectCommand = "SELECT * FROM {} WHERE Rating = {}".format(eachTable[0], ratingValue)
                cursor.execute(sqlSelectCommand)
                values = cursor.fetchall()

                for eachValue in values:
                    newRow = "{},{},{},{}".format(eachTable[0], eachValue[0], eachValue[1], eachValue[2])
                    new_list.append(newRow)

        writeToFile(outputPointFile, new_list)
        cursor.close()

def writeToFile(filename, rows):
    f = open(filename, 'w')
    for line in rows:
        f.write(line)
        f.write('\n')
    f.close()
