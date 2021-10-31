#!/bin/zsh
##################################################
# System name  : Macbook Air(M1,2020)
# Process name : 
# Shell name   : upgradeApp.sh
# Create date  : 2021.02.23
# Abstract     : check upgrade status & auto upgrade for brew Applications
# when         : immediately
# exec format  : zsh /Users/`id -un`/bin/brew/upgradeApp.sh
# Argument     : null
# return code  : "0" Successful Termination
#              : "1" Abnormal Termination
##################################################

#-----------------------
# define variables
#-----------------------
# working directory
WORK_DIR="/Users/"`id -un`"/bin/brew/"

# target config
# caution:Array number on zsh starts from 1 not 0.
TGT_LIST[1]=${WORK_DIR}app.list
TGT_LIST[2]=${WORK_DIR}app-gui.list
TGT_CASK_LIST=${WORK_DIR}app-cask.list
TGT_MAS_LIST=${WORK_DIR}app-mas.list

# check command "brew"
BREW=`which brew`

# output log dir
LOG_DIR=$WORK_DIR"log/"
mkdir -p $LOG_DIR

# log date
LOG_DATE=`date +"%Y%m%d%H%M%S"`

# output log file
OUT_LOG=$LOG_DIR"upgradeApp_"$LOG_DATE".log"

#-----------------------
# define functions
#-----------------------
#declare -f fileCheck
declare -f deleteCache
declare -f tapCheck
declare -f upgrade
declare -f upgradeCask
declare -f upgradeMas
declare -f execUpgrade
declare -f main

#-----------------------
# import functions
#-----------------------
# function fileCheck
# call format "checkFile $1"
. "/Users/"`id -un`"/bin/checkFileExist.sh"

#-----------------------
# function: deleteCache
#-----------------------
function deleteCache(){
echo "---------------"
echo "brew cleanup"
echo "---------------"
# delete brew cache
BREW cleanup --prune 20

if [[ 0 -eq $? ]]
then
    # 
    echo "deleted brew cache files updated before 20 days"
    for (( i = 0; i < 2; i++ ))
    do
        echo ""
    done
    
    return 0
else
    #
    echo "could not delete brew cache files"
    return 1
fi
}

#-----------------------
# function: tapCheck
#-----------------------
function tapCheck(){
echo "---------------"
echo "brew tap"
echo "---------------"
# brew tap
BREW tap homebrew/cask-drivers
for (( i = 0; i < 2; i++ ))
do
    echo ""
done
}

#-----------------------
# function: brew bundle dump
#-----------------------
function bundleDump(){
echo "---------------"
echo "brew bundle dump"
echo "---------------"
cd /Users/`id -un`/bin/brew/log/

# brew bundle dump
BREW bundle dump

# rename
mv Brewfile Brewfile_$LOG_DATE

cd
for (( i = 0; i < 2; i++ ))
do
    echo ""
done
}

#-----------------------
# function: upgrade
#-----------------------
function upgrade(){
echo "---------------"
echo "brew upgrade "$1
echo "---------------"
#BREW upgrade $1
BREW upgrade $1 | tee -a $OUT_LOG | tail -f
for (( i = 0; i < 2; i++ ))
do
    echo ""
done
}

#-----------------------
# function: upgradeCask
#-----------------------
function upgradeCask(){
echo "---------------"
echo "brew upgrade --cask "$1
echo "---------------"
#BREW upgrade --cask $1
BREW upgrade --cask $1 | tee -a $OUT_LOG | tail -f
for (( i = 0; i < 2; i++ ))
do
    echo ""
done
}
#-----------------------
# function: upgradeMas
#-----------------------
function upgradeMas(){
AppName=0
case "$1" in
    "408981424"  ) AppName="iMovie";;
    "409183694"  ) AppName="Keynote";;
    "539883307"  ) AppName="LINE";;
    "1274495053" ) AppName="Microsoft To-Do";;
    "409203825"  ) AppName="Numbers";;
    "409201541"  ) AppName="Pages";;
esac
echo "---------------"
echo "mas upgrade "$AppName
echo "---------------"
#mas upgrade $1
mas upgrade $1 | tee -a $OUT_LOG | tail -f
for (( i = 0; i < 2; i++ ))
do
    echo ""
done
}


#-----------------------
# function: execUpgrade
#-----------------------
function execUpgrade(){

# file check
fileCheck $1

# (upgrade Apps only when the configuration file exists)
if [[ 0 -eq $? ]]
then
    cat $1 | while read line
    do
        # detect comment line
        echo $line | grep -v '^#.*' > /dev/null

        # execute upgrade if not comment line
        if [ $? -eq 0 ];
        then
            # check a kind of upgrade
            if [[ $1 = ${TGT_CASK_LIST} ]]
            then
                # brew upgrade --cask
                upgradeCask $line

            elif [[ $1 = ${TGT_MAS_LIST} ]]
            then
                # mas upgrade
                upgradeMas $line

            else
                # brew upgrade
                upgrade $line
            fi
        fi
    done
fi
}

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
bundleDump

# exec date
date +"%Y/%m/%d,%H:%M:%S"

echo "■■■■ upgradeApp.sh finish ■■■■"
}

#-----------------------
# main process execution
#-----------------------
# main process
main $@
