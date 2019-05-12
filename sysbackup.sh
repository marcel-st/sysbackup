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

TIME=$(date +%d-%m-%y_%H%M)
INC=$INCREMENT_DB/$HOSTNAME/sysbackup.inc
ARC=$ARCHIVE_PATH/$HOSTNAME

function showUsage()
{
  echo "usage $0 <command> <date> <string or wildcard>"
  echo
  echo "commands with required parameters" 
  echo "  backup                                - Create a new backup"
  echo "  restore <date> <string or wildcard    - Restore data from backup"
  echo "  find <string or wildcard>             - Search for data in backup"
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
  if [ ! -d "$INCREMENT_DB/$HOSTNAME" ];
  then
    echo -n "The incremental database path does not exist, should i create it? (Y/n) : "
    read -r ANSWER
    if [[ $ANSWER == "Y" || $ANSWER == "y" ]];
    then
      mkdir -p "$INCREMENT_DB/$HOSTNAME"
    else
      echo "Cannot continue..."
      exit 1
    fi
  fi
  tar -czf "$ARC"/sysbackup."$HOSTNAME"."$TIME".tgz --listed-incremental="$INC" "$BACKUP"
  find "$INCREMENT_DB/$HOSTNAME" -mtime +$RETENTION -type f -name "sysbackup.inc" -exec rm {} \;
  SPARE=$((INC+INC))
  find "$ARC" -mtime +$SPARE -type f -name "sysbackup.$HOSTNAME.*.tgz" -exec rm -v {} \;
}

function doRestore()
{
  find "$ARC" -type f -name sysbackup."$HOSTNAME"."$1".tgz -exec tar -zxvf {} "$2" \;
}

function doSearch()
{
  for N in $(ls -l "$ARC" | grep ^- | awk '{print $9}')
  do
    echo "$N"
    tar -ztvf "$N" | grep "$1"
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
    find)
      if [[ -z "$2" && "$3" ]];
      then
        showUsage
      else
        doSearch "$2" "$3"
      fi
    ;;
    list)
      if [ -z "$2" ];
      then
        showUsage
      else
        showList "$2"
      fi
    ;;
    *)
      showUsage
    ;;
  esac
fi
