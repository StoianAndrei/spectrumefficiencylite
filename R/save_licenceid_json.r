library(httr2)
library(jsonlite)
library(logger)
library(glue)

get_rsm_licence_data <- function(licenceid = 468) {
  # Build the API URL
  url <- glue("https://api.business.govt.nz/gateway/radio-spectrum-management/v1/licences/{licenceid}?gridRefDefault=LAT_LONG_NZGD2000_D2000")

  # Make the API request
  response <- request(url) |>
    req_headers(
      'Cache-Control' = 'no-cache',
      'Ocp-Apim-Subscription-Key' = Sys.getenv("RSM_API_KEY")  # Replace with your actual key
    ) |>
    req_method("GET") |>
    req_perform()

  # Log the status code of the request
  status_code <- resp_status(response)
  log_info(glue("API request status code: {status_code}"))

  # Check if the request was successful
  if (status_code == 200) {
    # Parse the JSON response
    content <- resp_body_json(response)

    # Save the JSON to a file
    json_filename <- glue("data/licences/licence_{licenceid}.json")
    write_json(content, path = json_filename, pretty = TRUE)

    log_info(glue("Data for licence {licenceid} saved to {json_filename}"))

    return(content)
  } else {
    # Log the error and return NULL if the request failed
    log_error(glue("API request failed with status code: {status_code} for licence {licenceid}"))
    return(NULL)
  }
}

save_multiple_licence_data <- function(licence_ids) {
  for (licenceid in licence_ids) {
    get_rsm_licence_data(licenceid)
    Sys.sleep(0.3)
    print(licenceid)
  }
}


existing_licid   <- list.files(path = "data/licences/") |>
  as_tibble() |>
  mutate(licenceID = str_extract(value, "\\d+")) |>
  select(licenceID) |>
  unique() |>
  pull(licenceID)

# Example usage: Save data for licences 468, 469, and 470
licence_ids <-
  read_csv("combined_licence_data.csv") |>
  unique() |>
  count(licenceID) |>
  pull(licenceID)

licence_ids1 <- licence_ids[!licence_ids %in%existing_licid]

save_multiple_licence_data(licence_ids1[12:460])


process_json_file <- function(json_file) {
  # Read the JSON file
  content <- fromJSON(json_file, flatten = TRUE)

  # Process the content to extract the required fields
  # Example for extracting licence information:
  licence_info <- dplyr::tibble(
    licenceid =   purrr::pluck(content,"licenceID"),
    clientid =   purrr::pluck(content$clientDetails,"clientNumber"),
    licence_number = purrr::pluck(content,"licenceNumber"),
    status = purrr::pluck(content,"licenceStatus"),
    expiry_date = unlist(purrr::pluck(content,"expiryDate"))
  )

  return(licence_info)
}

# Process all saved JSON files
process_all_licences <- function(json_files_path = "raw-data/") {
  # List all JSON files in the directory
  json_files <- list.files(path = json_files_path, pattern = "*.json", full.names = TRUE)

  # Apply processing to each JSON file
  all_licence_data <- purrr::map(.x = json_files, ~process_json_file(json_file = .x))

  # Combine the results into a single data frame
  combined_data <- do.call(rbind, all_licence_data)

  return(combined_data)
}

# Example usage: Process all JSON files and combine the data
combined_licence_data <- process_all_licences(json_files_path = "raw-data/")
write.csv(combined_licence_data, "processed_licence_data.csv")

library(jsonlite)
library(glue)

# Helper function to read and flatten a JSON file
read_json_file <- function(json_file) {
  fromJSON(json_file, flatten = TRUE)
}

# 1. Extract associated licences
extract_associated_licences <- function(content) {
  if (!is.null(content$associatedLicenceOrRecord)) {
    data.frame(
      primarylicence = content$licenceID,
      associatedlicence = unlist(content$associatedLicenceOrRecord$licenceId)
    )
  } else {
    data.frame(primarylicence = content$licenceID, associatedlicence = NA)
  }
}

# 2. Extract client details
extract_client_details <- function(content) {
  client_details <- content$clientDetails
  data.frame(
    clientid = client_details$clientNumber,
    name = client_details$clientName,
    legal_order = NA,  # Not available in the response
    address1 = client_details$physicalAddress,
    address2 = NA,  # Additional address fields can be parsed if present
    address3 = NA
  )
}

# 3. Extract emission data
extract_emission <- function(content) {
  if (!is.null(content$spectrumRecords)) {
    data.frame(
      emissionid = unlist(lapply(content$spectrumRecords, function(x) x$spectrumId)),
      emission = unlist(lapply(content$spectrumRecords, function(x) ifelse(is.null(x$referenceFrequencies$emissions), NA, x$referenceFrequencies$emissions[1])))
    )
  } else {
    data.frame(emissionid = NA, emission = NA)
  }
}

# 4. Extract emission limit data
extract_emission_limit <- function(content) {
  if (!is.null(content$spectrumRecords)) {
    limits <- lapply(content$spectrumRecords, function(record) {
      if (!is.null(record$referenceFrequencies)) {
        data.frame(
          emissionlimitid = record$spectrumId,
          spectrumid = record$spectrumId,
          emissionlimittypeid = NA,  # Not available in the response
          limitfrequency = record$referenceFrequencies$frequency[1],
          limitvalue = record$referenceFrequencies$power[1],
          limitgraphpoint = NA  # Not available in the response
        )
      }
    })
    do.call(rbind, limits)
  } else {
    data.frame(emissionlimitid = NA, spectrumid = NA, emissionlimittypeid = NA, limitfrequency = NA, limitvalue = NA, limitgraphpoint = NA)
  }
}

# 5. Extract geographic reference
extract_geographic_reference <- function(content) {
  geo_reference <- lapply(content$transmitLocations, function(location) {
    data.frame(
      locationid = location$locationId,
      georeferencetypeid = NA,  # Not available in the response
      georeferencetype = location$gridReference[[1]]$GeoRefType,
      easting = location$gridReference[[1]]$Easting,
      northing = location$gridReference[[1]]$Northing,
      mapnumber = location$gridReference[[1]]$Map,
      original = NA,
      referenceorder = NA
    )
  })
  do.call(rbind, geo_reference)
}

# 6. Extract issuing office
extract_issuing_office <- function(content) {
  data.frame(
    officeid = content$officeId,
    officecode = NA,  # Not available in the response
    officename = NA   # Not available in the response
  )
}

# 7. Extract licence data
extract_licence <- function(content) {
  data.frame(
    licenceid = content$licenceID,
    managementrightid = content$managementRightId,
    clientid = content$clientDetails$clientNumber,
    licencetypeid = NA,  # Not available in the response
    licencetype = content$licenceType,
    licencecode = content$systemId,
    licencecategory = content$licenceClassification,
    licencestatusid = content$licenceStatus,
    officeid = content$officeId,
    licencenumber = content$licenceNumber,
    commencementdate = content$commencementDate,
    registrationdate = content$grantedDate,
    expiry_date = content$expiryDate,
    sets = content$numberOfSets,
    callsign = content$baseCallsign,
    renewalfee = NA,  # Not available in the response
    shipname = content$shipname
  )
}

# 8. Extract licence conditions
extract_licence_conditions <- function(content) {
  data.frame(
    licenceid = content$licenceID,
    licenceconditions = content$specificConditions
  )
}

# 9. Extract licence type
extract_licence_type <- function(content) {
  data.frame(
    licencetypeid = NA,  # Not available in the response
    licencetypeidentifier = NA,  # Not available in the response
    workingdescription = content$licenceType
  )
}

# 10. Extract location data
extract_location <- function(content) {
  location_data <- lapply(content$transmitLocations, function(location) {
    data.frame(
      locationid = location$locationId,
      locationtypeid = NA,  # Not available in the response
      locationname = location$locationName,
      locationheight = location$locationAltitude,
      nominalmap = location$gridReference[[1]]$Map,
      nominalref = location$gridReference[[1]]$GeoRefType,
      longeast = location$gridReference[[1]]$Longitude,
      longnorth = location$gridReference[[1]]$Latitude,
      districtid = NA  # Not available in the response
    )
  })
  do.call(rbind, location_data)
}

# 11. Extract management right
extract_management_right <- function(content) {
  data.frame(
    managementrightid = content$managementRightId,
    clientid = content$clientDetails$clientNumber,
    mrcommencementdate = content$commencementDate,
    mrregistrationdate = content$grantedDate,
    mrexpirydate = content$expiryDate,
    mrconditions = content$specificConditions
  )
}

# 12. Extract map district
extract_map_district <- function(content) {
  data.frame(
    mapdistrictid = NA,  # Not available in the response
    map = content$transmitLocations$gridReference[[1]]$Map,
    district = NA  # Not available in the response
  )
}

# 13. Extract radiation pattern
extract_radiation_pattern <- function(content) {
  if (!is.null(content$horizontalRadiationPatterns)) {
    data.frame(
      licenceid = content$licenceID,
      patterntypeid = NA,  # Not available in the response
      bearingfrom = content$horizontalRadiationPatterns$bearingFrom,
      bearingto = content$horizontalRadiationPatterns$bearingTo,
      bearingvalue = content$horizontalRadiationPatterns$bearingValue
    )
  } else {
    data.frame(licenceid = content$licenceID, patterntypeid = NA, bearingfrom = NA, bearingto = NA, bearingvalue = NA)
  }
}

# 14. Extract receive configuration
extract_receive_configuration <- function(content) {
  receive_config <- lapply(content$receiveLocations, function(location) {
    data.frame(
      receiveconfigurationid = location$locationId,
      licenceid = content$licenceID,
      locationid = location$locationId,
      rxantennamake = location$antenna$make,
      rxantennatype = location$antenna$type,
      rxantennaheight = location$locationAltitude,
      rxazimuth = location$azimuth,
      rxequipment = location$equipment$equipmentModel,
      mpis = NA,  # Not available in the response
      mpisunit = NA,  # Not available in the response
      wantedsignal = NA,  # Not available in the response
      wantedunit = NA  # Not available in the response
    )
  })
  do.call(rbind, receive_config)
}

# 15. Extract spectrum data
extract_spectrum <- function(content) {
  spectrum_data <- lapply(content$spectrumRecords, function(record) {
    data.frame(
      spectrumid = record$spectrumId,
      spectrumstatusid = NA,  # Not available in the response
      spectrumstatus = record$spectrumStatus,
      spectrumlabel = record$spectrumLabel,
      spectrumlow = record$spectrumLow,
      spectrumhigh = record$spectrumHigh,
      licenceid = content$licenceID,
      managementrightid = record$managementRightId,
      emissionid = record$emissionId,
      frequency = record$referenceFrequencies$frequency[1],
      power = record$referenceFrequencies$power[1],
      polarisation = record$polarisation,
      polarisationcode = NA,  # Not available in the response
      serviceid = NA,  # Not available in the response
      spectrumtypeid = NA,  # Not available in the response
      spectrumtype = record$serviceType,
      startdate = record$startDate,
      enddate = record$endDate,
      registereddate = record$registeredDate,
      spectrumremarks = record$remarks
    )
  })
  do.call(rbind, spectrum_data)
}

# 16. Extract transmit configuration
extract_transmit_configuration <- function(content) {
  transmit_config <- lapply(content$transmitLocations, function(location) {
    data.frame(
      transmitconfigurationid = location$locationId,
      licenceid = content$licenceID,
      locationid = location$locationId,
      txantennamake = location$antenna$make,
      txantennatype = location$antenna$type,
      txantennaheight = location$locationAltitude,
      txazimuth = location$azimuth,
      txequipment = location$equipment$equipmentModel
    )
  })
  do.call(rbind, transmit_config)
}



process_all_json_files <- function(json_files_path = "raw-data/") {
  # List all JSON files in the directory
  json_files <- list.files(path = json_files_path, pattern = "*.json", full.names = TRUE)

  # Loop through each JSON file and apply extraction functions
  associated_licences <- do.call(rbind, lapply(json_files, function(file) extract_associated_licences(read_json_file(file))))
  client_details <- do.call(rbind, lapply(json_files, function(file) extract_client_details(read_json_file(file))))
  emission_data <- do.call(rbind, lapply(json_files, function(file) extract_emission(read_json_file(file))))
  emission_limits <- do.call(rbind, lapply(json_files, function(file) extract_emission_limit(read_json_file(file))))
  geographic_references <- do.call(rbind, lapply(json_files, function(file) extract_geographic_reference(read_json_file(file))))
  issuing_offices <- do.call(rbind, lapply(json_files, function(file) extract_issuing_office(read_json_file(file))))
  licence_data <- do.call(rbind, lapply(json_files, function(file) extract_licence(read_json_file(file))))
  licence_conditions <- do.call(rbind, lapply(json_files, function(file) extract_licence_conditions(read_json_file(file))))
  licence_types <- do.call(rbind, lapply(json_files, function(file) extract_licence_type(read_json_file(file))))
  location_data <- do.call(rbind, lapply(json_files, function(file) extract_location(read_json_file(file))))
  management_rights <- do.call(rbind, lapply(json_files, function(file) extract_management_right(read_json_file(file))))
  map_districts <- do.call(rbind, lapply(json_files, function(file) extract_map_district(read_json_file(file))))
  radiation_patterns <- do.call(rbind, lapply(json_files, function(file) extract_radiation_pattern(read_json_file(file))))
  receive_configurations <- do.call(rbind, lapply(json_files, function(file) extract_receive_configuration(read_json_file(file))))
  spectrum_data <- do.call(rbind, lapply(json_files, function(file) extract_spectrum(read_json_file(file))))
  transmit_configurations <- do.call(rbind, lapply(json_files, function(file) extract_transmit_configuration(read_json_file(file))))

  # Save the data to CSV files
  write.csv(associated_licences, "associatedlicences_test.csv")
  write.csv(client_details, "clientname_test.csv")
  write.csv(emission_data, "emission_test.csv")
  write.csv(emission_limits, "emissionlimit_test.csv")
  write.csv(geographic_references, "geographicreference_test.csv")
  write.csv(issuing_offices, "issuingoffice_testcsv")
  write.csv(licence_data, "licence_test.csv")
  write.csv(licence_conditions, "licenceconditions_test.csv")
  write.csv(licence_types, "licencetype_test.csv")
  write.csv(location_data, "location_test.csv")
  write.csv(management_rights, "managementright_test.csv")
  write.csv(map_districts, "mapdistrict_test.csv")
  write.csv(radiation_patterns, "radiationpattern_test.csv")
  write.csv(receive_configurations, "receiveconfiguration_test.csv")
  write.csv(spectrum_data, "spectrum_test.csv")
  write.csv(transmit_configurations, "transmitconfiguration_test.csv")
}
# Process all JSON files in the "raw-data" directory and save to CSV
process_all_json_files()
