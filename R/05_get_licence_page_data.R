#' This is a REST service to GET/Search for a list of licences that match the search criteria.
#' Search the Register of Radio Frequencies and return matching Radio and Spectrum licences.
#'
#' @param page Integer. The page number for pagination.
#' @param pageSize Integer. The number of items per page.
#' @param sortBy Character. The field to sort by (default: "Licence ID").
#' @param sortOrder Character. The sort order, "asc" or "desc" (default: "desc").
#' @param search Character. Search term.
#' @param transmitlocation Character vector. Transmit locations.
#' @param receivelocation Character vector. Receive locations.
#' @param location Character vector. General locations.
#' @param district Character vector. Districts.
#' @param callSign Character. Call sign.
#' @param channel Character. Channel.
#' @param txRx Character vector. Transmit/Receive options (default: c("TRN", "RCV")).
#' @param LicenceDateType Character. Type of licence date (default: "LASTUPDATED_LU").
#' @param fromDate Character. Start date for date range.
#' @param toDate Character. End date for date range.
#' @param exactMatchFreq Numeric. Exact frequency match.
#' @param fromFrequency Numeric. Lower bound of frequency range.
#' @param toFrequency Numeric. Upper bound of frequency range.
#' @param eirp Numeric. Effective Isotropic Radiated Power.
#' @param licenceStatus Character vector. Licence statuses.
#' @param licenceTypeCode Character vector. Licence type codes.
#' @param managementRightId Character. Management right ID.
#' @param systemIdentifier Character. System identifier.
#' @param certifiedBy Character. Certifier.
#' @param GridRef List. Grid reference parameters.
#' @param radius Numeric. Search radius.
#' @param includeAssociatedLicences Logical. Whether to include associated licences.
#' @param gridRefDefault Character. Default grid reference system (default: "LAT_LONG_NZGD2000_D2000").
#' @param engineerDecisionIAgree Logical. Engineer decision agreement.
#' @param encode Logical. Return encoded msg or the url in full.
#'
#' @return Character. An MD5 hash representing the unique key for the query.
#'
#' @export
#'
#' @examples
#' generate_unique_key(page = 1, page_size = 100, sortBy  = "Licence ID",sortOrder = "desc", txRx = c("TRN", "RCV"),LicenceDateType = "LASTUPDATED_LU",gridRefDefault = "LAT_LONG_NZGD2000_D2000")
#'
#' @importFrom box use
#' @importFrom glue glue
#' @importFrom jsonlite toJSON,write_json
#' @importFrom openssl md5
#' @importFrom httr2 request,req_method,req_perform,resp_is_error,resp_body_json,resp_status,resp_status_desc
#' @importFrom logger log_error,log_info,log_warn
#' @importFrom purrr map,compact
get_licence_page_data <- function(
    page = NULL,
    pageSize = NULL,
    sortBy  = "Licence ID",
    sortOrder = "desc",
    search = NULL,
    transmitlocation = NULL,
    receivelocation = NULL,
    location = NULL,
    district = NULL,
    callSign = NULL,
    channel = NULL,
    txRx = c("TRN", "RCV"),
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
) {
  box::use(glue = glue[glue])
  box::use(jsonlite = jsonlite[toJSON,write_json])
  box::use(httr2 = httr2[request,req_method,req_perform,resp_is_error,resp_body_json,resp_status,resp_status_desc])
  box::use(logger = logger[log_error,log_info,log_warn])
  box::use(openssl = openssl[md5])
  box::use(purrr = purrr[map,compact])

  # Base API URL
  base_url <- "https://api.business.govt.nz/gateway/radio-spectrum-management/v1/licences"

  # Collect all parameters into a named list
  params <- list(
    page = page,
    'page-size' = pageSize,
    'sort-by' = sortBy,
    'sort-order' = sortOrder,
    search = search,
    transmitlocation = transmitlocation,
    receivelocation = receivelocation,
    location = location,
    district = district,
    callSign = callSign,
    channel = channel,
    txRx = txRx,
    LicenceDateType = LicenceDateType,
    fromDate = fromDate,
    toDate = toDate,
    exactMatchFreq = exactMatchFreq,
    fromFrequency = fromFrequency,
    toFrequency = toFrequency,
    eirp = eirp,
    licenceStatus = licenceStatus,
    licenceTypeCode = licenceTypeCode,
    managementRightId = managementRightId,
    systemIdentifier = systemIdentifier,
    certifiedBy = certifiedBy,
    radius = radius,
    includeAssociatedLicences = includeAssociatedLicences,
    gridRefDefault = gridRefDefault,
    engineerDecisionIAgree = engineerDecisionIAgree
  )

  # Construct the query string using purrr::map()
  query_params <- purrr::map(names(params), function(name) {
    value <- params[[name]]
    if (!is.null(value) && !all(is.na(value))) {
      if (is.vector(value) && length(value) > 1) {
        value <- paste(value, collapse = ",")
      }
      return(glue::glue("{name}={utils::URLencode(as.character(value))}"))
    }
    return(NULL)
  }) %>% purrr::compact() %>% unlist()

  # Handle 'GridRef' separately if it's not NULL or NA
  if (!is.null(GridRef) && !all(is.na(GridRef))) {
    grid_ref_json <- jsonlite$toJSON(GridRef, auto_unbox = TRUE)
    query_params <- c(query_params, glue::glue("GridRef={utils::URLencode(grid_ref_json)}"))
  }

  # Construct the full URL
  url <- glue::glue("{base_url}?{paste(query_params, collapse = '&')}")

  # Encode Unique key
  unique_key <- openssl$md5(url)

  # Perform the API request
  response <- httr2$request(url) |>
    httr2$req_headers(
      'Cache-Control' = 'no-cache',
      'Ocp-Apim-Subscription-Key' = Sys.getenv("RSM_API_KEY")
    ) |>
    httr2$req_method("GET") |>
    httr2$req_perform()

  # Handle potential errors
  if (httr2$resp_is_error(response)) {
    logger$log_error(glue$glue("API request failed: {httr2::resp_status_desc(response)}"))
    return(NULL)
  }

  # Log the status code of the request
  status_code <- httr2$resp_status(response)
  logger$log_info(glue::glue("API request status code: {status_code}"))

  # Parse the JSON response
  if (status_code == 200) {
    parsed_response <- httr2$resp_body_json(response)

    # Validate the response structure
    expected_fields <- c("licenceID", "licenceNumber", "licensee", "channel", "frequency",
                         "location", "gridRefDefault", "gridReference", "licenceType",
                         "status", "txrx", "suppressed")

    if (length(parsed_response) > 0 && is.list(parsed_response[[1]]) &&
        !all(expected_fields %in% names(parsed_response[[1]]))) {
      logger$log_warn("API response does not match expected structure")
    }

    # Save the JSON to a file
    json_filename <- glue$glue("data/licence_page/{unique_key}_{Sys.Date()}_{page}.json")
    jsonlite$write_json(parsed_response, path = json_filename, pretty = TRUE)

    logger$log_info(glue::glue("Page {page} was saved to {json_filename}"))
    # Return the parsed response
    return(parsed_response)
  } else {
    # Log the error and return NULL if the request failed
    logger$log_error(glue::glue("API request failed with status code: {status_code}"))
    return(NULL)
  }
}
