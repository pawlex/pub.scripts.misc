#!/usr/bin/python

# pip install python-dateutil
import csv
from datetime import datetime
from dateutil import tz

timeformat  = "%d-%b-%y,%H:%M:%S.%f"
in_filename = "LapTimerGPSRecDB.csv"
out_filename= "session_1.csv"
preheader   = "Harry's GPS LapTimer\n"

from_zone = tz.tzutc()
#to_zone = tz.gettz('America/Los_Angeles')
to_zone = tz.tzlocal()

def main():
    # Open both files for reading / writing respectively
    with open(in_filename,'rb') as readfile:
        #
        writefile = open(out_filename,'wb')
        phcheck = readfile.readline()
        if phcheck != preheader:
            readfile.seek(0);
        # Harry's tag, skip to next line
        else:
            reader=csv.DictReader(readfile)
            writefile.write(",".join(reader.fieldnames))
            writer=csv.DictWriter(writefile,reader.fieldnames)
            lasttimestamp = None
            for row in reader:
                utc = datetime.strptime(row['DATE']+","+row['TIME'], timeformat)
                utc = utc.replace(tzinfo=from_zone)
                local = utc.astimezone(to_zone)
                # SPLIT INTO SESSIONS
                if(lasttimestamp is not None and ((local.hour*60+local.minute - lasttimestamp) > 20)):
                    last_filename=writefile.name
                    writefile.close()
                    next_filename = last_filename.split(".", 1)[0] # grab everything before the .

                    #if(last_filename != out_filename):
                    #    # filename has changed.  assume we changed it and the last character is a number.
                    #    next_sequence = int(next_filename[-1])
                    #    next_filename = next_filename[:-1]+str(next_sequence+1)+".csv"
                    #else:
                    #    next_filename = next_filename+str(1)+".csv"

                    # increment the session number.
                    next_sequence = int(next_filename[-1])
                    next_filename = next_filename[:-1]+str(next_sequence+1)+".csv"
                    # open file for writing, re-write the header and continue
                    writefile = open(next_filename, "wb")
                    writefile.write(",".join(reader.fieldnames))
                    writer=csv.DictWriter(writefile,reader.fieldnames)
                #
                row['DATE'],row['TIME']=local.strftime(timeformat).split(",")
                writer.writerow(row)
                lasttimestamp = local.hour*60 + local.minute
            #
        #
    #
    readfile.close()
    writefile.close()
#

if __name__ == "__main__":
    main()
#
