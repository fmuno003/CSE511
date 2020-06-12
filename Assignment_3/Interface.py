#!/usr/bin/python2.7
#
# Interface for the assignment
#

import numbers
import psycopg2

def getOpenConnection(user='postgres', password='Cookies344!UCR', dbname='postgres'):
    return psycopg2.connect("dbname='" + dbname + "' user='" + user + "' host='localhost' password='" + password + "'")

def loadRatings(ratingstablename, ratingsfilepath, openconnection):
    """ Inserting Ratings.dat into the Database """
    with openconnection.cursor() as cursor:
        sqlDropCommand = "DROP TABLE IF EXISTS {}".format(ratingstablename)
        sqlCreateCommand = ''' CREATE TABLE {} (
            userid INT NOT NULL,
            movieid INT,
            rating NUMERIC(2,1),
            PRIMARY KEY(userid, movieid, rating))'''.format(ratingstablename)

        cursor.execute(sqlDropCommand)
        cursor.execute(sqlCreateCommand)

        ratingFile = open(ratingsfilepath, "r")
        lines = ratingFile.readlines()
        i = 0
        for line in lines:
            fields = line.split("::")
            if (i == 20):
                break
            sqlInsertCommand = "INSERT INTO " + ratingstablename + "(userid, movieid, rating) VALUES ({}, {}, {})".format(str(fields[0]), str(fields[1]), str(fields[2]))
            cursor.execute(sqlInsertCommand)
            i += 1
        
        ratingFile.close()
        cursor.close()

def rangePartition(ratingstablename, numberofpartitions, openconnection):
    """ Partition the table based on Number of Partitions Requested """
    with openconnection.cursor() as cursor:
        range_condition = float(5.0 / numberofpartitions)

        for i in range(0, numberofpartitions):
            sqlDropCommand = "DROP TABLE IF EXISTS range_part{};".format(str(i))
            cursor.execute(sqlDropCommand)
            j = float(i)

            if i == 0:
                sqlCreateCommand = "CREATE TABLE range_part{} AS SELECT * FROM {} WHERE Rating >= {} AND Rating <= {} ;".format(str(i), ratingstablename, str(j*range_condition), str((j+1)*range_condition))
                cursor.execute(sqlCreateCommand)
            else:
                sqlCreateCommand = "CREATE TABLE range_part{} AS SELECT * FROM {} WHERE Rating > {} AND Rating <= {} ;".format(str(i), ratingstablename, str(j*range_condition), str((j+1)*range_condition))
                cursor.execute(sqlCreateCommand)
        
        cursor.close()

def roundRobinPartition(ratingstablename, numberofpartitions, openconnection):
    """" Round Robin Partition """
    with openconnection.cursor() as cursor:
        if(numberofpartitions < 1 or (isinstance(numberofpartitions,int) == False)):
            return

        partition_list = list(reversed(range(numberofpartitions)))
        global partitionTotal
        global lastInsertedPosition

        partitionTotal = numberofpartitions
        lastInsertedPosition = 0
        j = 0

        for i in partition_list:
            sqlDropCommand = "DROP TABLE IF EXISTS rrobin_part{}".format(i)
            sqlCreateTableCommand = '''CREATE TABLE rrobin_part{} ( 
                                userid INT NOT NULL,
                                movieid INT NOT NULL,
                                rating NUMERIC(2,1))'''.format(i)


            sqlInsertCommand = ''' INSERT INTO rrobin_part{} 
                                SELECT t.userid, t.movieid, t.rating 
                                FROM(SELECT *, row_number() OVER() as row from {})t 
                                WHERE t.row % {} = {} '''.format(i, ratingstablename, numberofpartitions, i)

            cursor.execute(sqlDropCommand)
            cursor.execute(sqlCreateTableCommand)
            cursor.execute(sqlInsertCommand)

            sqlRowNumberCommand = "SELECT COUNT(*) FROM rrobin_part{};".format(i)
            rowNumber = cursor.execute(sqlRowNumberCommand)

            if rowNumber > j:
                lastInsertedPosition = i
                j = rowNumber

        cursor.close()

def roundrobininsert(ratingstablename, userid, itemid, rating, openconnection):
    """ Round Robin Insert """
    if rating > 5.0 or rating < 0.0:
        return

    with openconnection.cursor() as cursor:
        global partitionTotal
        global lastInsertedPosition
        lastPart = lastInsertedPosition % partitionTotal

        sqlInsertCommand = "INSERT INTO rrobin_part{} (userid, movieid, rating) VALUES ({}, {}, {})".format((lastPart), userid, itemid, rating)

        cursor.execute(sqlInsertCommand)
        
        lastInsertedPosition += 1

        if lastInsertedPosition == 5:
            lastInsertedPosition = 0

        cursor.close()

def rangeinsert(ratingstablename, userid, itemid, rating, openconnection):
    """ Range Insert """
    with openconnection.cursor() as cursor:
        Lower = partitionnumber = 0
        Upper = 1.0
    
        while Lower < 5.0:
            if Lower == 0:
                if rating >= Lower and rating <= Upper:
                    break
            else: 
                if rating > Lower and rating <= Upper:
                    break

            partitionnumber += 1
            Lower += 1.0
            Upper += 1.0
            
        sqlInsertCommand = "INSERT INTO range_part{} (userid, movieid, rating) VALUES ({}, {}, {})".format(partitionnumber, userid, itemid, rating)
        cursor.execute(sqlInsertCommand)
        cursor.close()

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
        print ('A database named {0} already exists').format(dbname)

    # Clean up
    cur.close()
    con.close()

def deletepartitionsandexit(openconnection):
    cur = openconnection.cursor()
    cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
    l = []
    for row in cur:
        l.append(row[0])
    for tablename in l:
        cur.execute("drop table if exists {0} CASCADE".format(tablename))

    cur.close()

def deleteTables(ratingstablename, openconnection):
    try:
        cursor = openconnection.cursor()
        if ratingstablename.upper() == 'ALL':
            cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
            tables = cursor.fetchall()
            for table_name in tables:
                cursor.execute('DROP TABLE %s CASCADE' % (table_name[0]))
        else:
            cursor.execute('DROP TABLE %s CASCADE' % (ratingstablename))
        openconnection.commit()
    except psycopg2.DatabaseError, e:
        if openconnection:
            openconnection.rollback()
        print 'Error %s' % e
    except IOError, e:
        if openconnection:
            openconnection.rollback()
        print 'Error %s' % e
    finally:
        if cursor:
            cursor.close()
