#!/usr/bin/python2.7
#
# Assignment3 Interface
#

import psycopg2
import os
import sys
import heapq
from threading import Thread

####################################################################################################
threadList0 = []
threadList1 = []
threadList2 = []
threadList3 = []
threadList4 = []

def ParallelSort(InputTable, SortingColumnName, OutputTable, openconnection):
    with openconnection.cursor() as cursor:
        sqlSelectCommand = "SELECT {} FROM {};".format(SortingColumnName, InputTable)
        cursor.execute(sqlSelectCommand)

        # Logic to divide the table data in round robin manner for 5 threads
        if bool(cursor.rowcount):
            rows = cursor.fetchall()
            lastInserted = 0

            for row in rows:
                lastInserted %= 5

                if lastInserted == 0:
                    threadList0.append(row[0])
                elif lastInserted == 1:
                    threadList1.append(row[0])
                elif lastInserted == 2:
                    threadList2.append(row[0])
                elif lastInserted == 3:
                    threadList3.append(row[0])
                elif lastInserted == 4:
                    threadList4.append(row[0])

                lastInserted += 1

        # Allocate each thread separate list
        for i in range(5):
            if i == 0:
                a = threadList0
            elif i == 1:
                a = threadList1
            elif i == 2:
                a = threadList2
            elif i == 3:
                a = threadList3
            elif i == 4:
                a = threadList4

            t = Thread(target=columnSort, args=(a,))
            t.start()

        finalList = list(heapq.merge(threadList0, threadList1, threadList2, threadList3, threadList4))
        finalList = list(set(finalList))

        sqlDropOutputTable = "DROP TABLE IF EXISTS {}".format(OutputTable)
        sqlCreateOutputTable = '''CREATE TABLE {} AS 
                                SELECT *
                                FROM {}
                                WHERE 1=2;
        '''.format(OutputTable, InputTable)

        cursor.execute(sqlDropOutputTable)
        cursor.execute(sqlCreateOutputTable)


        # Logic to select rows from input table and writing them to output table
        for value in finalList:
            sqlInsertQueryCommand = '''INSERT INTO {}
                                        SELECT * FROM {}
                                        WHERE {} = {};
            '''.format(OutputTable, InputTable, SortingColumnName, value)

            cursor.execute(sqlInsertQueryCommand)

        cursor.close()

def columnSort(threadList):
    threadList.sort()

#####################################################################################################################
def ParallelJoin(InputTable1, InputTable2, Table1JoinColumn, Table2JoinColumn, OutputTable, openconnection):
    columnRenaming = ""
    with openconnection.cursor() as cursor:

        if Table1JoinColumn != Table2JoinColumn:
            dropOutputTableQuery = "DROP TABLE IF EXISTS {}".format(OutputTable)
            createOutputTableQuery = '''CREATE TABLE {} AS 
                                        SELECT * FROM {}
                                        JOIN {} on {} = {}
                                        WHERE 1=2;
            '''.format(OutputTable, InputTable1, InputTable2, Table1JoinColumn, Table2JoinColumn)

            cursor.execute(dropOutputTableQuery)
            cursor.execute(createOutputTableQuery)
        else:
            columnRenaming = "{}_table1".format(Table1JoinColumn)
            alterTableQuery = "ALTER TABLE {} RENAME COLUMN {} TO {}".format(InputTable1, Table1JoinColumn, columnRenaming)
            Table1JoinColumn = columnRenaming

            dropOutputTableQuery = "DROP TABLE IF EXISTS {}".format(OutputTable)
            createOutputTableQuery = '''CREATE TABLE {} AS 
                                        SELECT * FROM {}
                                        JOIN {} on {} = {}
                                        WHERE 1=2;
            '''.format(OutputTable, InputTable1, InputTable2, columnRenaming, Table2JoinColumn)

            cursor.execute(alterTableQuery)
            cursor.execute(dropOutputTableQuery)
            cur.execute(createOutputTableQuery)

        firstList = []
        sqlSelectQueryOne = "SELECT {} FROM {}".format(Table1JoinColumn, InputTable1)
        cursor.execute(sqlSelectQueryOne)
    
        rows = cursor.fetchall()
        for row in rows:
            firstList.append(row[0])

        max_val = max(firstList)
        min_val = min(firstList)

        step_size = max_val / 5
        min_step_range = min_val - 5
        max_step_range = step_size + 5

        # Allocate each thread separate list
        for i in range(5):
            min_range_value = min_step_range
            max_range_value = max_step_range
            t = Thread(target=tableJoin, args=(min_range_value, max_range_value, InputTable1, InputTable2, Table1JoinColumn, Table2JoinColumn, OutputTable, openconnection,))
            t.start()
            min_step_range = max_range_value
            max_step_range += step_size

def tableJoin(min_value, max_value, InputTable1, InputTable2, Table1JoinColumn, Table2JoinColumn, OutputTable, openconnection):
    with openconnection.cursor() as cursor:
        sqlInsertJoinQuery = '''INSERT INTO {} 
                                (SELECT * FROM {} JOIN {} on {} = {} WHERE {} > {} AND {} <= {})
        '''.format(OutputTable, InputTable1, InputTable2, Table1JoinColumn, Table2JoinColumn, Table1JoinColumn, min_value, Table1JoinColumn, max_value)

        cursor.execute(sqlInsertJoinQuery)


################### DO NOT CHANGE ANYTHING BELOW THIS #############################
# Donot change this function
def getOpenConnection(user='postgres', password='1234', dbname='postgres'):
    return psycopg2.connect("dbname='" + dbname + "' user='" + user + "' host='localhost' password='" + password + "'")

# Donot change this function
def createDB(dbname='dds_assignment'):
    """
    We create a DB by connecting to the default user and database of Postgres
    The function first checks if an existing database exists for a given name, else creates it.
    :return:None
    """
    # Connect to the default database
    con = getOpenConnection(dbname='postgres')
    con.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    cur = con.cursor()

    # Check if an existing database with the same name exists
    cur.execute('SELECT COUNT(*) FROM pg_catalog.pg_database WHERE datname=\'%s\'' % (dbname,))
    count = cur.fetchone()[0]
    if count == 0:
        cur.execute('CREATE DATABASE %s' % (dbname,))  # Create the database
    else:
        print 'A database named {0} already exists'.format(dbname)

    # Clean up
    cur.close()
    con.commit()
    con.close()
