#!/bin/bash

echo "start!"
wdir=$(pwd -P)
echo "your working directory is: " $wdir
echo "removing old files..."
rm -rf  ${wdir}/to_delete.txt
rm -rf ${wdir}/to_create.txt
rm -rf ${wdir}/to_delete.xml
rm -rf ${wdir}/to_create.xml
rm -rf ${wdir}/ipdatabase.txt
rm -rf ${wdir}/ipdatabase_selected.txt
echo "done!"


PS3='Please enter your choice: '
options=("Step 1: Chose target BSC name for SIU/TCU association" "Step 2: Prepare SIU/TCU files" "Step 3: Apply SIU/TCU deletion in OSS" "Step 4: Apply SIU/TCU creation in OSS" "Perform adjust before quit" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Step 1: Chose target BSC name for SIU/TCU association")
            echo "you have the following list of BSC on OSS-RC1:"
            /opt/ericsson/bin/eac_esi_config -nelist | grep 'APG' | egrep "[B][0-9]" | awk '{print $1}' | perl -pi -e 's/\n/\|/g;' | perl -pi -e 's/\|$/\n/g;'
            #KIEB9|KIEB2|KIEB5|KITB3|CHGB1|CHGB2|CKAB2|KIEB1|VNIB1|VNIB2|VNIB3|MYKB1|MYKB2|MYKB3|KIEB8|KIEB7|KIEB6|KIEB4|KIEB3|DNEB20|DNEB19
            echo "Chise one of the mentioned BSC - just type it and press Enter"
            read bsc_name
            echo 'It was choosen: ' $bsc_name 'Ok. Go to the next step!'
            ;;
        "Step 2: Prepare SIU/TCU files")
            echo "you have choosen Step 2"
            if [ -z "$bsc_name" ]; then echo "You have not choosen BSC at Step 1. Go to the Step 1 and return here"; fi
            
            echo "checking if it is exist the site_list.txt file with list of sites for processing.."
            if ! [ -f ${wdir}/site_list.txt ]
                then
                    echo "The site_list.txt file doesn't exist. Please, put that file to the working directory! " "$wdir".
                else
                    echo "The site_list.txt file has been found. I can continue..."
            fi
            
            cd ${wdir}
            echo "making topology database file..."
            /opt/ericsson/ddc/util/bin/listme > ${wdir}/ipdatabase.txt 
            echo "The ipdatabase file : " "${wdir}/ipdatabase.txt" " has been created."
            
            #"making one line of sites separated by special symbols..."
            my_line=$(cat site_list.txt | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//' | perl -pi -e 's/\n/\|/g;' | perl -pi -e 's/\|$/\n/g;')
            echo 'my_line: ' "$my_line"
            result=$(egrep $my_line ${wdir}/ipdatabase.txt)
            #echo "$result"  #show result on display
            rm -rf ${wdir}/ipdatabase_selected.txt
            echo "$result" > ${wdir}/ipdatabase_selected.txt
            echo "It was created the file: " "${wdir}/ipdatabase_selected.txt"
            echo "The file has " "$(cat ${wdir}/ipdatabase_selected.txt | wc -l)" " lines"
            
            #Making delete txt file
            rm -rf ${wdir}/to_delete.txt
            cat ${wdir}/ipdatabase_selected.txt | perl -pi -e 's/^SubNetwork=ONRM_RootMo_R,SubNetwork=IPRAN,MeContext=((\w+\d+)_\w+\d+)@(\d+.\d+.\d+.\d+).*$/$1/gi' > ${wdir}/to_delete.txt
            echo "The ${wdir}/to_delete.txt file has been created"
            
            #Making create txt file
            rm -rf ${wdir}/to_create.txt
            cat ${wdir}/ipdatabase_selected.txt | perl -pi -e 's/^SubNetwork=ONRM_RootMo_R,SubNetwork=IPRAN,MeContext=((\w+\d+)_\w+\d+)@(\d+.\d+.\d+.\d+).*$/SIU,\1,\2,\3/gi' > ${wdir}/to_create.txt
            echo "The ${wdir}/to_create.txt file has been created"
            
            #Making delete xml file
            rm -rf ${wdir}/to_delete.xml
            python ${wdir}/eric_to_delete_xml_file.py
            echo "The ${wdir}/eric_to_delete_xml_file.py file has been created"
            
            #Making create xml file
            rm -rf ${wdir}/to_create.xml
            python ${wdir}/eric_to_create_xml_file.py $bsc_name
            echo "The ${wdir}/eric_to_create_xml_file.py file has been created with target BSC ${bsc_name}"
            
            echo "Step 2 is finished. Make you further choice."
            ;;
        "Step 3: Apply SIU/TCU deletion in OSS")
            echo "you have choosen Step 3"
            if ! [ -f ${wdir}/to_delete.xml ]
                then
                    echo "The ${wdir}/to_delete.xml file doesn't exist. Go to the Step 2, generate that files and return here. ".
                    #;; #from the end of cycle
                else
                    echo "The validation of xml file for SIU/TCU deletion is ongoing....."
                    echo "Be sure, that at the end of validation you are able to see: There were 0 errors reported during validation"
                    /opt/ericsson/arne/bin/import.sh -f ${wdir}/to_delete.xml -val:rall
                    echo "Do you wish to run import for start deletion of SIU/TCU, press (y/n)?"
                    #echo -n "Is this a good question (y/n)? "
                    read answer
                    if [ "$answer" != "${answer#[Yy]}" ] ;then
                        echo "I will need to stop two OSS services before importing.."
                        echo "Now, their status before stopping are:"
                        /opt/ericsson/nms_cif_sm/bin/smtool -l | egrep 'MAF|FM_ims'
                        echo "Run stop OSS services command.."
                        /opt/ericsson/nms_cif_sm/bin/smtool offline "MAF" -reason=upgrade -reasontext="Large Node Import"
                        /opt/ericsson/nms_cif_sm/bin/smtool offline "FM_ims" -reason=upgrade -reasontext="MAF offline"
                        echo "Now, their status after stopping are:"
                        /opt/ericsson/nms_cif_sm/bin/smtool -l | egrep 'MAF|FM_ims'
                        echo "I performing importing xml for deletion.."
                        echo "Be sure, that at the end of importing you are able to see:"
                        echo "Import Finished."
                        echo "No Errors Reported."
                        /opt/ericsson/arne/bin/import.sh -import -f to_delete.xml
                        echo "Run start OSS services command.."
                        /opt/ericsson/nms_cif_sm/bin/smtool online "MAF" 
                        /opt/ericsson/nms_cif_sm/bin/smtool online "FM_ims"
                        echo "Now, their status after starting are:"
                        /opt/ericsson/nms_cif_sm/bin/smtool -l | egrep 'MAF|FM_ims'
                    else
                        echo "Your choice is No. Enter up level.."
                        #;; from the end of cycle
                    fi
            fi
            echo "Step 3 is finished. Make you further choice."
            ;;
        "Step 4: Apply SIU/TCU creation in OSS")
            echo "you have choosen Step 4"
            if ! [ -f ${wdir}/to_create.xml ]
                then
                    echo "The ${wdir}/to_create.xml file doesn't exist. Go to the Step 2, generate that files and return here. ".
                    #;; #from the end of cycle
                else
                    echo "The validation of xml file for SIU/TCU creation is ongoing....."
                    echo "Be sure, that at the end of validation you are able to see: There were 0 errors reported during validation"
                    /opt/ericsson/arne/bin/import.sh -f ${wdir}/to_create.xml -val:rall
                    echo "Do you wish to run import for start creation of SIU/TCU, press (y/n)?"
                    #echo -n "Is this a good question (y/n)? "
                    read answer
                    if [ "$answer" != "${answer#[Yy]}" ] ;then
                        echo "I will need to stop two OSS services before importing.."
                        echo "Now, their status before stopping are:"
                        /opt/ericsson/nms_cif_sm/bin/smtool -l | egrep 'MAF|FM_ims'
                        echo "Run stop OSS services command.."
                        /opt/ericsson/nms_cif_sm/bin/smtool offline "MAF" -reason=upgrade -reasontext="Large Node Import"
                        /opt/ericsson/nms_cif_sm/bin/smtool offline "FM_ims" -reason=upgrade -reasontext="MAF offline"
                        echo "Now, their status after stopping are:"
                        /opt/ericsson/nms_cif_sm/bin/smtool -l | egrep 'MAF|FM_ims'
                        echo "I performing importing xml for creation.."
                        echo "Be sure, that at the end of importing you are able to see:"
                        echo "Import Finished."
                        echo "No Errors Reported."
                        /opt/ericsson/arne/bin/import.sh -import -f to_create.xml
                        echo "Run start OSS services command.."
                        /opt/ericsson/nms_cif_sm/bin/smtool online "MAF" 
                        /opt/ericsson/nms_cif_sm/bin/smtool online "FM_ims"
                        echo "Now, their status after starting are:"
                        /opt/ericsson/nms_cif_sm/bin/smtool -l | egrep 'MAF|FM_ims'
                    else
                        echo "Your choice is No. Enter up level.."
                        #;; from the end of cycle
                    fi
            fi
            echo "Step 4 is finished. Make you further choice."
            ;;
        "Perform adjust before quit")
            echo "Starting gsm_synch adust process after Step 3 and Step 4..."
            echo "It takes up to 25 mins..."
            echo "Be sure, that at the end of operation you are able to see:"
            echo "Adjust Completed."
            /opt/ericsson/fwSysConf/bin/startAdjust.sh
            echo "Step 5 is finished. Make you further choice."
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
