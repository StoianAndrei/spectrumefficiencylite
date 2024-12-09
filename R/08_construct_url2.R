#' Construct URL for Radio Spectrum Management API
#'
#' This function builds a URL for querying the Radio Spectrum Management API from the New Zealand Government.
#' It handles multiple query parameters and properly encodes them for HTTP requests.
#'
#' @param page Integer. Page number for paginated results
#' @param pageSize Integer. Number of results per page
#' @param sortBy Character. Field to sort results by (default: "Licence ID")
#' @param sortOrder Character. Sort direction, either "asc" or "desc" (default: "desc")
#' @param search Character. Search term for filtering results
#' @param transmitlocation Character. Filter by transmit location
#' @param receivelocation Character. Filter by receive location
#' @param location Character. Filter by general location
#' @param district Character. Filter by district
#' @param callSign Character. Filter by call sign
#' @param channel Character. Filter by channel
#' @param txRx Character vector. Type of transmission, can be "TRN" and/or "RCV" (default: c("TRN", "RCV"))
#' @param LicenceDateType Character. Type of date to filter by (default: "LASTUPDATED_LU")
#' @param fromDate Character. Start date for date range filter (YYYY-MM-DD format)
#' @param toDate Character. End date for date range filter (YYYY-MM-DD format)
#' @param exactMatchFreq Numeric. Exact frequency to match
#' @param fromFrequency Numeric. Lower bound of frequency range
#' @param toFrequency Numeric. Upper bound of frequency range
#' @param eirp Numeric. Effective Isotropic Radiated Power filter
#' @param licenceStatus Character. Filter by licence status
#' @param licenceTypeCode Character. Filter by licence type code
#' @param managementRightId Character. Filter by management right ID
#' @param systemIdentifier Character. Filter by system identifier
#' @param certifiedBy Character. Filter by certifier
#' @param GridRef List. Geographic coordinates for spatial filtering
#' @param radius Numeric. Search radius when using GridRef
#' @param includeAssociatedLicences Logical. Whether to include associated licences
#' @param gridRefDefault Character. Default grid reference system (default: "LAT_LONG_NZGD2000_D2000")
#' @param engineerDecisionIAgree Logical. Engineer decision agreement flag
#'
#' @return Character string containing the constructed URL with encoded parameters
#'
#' @examples
#' \dontrun{
#' url <- construct_url2(
#'   page = 1,
#'   pageSize = 10,
#'   search = "test",
#'   fromDate = "2024-01-01",
#'   toDate = "2024-12-31"
#' )
#' }
#'
#' @importFrom box use
#' @importFrom glue glue
#' @importFrom jsonlite toJSON write_json
#' @importFrom httr2 request req_method req_perform resp_is_error resp_body_json resp_status resp_status_desc
#' @importFrom logger log_error log_info log_warn
#' @importFrom openssl md5
#' @importFrom purrr map compact
#'
#' @export
construct_url2 <- function(
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
  box::use(utils = utils[URLencode])

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
      return(glue::glue("{name}={URLencode(as.character(value))}"))
    }
    return(NULL)
  }) |> purrr::compact() |> unlist()

  # Handle 'GridRef' separately if it's not NULL or NA
  if (!is.null(GridRef) && !all(is.na(GridRef))) {
    grid_ref_json <- jsonlite$toJSON(GridRef, auto_unbox = TRUE)
    query_params <- c(query_params, glue::glue("GridRef={URLencode(grid_ref_json)}"))
  }

  # Construct the full URL
  url <- glue::glue("{base_url}?{paste(query_params, collapse = '&')}")
  return(url)
}
