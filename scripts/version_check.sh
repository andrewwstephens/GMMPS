#!/bin/bash

# This script runs a version check, retrieving the version string from a text file on one of our servers

# $1: GMMPS root directory

# The URL with the GMMPS release packages
URL_GMMPS="http://software.gemini.edu/gmmps/"

# The URL with the text file containing the version string
URL_VERSION="http://software.gemini.edu/gmmps/VERSION"

# Version check (only if 'wget' is installed):
mkdir -p ${HOME}/.gmmps
current_userversion_orig=`cat ${GMMPS}/VERSION`
current_userversion=`echo ${current_userversion_orig} | sed 's/\.//g' | awk '{print $1*1}'`

# check if 'wget' is available
check_wget=`which wget`

if [ "${check_wget}_A" != "_A" ]; then
    rm -f ${HOME}/.gmmps/VERSION
    echo "Checking for updates ... " 
    # Download the version text file; timeout after 5 seconds
    wget -T 5 -t 1 -O ${HOME}/.gmmps/VERSION ${URL_VERSION} -o ${HOME}/.gmmps/wget.log
    connection_test=`grep "Connection timed out" ${HOME}/.gmmps/wget.log`

    # if no connection could be established
    if [ "${connection_test}_A" != "_A" ]; then
        echo "No response from server."
        echo "Check ${URL_GMMPS} for newer versions of GMMPS."
        echo "You are currently running version ${current_userversion_orig}"
        echo ">"
        sleep 2
    # if a connection was established
    else
        current_serverversion_orig=`cat ${HOME}/.gmmps/VERSION`
        current_serverversion=`echo ${current_serverversion_orig} | sed 's/\.//g' | awk '{print $1*1}'`
	# EXIT if the server version is newer than the user version
        if [ ${current_serverversion} -gt ${current_userversion} ]; then
            echo "A newer version (${current_serverversion_orig}) of GMMPS is available at"
            echo "${URL_GMMPS}"
            echo ""
            echo "Please update to this latest version to ensure"
            echo "that your mask designs are fully compatible."
            echo ""
            echo "You are currently running version ${current_userversion_orig}"
            echo ""
	    echo "Hit any key to acknowledge :"
	    read user_ack
            exit
	# Do nothing if we are up to date
        else
            echo "GMMPS (v${current_userversion_orig}) skycat plugin is up to date"
            echo ""
            sleep 1
        fi
    fi

# If 'wget' is not installed on the user's system
else
    echo ">>   "
    echo ">>   You are currently running GMMPS version ${current_userversion_orig}"
    echo ">>   Please check this URL for the latest version to"
    echo ">>   ensure that your mask designs are fully compatible:"
    echo ">>   "
    echo ">>   ${URL_GMMPS}"
    echo ">>   "
    echo ">>   If you install \'wget\', GMMPS will perform a version check automatically"
    echo ">>   during startup and notify you if a more recent version has been released."
    echo ">>   "
    sleep 2
fi
