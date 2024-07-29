# bash_logger
Simple, but powerful bash logger

## USAGE
1. Paste this logger file into the same folder where the script you want to log is.
2. In the script you want to log add lines at the beginning:
<br>```SDIR=$(dirname -- "$( readlink -f -- "$0"; )";)```
<br>```source $SDIR/logger.sh```
2. Log command pattern: log log level 'log message'.
3. If you want to use logger cleaner put ' log_cleaner ' at the end of your script.
4. If you want to change some options - look at 'Variables' section below <br>(add variables into the script you want to log at the beginning like: ```LOGGER_FILE=1```).
                                                                                                         
Example: " command && log warning 'Here occurs the warning' "

## Severity levels [RFC5424]:
|<b>Level|<b>Keyword|<b>Severity|
|--|--|--|
|0|EMERG|Emergency|
|1|ALERT|Alert|
|2|CRIT|Critical|
|3|ERR|Error|
|4|WARNING|Warning|
|5|NOTICE|Notice|
|6|INFO|Informational|
|7|DEBUG|Debug|

## Variables
|<b>Variable|<b>Options|<b>Default value|<b>Explanation|
|--|--|--|--|
|LOGGER_FILE|1/0|0|Logging to TXT file ON/OFF|
|LOGGER_JSON|1/0|0|Logging to JSON file ON/OFF|
|||||
|LOGGER_TSFORMAT|{timestamp format}|"+%Y-%M-%D %H-%m-%s"|Timestamp format|
|LOGGER_TS_UTC|1/0|1|TimeStamp in UTC time|
|LOGGER_TS_NAME|1/0|1|TimeStamp in log files names|
|LOGGER_TS_FRONT|1/0|0|Log name order: 1 = timestamp_name.log 0 = name_timestamp.log|
|||||
|LOGGER_FILE_NAME||'name_of_running_script.log'|Name of the txt log file with extension|
|LOGGER_JSON_NAME||'name_of_running_script.log.json'|Name of the json log file with extension|
|||||
|LOGGER_FILE_PATH|"/path/"|location_of_running_script|Output location for TXT file [Must end with '/']|
|LOGGER_JSON_PATH|"/path/"|location_of_running_script|Output location for JSON file [Must end with '/']|
|||||
|DEBUG|1/0|0|DEBUG option (running only lines with logging option + stop where ERROR level occurs)|
|||||
|LOGGER_INP|1/0|0|Put path of the script into logs|
|||||
|LOGGER_CLTIME|number of days|30 days|How long log files should be kept (automatic delete)|
