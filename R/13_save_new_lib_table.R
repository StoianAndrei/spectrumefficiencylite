# Load required packages
library(jsonlite)
library(dplyr)

# Assign the JSON data to a variable
json_data <- '{
  "licenceDiscriminator": ["RadioLicenceResponse"],
  "summary": {
    "licenceID": [104209],
    "licenceNumber": {},
    "licensee": ["RODNEY DISTRICT COUNCIL"],
    "channel": ["FN85#"],
    "frequency": [473.0562],
    "location": ["WARKWORTH MM AREA"],
    "gridRefDefault": ["LAT_LONG_NZGD2000_D2000"],
    "gridReference": {},
    "licenceType": ["Land Mobile/Repeater/Land Mobile - Mobile Transmit (LM)"],
    "status": ["CANCELLED"],
    "txrx": ["TX"],
    "suppressed": [false]
  },
  "licenceID": [104209],
  "licenceNumber": {},
  "systemId": {},
  "lastUpdated": ["2010-09-20T15:03:27"],
  "clientDetails": {
    "clientNumber": [1353],
    "clientName": ["RODNEY DISTRICT COUNCIL"],
    "emailAddress": {},
    "physicalAddress": ["2 Nuffield Street, Newmarket, AUCKLAND, 1023, NZ"],
    "licenceContact": {}
  },
  "licenceStatus": ["CANCELLED"],
  "licenceReference": {},
  "licenceType": ["Land Mobile/Repeater/Land Mobile - Mobile Transmit (LM)"],
  "licenceClassification": ["A"],
  "baseCallsign": {},
  "mobileCallsign": {},
  "engineer": ["Digby Gudsell"],
  "fixedTerm": [false],
  "commencementDate": {},
  "expiryDate": {},
  "cancellationDate": ["2010-09-20"],
  "grantedDate": {},
  "anniversaryMonth": {},
  "annualLicenceFees": [0],
  "feesPaidOn": {},
  "paidUpUntil": {},
  "additionalInformation": {},
  "suppressLicenceDetails": [false],
  "disableRenewal": {},
  "reservedLicence": {},
  "horizontalRadiationPatterns": {},
  "verticalRadiationPatterns": {},
  "associatedLicenceOrRecord": [
    {
      "licenceId": [104198],
      "licenceNumber": [203428],
      "associationType": ["Record"],
      "primary": [false]
    }
  ],
  "relatedLicence": [],
  "spectrumRecords": [
    {
      "spectrumId": [161875],
      "channel": ["FN85#"],
      "spectrumLow": [473.05],
      "spectrumHigh": [473.0625],
      "spectrumStatus": ["CANCELLED"],
      "serviceType": ["Land Mobile"],
      "polarisation": ["V"],
      "accessCode": {},
      "remarks": {},
      "startDate": {},
      "endDate": {},
      "referenceFrequencies": [
        {
          "frequency": [473.0562],
          "frequencyType": ["Carrier Frequency"],
          "power": [14],
          "powerType": ["Mean Power"],
          "tolerance": ["±1.5kHz"],
          "emissions": ["10K0F3EJN"],
          "startTime": {},
          "stopTime": {},
          "hoursOfOperation": {},
          "refFrequencyId": [169515]
        }
      ],
      "unwantedEmissionLimits": {}
    }
  ],
  "transmitLocations": [
    {
      "locationId": [1321],
      "locationName": ["WARKWORTH MM AREA"],
      "LocationType": ["Defined Area"],
      "locationAltitude": [0],
      "locationAltitudeUOM": ["M"],
      "gridReference": [],
      "antenna": {},
      "azimuth": {},
      "elevation": {},
      "height": {},
      "equipment": {
        "equipmentId": [1016],
        "equipmentIdentifier": [1016],
        "equipmentModel": ["T2000"],
        "equipmentMake": ["TAIT"],
        "equipmentVersion": ["1"]
      },
      "configurationLoss": {}
    }
  ],
  "receiveLocations": [
    {
      "locationId": [24156],
      "locationName": ["SCANDRETTS RDC"],
      "LocationType": ["Point"],
      "locationAltitude": [66],
      "locationAltitudeUOM": ["M"],
      "gridReference": [
        {
          "GeoRefType": ["LAT_LONG_NZGD2000_D2000"],
          "Map": {},
          "Easting": {},
          "Northing": {},
          "Latitude": [-36.4455],
          "Longitude": [174.7604]
        }
      ],
      "antenna": {
        "id": [2037],
        "identifier": [2037],
        "versionNumber": [1],
        "make": ["RFI"],
        "model": ["COL11"],
        "type": ["UHF COLINEAR"],
        "remarks": ["GAIN 5.2 DBI"],
        "lowFrequency": [400],
        "highFrequency": [520],
        "gainLow": {},
        "gainMid": [5.2],
        "gainHigh": {},
        "beamWidth": {},
        "diameter": {},
        "frontBackRatio": {},
        "xpol": {}
      },
      "azimuth": {},
      "elevation": {},
      "height": {},
      "equipment": {
        "equipmentId": [1016],
        "equipmentIdentifier": [1016],
        "equipmentModel": ["T2000"],
        "equipmentMake": ["TAIT"],
        "equipmentVersion": ["1"]
      },
      "configurationLoss": [3],
      "protectionRatio": {},
      "bearing": {},
      "pathLoss": {},
      "wantedSignal": {},
      "wantedSignalUOM": {},
      "measuredSignal": {},
      "measuredSignalUOM": {},
      "mpis": {},
      "mpisUOM": {}
    }
  ],
  "specificConditions": {},
  "numberOfSets": {}
}'

# Parse the JSON data
data_list <- fromJSON(json_data, simplifyVector = FALSE)

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
  stringsAsFactors = FALSE
)


# Extract Client Details
client_details <- data_list$clientDetails
clients_df <- data.frame(
  clientNumber = extract_value(client_details$clientNumber),
  clientName = extract_value(client_details$clientName),
  emailAddress = extract_value(client_details$emailAddress),
  physicalAddress = extract_value(client_details$physicalAddress),
  licenceContact = extract_value(client_details$licenceContact),
  stringsAsFactors = FALSE
)

# Extract Spectrum Records
spectrum_records_list <- lapply(data_list$spectrumRecords, function(record) {
  data.frame(
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
    stringsAsFactors = FALSE
  )
})
spectrum_records_df <- bind_rows(spectrum_records_list)


# Extract Reference Frequencies
reference_frequencies_list <- lapply(data_list$spectrumRecords, function(record) {
  lapply(record$referenceFrequencies, function(ref_freq) {
    data.frame(
      spectrumId = extract_value(record$spectrumId),
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
      stringsAsFactors = FALSE
    )
  })
})
reference_frequencies_df <- bind_rows(unlist(reference_frequencies_list, recursive = FALSE))

# Extract Transmit Locations
transmit_locations_list <- lapply(data_list$transmitLocations, function(location) {
  data.frame(
    locationId = extract_value(location$locationId),
    locationName = extract_value(location$locationName),
    LocationType = extract_value(location$LocationType),
    locationAltitude = extract_value(location$locationAltitude),
    locationAltitudeUOM = extract_value(location$locationAltitudeUOM),
    azimuth = extract_value(location$azimuth),
    elevation = extract_value(location$elevation),
    height = extract_value(location$height),
    configurationLoss = extract_value(location$configurationLoss),
    stringsAsFactors = FALSE
  )
})
transmit_locations_df <- bind_rows(transmit_locations_list)


# Extract Receive Locations
receive_locations_list <- lapply(data_list$receiveLocations, function(location) {
  data.frame(
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
    stringsAsFactors = FALSE
  )
})
receive_locations_df <- bind_rows(receive_locations_list)


# Extract Antenna Information from Receive Locations
antenna_list <- lapply(data_list$receiveLocations, function(location) {
  antenna <- location$antenna
  if (is.null(antenna) || length(antenna) == 0) return(NULL)
  data.frame(
    locationId = extract_value(location$locationId),
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
    stringsAsFactors = FALSE
  )
})
antenna_df <- bind_rows(antenna_list)


# Extract Equipment Information from Receive Locations
equipment_list <- lapply(data_list$receiveLocations, function(location) {
  equipment <- location$equipment
  if (is.null(equipment) || length(equipment) == 0) return(NULL)
  data.frame(
    locationId = extract_value(location$locationId),
    equipmentId = extract_value(equipment$equipmentId),
    equipmentIdentifier = extract_value(equipment$equipmentIdentifier),
    equipmentModel = extract_value(equipment$equipmentModel),
    equipmentMake = extract_value(equipment$equipmentMake),
    equipmentVersion = extract_value(equipment$equipmentVersion),
    stringsAsFactors = FALSE
  )
})
equipment_df <- bind_rows(equipment_list)


# Extract Grid Reference from Receive Locations
grid_reference_list <- lapply(data_list$receiveLocations, function(location) {
  gridReference <- location$gridReference
  if (is.null(gridReference) || length(gridReference) == 0) return(NULL)
  lapply(gridReference, function(gr) {
    data.frame(
      locationId = extract_value(location$locationId),
      GeoRefType = extract_value(gr$GeoRefType),
      Map = extract_value(gr$Map),
      Easting = extract_value(gr$Easting),
      Northing = extract_value(gr$Northing),
      Latitude = extract_value(gr$Latitude),
      Longitude = extract_value(gr$Longitude),
      stringsAsFactors = FALSE
    )
  })
})
grid_reference_df <- bind_rows(unlist(grid_reference_list, recursive = FALSE))


# Extract Associated Licence or Record
associated_licence_list <- lapply(data_list$associatedLicenceOrRecord, function(record) {
  data.frame(
    licenceId = extract_value(record$licenceId),
    licenceNumber = extract_value(record$licenceNumber),
    associationType = extract_value(record$associationType),
    primary = extract_value(record$primary),
    stringsAsFactors = FALSE
  )
})
associated_licence_df <- bind_rows(associated_licence_list)

# Write Licence Information to CSV
write.csv(licence_df, "licence.csv", row.names = FALSE)
# Write Client Details to CSV
write.csv(clients_df, "clients.csv", row.names = FALSE)
# Write Spectrum Records to CSV
write.csv(spectrum_records_df, "spectrum_records.csv", row.names = FALSE)
# Write Reference Frequencies to CSV
write.csv(reference_frequencies_df, "reference_frequencies.csv", row.names = FALSE)

# Write Transmit Locations to CSV
write.csv(transmit_locations_df, "transmit_locations.csv", row.names = FALSE)
# Write Receive Locations to CSV
write.csv(receive_locations_df, "receive_locations.csv", row.names = FALSE)
# Write Antenna Information to CSV
write.csv(antenna_df, "antenna.csv", row.names = FALSE)
# Write Equipment Information to CSV
write.csv(equipment_df, "equipment.csv", row.names = FALSE)
# Write Grid Reference to CSV
write.csv(grid_reference_df, "grid_reference.csv", row.names = FALSE)
# Write Associated Licence Information to CSV
write.csv(associated_licence_df, "associated_licence.csv", row.names = FALSE)

library(RSQLite)
# Replace 'path/to/your/database.sqlite' with the actual path to your SQLite database
db_path <- "data/spectrumefficiency.sqlite"
con <- dbConnect(RSQLite::SQLite(), dbname = db_path)
# Create Silver Licence Table
# Load required library
library(RSQLite)

# Connect to the SQLite database
db_path <- "path/to/your/database.sqlite"  # Update with your database path
con <- dbConnect(RSQLite::SQLite(), dbname = db_path)

# Create and populate Silver Licence Table
dbExecute(con, "
CREATE TABLE SilverLicence (
    licenceID INT PRIMARY KEY,
    licenceNumber VARCHAR(255),
    systemId VARCHAR(255),
    lastUpdated DATETIME,
    licenceStatus VARCHAR(50),
    licenceType VARCHAR(255),
    licenceClassification VARCHAR(50),
    baseCallsign VARCHAR(255),
    mobileCallsign VARCHAR(255),
    engineer VARCHAR(255),
    fixedTerm BOOLEAN,
    commencementDate DATE,
    expiryDate DATE,
    cancellationDate DATE,
    grantedDate DATE,
    anniversaryMonth INT,
    annualLicenceFees DECIMAL(10, 2),
    feesPaidOn DATE,
    paidUpUntil DATE,
    additionalInformation TEXT,
    suppressLicenceDetails BOOLEAN
);
")
dbWriteTable(con, "SilverLicence", licence_df, append = TRUE, row.names = FALSE)

# Create and populate Silver Client Name Table
dbExecute(con, "
CREATE TABLE SilverClientName (
    clientNumber INT PRIMARY KEY,
    clientName VARCHAR(255),
    emailAddress VARCHAR(255),
    physicalAddress VARCHAR(255),
    licenceContact VARCHAR(255)
);
")
dbWriteTable(con, "SilverClientName", clients_df, append = TRUE, row.names = FALSE)

# Create and populate Silver Spectrum Records Table
dbExecute(con, "
CREATE TABLE SilverSpectrumRecords (
    spectrumId INT PRIMARY KEY,
    channel VARCHAR(255),
    spectrumLow DECIMAL(10, 4),
    spectrumHigh DECIMAL(10, 4),
    spectrumStatus VARCHAR(50),
    serviceType VARCHAR(255),
    polarisation VARCHAR(50),
    accessCode VARCHAR(255),
    remarks TEXT,
    startDate DATE,
    endDate DATE
);
")
dbWriteTable(con, "SilverSpectrumRecords", spectrum_records_df, append = TRUE, row.names = FALSE)

# Create and populate Silver Reference Frequencies Table
dbExecute(con, "
CREATE TABLE SilverReferenceFrequencies (
    refFrequencyId INT PRIMARY KEY,
    spectrumId INT,
    frequency DECIMAL(10, 4),
    frequencyType VARCHAR(255),
    power DECIMAL(10, 4),
    powerType VARCHAR(255),
    tolerance VARCHAR(50),
    emissions VARCHAR(255),
    startTime DATE,
    stopTime DATE,
    hoursOfOperation VARCHAR(50)
);
")
dbWriteTable(con, "SilverReferenceFrequencies", reference_frequencies_df, append = TRUE, row.names = FALSE)

# Create and populate Silver Transmit Locations Table
dbExecute(con, "
CREATE TABLE SilverTransmitLocations (
    locationId INT PRIMARY KEY,
    locationName VARCHAR(255),
    LocationType VARCHAR(50),
    locationAltitude DECIMAL(10, 2),
    locationAltitudeUOM VARCHAR(10),
    azimuth DECIMAL(10, 2),
    elevation DECIMAL(10, 2),
    height DECIMAL(10, 2),
    configurationLoss DECIMAL(10, 2)
);
")
dbWriteTable(con, "SilverTransmitLocations", transmit_locations_df, append = TRUE, row.names = FALSE)

# Create and populate Silver Receive Locations Table
dbExecute(con, "
CREATE TABLE SilverReceiveLocations (
    locationId INT PRIMARY KEY,
    locationName VARCHAR(255),
    LocationType VARCHAR(50),
    locationAltitude DECIMAL(10, 2),
    locationAltitudeUOM VARCHAR(10),
    azimuth DECIMAL(10, 2),
    elevation DECIMAL(10, 2),
    height DECIMAL(10, 2),
    configurationLoss DECIMAL(10, 2),
    protectionRatio DECIMAL(10, 2),
    bearing DECIMAL(10, 2),
    pathLoss DECIMAL(10, 2),
    wantedSignal DECIMAL(10, 2),
    wantedSignalUOM VARCHAR(10),
    measuredSignal DECIMAL(10, 2),
    measuredSignalUOM VARCHAR(10),
    mpis DECIMAL(10, 2),
    mpisUOM VARCHAR(10)
);
")
dbWriteTable(con, "SilverReceiveLocations", receive_locations_df, append = TRUE, row.names = FALSE)

# Create and populate Silver Antenna Table
dbExecute(con, "
CREATE TABLE SilverAntenna (
    locationId INT,
    id INT,
    identifier INT,
    versionNumber INT,
    make VARCHAR(255),
    model VARCHAR(255),
    type VARCHAR(255),
    remarks TEXT,
    lowFrequency DECIMAL(10, 2),
    highFrequency DECIMAL(10, 2),
    gainLow DECIMAL(10, 2),
    gainMid DECIMAL(10, 2),
    gainHigh DECIMAL(10, 2),
    beamWidth DECIMAL(10, 2),
    diameter DECIMAL(10, 2),
    frontBackRatio DECIMAL(10, 2),
    xpol DECIMAL(10, 2),
    PRIMARY KEY (locationId, id)
);
")
dbWriteTable(con, "SilverAntenna", antenna_df, append = TRUE, row.names = FALSE)

# Create and populate Silver Equipment Table
dbExecute(con, "
CREATE TABLE SilverEquipment (
    locationId INT,
    equipmentId INT,
    equipmentIdentifier INT,
    equipmentModel VARCHAR(255),
    equipmentMake VARCHAR(255),
    equipmentVersion VARCHAR(255),
    PRIMARY KEY (locationId, equipmentId)
);
")
dbWriteTable(con, "SilverEquipment", equipment_df, append = TRUE, row.names = FALSE)

# Create and populate Silver Grid Reference Table
dbExecute(con, "
CREATE TABLE SilverGridReference (
    locationId INT,
    GeoRefType VARCHAR(255),
    Map VARCHAR(255),
    Easting DECIMAL(10, 2),
    Northing DECIMAL(10, 2),
    Latitude DECIMAL(10, 6),
    Longitude DECIMAL(10, 6),
    PRIMARY KEY (locationId, GeoRefType)
);
")
dbWriteTable(con, "SilverGridReference", grid_reference_df, append = TRUE, row.names = FALSE)

# Create and populate Silver Associated Licence Table
dbExecute(con, "
CREATE TABLE SilverAssociatedLicence (
    licenceId INT,
    licenceNumber VARCHAR(255),
    associationType VARCHAR(255),
    primary BOOLEAN,
    PRIMARY KEY (licenceId, licenceNumber)
);
")
dbWriteTable(con, "SilverAssociatedLicence", associated_licence_df, append = TRUE, row.names = FALSE)

# Close the database connection
dbDisconnect(con)
