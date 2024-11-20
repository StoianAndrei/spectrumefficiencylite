#' Generate Control Table Entries for a Date Range
#'
#' @param path_var Path where the json files to extract the top layer also know as meta data is located
#'
#' @return A tibble with one row per day in the date range, representing control table entries.
get_metadata <- function(path_var) {
  json_tbl <-
    jsonlite::fromJSON(path_var, flatten = TRUE)
  total_items <- purrr::pluck(json_tbl, "totalItems")
  total_pages <- purrr::pluck(json_tbl, "totalPages")

  code <- tibble::tibble(
    path = path_var,
    totalPages = total_pages,
    totalItems = total_items,
    statusCode = 200
  )
  return(code)
}
