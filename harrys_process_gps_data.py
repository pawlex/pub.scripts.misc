#!/usr/bin/python
# pip install python-dateutil

""" 
    Converts time from UTC to LOCALTIME in Harry's lap timer GPS database in csv format.
    TODO:  Split output .csv files into "sessions"

"""

import csv
from datetime import datetime
from dateutil import tz

timeformat  = "%d-%b-%y,%H:%M:%S.%f"
in_filename = "LapTimerGPSRecDB.csv"
out_filename= "out.csv"
preheader   = "Harry's GPS LapTimer\n"

from_zone = tz.tzutc()
#to_zone = tz.gettz('America/Los_Angeles')
to_zone = tz.tzlocal()

def main():
    # Open both files for reading / writing respectively
    with open(in_filename,'rb') as readfile:
        with open(out_filename,'wb') as writefile:
            phcheck = readfile.readline()
            if phcheck != preheader:
                readfile.seek(0);
            # Harry's tag, skip to next line
            else:
                reader=csv.DictReader(readfile)
                writefile.write(",".join(reader.fieldnames))
                writer=csv.DictWriter(writefile,reader.fieldnames)
                for row in reader:
                    utc = datetime.strptime(row['DATE']+","+row['TIME'], timeformat)
                    utc = utc.replace(tzinfo=from_zone)
                    local = utc.astimezone(to_zone)
                    row['DATE'],row['TIME']=local.strftime(timeformat).split(",")
                    writer.writerow(row)
                #
            #
        #
    #
    readfile.close()
    writefile.close()
#

if __name__ == "__main__":
    main()
#
