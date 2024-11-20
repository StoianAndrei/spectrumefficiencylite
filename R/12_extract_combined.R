# Load required packages
library(jsonlite)
library(dplyr)
library(purrr)

# Define the directory containing the JSON files
json_dir <- "data/licences/"

# Get a list of all JSON files in the directory
json_files <- list.files(path = json_dir, pattern = "*.json", full.names = TRUE,)

# Initialize empty lists to store data frames
licence_list <- list()
clients_list <- list()
spectrum_records_list <- list()
reference_frequencies_list <- list()
transmit_locations_list <- list()
receive_locations_list <- list()
antenna_list <- list()
equipment_list <- list()
grid_reference_list <- list()
associated_licence_list <- list()

# Function to safely extract values
extract_value <- function(x) {
  if (is.null(x) || length(x) == 0) {
    return(NA)
  } else if (is.list(x) && length(x) == 1) {
    return(x[[1]])
  } else {
    return(x)
  }
}

# Loop over each JSON file
for (file in json_files) {
  # Read the JSON data
  json_data <- readLines(file, warn = FALSE)
  data_list <- fromJSON(paste(json_data, collapse = ""), simplifyVector = FALSE)

  # Include the file path as a link
  file_link <- file

  # Extract Licence Information
  licence_df <- data.frame(
    licenceID = extract_value(data_list$licenceID),
    licenceNumber = extract_value(data_list$licenceNumber),
    systemId = extract_value(data_list$systemId),
    lastUpdated = extract_value(data_list$lastUpdated),
    licenceStatus = extract_value(data_list$licenceStatus),
    licenceType = extract_value(data_list$licenceType),
    licenceClassification = extract_value(data_list$licenceClassification),
    baseCallsign = extract_value(data_list$baseCallsign),
    mobileCallsign = extract_value(data_list$mobileCallsign),
    engineer = extract_value(data_list$engineer),
    fixedTerm = extract_value(data_list$fixedTerm),
    commencementDate = extract_value(data_list$commencementDate),
    expiryDate = extract_value(data_list$expiryDate),
    cancellationDate = extract_value(data_list$cancellationDate),
    grantedDate = extract_value(data_list$grantedDate),
    anniversaryMonth = extract_value(data_list$anniversaryMonth),
    annualLicenceFees = extract_value(data_list$annualLicenceFees),
    feesPaidOn = extract_value(data_list$feesPaidOn),
    paidUpUntil = extract_value(data_list$paidUpUntil),
    additionalInformation = extract_value(data_list$additionalInformation),
    suppressLicenceDetails = extract_value(data_list$suppressLicenceDetails),
    filePath = file_link,
    stringsAsFactors = FALSE
  )
  licence_list[[length(licence_list) + 1]] <- licence_df

  # Extract Client Details
  client_details <- data_list$clientDetails
  clients_df <- data.frame(
    licenceID = extract_value(data_list$licenceID),  # Link to licence
    clientNumber = extract_value(client_details$clientNumber),
    clientName = extract_value(client_details$clientName),
    emailAddress = extract_value(client_details$emailAddress),
    physicalAddress = extract_value(client_details$physicalAddress),
    licenceContact = extract_value(client_details$licenceContact),
    filePath = file_link,
    stringsAsFactors = FALSE
  )
  clients_list[[length(clients_list) + 1]] <- clients_df

  # Extract Spectrum Records
  if (!is.null(data_list$spectrumRecords) && length(data_list$spectrumRecords) > 0) {
    for (record in data_list$spectrumRecords) {
      spectrum_df <- data.frame(
        licenceID = extract_value(data_list$licenceID),  # Link to licence
        spectrumId = extract_value(record$spectrumId),
        channel = extract_value(record$channel),
        spectrumLow = extract_value(record$spectrumLow),
        spectrumHigh = extract_value(record$spectrumHigh),
        spectrumStatus = extract_value(record$spectrumStatus),
        serviceType = extract_value(record$serviceType),
        polarisation = extract_value(record$polarisation),
        accessCode = extract_value(record$accessCode),
        remarks = extract_value(record$remarks),
        startDate = extract_value(record$startDate),
        endDate = extract_value(record$endDate),
        filePath = file_link,
        stringsAsFactors = FALSE
      )
      spectrum_records_list[[length(spectrum_records_list) + 1]] <- spectrum_df

      # Extract Reference Frequencies
      if (!is.null(record$referenceFrequencies) && length(record$referenceFrequencies) > 0) {
        for (ref_freq in record$referenceFrequencies) {
          ref_freq_df <- data.frame(
            licenceID = extract_value(data_list$licenceID),  # Link to licence
            spectrumId = extract_value(record$spectrumId),  # Link to spectrum record
            frequency = extract_value(ref_freq$frequency),
            frequencyType = extract_value(ref_freq$frequencyType),
            power = extract_value(ref_freq$power),
            powerType = extract_value(ref_freq$powerType),
            tolerance = extract_value(ref_freq$tolerance),
            emissions = extract_value(ref_freq$emissions),
            startTime = extract_value(ref_freq$startTime),
            stopTime = extract_value(ref_freq$stopTime),
            hoursOfOperation = extract_value(ref_freq$hoursOfOperation),
            refFrequencyId = extract_value(ref_freq$refFrequencyId),
            filePath = file_link,
            stringsAsFactors = FALSE
          )
          reference_frequencies_list[[length(reference_frequencies_list) + 1]] <- ref_freq_df
        }
      }
    }
  }

  # Extract Transmit Locations
  if (!is.null(data_list$transmitLocations) && length(data_list$transmitLocations) > 0) {
    for (location in data_list$transmitLocations) {
      transmit_df <- data.frame(
        licenceID = extract_value(data_list$licenceID),  # Link to licence
        locationId = extract_value(location$locationId),
        locationName = extract_value(location$locationName),
        LocationType = extract_value(location$LocationType),
        locationAltitude = extract_value(location$locationAltitude),
        locationAltitudeUOM = extract_value(location$locationAltitudeUOM),
        azimuth = extract_value(location$azimuth),
        elevation = extract_value(location$elevation),
        height = extract_value(location$height),
        configurationLoss = extract_value(location$configurationLoss),
        filePath = file_link,
        stringsAsFactors = FALSE
      )
      transmit_locations_list[[length(transmit_locations_list) + 1]] <- transmit_df
    }
  }

  # Extract Receive Locations
  if (!is.null(data_list$receiveLocations) && length(data_list$receiveLocations) > 0) {
    for (location in data_list$receiveLocations) {
      receive_df <- data.frame(
        licenceID = extract_value(data_list$licenceID),  # Link to licence
        locationId = extract_value(location$locationId),
        locationName = extract_value(location$locationName),
        LocationType = extract_value(location$LocationType),
        locationAltitude = extract_value(location$locationAltitude),
        locationAltitudeUOM = extract_value(location$locationAltitudeUOM),
        azimuth = extract_value(location$azimuth),
        elevation = extract_value(location$elevation),
        height = extract_value(location$height),
        configurationLoss = extract_value(location$configurationLoss),
        protectionRatio = extract_value(location$protectionRatio),
        bearing = extract_value(location$bearing),
        pathLoss = extract_value(location$pathLoss),
        wantedSignal = extract_value(location$wantedSignal),
        wantedSignalUOM = extract_value(location$wantedSignalUOM),
        measuredSignal = extract_value(location$measuredSignal),
        measuredSignalUOM = extract_value(location$measuredSignalUOM),
        mpis = extract_value(location$mpis),
        mpisUOM = extract_value(location$mpisUOM),
        filePath = file_link,
        stringsAsFactors = FALSE
      )
      receive_locations_list[[length(receive_locations_list) + 1]] <- receive_df

      # Extract Antenna Information
      antenna <- location$antenna
      if (!is.null(antenna) && length(antenna) > 0) {
        antenna_df <- data.frame(
          licenceID = extract_value(data_list$licenceID),  # Link to licence
          locationId = extract_value(location$locationId),  # Link to location
          id = extract_value(antenna$id),
          identifier = extract_value(antenna$identifier),
          versionNumber = extract_value(antenna$versionNumber),
          make = extract_value(antenna$make),
          model = extract_value(antenna$model),
          type = extract_value(antenna$type),
          remarks = extract_value(antenna$remarks),
          lowFrequency = extract_value(antenna$lowFrequency),
          highFrequency = extract_value(antenna$highFrequency),
          gainLow = extract_value(antenna$gainLow),
          gainMid = extract_value(antenna$gainMid),
          gainHigh = extract_value(antenna$gainHigh),
          beamWidth = extract_value(antenna$beamWidth),
          diameter = extract_value(antenna$diameter),
          frontBackRatio = extract_value(antenna$frontBackRatio),
          xpol = extract_value(antenna$xpol),
          filePath = file_link,
          stringsAsFactors = FALSE
        )
        antenna_list[[length(antenna_list) + 1]] <- antenna_df
      }

      # Extract Equipment Information
      equipment <- location$equipment
      if (!is.null(equipment) && length(equipment) > 0) {
        equipment_df <- data.frame(
          licenceID = extract_value(data_list$licenceID),  # Link to licence
          locationId = extract_value(location$locationId),  # Link to location
          equipmentId = extract_value(equipment$equipmentId),
          equipmentIdentifier = extract_value(equipment$equipmentIdentifier),
          equipmentModel = extract_value(equipment$equipmentModel),
          equipmentMake = extract_value(equipment$equipmentMake),
          equipmentVersion = extract_value(equipment$equipmentVersion),
          filePath = file_link,
          stringsAsFactors = FALSE
        )
        equipment_list[[length(equipment_list) + 1]] <- equipment_df
      }

      # Extract Grid Reference
      if (!is.null(location$gridReference) && length(location$gridReference) > 0) {
        for (gr in location$gridReference) {
          grid_ref_df <- data.frame(
            licenceID = extract_value(data_list$licenceID),  # Link to licence
            locationId = extract_value(location$locationId),  # Link to location
            GeoRefType = extract_value(gr$GeoRefType),
            Map = extract_value(gr$Map),
            Easting = extract_value(gr$Easting),
            Northing = extract_value(gr$Northing),
            Latitude = extract_value(gr$Latitude),
            Longitude = extract_value(gr$Longitude),
            filePath = file_link,
            stringsAsFactors = FALSE
          )
          grid_reference_list[[length(grid_reference_list) + 1]] <- grid_ref_df
        }
      }
    }
  }

  # Extract Associated Licence or Record
  if (!is.null(data_list$associatedLicenceOrRecord) && length(data_list$associatedLicenceOrRecord) > 0) {
    for (record in data_list$associatedLicenceOrRecord) {
      assoc_df <- data.frame(
        licenceID = extract_value(data_list$licenceID),  # Link to licence
        associatedLicenceId = extract_value(record$licenceId),
        associatedLicenceNumber = extract_value(record$licenceNumber),
        associationType = extract_value(record$associationType),
        primary = extract_value(record$primary),
        filePath = file_link,
        stringsAsFactors = FALSE
      )
      associated_licence_list[[length(associated_licence_list) + 1]] <- assoc_df
    }
  }
}

# Combine all data frames from the lists
licence_df_combined <- bind_rows(licence_list)
clients_df_combined <- bind_rows(clients_list)
spectrum_records_df_combined <- bind_rows(spectrum_records_list)
reference_frequencies_df_combined <- bind_rows(reference_frequencies_list)
transmit_locations_df_combined <- bind_rows(transmit_locations_list)
receive_locations_df_combined <- bind_rows(receive_locations_list)
antenna_df_combined <- bind_rows(antenna_list)
equipment_df_combined <- bind_rows(equipment_list)
grid_reference_df_combined <- bind_rows(grid_reference_list)
associated_licence_df_combined <- bind_rows(associated_licence_list)


fs::dir_create("data/combined")
# Write combined data frames to CSV files
write.csv(licence_df_combined, "data/combined/licence.csv", row.names = FALSE)
write.csv(clients_df_combined, "data/combined/clients.csv", row.names = FALSE)
write.csv(spectrum_records_df_combined, "data/combined/spectrum_records.csv", row.names = FALSE)
write.csv(reference_frequencies_df_combined, "data/combined/reference_frequencies.csv", row.names = FALSE)
write.csv(transmit_locations_df_combined, "data/combined/transmit_locations.csv", row.names = FALSE)
write.csv(receive_locations_df_combined, "data/combined/receive_locations.csv", row.names = FALSE)
write.csv(antenna_df_combined, "data/combined/antenna.csv", row.names = FALSE)
write.csv(equipment_df_combined, "data/combined/equipment.csv", row.names = FALSE)
write.csv(grid_reference_df_combined, "data/combined/grid_reference.csv", row.names = FALSE)
write.csv(associated_licence_df_combined, "data/combined/associated_licence.csv", row.names = FALSE)
