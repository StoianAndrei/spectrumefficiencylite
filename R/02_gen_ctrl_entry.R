#' Generate Control Table Entries for a Date Range
#'
#' @param fromDate Date. The start date for the date range.
#' @param toDate Date. The end date for the date range.
#'
#' @export
#'
#' @return A tibble with one row per day in the date range, representing control table entries.
gen_ctrl_entry <- function(fromDate, toDate,page = 1) {
  # Use specific functions from each library
  box::use(
    dplyr = dplyr[rowwise, mutate, ungroup, select],
    tibble = tibble[tibble],
    glue = glue[glue],
    openssl = openssl[md5],
    lubridate = lubridate[days]
  )

  # Source the construct_url2 function
  box::use(./`08_construct_url2`[construct_url2])
  # Convert input dates to Date format
  fromDate <- as.Date(fromDate)
  toDate <- as.Date(toDate)

  # # Generate a sequence of dates from fromDate to toDate
  date_seq <- seq.Date(fromDate, toDate, by = "day")
  #
  # Create a tibble with parameters for each date

  # Construct URLs and compute unique keys
  entries <-
    tibble(
      fromDate = date_seq,
      toDate = date_seq + lubridate::days(1),
      page = page,
      sortBy = "Licence ID",
      sortOrder = "desc",
      txRx = "TRN, RCV",
      licenceDateType = "LASTUPDATED_LU",
      gridRefDefault = "LAT_LONG_NZGD2000_D2000"
    ) |>
    rowwise() |>
    mutate(
      # Convert txRx string to a vector
      # txRx_vector = strsplit(txRx, ",\\s*")[[1]],
      # Construct the URL using construct_url2
      url = construct_url2(
        page = page,
        sortBy = sortBy,
        sortOrder = sortOrder,
        txRx = txRx,
        LicenceDateType = licenceDateType,
        fromDate = as.character(fromDate),
        toDate = as.character(toDate),
        gridRefDefault = gridRefDefault
      ),
      # Compute unique key
      uniqueKey = md5(url),
      # Define the path for saving JSON data
      path = glue("data/page/{uniqueKey}.json"),
      # Record the creation timestamp
      createdAt = Sys.time(),
      # Initialize additional columns
      fromFrequency = NA_real_,
      toFrequency = NA_real_,
      licenceStatus = NA_character_,
      totalPages = NA_real_,
      totalItems = NA_real_,
      statusCode = NA_real_
    ) |>
    ungroup() |>
    # Select and reorder the columns
    select(
      uniqueKey, path, url, createdAt, page, sortBy, sortOrder, txRx,
      licenceDateType, fromDate, toDate, gridRefDefault, fromFrequency,
      toFrequency, licenceStatus, totalPages, totalItems,statusCode
    )

  return(entries)
}
