CREATE TABLE Licence (
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
  commencementDate DATETIME,
  expiryDate DATETIME,
  cancellationDate DATETIME,
  grantedDate DATETIME,
  anniversaryMonth INT,
  annualLicenceFees DECIMAL(10, 2),
  feesPaidOn DATETIME,
  paidUpUntil DATETIME,
  additionalInformation TEXT,
  suppressLicenceDetails BOOLEAN
);

CREATE TABLE Client (
  clientNumber INT PRIMARY KEY,
  clientName VARCHAR(255),
  emailAddress VARCHAR(255),
  physicalAddress VARCHAR(255),
  licenceContact VARCHAR(255)
);

CREATE TABLE SpectrumRecord (
  spectrumId INT PRIMARY KEY,
  channel VARCHAR(255),
  spectrumLow DECIMAL(10, 4),
  spectrumHigh DECIMAL(10, 4),
  spectrumStatus VARCHAR(50),
  serviceType VARCHAR(255),
  polarisation VARCHAR(50),
  accessCode VARCHAR(255),
  remarks TEXT,
  startDate DATETIME,
  endDate DATETIME,
  licenceID INT,
  FOREIGN KEY (licenceID) REFERENCES Licence(licenceID)
);

CREATE TABLE ReferenceFrequency (
  refFrequencyId INT PRIMARY KEY,
  frequency DECIMAL(10, 4),
  frequencyType VARCHAR(255),
  power DECIMAL(10, 4),
  powerType VARCHAR(255),
  tolerance VARCHAR(50),
  emissions VARCHAR(255),
  startTime DATETIME,
  stopTime DATETIME,
  hoursOfOperation VARCHAR(50),
  spectrumId INT,
  FOREIGN KEY (spectrumId) REFERENCES SpectrumRecord(spectrumId)
);

CREATE TABLE TransmitLocation (
  locationId INT PRIMARY KEY,
  locationName VARCHAR(255),
  LocationType VARCHAR(50),
  locationAltitude DECIMAL(10, 2),
  locationAltitudeUOM VARCHAR(10),
  configurationLoss DECIMAL(10, 2),
  licenceID INT,
  FOREIGN KEY (licenceID) REFERENCES Licence(licenceID)
);

CREATE TABLE ReceiveLocation (
  locationId INT PRIMARY KEY,
  locationName VARCHAR(255),
  LocationType VARCHAR(50),
  locationAltitude DECIMAL(10, 2),
  locationAltitudeUOM VARCHAR(10),
  configurationLoss DECIMAL(10, 2),
  protectionRatio DECIMAL(10, 2),
  bearing DECIMAL(10, 2),
  pathLoss DECIMAL(10, 2),
  wantedSignal DECIMAL(10, 2),
  wantedSignalUOM VARCHAR(10),
  measuredSignal DECIMAL(10, 2),
  measuredSignalUOM VARCHAR(10),
  mpis DECIMAL(10, 2),
  mpisUOM VARCHAR(10),
  licenceID INT,
  FOREIGN KEY (licenceID) REFERENCES Licence(licenceID)
);

CREATE TABLE Antenna (
  id INT PRIMARY KEY,
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
  locationId INT,
  FOREIGN KEY (locationId) REFERENCES ReceiveLocation(locationId)
);

CREATE TABLE Equipment (
  equipmentId INT PRIMARY KEY,
  equipmentIdentifier INT,
  equipmentModel VARCHAR(255),
  equipmentMake VARCHAR(255),
  equipmentVersion VARCHAR(255),
  locationId INT,
  FOREIGN KEY (locationId) REFERENCES ReceiveLocation(locationId)
);

CREATE TABLE GridReference (
  GeoRefType VARCHAR(255),
  Map VARCHAR(255),
  Easting DECIMAL(10, 2),
  Northing DECIMAL(10, 2),
  Latitude DECIMAL(10, 6),
  Longitude DECIMAL(10, 6),
  locationId INT,
  FOREIGN KEY (locationId) REFERENCES ReceiveLocation(locationId)
);

CREATE TABLE AssociatedLicence (
  licenceId INT PRIMARY KEY,
  licenceNumber VARCHAR(255),
  associationType VARCHAR(255),
  primary BOOLEAN,
  licenceID INT,
  FOREIGN KEY (licenceID) REFERENCES Licence(licenceID)
);
