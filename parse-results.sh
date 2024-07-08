#!/bin/bash

process_results () {
    # REMOVE UNNECESARY INFORMATION
    sed -i "/^Rule File Title/s/This program.*$/ /" $1
    sed -i "/^Rule File Pathname/s/\/.*$/ /" $1

    return 
    # - 0 0 41 May  6 10:45:05 2024
    sed -i "/^Rule File Pathname/d" $1
    sed -i "/^[[:digit:]]* [[:digit:]]* [[:digit:]]* [a-zA-Z]* [[:digit:]]*/d" $1

    return

    # REMOVE COORDINATES
    # 103245 32700
    # -10545 53050
    # -10545 -53050
    sed -i "/^[-[:digit:]]* [-[:digit:]]*$/d" $1
    sed -i "/^[-[:digit:]]* [-[:digit:]]* [-[:digit:]]* [-[:digit:]]*$/d" $1


    # REMOVE THIS
    # p 533 4
    sed -i "/^[pe] [[:digit:]]* [[:digit:]]*/d" $1

    # REMOVE THIS OTHER THING
    sed -i "/^CN /d" $1

    # Remove txt file names
    # ex: p2_den.txt
    sed -i "/^[a-zA-Z0-9_.]*[.]txt$/d" $1

}

process_summary () {
    # REMOVE SENSIBLE INFORMATION
    sed -i "/Rule File Pathname:/d" $1
    sed -i "/Rule File Title:/d" $1
    sed -i "/Calibre Version:/d" $1
    sed -i "/User Name:/d" $1
    sed -i "/Current Directory:/d" $1


    # REMOVE Acute angle INFOMRATION
    sed -i "/ACUTE angle on layer my_Metal4/d" $1
    sed -i "/ACUTE angle on layer my_Metal5/d" $1

    # REMOVE Geometry count = 0 INFORMATION
    sed -i "/TOTAL Original Geometry Count = 0      (0)/d" $1
    
    # REMOVE DRC rules that doesn't have problems
    sed -i "/TOTAL Result Count = 0    (0)$/d" $1
    sed -i "/[.]* NOT EXECUTED$/d" $1

    # SOME FORMATTING
    sed -i "s/    RULECHECK /    /" $1
    
    # REMOVING PADRING ERRORS
    sed -i "/ DCF.1a /d" $1 # For instance, padring has a lot of drc errors.
    
}

main_results () {
    DRC_RESULTS=$1
    DRC_RESULTS_EDITED=${DRC_RESULTS}.edited

    cp $DRC_RESULTS $DRC_RESULTS_EDITED

    process_results $DRC_RESULTS_EDITED


    echo "Result file processed, showing first 15 lines:"
    echo "................."
    head $DRC_RESULTS_EDITED -n 15
    echo "................."
    readlink -f $DRC_RESULTS_EDITED
}

main_summary () {
    DRC_SUMMARY=$1
    DRC_SUMMARY_EDITED=${DRC_SUMMARY}.edited

    cp $DRC_SUMMARY $DRC_SUMMARY_EDITED

    process_summary $DRC_SUMMARY_EDITED

    echo "Summary processed, showing first 15 lines:"
    echo "................."
    head $DRC_SUMMARY_EDITED -n 15
    echo "................."
    readlink -f $DRC_SUMMARY_EDITED

}

# main_results LTC2_IO3a2.drc.results
# main_summary LTC2_IO3a2.drc.summary