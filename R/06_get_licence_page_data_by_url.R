get_licence_page_data_by_url <- function(url) {
  box::use(glue = glue[glue])
  box::use(jsonlite = jsonlite[toJSON,write_json])
  box::use(httr2 = httr2[request,req_method,req_perform,resp_is_error,resp_body_json,resp_status])
  box::use(logger = logger[log_error,log_info,log_warn])
  box::use(openssl = openssl[md5])


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
    logger$log_error(glue$glue("API request failed: {resp_status_desc(response)}"))
    return(NULL)
  }

  # Log the status code of the request
  status_code <- httr2$resp_status(response)
  log_info(glue("API request status code: {status_code}"))

  # Parse the JSON response
  # Check if the request was successful
  if (status_code == 200) {
    # Parse the JSON response
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
    json_filename <- glue$glue("data/page/{unique_key}.json")
    jsonlite$write_json(parsed_response, path = json_filename, pretty = TRUE)

    logger$log_info(glue("Unique key {unique_key} was saved to {json_filename}"))
    # Return the parsed response
    return(parsed_response)
  } else {
    # Log the error and return NULL if the request failed
    logger$log_error(glue("API request failed with status code: {status_code} for licence {licenceid}"))
    return(NULL)
  }

}
