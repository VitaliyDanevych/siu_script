#  #!/usr/bin/env python
__AUTHOR__='Danevych V.'
__COPYRIGHT__='Danevych V. 2016 Kiev, Ukraine'
#vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4

import csv
import sys


if len(sys.argv) < 2:
   print "It is missed BSC name as argument"
   print "Make a choice in menu bumber 1 before start that script!"
   exit(1)
bsc_name = sys.argv[1]  
   

try:
    writefile = open('to_create.xml', 'w+')
except ValueError as msg:
    print msg

    
## Header
writefile.writelines('<?xml version="1.0" encoding="UTF-8" standalone="no"?>' + '\n')
writefile.writelines('<!DOCTYPE Model SYSTEM "/opt/ericsson/arne/etc/arne17_0.dtd">'+ '\n') 
writefile.writelines('<Model version="1" importVersion="17.0">'+ '\n')

## Start create
writefile.writelines('  '+ '<Create>'+ '\n')
## Subnetwork IPRAN start     
writefile.writelines('      '+ '<SubNetwork userLabel="IPRAN" networkType="IPRAN">'+ '\n')


with open('to_create.txt', 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',', quotechar='|')
        line_num = 0
        for row in reader:
            line_num += 1
            if (not len(row) == 4):
                print 'The quantuty of arguments at the line number ' + str(line_num) + ' is not enouph (4)'
                continue
            #rint row
            types = row[0].strip().upper() # upper case and remove all spaces
            full_s_name = row[1]
            site_name = row[2]
            ip = row[3]
            #print types + ':' + str(type(types))
            if types not in ('SIU','TCU02'):
                print "First correct argument was not found, I'll miss that line, line_num is " + str(line_num)
                #continue
            ## ManagedElement start    
            writefile.writelines('         ' + '<ManagedElement sourceType="' + types + '">'+ '\n')
            writefile.writelines('            ' + '<ManagedElementId string="' + full_s_name + '"/>'+ '\n') 
            writefile.writelines('            ' + '<primaryType type="STN"/>'+ '\n')
            writefile.writelines('            ' + '<managedElementType types=""/>' + '\n')
            writefile.writelines('            ' + '<associatedSite string="Site=' + site_name + '"/>' + '\n')
            writefile.writelines('            ' + '<nodeVersion string="T14B"/>' + '\n')
            writefile.writelines('            ' + '<platformVersion string="STN"/>'+ '\n')
            writefile.writelines('            ' + '<swVersion string=""/>'+ '\n')
            writefile.writelines('            ' + '<vendorName string=""/>'+ '\n')
            writefile.writelines('            ' + '<userDefinedState string=""/>'+ '\n')
            writefile.writelines('            ' + '<managedServiceAvailability int="1"/>'+ '\n')
            writefile.writelines('            ' + '<isManaged boolean="true"/>'+ '\n')
            writefile.writelines('            ' + '<connectionStatus string="ON"/>'+ '\n')
            ## Connectivity start
            writefile.writelines('            ' + '<Connectivity>'+ '\n')
            ## Default start
            writefile.writelines('               ' + '<DEFAULT>'+ '\n')
            writefile.writelines('                  ' + '<emUrl url="' + ip + '"/>'+ '\n')
            writefile.writelines('                  ' + '<ipAddress string="' + ip + '"/>'+ '\n')
            writefile.writelines('                  ' + '<oldIpAddress string=""/>'+ '\n')
            writefile.writelines('                  ' + '<hostname string="' + site_name + '"/>'+ '\n')
            writefile.writelines('                  ' + '<nodeSecurityState state="ON"/>'+ '\n')
            writefile.writelines('                  ' + '<boardId string=""/>'+ '\n')
            ## Protocol 0 start
            writefile.writelines('                  ' + '<Protocol number="0">'+ '\n')
            writefile.writelines('                     ' + '<protocolType string="SNMP"/>'+ '\n')
            writefile.writelines('                     ' + '<port int="161"/>'+ '\n')
            writefile.writelines('                     ' + '<protocolVersion string="V2C"/>'+ '\n')
            writefile.writelines('                     ' + '<securityName string=""/>'+ '\n')
            writefile.writelines('                     ' + '<authenticationMethod string=""/>'+ '\n')
            writefile.writelines('                     ' + '<encryptionMethod string=""/>'+ '\n')
            writefile.writelines('                     ' + '<communityString string="public"/>'+ '\n')
            writefile.writelines('                     ' + '<context string=""/>'+ '\n')
            writefile.writelines('                     ' + '<namingUrl string=""/>'+ '\n')
            writefile.writelines('                     ' + '<namingPort int=""/>'+ '\n')
            writefile.writelines('                     ' + '<notificationIRPAgentVersion string=""/>'+ '\n')
            writefile.writelines('                     ' + '<alarmIRPAgentVersion string=""/>'+ '\n')
            writefile.writelines('                     ' + '<notificationIRPNamingContext context=""/>'+ '\n')
            writefile.writelines('                     ' + '<alarmIRPNamingContext context=""/>'+ '\n')
            writefile.writelines('                  ' + '</Protocol>'+ '\n')
            ## Protocol 0 end
            ## Protocol 1 start
            writefile.writelines('                  ' + '<Protocol number="1">'+ '\n')
            writefile.writelines('                     ' + '<protocolType string="SSH"/>'+ '\n')
            writefile.writelines('                     ' + '<port int="22"/>'+ '\n')
            writefile.writelines('                     ' + '<protocolVersion string=""/>'+ '\n')
            writefile.writelines('                     ' + '<securityName string=""/>'+ '\n')
            writefile.writelines('                     ' + '<authenticationMethod string=""/>'+ '\n')
            writefile.writelines('                     ' + '<encryptionMethod string=""/>'+ '\n')
            writefile.writelines('                     ' + '<communityString string=""/>'+ '\n')
            writefile.writelines('                     ' + '<context string=""/>'+ '\n')
            writefile.writelines('                     ' + '<namingUrl string=""/>'+ '\n')
            writefile.writelines('                     ' + '<namingPort int=""/>'+ '\n')
            writefile.writelines('                     ' + '<notificationIRPAgentVersion string=""/>'+ '\n')
            writefile.writelines('                     ' + '<alarmIRPAgentVersion string=""/>'+ '\n')
            writefile.writelines('                     ' + '<notificationIRPNamingContext context=""/>'+ '\n')
            writefile.writelines('                     ' + '<alarmIRPNamingContext context=""/>'+ '\n')
            writefile.writelines('                  ' + '</Protocol>'+ '\n')
            ## Protocol 1 end
            ## Browser start
            writefile.writelines('                  ' + '<Browser>'+ '\n')
            writefile.writelines('                     ' + '<browser string=""/>'+ '\n')
            writefile.writelines('                     ' + '<browserURL string=""/>'+ '\n')
            writefile.writelines('                     ' + '<bookname string=""/>'+ '\n')
            writefile.writelines('                  ' + '</Browser>'+ '\n')
            ## Browser end
            ## Default end
            writefile.writelines('               ' + '</DEFAULT>'+ '\n')
            ## Connectivity end
            writefile.writelines('            ' + '</Connectivity>'+ '\n')
            ## Tss start
            writefile.writelines('            ' + '<Tss>'+ '\n')
            ## Entry secure start
            writefile.writelines('               ' + '<Entry>'+ '\n')
            writefile.writelines('                  ' + '<System string="' + full_s_name + '"/>'+ '\n')
            writefile.writelines('                  ' + '<Type string="SECURE"/>'+ '\n')
            writefile.writelines('                  ' + '<User string="admin"/>'+ '\n')
            writefile.writelines('                  ' + '<Password string="hidden"/>'+ '\n')
            writefile.writelines('               ' + '</Entry>'+ '\n')
            ## Entry secure end
            ## Entry normal start
            writefile.writelines('               ' + '<Entry>'+ '\n')
            writefile.writelines('                  ' + '<System string="' + full_s_name + '"/>'+ '\n')
            writefile.writelines('                  ' + '<Type string="NORMAL"/>'+ '\n')
            writefile.writelines('                  ' + '<User string="admin"/>'+ '\n')
            writefile.writelines('                  ' + '<Password string="hidden"/>'+ '\n')
            writefile.writelines('               ' + '</Entry>'+ '\n')
            ## Entry normal end
            ## Tss end
            writefile.writelines('            ' + '</Tss>'+ '\n')
            ## Relationship start
            writefile.writelines('            '+ '<Relationship>'+ '\n')
            writefile.writelines('               '+ '<AssociableNode TO_FDN="FtpServer=SMRSSLAVE-kinedss,FtpService=cmdown-kinedss" AssociationType="ManagedElement_to_neTransientCmDown"/>'+ '\n')
            writefile.writelines('               '+ '<AssociableNode TO_FDN="FtpServer=SMRSSLAVE-kinedss,FtpService=cmup-kinedss" AssociationType="ManagedElement_to_neTransientCmUp"/>'+ '\n')
            writefile.writelines('               '+ '<AssociableNode TO_FDN="FtpServer=SMRSSLAVE-kinedss,FtpService=pmup-kinedss" AssociationType="ManagedElement_to_neTransientPm"/>'+ '\n')
            writefile.writelines('               '+ '<AssociableNode TO_FDN="FtpServer=SMRSSLAVE-kinedss,FtpService=swstore-kinedss" AssociationType="ManagedElement_to_ftpSwStore"/>'+ '\n')
            writefile.writelines('               '+ '<AssociableNode TO_FDN="ManagedElement=' + bsc_name + ',BssFunction=BSS_ManagedFunction" FROM_FDN="SubNetwork=IPRAN,ManagedElement=' + full_s_name + ',StnFunction=STN_ManagedFunction" AssociationType="StnFunction_to_BssFunction"/>'+ '\n')
            writefile.writelines('               '+ '<AssociableNode TO_FDN="ManagedElement=' + bsc_name + ',BssFunction=BSS_ManagedFunction,BtsSiteMgr=' + site_name + '" FROM_FDN="SubNetwork=IPRAN,ManagedElement=' + full_s_name +',StnFunction=STN_ManagedFunction" AssociationType="StnFunction_to_BtsSiteMgr"/>'+ '\n')
            writefile.writelines('               '+ '<AssociableNode TO_FDN="ManagementNode=ONRM" AssociationType="MgmtAssociation"/>'+ '\n')
            ## Relationship end
            writefile.writelines('            '+ '</Relationship>'+ '\n')
            ## ManagedElement end
            writefile.writelines('         '+ '</ManagedElement>'+ '\n')
 
## Subnetwork IPRAN end     
writefile.writelines('      '+ '</SubNetwork>'+ '\n')
## Stop create     
writefile.writelines('  '+ '</Create>'+ '\n')
writefile.writelines('</Model>'+ '\n')     
writefile.close()

#print "to_create.xml file was created."
#print 'For check xml file use: ' + '/opt/ericsson/arne/bin/import.sh -f to_create.xml -val:rall' + '\n'
#print 'For start xml file use: ' + '/opt/ericsson/arne/bin/import.sh -import -f to_create.xml' + '\n'

