library(jsonlite)
library(logger)
library(purrr)
library(tidyr)
library(glue)

# Function to safely extract and handle empty fields
safe_extract <- function(item, type = "character", default = NA) {
  if (is.null(item) || length(item) == 0) {
    return(default)
  }
  item_value <- item[[1]]
  # Ensure the item is cast to the specified type
  if (type == "character") {
    return(as.character(item_value))
  } else if (type == "integer") {
    return(as.integer(item_value))
  } else if (type == "numeric") {
    return(as.numeric(item_value))
  } else if (type == "logical") {
    return(as.logical(item_value))
  }
  return(item_value)
}

# Function to ensure missing columns are added with default values and column order is maintained
impose_structure <- function(data) {
  # Define the required column names and their order
  required_columns <- c("licenceID", "licenceNumber", "licensee", "channel",
                        "frequency", "location", "gridRefDefault",
                        "gridReference", "licenceType", "status",
                        "txrx", "suppressed")

  # Add any missing columns with default NA values
  for (col in required_columns) {
    if (!col %in% colnames(data)) {
      data <- tibble::add_column(data, !!col := list(NA), .before = 1)
    }
  }

  # Reorder columns to the specified order
  data <- data[, required_columns, drop = FALSE]

  return(data)
}

# Function to process a single JSON file
process_json_file <- function(json_file) {
  tryCatch({
    # Read the JSON file
    content <- fromJSON(json_file, flatten = TRUE)

    # Ensure all required columns are present and ordered in the data
    content$items <- impose_structure(as_tibble(content$items))

    # Process the data
    licence_info <- content$items %>%
      mutate(
        licenceID = map(licenceID, ~safe_extract(.x, "integer", NA_integer_)),
        licenceNumber = map(licenceNumber, ~safe_extract(.x, "character", NA_character_)),
        licensee = map(licensee, ~safe_extract(.x, "character", NA_character_)),
        channel = map(channel, ~safe_extract(.x, "character", NA_character_)),
        frequency = map(frequency, ~safe_extract(.x, "numeric", NA_real_)),
        location = map(location, ~safe_extract(.x, "character", NA_character_)),
        gridRefDefault = map(gridRefDefault, ~safe_extract(.x, "character", NA_character_)),
        gridReference = map(gridReference, ~safe_extract(.x, "character", NA_character_)),
        licenceType = map(licenceType, ~safe_extract(.x, "character", NA_character_)),
        status = map(status, ~safe_extract(.x, "character", NA_character_)),
        txrx = map(txrx, ~safe_extract(.x, "character", NA_character_)),
        suppressed = map(suppressed, ~safe_extract(.x, "logical", NA))
      ) %>%
    # Unnest all columns to flatten the lists
      unnest(cols = everything()) |>
      mutate(path = json_file) |>
      mutate(createdAt = Sys.Date())

    return(licence_info)

  }, error = function(e) {
    log_error(glue("Error processing file {json_file}: {e$message}"))
    return(NULL)
  })
}

# Example function to process all JSON files
process_all_licences <- function(json_files_path = "data/page") {
  json_files <- list.files(path = json_files_path, pattern = "*.json", full.names = TRUE,recursive = TRUE,)

  if (length(json_files) == 0) {
    log_warn(glue("No JSON files found in {json_files_path}"))
    return(NULL)
  }

  # Process all files and collect licence data
  all_licence_data <- map(.x = json_files,.f =  ~ process_json_file(json_file = .x))

  # Filter out null results and combine data
  valid_licence_data <- keep(all_licence_data, ~!is.null(.x))

  if (length(valid_licence_data) == 0) {
    log_warn("No valid licence data processed from JSON files")
    return(NULL)
  }
  combined_licence_data <-
    bind_rows(valid_licence_data) |>
    dplyr::mutate(licenceID = as.integer(licenceID)) |>
    dplyr::mutate(licenceNumber = as.integer(licenceNumber))


  existing_combined_licence_data <-
    readr::read_csv(file = "data/combined_licence_data.csv") |>
    dplyr::mutate(licenceID = as.integer(licenceID)) |>
    dplyr::mutate(licenceNumber = as.integer(licenceNumber))


  # Combine with existing control table without overwriting
  updated_control_table <-
    existing_combined_licence_data |>
    bind_rows(combined_licence_data) |>
    distinct()

  # Only write back if there are new entries to append
  if (nrow(combined_licence_data) > 0) {
    write_csv(combined_licence_data, "data/combined_licence_data.csv")
  }

  # Write combined licence data to CSV file
  log_info(glue("Processed {nrow(combined_licence_data)} licences"))

  return(combined_licence_data)
}




# Function to process metadata
process_file_metadata <- function(json_file) {
  tryCatch({
    content <- fromJSON(json_file, flatten = TRUE)

    # Extracting metadata from the file
    metadata <- tibble(
      pageSize = pluck(content, "pageSize", 1, .default = NA),
      page = pluck(content, "page", 1, .default = NA),
      totalItems = pluck(content, "totalItems", 1, .default = NA),
      totalPages = pluck(content, "totalPages", 1, .default = NA),
      sortBy = pluck(content, "sortBy", 1, .default = NA),
      sortOrder = pluck(content, "sortOrder", 1, .default = NA),
      path = json_file,
      uniqueKey = stringr::str_remove(stringr::str_remove(path,"data/page/"),"\\.json"),
      lastUpdated = Sys.time() # Capture when the API was processed
    )


    return(metadata)

  }, error = function(e) {
    log_error(glue("Error processing metadata from file {json_file}: {e$message}"))
    return(NULL)
  })
}
# Function to process metadata
process_all_metadata <- function(json_file) {
  tryCatch({
    json_files <- list.files(path = json_files_path, pattern = "*.json", full.names = TRUE,recursive = TRUE,)

    if (length(json_files) == 0) {
      log_warn(glue("No JSON files found in {json_files_path}"))
      return(NULL)
    }

    # Process all files and collect licence data
    all_metadata <- map(.x = json_files,.f =  ~ process_file_metadata(json_file = .x))

    # Filter out null results and combine data
    valid_metadata <- keep(all_metadata, ~!is.null(.x))

    if (length(valid_metadata) == 0) {
      log_warn("No valid licence data processed from JSON files")
      return(NULL)
    }
    combined_metadata <-
      bind_rows(valid_metadata)


    existing_combined_licence_data <-
      readr::read_csv(file = "data/combined_metadata.csv")


    # Combine with existing control table without overwriting
    updated_metadata <-
      existing_combined_licence_data |>
      bind_rows(combined_metadata) |>
      distinct() |>
      group_by(uniqueKey) |>
      mutate(index = 1:n()) |>
      filter(index == 1) |>
      select(-index)

    # Only write back if there are new entries to append
    if (nrow(combined_licence_data) > 0) {
      write_csv(combined_licence_data, "data/combined_licence_data.csv")
    }



    return(updated_metadata)

  }, error = function(e) {
    log_error(glue("Error processing metadata from file {json_file}: {e$message}"))
    return(NULL)
  })
}

# Example usage
process_all_licences("data/page/")
process_all_metadata("data/page/")
