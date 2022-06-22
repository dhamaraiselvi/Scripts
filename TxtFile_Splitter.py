#-*- coding: utf-8 -*-
"""
Created on Wed Aug  17 20:45:15 2019

@author:  Anton
ORCID iD: https://orcid.org/0000-0002-0559-0981
Download: https://www.python.org/downloads/
"""

import os
import sys

def Split_file():

    # Tool info
    print('TxtFile Splitter [v1.08r]\n\u00A9 2019 by Anton Vrdoljak\n\n')
    
    # Input the full path for text file
    path_name = input('> Step 1: Input the full path of your (.txt or .csv) file (for example C:\\Folder\\file.txt): ')
    while not (os.path.isfile(path_name) and ((path_name[-3:] == 'txt') or (path_name[-3:] == 'csv'))) :
        if not os.path.isfile(path_name) :
            print('\a', end = '')
            path_name = input('\n> A given path (' + path_name + ') does not exist, please input the valid full path\nof your (.txt or .csv) file (for example C:\\Folder\\file.txt): ')
        elif path_name[-3:] != 'txt' and path_name[-3:] != 'csv' :
            print('\a', end = '')
            path_name = input('\n> A given path (' + path_name + ') is not related with .txt or .csv file,\n please input the full path of your (text) file (for example C:\\Folder\\file.txt): ')
    
    # Get the line count & the file name
    try :
        file_name = os.path.splitext(path_name.rsplit(os.sep, 1)[1])[0]
        line_count = sum(1 for line in open(path_name))
    except :
        print('\a', end = '')
        print('\n> Unfortunately, TxtFile Splitter has encountered a problem: an error has occurred while attempting to get the line count from your file (' + path_name +'). In other words, TxtFile Splitter has found that your file is corrupted. Please, check is your file (plain) text file...')
        input('\nPress Enter to close TxtFile Splitter...')
        sys.exit(0)
    
    # Input the number of lines per file
    print('\a', end = '')
    num_lines = input('\n\n> Step 2: Input the number of lines per file (less or equal than ' + str(line_count) + '): ')
    while not (num_lines.isdigit() and int(num_lines) > 0 and int(num_lines) <= line_count) :
        if not num_lines.isdigit() :
            print('\a', end = '')
            num_lines = input('\n> You have entered a value ' + num_lines + ' that is not a number (positive integer),\nplease input a positive integer (less or equal than ' + str(line_count) + ') for the number of lines per file: ')
        elif int(num_lines) <= 0:
            print('\a', end = '')
            num_lines = input('\n> You have entered a value ' + num_lines + ' that is not a positive integer,\nplease input a positive integer (less or equal than ' + str(line_count) + ') for the number of lines per file: ')
        elif int(num_lines) > line_count :
            print('\a', end = '')
            num_lines = input('\n> You have entered a value ' + num_lines + ' that is larger than ' + str(line_count) + ',\nplease input a positive integer (less or equal than ' + str(line_count) + ') for the number of lines per file: ')
            
    # Make directory
    print('\a', end = '')
    print('\n\n> Step 3: Directory (folder) C:\\TxtFiles\\ will be created on your local disk C (if such folder does not exist on your disk)!')
    input('\nPress Enter to continue...')
    if not os.path.exists('TxtFiles') :
        os.makedirs('TxtFiles')
    
    # Determine the number of parts (chunks)
    def num_parts() :
        if line_count % int(num_lines) == 0 :
            return round(line_count/int(num_lines)) + 1
        else :
            return round(line_count/int(num_lines) - 0.5) + 2
    c = 1
    
    # Split the file into desired parts (chunks)
    with open(path_name, 'r') as f :
        try :
            f1 = open('TxtFiles' + file_name + '-' + str(c) + '.' + path_name[-3:], 'w')
            for n, line in enumerate(f) :
                if not n % int(num_lines) :
                    f1.close()
                    f1 = open('TxtFiles' + file_name + '-' + str(c) + '.' + path_name[-3:], 'w')
                    c += 1
                f1.write(line)
        finally :
            f1.close()
            
    print('\a', end = '')
    print('\n\nSplitting process finished successfully! You made ' + str(num_parts() - 1) + ' files, each with at least ' + num_lines + ' lines.')
    input('\nPress Enter to close TxtFile Splitter...')

Split_file()
