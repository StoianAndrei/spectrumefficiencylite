#' This retrieves a licences based on the given licence Id
#' Search the Register of Radio Frequencies and return matching licences.
#'
#' @param licenceId Integer. Format - integer. The ID of the Licence to be retrieved.
#' @param gridRefDefault Character. Grid Reference format, user defined or default.
#' @param engineerDecisionIAgree Logical. 1 for agree to not divulge records that are withheld from the public, 0 to disagree.
#' @return List containing API response data
#' @export
get_rsm_licence_data <- function(licenceId = NULL,gridRefDefault = "LAT_LONG_NZGD2000_D2000",engineerDecisionIAgree = NULL) {
  box::use(glue = glue[glue])
  box::use(jsonlite = jsonlite[toJSON,write_json])
  box::use(httr2 = httr2[request,req_method,req_perform,resp_is_error,resp_body_json,resp_status])
  box::use(logger = logger[log_error,log_info,log_warn])

  # Build the API URL
  base_url <- if(!is.null(licenceId)) {glue$glue("https://api.business.govt.nz/gateway/radio-spectrum-management/v1/licences/{licenceId}")
    } else {
  # Log the error and return NULL if the request failed
  logger$log_error(glue$glue("A licenceId must be supplied for this API request."))
  return(NULL)
}

  # Construct the query string
  query_params <- c(
    glue$glue("gridRefDefault={gridRefDefault}"),
    if(!is.null(engineerDecisionIAgree)) glue$glue("engineerDecisionIAgree={engineerDecisionIAgree}")
  )
  # Construct the full URL
  url <- glue$glue("{base_url}?{paste(query_params, collapse = '&')}")


  # Perform the API request
  response <- httr2$request(base_url) |>
    httr2$req_headers(
      'Cache-Control' = 'no-cache',
      'Ocp-Apim-Subscription-Key' = Sys.getenv("RSM_API_KEY")
    ) |>
    httr2$req_method("GET") |>
    httr2$req_perform()

  # Handle potential errors
  if (httr2$resp_is_error(response)) {
    logger$log_error(glue$glue("API request failed: {resp_status_desc(response)}"))
    return(NULL)
  }

  # Log the status code of the request
  status_code <- httr2$resp_status(response)
  logger$log_info(glue$glue("API request status code: {status_code}"))

  # Check if the request was successful
  if (status_code == 200) {
    # Parse the JSON response
    parsed_response <- httr2$resp_body_json(response)


    # Save the JSON to a file
    json_filename <- glue$glue("data/licences/{licenceId}.json")
    jsonlite$write_json(parsed_response, path = json_filename, pretty = TRUE)

    logger$log_info(glue$glue("Data for licence {licenceId} saved to {json_filename}"))
    # Return the parsed response
    return(parsed_response)
  } else {
    # Log the error and return NULL if the request failed
    logger$log_error(glue("API request failed with status code: {status_code} for licence {licenceId}"))
    return(NULL)
  }

}
