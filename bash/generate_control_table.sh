#!/bin/bash

# Function to URL encode a string
urlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
}

# Function to generate MD5 hash
md5_hash() {
  echo -n "$1" | md5sum | awk '{print $1}'
}

# Base URL
base_url="https://api.business.govt.nz/gateway/radio-spectrum-management/v1/licences"

# Default parameters
page=1
sortBy="Licence ID"
sortOrder="desc"
txRx="TRN,RCV"
licenceDateType="LASTUPDATED_LU"
gridRefDefault="LAT_LONG_NZGD2000_D2000"

# Generate date range
fromDate=$(date -u +"%Y-%m-%d")
toDate=$(date -u -d "+1 day" +"%Y-%m-%d")

# Construct URL and generate unique key
construct_url_and_key() {
  local fromDate="$1"
  local toDate="$2"
  local page="$3"
  local sortBy="$4"
  local sortOrder="$5"
  local txRx="$6"
  local licenceDateType="$7"
  local gridRefDefault="$8"

  # Construct URL
  url="${base_url}?page=${page}&sort-by=$(urlencode "${sortBy}")&sort-order=${sortOrder}&txRx=$(urlencode "${txRx}")&LicenceDateType=${licenceDateType}&fromDate=${fromDate}&toDate=${toDate}&gridRefDefault=${gridRefDefault}"

  # Add timestamp to ensure uniqueness
  timestamp=$(date -u +"%Y%m%d%H%M%S")
  uniqueKey=$(md5_hash "${url}-${timestamp}")

  echo "${uniqueKey},${url},${timestamp}"
}

# Generate control table entries
generate_control_table() {
  local fromDate="$1"
  local toDate="$2"

  # Create or append to the control table file
  control_table_file="control_table.csv"

  # Write header if file does not exist
  if [ ! -f "$control_table_file" ]; then
    echo "uniqueKey,path,url,createdAt,page,sortBy,sortOrder,txRx,licenceDateType,fromDate,toDate,gridRefDefault,fromFrequency,toFrequency,licenceStatus,totalPages,totalItems,statusCode" > "$control_table_file"
  fi

  # Generate URL and unique key
  IFS="," read -r uniqueKey url timestamp <<< "$(construct_url_and_key "$fromDate" "$toDate" "$page" "$sortBy" "$sortOrder" "$txRx" "$licenceDateType" "$gridRefDefault")"

  # Define path
  path="data/page/${uniqueKey}.json"

  # Append entry to control table
  echo "${uniqueKey},${path},${url},$(date -u +"%Y-%m-%dT%H:%M:%SZ"),${page},${sortBy},${sortOrder},${txRx},${licenceDateType},${fromDate},${toDate},${gridRefDefault},NA,NA,NA,NA,NA,NA" >> "$control_table_file"
}

# Main function
main() {
  fromDate=$(date -u +"%Y-%m-%d")
  toDate=$(date -u -d "+1 day" +"%Y-%m-%d")

  # Generate control table entry
  generate_control_table "$fromDate" "$toDate"
}

# Run the script
main
