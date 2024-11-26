#' Build Schedule and Fetch First Page of Licence Data
#'
#' This function creates a date table for a given date range, generates a schedule
#' for API calls, and fetches the first page of licence data for each hour.
#'
#' @param control_table_path Character. Path to the control table CSV file.
#'
#' @return Updated control table as a tibble.
#'
#' @export
#'
#' @importFrom box use
#' @importFrom dplyr mutate lead filter bind_rows
#' @importFrom purrr map2_dfr
#' @importFrom readr read_csv write_csv
#' @importFrom tibble tibble
#' @importFrom lubridate floor_date ceiling_date
#' @importFrom glue glue
build_schedule_and_fetch_data <- function(control_table_path = "data/page/control_table.csv") {
    box::use(dplyr = dplyr[arrange,inner_join,mutate, n, lead, filter, bind_rows,distinct,select,ungroup,group_by,pull])
    box::use(purrr = purrr[map2_dfr,reduce,map])
    box::use(readr = readr[read_csv, write_csv])
    box::use(tibble = tibble[tibble])
    box::use(lubridate = lubridate[floor_date, ceiling_date, as_datetime])
    box::use(glue = glue[glue])
    source("R/03_get_metadata.R")
    source("R/06_get_licence_page_data_by_url.R")
    source("R/07_page_2_to_n.R")
    source("R/08_construct_url2.R")
    source("R/02_gen_ctrl_entry.R")

  # source("R/08_construct_url2.R")

  # Read the existing control table
  if (file.exists(control_table_path)) {
    existing_control_table <-
      readr::read_csv(control_table_path) |>
      # janitor::clean_names(case = "small_camel") |>
      # mutate(path = paste0("data/page/",uniqueKey,".json")) |>
      mutate(uniqueKey = openssl::md5(url)) |>
      mutate(fromDate = as.Date(fromDate)) |>
      mutate(toDate = as.Date(toDate)) |>
      distinct()
  } else {
    existing_control_table <-
      tibble::tibble(
      uniqueKey = openssl::md5(x = "delete"),
      path = NA_character_,
      url = NA_character_,
      createdAt = Sys.Date(),
      page = NA_integer_,
      sortBy = NA_character_,
      sortOrder = NA_character_,
      txRx = NA_character_,
      licenceDateType = NA_character_,
      fromDate = Sys.Date(),
      toDate = Sys.Date(),
      gridRefDefault = NA_character_,
      fromFrequency = NA_real_,
      toFrequency = NA_real_,
      licenceStatus = NA_character_,
      totalPages = NA_integer_,
      totalItems = NA_integer_,
      statusCode = NA_integer_) |>
      filter(uniqueKey != "099af53f601532dbd31e0ea99ffdeb64")
  }
  ### **2. Determining the Date Range for New Entries**
  # We can use the `createdAt` from the existing control table or the files
  # themselves to determine when the process was last run.
  # Determine the latest date from the existing control table
  if (nrow(existing_control_table) > 0) {
    last_run_time <- max(existing_control_table$createdAt, na.rm = TRUE)
  } else {
    # If no existing entries, use a default start date
    last_run_time <- as.POSIXct(Sys.time() - lubridate::days(1), tz = "UTC")
  }
  # Define the new date range starting from the last run time
  start_date <- format(last_run_time, "%Y-%m-%d")
  # Up to the current time
  end_date <- format(Sys.Date(), "%Y-%m-%d")  # Up to the current time
  ### **3. Initializing All Parameters with `NA`**
  ### We will create a list of all possible parameters, initializing them with `NA`, and then update them as needed.
  append_ctrl_tbl <-
    gen_ctrl_entry(fromDate = start_date,toDate = end_date)

  if (file.exists(control_table_path)) {
  existing_control_table |>
    bind_rows(append_ctrl_tbl) |>
    distinct() |>
    write_csv(control_table_path)
  } else {
    # If no existing entries, use a default start date
    append_ctrl_tbl |>
      distinct() |>
      write_csv(control_table_path)
  }


  control_table <-
    read_csv(control_table_path)

  get_last_url_vec <-
    control_table |>
    filter(is.na(statusCode)) |>
    select(-createdAt) |>
    distinct() |>
    pull(url)

  get_last_path_vec <-
    control_table |>
    filter(is.na(statusCode)) |>
    select(-createdAt) |>
    distinct() |>
    pull(path)

  map(.x = get_last_url_vec, .f = ~get_licence_page_data_by_url(url = .x))


  meta_data <- purrr::map(.x = get_last_path_vec,.f = ~get_metadata(path_var = .x)) |>
    reduce(bind_rows)

  control_table |>
    filter(is.na(statusCode)) |>
    select(-totalItems,-totalPages,-statusCode) |>
    inner_join(meta_data,by = "path") |>
    bind_rows(control_table |> filter(!is.na(statusCode))) |>
    arrange(desc(createdAt)) |>
    group_by(uniqueKey,fromDate) |>
    mutate(index = 1:n()) |>
    filter(index == min(index)) |>
    select(-index) |>
    ungroup() |>
    distinct() |>
    write_csv(control_table_path)

  code <-
    readr::read_csv(control_table_path) |>
    janitor::clean_names(case = "small_camel") |>
    mutate(uniqueKey = openssl::md5(url))
  ## add page 2,3,5...


return(code)
}
