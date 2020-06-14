#!/usr/bin/python2.7
#
#Tester for students
# Do not hard code values in your program for ratings.
# table name and input file name.
# Do not close con objects in your program.
# Invalid ranges will not be tested.
# Order of output does not matter, only correctness will be checked.
# Use discussion board extensively to clear doubts.
# Sample output does not correspond to data in test_data.txt.
#

DATABASE_NAME = 'dds_assignment'

import Assignment1 as Assignment1
import Interface as Assignment2
import traceback

if __name__ == '__main__':
    try:
        #Creating Database ddsassignment2
        print "Creating Database named as " + DATABASE_NAME
        Assignment1.createDB(DATABASE_NAME);

        # Getting connection to the database
        print "Getting connection from the "+ DATABASE_NAME + " database"
        con = Assignment1.getOpenConnection(dbname=DATABASE_NAME);

        # Clear the database existing tables
        print "Delete tables"
        Assignment1.deleteTables('all', con);

        # Loading Ratings table
        print "Creating and Loading the ratings table"
        Assignment1.loadRatings('ratings', 'test_data.txt', con);

        # Doing Range Partition
        print "Doing the Range Partitions"
        Assignment1.rangePartition('ratings', 5, con);

        # Doing Round Robin Partition
        print "Doing the Round Robin Partitions"
        Assignment1.roundRobinPartition('ratings', 5, con);

        # Deleting Ratings Table because Point Query and Range Query should not use ratings table instead they should use partitions.
        Assignment1.deleteTables('ratings', con);

        # Calling RangeQuery
        print "Performing Range Query"
        Assignment2.RangeQuery('ratings', 1.5, 3.5, con);
        #Assignment2.RangeQuery('ratings',1,4,con);

        # Calling PointQuery
        print "Performing Point Query"
        Assignment2.PointQuery('ratings', 4.5, con);
        #Assignment2.PointQuery('ratings',2,con);
        
        # Deleting All Tables
        Assignment1.deleteTables('all', con);

        if con:
            con.close()

    except Exception as detail:
        traceback.print_exc()
