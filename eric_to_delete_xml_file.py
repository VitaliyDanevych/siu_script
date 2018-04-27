 #!/usr/bin/env python -tt
__AUTHOR__='Danevych V.'
__COPYRIGHT__='Danevych V. 2016 Kiev, Ukraine'
#vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4

import csv

try:
    writefile = open('to_delete.xml', 'w+')
except ValueError as msg:
    print msg

writefile.writelines('<?xml version="1.0" encoding="UTF-8" standalone="no"?>' + '\n')
writefile.writelines('<!DOCTYPE Model SYSTEM "/opt/ericsson/arne/etc/arne17_0.dtd">'+ '\n') 
writefile.writelines('<Model version="1" importVersion="17.0">'+ '\n') 
writefile.writelines('  '+ '<Delete>'+ '\n')     
 
try:
    readfile = open('to_delete.txt', 'r')
except ValueError as msg:
    print msg
    
for line in readfile:
    line = line.rstrip()
    str = '     ' + '<Object fdn=\"SubNetwork=ONRM_RootMo,SubNetwork=IPRAN,ManagedElement=' + line + '"/>' + '\n'
    #print str
    writefile.writelines(str)
    
writefile.writelines('  '+ '</Delete>'+ '\n')
writefile.writelines('</Model>'+ '\n')     
writefile.close()

#print 'For check xml file use: ' + '/opt/ericsson/arne/bin/import.sh -f to_delete.xml -val:rall' + '\n'
#print 'For start xml file use: ' + '/opt/ericsson/arne/bin/import.sh -import -f to_delete.xml' + '\n'


