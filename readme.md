# System backup script

This is a system backup solution for CentOS/RHEL.
Based on tar and a mounted filesystem (network or local disk)

## Installation

* Download sysbackup and sysbackup.conf too any location you like (just keep the files together!)
* mount the filesystem where you want to put the backups
* edit sysbackup.config to your liking
* run "sysbackup prep" to setup the required folders
* schedule sysbackup to run every 24 hours

## Usage

usage ./sysbackup [command] [date] [string or wildcard]

commands with required parameters
* prep                                  - Create the required folder structure for your system
* backup                                - Create a new backup
* restore [date] [string or wildcard]   - Restore data from backup
* search [string or wildcard]          - Search for data in backup
* list                                  - List available safesets

options
* [date] in format <day-month-year_hour+minutes> : example 31-12-19_2355
* [string or wildcard] example : home/kenneth/.ssh/id_rsa.pub
