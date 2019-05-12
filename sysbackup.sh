#!/bin/bash

# Change underneath to match your requirements
#

BACKUP="/home /root /container"
RETENTION=7
ARCHIVE_PATH=/mnt
INCREMENT_DB=/mnt/database

# Runcode, don't change anything underneath
# unless if you know what you are doing
#

NAME=$(hostname -s)
TIME=$(date +%d-%m-%y_%H%M)
INC=$INCREMENT_DB/$NAME.db
ARC=$ARCHIVE_PATH/$NAME

function showUsage()
{
  echo "usage $0 <command> <date> <string or wildcard>"
  echo
  echo "commands with required parameters" 
  echo "  backup                                - Create a new backup"
  echo "  restore <date> <string or wildcard    - Restore data from backup"
  echo "  search <string or wildcard>             - Search for data in backup"
  echo "  list                                  - List available safesets"
  echo
  echo "options"
  echo "  <date> in format <day-month-year_hour+minutes> : example 31-12-19_2355"
  echo "  <string or wildcard> example : home/kenneth/.ssh/id_rsa.pub"
  echo
  exit 0
}

function doBackup()
{
  if [ ! -d "$ARC" ];
  then
    echo -n "The archive path does not exist, should i create it? (Y/n) : "
    read -r ANSWER
    if [[ $ANSWER == "Y" || $ANSWER == "y" ]];
    then
      mkdir -p "$ARC"
    else
      echo "Cannot continue..."
      exit 1
    fi
  fi
  if [ ! -d "$INCREMENT_DB/$NAME" ];
  then
    echo -n "The incremental database path does not exist, should i create it? (Y/n) : "
    read -r ANSWER
    if [[ $ANSWER == "Y" || $ANSWER == "y" ]];
    then
      mkdir -p "$INCREMENT_DB/$NAME"
    else
      echo "Cannot continue..."
      exit 1
    fi
  fi
  tar -czf $ARC/sysbackup.$NAME.$TIME.tgz --listed-incremental=$INC $BACKUP
  find "$INCREMENT_DB" -mtime +$RETENTION -type f -name "$NAME.db" -exec rm {} \;
  SPARE=$((RETENTION+RETENTION))
  find "$ARC" -mtime +$SPARE -type f -name "sysbackup.$NAME.*.tgz" -exec rm -v {} \;
}

function doRestore()
{
  find "$ARC" -type f -name sysbackup."$NAME"."$1".tgz -exec tar -zxvf {} "$2" \;
}

function doSearch()
{
  for N in $(ls -l "$ARC" | grep ^- | awk '{print $9}')
  do
    echo "$N"
    tar -ztvf "$ARC/$N" | grep "$1"
    read -n 1 -r -s -p "Press any key to continue..."
  done
}

function showList()
{
  ls -l $ARC | grep ^- | awk '{print $9}'
}

if [ -z "$1" ];
then
  showUsage
else
  case "$1" in
    backup)
      doBackup
    ;;
    restore)
      if [[ -z "$2" && "$3" ]];
      then
        showUsage
      else
        doRestore "$2" "$3"
      fi
    ;;
    search)
      if [ -z "$2" ];
      then
        showUsage
      else
        doSearch "$2"
      fi
    ;;
    list)
      showList "$2"
    ;;
    *)
      showUsage
    ;;
  esac
fi
