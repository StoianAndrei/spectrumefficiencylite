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
