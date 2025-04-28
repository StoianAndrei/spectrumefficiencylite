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

# Base URL
base_url="https://api.business.govt.nz/sandbox/radio-spectrum-management/v1/licences"

# Set required parameters with defaults
page="${page:-1}"
sortBy="${sortBy:-Licence ID}"
sortOrder="${sortOrder:-desc}"
txRx="${txRx:-TRN}"
LicenceDateType="${LicenceDateType:-LASTUPDATED_LU}"
gridRefDefault="${gridRefDefault:-LAT_LONG_NZGD2000_D2000}"

# Array to hold query parameters (maintain order explicitly)
declare -a params=(
  "page=${page}"
  "sort-by=${sortBy}"  # Do not encode sortBy if it's already URL-encoded
  "sort-order=${sortOrder}"
  "txRx=${txRx}"
  "LicenceDateType=${LicenceDateType}"
  "gridRefDefault=${gridRefDefault}"
)

# Add optional parameters if they are set
add_param_if_set() {
  local key="$1"
  local value="$2"
  if [ -n "$value" ]; then
    params+=("${key}=$(urlencode "${value}")")
  fi
}

add_param_if_set "page-size" "$pageSize"
add_param_if_set "search" "$search"
add_param_if_set "transmitlocation" "$transmitlocation"
add_param_if_set "receivelocation" "$receivelocation"
add_param_if_set "location" "$location"
add_param_if_set "district" "$district"
add_param_if_set "callSign" "$callSign"
add_param_if_set "channel" "$channel"
add_param_if_set "fromDate" "$fromDate"
add_param_if_set "toDate" "$toDate"
add_param_if_set "exactMatchFreq" "$exactMatchFreq"
add_param_if_set "fromFrequency" "$fromFrequency"
add_param_if_set "toFrequency" "$toFrequency"
add_param_if_set "eirp" "$eirp"
add_param_if_set "licenceStatus" "$licenceStatus"
add_param_if_set "licenceTypeCode" "$licenceTypeCode"
add_param_if_set "managementRightId" "$managementRightId"
add_param_if_set "systemIdentifier" "$systemIdentifier"
add_param_if_set "certifiedBy" "$certifiedBy"
add_param_if_set "radius" "$radius"
add_param_if_set "includeAssociatedLicences" "$includeAssociatedLicences"
add_param_if_set "engineerDecisionIAgree" "$engineerDecisionIAgree"

# Handle GridRef as JSON
if [ -n "$GridRef" ]; then
  encoded_grid_ref=$(urlencode "$GridRef")
  params+=("GridRef=${encoded_grid_ref}")
fi

# Build the full URL
query_string=$(IFS='&'; echo "${params[*]}")
url="${base_url}?${query_string}"

# Output the URL
echo "$url"
