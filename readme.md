# System backup script

This is a system backup solution for CentOS/RHEL.
Based on tar and a mounted filesystem (network or local disk)

It's probably not the most elegant method, but it works quite good

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

parameters
* [date] in format <day-month-year_hour+minutes> : example 31-12-19_2355
* [string or wildcard] example : home/kenneth/.ssh/id_rsa.pub

## Notes

* for e-mail notifications, set the MAILTO= parameter in cron to your mailadres and configure postfix to allow sending mail from localhost.
* I've designed the script to allow multiple hosts using the same storage location. Just mount it on the server and prep. The hostname of your system must be unique, else it will screw things up.
* The backup data itself will remain in the storage location twice as long as the value set in RETENTION=. Reason for this is to ensure that there is always a full backup with chainset of incrementals.


Feel free to optimize the code, add new functionality and improve it.
I'dd appreciate seeing how you made it better.

Marcel
