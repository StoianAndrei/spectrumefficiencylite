library(fs)
library(tidyverse)


page_list <- fs::dir_info("data/dlete/") |>
  mutate(size_num = str_extract(size, "\\d+"))# |>  filter(size_num <= 50)

parameters <-
page_list |>
select(path,size_num,ends_with("time")) |>
  mutate(path_char = as.character(path)) |>
  mutate(birth_date = lubridate::ymd(str_extract(birth_time,"\\d{4}-\\d{2}-\\d{2}"))) |>
  # Floor the hour by setting minute and second to zero
  mutate(birth_hour = lubridate::floor_date(birth_time, unit = "hour"))|>
  select(path_char,birth_date,birth_hour) |>
  rowid_to_column() |>
  ## data/dlete/licence_page_2000_3000100.json
  mutate(page_txt = str_remove(path_char,"data/dlete/licence_page")) |>
  mutate(page_just = str_extract(page_txt , "\\d+\\.json")) |>
  mutate(page = as.integer(str_extract(page_just, "\\d+"))) |>
  # mutate(page_999999     = str_detect(path_char,"data/dlete/licence_page_15000_999999")) |>
  # mutate(page_5000_15000 = str_detect(path_char,"data/dlete/licence_page_5000_15000")) |>
  # mutate(page_2000_3000  = str_detect(path_char,"data/dlete/licence_page_2000_3000")) |>
  # mutate(page_1000       = str_detect(path_char,"data/dlete/licence_page_850_1000")) |>
  #
  #
  mutate(page_freq = str_detect(page_txt ,"\\d+_\\d+\\.json$")) |>
  mutate(page_toDate = str_detect(page_txt ,"_\\d{4}-\\d{2}-\\d{2}_\\d+\\.json$")) |>
  # mutate(page = ifelse(page_999999,yes = as.integer(str_remove(page, "999999")),no = page)) |>
  # mutate(page = ifelse(page_5000_15000,yes = as.integer(str_remove(page, "15000")),no = page)) |>
  # mutate(page = ifelse(page_2000_3000,yes = as.integer(str_remove(page, "3000")),no = page)) |>
  # mutate(page = ifelse(page_1000,yes = as.integer(str_remove(page, "1000")),no = page)) |>
  #
  mutate(fromFrequency = ifelse(page_freq,yes = as.integer(str_extract(page_txt, "\\d+")),no = NA)) |>
  mutate(toFrequency = ifelse(page_freq,yes = as.integer(str_extract(str_remove(page_txt, "_\\d+_"), "\\d+")),no = NA)) |>

  # mutate(toFrequency = ifelse(page_999999,yes = as.integer(str_remove(str_remove(page_just, "999999"),"\\.json")),no = toFrequency)) |>
  # mutate(toFrequency = ifelse(page_5000_15000,yes = as.integer(str_remove(str_remove(page_just, "15000"),"\\.json")),no = toFrequency)) |>
  # mutate(toFrequency = ifelse(page_2000_3000,yes = as.integer(str_remove(str_remove(page_just, "3000"),"\\.json")),no = toFrequency)) |>
  # mutate(toFrequency = ifelse(page_1000,yes = as.integer(str_remove(str_remove(page_just, "1000"),"\\.json")),no = toFrequency)) |>

  mutate(fromDate =  ifelse(page_toDate,yes = str_extract(page_txt, "_\\d{4}-\\d{2}-\\d{2}"),no = NA)) |>
  mutate(toDate = ifelse(page_toDate,yes = str_extract(page_txt, "_\\d{4}-\\d{2}-\\d{2}_\\d{4}-\\d{2}-\\d{2}"),no = NA)) |>
  mutate(toDate = str_remove(str_remove(toDate,fromDate),"_")) |>
  mutate(fromDate = str_remove(fromDate,"_")) |>
  mutate(
    # Extract licenceStatus from different conditions
    licenceStatus = str_remove(str_extract(path_char, "data/dlete/licence_page_(cancelled|certificate_expired|current|expired|planned)"), "data/dlete/licence_page_")
  ) %>%

 select(rowid,path_char,page,fromDate,fromDate,toDate,fromFrequency,toFrequency,licenceStatus)

# Create a data frame with the additional columns and default values in the correct order
additional_columns <- data.frame(
  page_size = NA,
  sort_by = "Licence ID",
  sort_order = "desc",
  search1 = NA,
  transmitlocation = NA,
  receivelocation = NA,
  location = NA,
  district = NA,
  call_sign = NA,
  channel = NA,
  tx_rx = "TRN, RCV",  # Convert vector to comma-separated string
  LicenceDateType = "LASTUPDATED_LU",
  exactMatchFreq = NA,
  eirp = NA,
  licenceTypeCode = NA,
  managementRightId = NA,
  systemIdentifier = NA,
  certifiedBy = NA,
  GridRef = NA,
  radius = NA,
  includeAssociatedLicences = NA,
  gridRefDefault = "LAT_LONG_NZGD2000_D2000",
  engineerDecisionIAgree = NA,
  stringsAsFactors = FALSE
)

# Update parameters table with the correct column order
parameters <- parameters %>%
  bind_cols(additional_columns) %>%
  select(
    path_char, page, page_size, sort_by, sort_order, search1, transmitlocation, receivelocation, location,
    district, call_sign, channel, tx_rx, LicenceDateType, fromDate, toDate, exactMatchFreq, fromFrequency,
    toFrequency, eirp, licenceStatus, licenceTypeCode, managementRightId, systemIdentifier, certifiedBy,
    GridRef, radius, includeAssociatedLicences, gridRefDefault, engineerDecisionIAgree
  )


page = NULL,
page_size = NULL,
sort_by = "Licence ID",
sort_order = "desc",
search1 = NULL,
transmitlocation = NULL,
receivelocation = NULL,
location = NULL,
district = NULL,
call_sign = NULL,
channel = NULL,
tx_rx = c("TRN", "RCV"),
LicenceDateType = "LASTUPDATED_LU",
fromDate = NULL,
toDate = NULL,
exactMatchFreq = NULL,
fromFrequency = NULL,
toFrequency = NULL,
eirp = NULL,
licenceStatus = NULL,
licenceTypeCode = NULL,
managementRightId = NULL,
systemIdentifier = NULL,
certifiedBy = NULL,
GridRef = NULL,
radius = NULL,
includeAssociatedLicences = NULL,
gridRefDefault = "LAT_LONG_NZGD2000_D2000",
engineerDecisionIAgree = NULL
