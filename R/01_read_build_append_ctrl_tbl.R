library(dplyr)
library(readr)
library(tidyverse)
library(openssl)

### **1. Reading and Preserving the Existing Control Table**

### First, we need to read the existing control table and ensure that all previous parameters are preserved.

control_table_path <-  "data/page/control_table.csv"

# Read the existing control table
if (file.exists(control_table_path)) {
  existing_control_table <-
    readr::read_csv(control_table_path) |>
    janitor::clean_names(case = "small_camel") |>
    mutate(path = paste0("data/page/",uniqueKey,".json")) |>
    mutate(uniqueKey = openssl::md5(url)) |>
    mutate(fromDate = as.Date(fromDate)) |>
    mutate(toDate = as.Date(toDate)) |>
    distinct()
} else {
  existing_control_table <- tibble::tibble()
}


### **2. Determining the Date Range for New Entries**
# We can use the `createdAt` from the existing control table or the files themselves to determine when the process was last run.
# Determine the latest date from the existing control table

if (nrow(existing_control_table) > 0) {
  last_run_time <- max(existing_control_table$createdAt, na.rm = TRUE)
} else {
  # If no existing entries, use a default start date
  last_run_time <- as.POSIXct("2024-01-01 12:00:00", tz = "UTC")
}



# Define the new date range starting from the last run time
start_date <- format(last_run_time, "%Y-%m-%d")
 # Up to the current time
end_date <- format(Sys.Date(), "%Y-%m-%d")  # Up to the current time

### **3. Initializing All Parameters with `NA`**
### We will create a list of all possible parameters, initializing them with `NA`, and then update them as needed.
source("R/02_gen_ctrl_entry.R")
source("R/08_construct_url2.R")
source("R/03_get_metadata.R")

append_ctrl_tbl <-
  gen_ctrl_entry(fromDate = start_date,toDate = end_date)

existing_control_table |>
  bind_rows(append_ctrl_tbl) |>
  distinct() |>
  write_csv(control_table_path)

control_table <-
  read_csv(control_table_path)
source("R/06_get_licence_page_data_by_url.R")

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

source("R/07_page_2_to_n.R")
control_table <-
  readr::read_csv(control_table_path) |>
  janitor::clean_names(case = "small_camel") |>
  mutate(uniqueKey = openssl::md5(url))
## add page 2,3,5...

append_additional_pages(control_table ) |>
  write_csv(control_table_path)
