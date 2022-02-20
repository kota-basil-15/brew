#!/bin/zsh
##################################################
# System name  : Macbook Air(M1,2020)
# Process name : 
# Shell name   : upgradeApp.sh
# Create date  : 2021.02.23
# Abstract     : check upgrade status & auto upgrade for brew Applications
# when         : immediately
# exec format  : zsh /Users/`id -un`/bin/brew/upgradeApp/upgradeApp.sh
# Argument     : null
# return code  : "0" Successful Termination
#              : "1" Abnormal Termination
##################################################

#-----------------------
# define variables
#-----------------------
# working directory
WORK_DIR="/Users/"`id -un`"/bin/brew/upgradeApp/"

# output log dir
LOG_DIR=$WORK_DIR"log/"
mkdir -p $LOG_DIR

# log date
LOG_DATE=`date +"%Y%m%d%H%M%S"`

# output log file
OUT_LOG=$LOG_DIR"upgradeApp_"$LOG_DATE".log"

#-----------------------
# import target applist
#-----------------------
# caution:Array number on zsh starts from 1 not 0.
TGT_LIST[1]=${WORK_DIR}appfiles/app.list
TGT_LIST[2]=${WORK_DIR}appfiles/app-gui.list
TGT_CASK_LIST=${WORK_DIR}appfiles/app-cask.list
TGT_MAS_LIST=${WORK_DIR}appfiles/app-mas.list

#-----------------------
# import functions
#-----------------------
# function fileCheck
# call format "checkFile $1"
. "/Users/"`id -un`"/bin/checkFileExist.sh"
. $WORK_DIR"functions/deleteCache.func"
. $WORK_DIR"functions/tapCheck.func"
. $WORK_DIR"functions/upgrade.func"
. $WORK_DIR"functions/upgradeCask.func"
. $WORK_DIR"functions/upgradeMas.func"
. $WORK_DIR"functions/execUpgrade.func"
. $WORK_DIR"functions/bundleDump.func"

#-----------------------
# function: main
#-----------------------
function main(){
echo "■■■■ upgradeApp.sh start ■■■■"

# exec date
date +"%Y/%m/%d,%H:%M:%S"

# delete brew cache files
deleteCache

# tap check
tapCheck

# brew upgrade(app.list)
execUpgrade ${TGT_LIST[1]}

# brew upgrade(app-gui.list)
execUpgrade ${TGT_LIST[2]}

# brew upgrade --cask
execUpgrade ${TGT_CASK_LIST}

# mas upgrade
execUpgrade ${TGT_MAS_LIST}

# brew bundle dump
bundleDump $LOG_DIR $LOG_DATE

# exec date
date +"%Y/%m/%d,%H:%M:%S"

echo "■■■■ upgradeApp.sh finish ■■■■"
}

#-----------------------
# main process execution
#-----------------------
# main process
main $@
