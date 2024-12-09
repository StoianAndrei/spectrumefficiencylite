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
append_new_and_fetch_data <- function(control_table_path) {
  box::use(dplyr = dplyr[arrange,inner_join,mutate, n, lead, filter, bind_rows,distinct,select,ungroup,group_by,pull])
  box::use(purrr = purrr[map2_dfr,reduce])
  box::use(readr = readr[read_csv, write_csv])
  box::use(tibble = tibble[tibble])
  box::use(lubridate = lubridate[floor_date, ceiling_date, as_datetime])
  box::use(glue = glue[glue])
  # box::use(./R/`02_gen_ctrl_entry`[gen_ctrl_entry])
  # box::use(./R/`03_get_metadata`[get_metadata])
  # box::use(./R/`06_get_licence_page_data_by_url`[get_licence_page_data_by_url])
  # box::use(./R/`07_page_2_to_n`[append_additional_pages])
  # box::use(./R/`08_construct_url2`[construct_url2])
  source("R/03_get_metadata.R")
  source("R/06_get_licence_page_data_by_url.R")
  source("R/07_page_2_to_n.R")
  source("R/08_construct_url2.R")
  source("R/02_gen_ctrl_entry.R")
  control_table <- read_csv("data/page/control_table.csv")|>
    mutate(uniqueKey = openssl::md5(url))
existing_path_vec <-
  fs::dir_info(path = "data/page/",type = "file",regexp = "\\.json") |>
    mutate(path = as.character(path)) |>
    select(path) |>
  pull(path)
code <-
append_additional_pages(control_table = control_table) |>
  mutate(path = as.character(path)) |>
  filter(!path %in% existing_path_vec)

get_last_url_vec <-
  code |>
  filter(is.na(statusCode)) |>
  select(-createdAt) |>
  distinct() |>
  pull(url)

get_last_path_vec <-
  code |>
  filter(is.na(statusCode)) |>
  select(-createdAt) |>
  distinct() |>
  pull(path)

map(.x = get_last_url_vec, .f = ~get_licence_page_data_by_url(url = .x))


meta_data <- purrr::map(.x = get_last_path_vec,.f = ~get_metadata(path_var = .x)) |>
  reduce(bind_rows)

code <-
  code |>
  filter(is.na(statusCode)) |>
  select(-totalItems,-totalPages,-statusCode) |>
  inner_join(meta_data,by = "path") |>
  bind_rows(code |> filter(!is.na(statusCode))) |>
  arrange(desc(createdAt)) |>
  group_by(uniqueKey,fromDate) |>
  mutate(index = 1:n()) |>
  filter(index == min(index)) |>
  select(-index) |>
  ungroup() |>
  distinct()

code |>
  write_csv(control_table_path)

return(code)
}
