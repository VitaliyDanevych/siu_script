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

show_menu(){
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Step 1: Chose target BSC name for SIU/TCU association ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Step 2: Prepare SIU/TCU files ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Step 3: Apply SIU/TCU deletion in OSS ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Step 4: Apply SIU/TCU creation in OSS ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Step 5: Perform adjust before quit ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 6)${MENU} Step 6: Quit ${NORMAL}"
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${ENTER_LINE}Please enter a menu option or press for exit ${RED_TEXT}Ctl+C ${NORMAL}"
    #read opt
}

#show_menu

PS3='Please enter your choice: '
options=("Step 1: Chose target BSC name for SIU/TCU association" "Step 2: Prepare SIU/TCU files" "Step 3: Apply SIU/TCU deletion in OSS" "Step 4: Apply SIU/TCU creation in OSS" "Step 5: Perform adjust before quit" "Step 6: Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Step 1: Chose target BSC name for SIU/TCU association")
            echo "you have the following list of BSC on OSS-RC1:"
            /opt/ericsson/bin/eac_esi_config -nelist | grep 'APG' | egrep "[B][0-9]" | awk '{print $1}' | perl -pi -e 's/\n/\|/g;' | perl -pi -e 's/\|$/\n/g;'
            echo "Chise one of the mentioned BSC - just type it and press Enter"
            read bsc_name
            echo 'It was choosen: ' $bsc_name 'Ok. Go to the next step!'
            show_menu
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
            my_line=$(cat site_list.txt | sed '/^$/d' | dos2unix | sed 's/^[ \t]*//;s/[ \t]*$//' | perl -pi -e 's/\n/\|/g;' | perl -pi -e 's/\|$/\n/g;')
            echo 'my_line: ' "$my_line"
            result=$(egrep $my_line ${wdir}/ipdatabase.txt)
            #echo "$result"  #show result on display
            rm -rf ${wdir}/ipdatabase_selected.txt
            echo "$result" > ${wdir}/ipdatabase_selected.txt
            echo "It was created the file: " "${wdir}/ipdatabase_selected.txt"
            #echo "The file has " "$(cat ${wdir}/ipdatabase_selected.txt | wc -l)" " lines"
            echo -e "${ENTER_LINE}The file has ${MENU} $(cat ${wdir}/ipdatabase_selected.txt | wc -l) ${ENTER_LINE} lines: SIU/TCU elements ${NORMAL}"
            
            
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
            echo -e "${ENTER_LINE}The ${wdir}/to_delete.xml file has been created"
            
            #Making create xml file
            rm -rf ${wdir}/to_create.xml
            python ${wdir}/eric_to_create_xml_file.py $bsc_name
            echo -e "${ENTER_LINE}The ${wdir}/to_create.xml file has been created with ${MENU}target BSC ${bsc_name}"
            
            echo -e "${ENTER_LINE}Step 2 is finished. Go to the next step!"
            show_menu
            ;;
        "Step 3: Apply SIU/TCU deletion in OSS")
            echo "${MENU}you have choosen Step 3 ${NORMAL}"
            if ! [ -f ${wdir}/to_delete.xml ]
                then
                    echo "The ${wdir}/to_delete.xml file doesn't exist. Go to the Step 2, generate that files and return here. ".
                    #;; #from the end of cycle
                else
                    echo "The validation of xml file for SIU/TCU deletion is ongoing....."
                    echo -e "${ENTER_LINE}Be sure, that at the end of validation you are able to see (Example): ${MENU} There were 0 errors reported during validation ${NORMAL}"
                    /opt/ericsson/arne/bin/import.sh -f ${wdir}/to_delete.xml -val:rall
                    echo "${ENTER_LINE}Do you wish to run import for start deletion of SIU/TCU, ${RED_TEXT} press (y/n)? ${NORMAL}"
                    read answer
                    if [ "$answer" != "${answer#[Yy]}" ] ;then
                        echo "I will need to stop two OSS services before importing.."
                        echo "Now, their status before stopping are:"
                        /opt/ericsson/nms_cif_sm/bin/smtool -l | egrep 'MAF|FM_ims'
                        echo "Run stop OSS services command.."
                        /opt/ericsson/nms_cif_sm/bin/smtool offline "MAF" -reason=upgrade -reasontext="Large Node Import"
                        /opt/ericsson/nms_cif_sm/bin/smtool offline "FM_ims" -reason=upgrade -reasontext="MAF offline"
                        echo "Now, their status after stopping are:"
                        sleep 3s
                        /opt/ericsson/nms_cif_sm/bin/smtool -l | egrep 'MAF|FM_ims'
                        echo "I performing importing xml for deletion.."
                        echo -e "${ENTER_LINE}Be sure, that at the end of importing you are able to see:"
                        echo -e "${MENU}Import Finished."
                        echo -e "${MENU}No Errors Reported."
                        /opt/ericsson/arne/bin/import.sh -import -f to_delete.xml
                        echo "Run start OSS services command.."
                        /opt/ericsson/nms_cif_sm/bin/smtool online "MAF" 
                        /opt/ericsson/nms_cif_sm/bin/smtool online "FM_ims"
                        echo "Now, their status after starting are:"
                        sleep 3s
                        /opt/ericsson/nms_cif_sm/bin/smtool -l | egrep 'MAF|FM_ims'
                    else
                        echo "Your choice is No. Enter up level.."
                        #;; from the end of cycle
                    fi
            fi
            echo -e "${ENTER_LINE}Step 3 is finished. Go to the next step!"
            show_menu
            ;;
        "Step 4: Apply SIU/TCU creation in OSS")
            echo "you have choosen Step 4"
            if ! [ -f ${wdir}/to_create.xml ]
                then
                    echo "The ${wdir}/to_create.xml file doesn't exist. Go to the Step 2, generate that files and return here. ".
                    #;; #from the end of cycle
                else
                    echo "The validation of xml file for SIU/TCU creation is ongoing....."
                    echo -e "${ENTER_LINE}Be sure, that at the end of validation you are able to see (Example): ${MENU} There were 0 errors reported during validation ${NORMAL}"
                    /opt/ericsson/arne/bin/import.sh -f ${wdir}/to_create.xml -val:rall
                    echo "${ENTER_LINE}Do you wish to run import for start creation of SIU/TCU, ${RED_TEXT} press (y/n)? ${NORMAL}"
                    read answer
                    if [ "$answer" != "${answer#[Yy]}" ] ;then
                        echo "I will need to stop two OSS services before importing.."
                        echo "Now, their status before stopping are:"
                        /opt/ericsson/nms_cif_sm/bin/smtool -l | egrep 'MAF|FM_ims'
                        echo "Run stop OSS services command.."
                        /opt/ericsson/nms_cif_sm/bin/smtool offline "MAF" -reason=upgrade -reasontext="Large Node Import"
                        /opt/ericsson/nms_cif_sm/bin/smtool offline "FM_ims" -reason=upgrade -reasontext="MAF offline"
                        echo "Now, their status after stopping are:"
                        sleep 3s
                        /opt/ericsson/nms_cif_sm/bin/smtool -l | egrep 'MAF|FM_ims'
                        echo "I performing importing xml for creation.."
                        echo -e "${ENTER_LINE}Be sure, that at the end of importing you are able to see:"
                        echo -e "${MENU}Import Finished."
                        echo -e "${MENU}No Errors Reported."
                        /opt/ericsson/arne/bin/import.sh -import -f to_create.xml
                        echo "Run start OSS services command.."
                        /opt/ericsson/nms_cif_sm/bin/smtool online "MAF" 
                        /opt/ericsson/nms_cif_sm/bin/smtool online "FM_ims"
                        echo "Now, their status after starting are:"
                        sleep 3s
                        /opt/ericsson/nms_cif_sm/bin/smtool -l | egrep 'MAF|FM_ims'
                    else
                        echo "Your choice is No. Enter up level.."
                        #;; from the end of cycle
                    fi
            fi
            echo -e "${ENTER_LINE} Step 4 is finished. Go to the next step!"
            show_menu
            ;;
        "Step 5: Perform adjust before quit")
            echo "Starting gsm_synch adust process after Step 3 and Step 4..."
            echo "It takes up to 25 mins..."
            echo -e "${ENTER_LINE}Be sure, that at the end of operation you are able to see:"
            echo -e "${ENTER_LINE}Adjust Completed. ${NORMAL}"
            echo "Adjust Completed."
            /opt/ericsson/fwSysConf/bin/startAdjust.sh
            echo -e "${ENTER_LINE}Step 5 is finished. Go to the next step! ${NORMAL}"
            show_menu
            ;;
        "Step 6: Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
