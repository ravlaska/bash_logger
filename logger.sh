#!/bin/bash

set -uo pipefail;

# <<< VARIABLES TO DEFINE IN MAIN SCRIPT >>>
# ---------------------------------------------------------------------------------------------------------
# LOGGER_FILE=1 [Logging to TXT file ON]                                                                   |
# LOGGER_JSON=1 [Logging to JSON file ON]                                                                  |
#                                                                                                          |
# LOGGER_TSFORMAT="+%Y-%M-%D %H-%m-%s" [Specify wanted timestamp format]                                   |
# LOGGER_TS_UTC=1 [Turn ON TimeStamp in UTC time (default ON)]                                             |
# LOGGER_TS_NAME=1 [Turn ON TimeStamp in log files names (default ON)]                                     |
# LOGGER_TS_FRONT=1 [Turn ON log name: timestamp_name.log (default OFF - name_timestamp.log)]              |
#                                                                                                          |
# LOGGER_FILE_NAME=file.log [Specify name of the txt log file with extension]                              |
# LOGGER_JSON_NAME=file.json [Specify name of the json log file with extension]                            |
#                                                                                                          |
# LOGGER_FILE_PATH="/path/" [Specify file location for TXT file] [Must end with '/']                       |
# LOGGER_JSON_PATH="/path/" [Specify file location for JSON file] [Must end with '/']                      |
#                                                                                                          |
# DEBUG=1 [Turn DEBUG option ON (running only lines with logging option + stop where ERROR level occurs)]  |
#                                                                                                          |
# LOGGER_INP=1 [Turn ON path of script into log (default OFF)]                                             |
#                                                                                                          |
# LOGGER_CLTIME=30 [How long files should be kept (default 30 days)]                                       |
# ---------------------------------------------------------------------------------------------------------

# <<< USAGE >>>
# ---------------------------------------------------------------------------------------------------------
# 1. Paste this logger file into the same folder where the script you want to log is.                      |
# 2. In the script you want to log add lines at the beginning:                                             |
#                                                        SDIR=$(dirname -- "$( readlink -f -- "$0"; )";)   |
#                                                        source $SDIR/logger.sh                            |
# 2. Log command pattern: log log level 'log message'                                                      |
# 3. If you want to use logger cleaner put ' log_cleaner ' at the end of your script.                      |
#                                                                                                          |
# Example: " command && log warning 'Here occurs the warning' "                                            |
# ---------------------------------------------------------------------------------------------------------
# Severity levels [RFC5424]:                                                                               |
#                      <Level>          <Keyword>        <Severity>                                        |
#                          0              EMERG           Emergency                                        |
#                          1              ALERT           Alert                                            |
#                          2              CRIT            Critical                                         |
#                          3              ERR             Error                                            |
#                          4              WARNING         Warning                                          |
#                          5              NOTICE          Notice                                           |
#                          6              INFO            Informational                                    |
#                          7              DEBUG           Debug                                            |
# ---------------------------------------------------------------------------------------------------------

# ===========================
# ===DIR CREATION FUNCTION===
# ===========================
function folder_creator() {
  echo -e "\n==========================================="
  echo "                                           |"
  echo -e "\033[33mDirectory for output logs does not exist.\033[0m  |"
  echo "                                           |"
  echo -e "\033[34mCreating specified directory...\033[0m            |"
  echo "                                           |"
  mkdir "$1" # create folder for logs
  if [ $? -eq 0 ]; then
    echo -e "\033[32mSpecified directory created.\033[0m               |"
    echo "                                           |"
    echo -e "===========================================\n"
  else
    echo -e "\033[31mAn Error occured while creating a\033[0m          |"
    echo -e "\033[31mdirectory for output logs.\033[0m                 |"
    echo "                                           |"
    echo -e "===========================================\n"
    exit
  fi
}

# ======================
# ===CLEANER FUNCTION===
# ======================
function log_cleaner() {
  # txt path
  local file="${LOGGER_FILE:-0}";
  local file_path="${LOGGER_FILE_PATH:-""}";

  # json path
  local json="${LOGGER_JSON:-0}";
  local json_path="${LOGGER_JSON_PATH:-""}";

  # time to preserve
  local cltime="${LOGGER_CLTIME:-30}"

  if [ $file -eq 1 ]; then
    find $file_path -mtime +${cltime} -type f -name '*.log' -delete
  fi
  if [ $json -eq 1 ]; then
    find $json_path -mtime +${cltime} -type f -name '*.json' -delete
  fi
}

# =====================
# ===LOGGER FUNCTION===
# =====================
function log() {
  # timestamps for filenames
  local tsf="${LOGGER_TS_UTC:-1}";
  if [ $tsf -eq 1 ]; then
    local timestamp_file="$(date -u +%Y%m%d)";
  else
    local timestamp_file="$(date +%Y%m%d)";
  fi

  # timestamp in filenames
  local tsn="${LOGGER_TS_NAME:-1}"
  local tslay="${LOGGER_TS_FRONT:-0}";

  # timestamps for output
  local timestamp_format="${LOGGER_TSFORMAT:-+%F %H:%M:%S:%3N}";
  if [ $tsf -eq 1 ]; then
    local timestamp="$(date -u "${timestamp_format}")";
    local timestamp_json="$(date -u "+%Y-%m-%dT%H:%M:%S:%3NZ")";
  else
    local timestamp="$(date "${timestamp_format}")";
    local timestamp_json="$(date "+%Y-%m-%dT%H:%M:%S:%3NZ")";
  fi
  
  # txt path
  local file="${LOGGER_FILE:-0}";

  if [ $file -eq 1 ]; then
    local file_path="${LOGGER_FILE_PATH:-""}";
    if [ -n "$file_path" ]; then # check if directory is specified in configuration
      if [ ! -d "$file_path" ]; then # check if directory for txt logs exists
        folder_creator $file_path
      fi
    fi
    local file_name="${LOGGER_FILE_NAME:-$(basename "${0%.*}")}";
    if [ $tsn -eq 1 ]; then
      if [ $tslay -eq 0 ]; then
        local file_merge="$file_path$file_name"_"$timestamp_file.log";
      else
        local file_merge="$file_path$timestamp_file"_"$file_name.log";
      fi
    else
      local file_merge="$file_path$file_name.log";
    fi
    local file_out="${file_merge:-$timestamp_file.log}";
  fi

  # json path
  local json="${LOGGER_JSON:-0}";

  if [ $json -eq 1 ]; then
    local json_path="${LOGGER_JSON_PATH:-""}";
    if [ -n "$file_path" ]; then # check if directory is specified in configuration
      if [ ! -d "$json_path" ]; then # check if directory for json logs exists
        folder_creator $json_path
      fi
    fi
    local json_name="${LOGGER_JSON_NAME:-$(basename "${0%.*}")}";
    if [ $tsn -eq 1 ]; then
      if [ $tslay -eq 0 ]; then
        local json_merge="$json_path$json_name"_"$timestamp_file.log.json";
      else
        local json_merge="$json_path$timestamp_file"_"$json_name.log.json";
      fi
    else
      local json_merge="$json_path$json_name.log.json";
    fi
    local json_out="${json_merge:-$timestamp_file.log.json}";
  fi

  # log levels
  local json_level="${1}";
  local level="$(echo "${json_level}" | awk '{print toupper($0)}')";
  local debug_level="${DEBUG:-0}";

  # other info
  local user=$(whoami)
  local host=$(hostname)

  # path of script
  local ptsl="${LOGGER_INP:-0}"
  local sloc=$(dirname -- "$( readlink -f -- "$0"; )";)

  shift 1; # shift argument to log message

  local line="${@}"; # get log message

  # define severities array
  local -A severities;
  severities['EMERG']=0;  
  severities['ALERT']=1;  
  severities['CRIT']=2;   
  severities['ERR']=3;
  severities['WARNING']=4;
  severities['NOTICE']=5; 
  severities['INFO']=6;
  severities['DEBUG']=7;

  local severity="${severities[${level}]:-3}" # get severity

  # define severities colors
  local -A colors;
  colors['EMERG']='\033[41m'    # Red Background
  colors['ALERT']='\033[41m'    # Red Background
  colors['CRIT']='\033[41m'     # Red Background
  colors['ERR']='\033[31m'      # Red
  colors['WARNING']='\033[33m'  # Yellow
  colors['NOTICE']='\033[35m'   # Magenta
  colors['INFO']='\033[32m'     # Green
  colors['DEBUG']='\033[34m'    # Blue
  colors['DEFAULT']='\033[0m'   # Default

  local def_color="${colors['DEFAULT']}"; # select default color
  local color="${colors[${level}]:-\033[31m}"; # select proper severity color

  local std_line="${color}${timestamp} [${level}] ${line}${def_color}"; # output terminal line

  # save log to files
  if [ "${debug_level}" -gt 0 ] || [ "${severity}" -lt 7 ]; then
    if [ "${file}" -eq 1 ]; then
      if [ $ptsl -eq 1 ]; then
        local file_line="${timestamp} | <$host@$user> ${sloc} | [${level}] ${line}"; # output TXT line
      else
        local file_line="${timestamp} | <$host@$user> | [${level}] ${line}"; # output TXT line
      fi
      echo -e "${file_line}" >> "${file_out}" # save to file
    fi;
    
    if [ "${json}" -eq 1 ]; then
      if [ $ptsl -eq 1 ]; then
        local json_line="$(printf '{"timestamp":"%s","hostname":"%s","user":"%s","path":"%s","level":"%s","message":"%s"}' "${timestamp_json}" "${host}" "${user}" "${sloc}" "${json_level}" "${line}")"; # output JSON line
      else
        local json_line="$(printf '{"timestamp":"%s","hostname":"%s","user":"%s","level":"%s","message":"%s"}' "${timestamp_json}" "${host}" "${user}" "${json_level}" "${line}")"; # output JSON line
      fi
      echo -e "${json_line}" >> "${json_out}" # save to file
    fi;
  fi;

  # output to terminal
  if [ -z ${severities[${level}]+x} ]; then # check if log level is wrong (unset in array)
    log 'err' "Undefined log level trying to log: ${@}";

  elif [ ${severities[${level}]} -lt 7 ] && [ ${severities[${level}]} -ne 3 ]; then # check if log level is anything except debug and err
    echo -e "${std_line}";

  elif [ ${severities[${level}]} -eq 7 ]; then # check if log level is debug
    if [ "${debug_level}" -gt 0 ]; then
        echo -e "${std_line}";
    fi;

  elif [ ${severities[${level}]} -eq 3 ]; then # check if log level is err
    echo -e "${std_line}" >&2;
    if [ "${debug_level}" -gt 0 ]; then
      echo -e "Here an ERROR occurs.";
      exit "${?}";
    fi
  fi
}
