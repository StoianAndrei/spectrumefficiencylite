#' Append Additional Pages to Control Table
#'
#' This function appends new rows to the control table for additional pages
#' (pages 2:totalPages) based on metadata.
#'
#' @param control_table The current control table to which new entries will be appended.
#' @return An updated control table with new entries for additional pages.
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
#'
append_additional_pages <- function(control_table) {
  # box::use(dplyr = dplyr[arrange,mutate, n, lead, filter, bind_rows,distinct,select,ungroup,group_by,rowwise])
  # box::use(purrr = purrr[map2_dfr])
  # box::use(readr = readr[read_csv, write_csv])
  # box::use(tibble = tibble[tibble])
  # box::use(lubridate = lubridate[floor_date, ceiling_date, as_datetime])
  # box::use(tidyr = tidyr[unnest])
  # box::use(glue = glue[glue])
  #
  #
  # # Filter metadata for rows where totalPages > 1
  # if (file.exists(control_table_path)) {
  # metadata_to_paginate <-
  #   control_table |>
  #   filter(createdAt >= Sys.Date() - lubridate::days(1) ) |>
  #   filter(page == 1)
  # } else {
  #   # If no existing entries, use a default start date
  #   metadata_to_paginate <-
  #     control_table |>
  #     filter(page == 1)
  # }
  #
  #
  # # Generate new entries for pages 2:totalPages
  # additional_entries <-
  #   metadata_to_paginate |>
  #   select(fromDate,toDate,totalPages) |>
  #   distinct() |>
  #   rowwise() |>
  #   mutate(
  #     # Generate a list of additional pages
  #     page_seq = list(2:totalPages)
  #   ) |>
  #   unnest(page_seq) |>
  #   select(-totalPages) |>
  #   unique() |>
  #   group_split(fromDate, toDate,page_seq) |>
  #   map(~ gen_ctrl_entry(
  #     fromDate = .x$fromDate,
  #     toDate = .x$toDate,
  #     page = .x$page_seq
  #   ))
  #
  # # Append the new entries to the control table
  # updated_control_table <- control_table |>
  #   bind_rows(additional_entries) |>
  #   arrange(desc(createdAt))
  #
  # return(updated_control_table)
  box::use(dplyr = dplyr[arrange, mutate, filter, bind_rows, distinct, select, ungroup, group_by, rowwise])
  box::use(purrr = purrr[map2_dfr])
  box::use(readr = readr[read_csv, write_csv])
  box::use(tibble = tibble[tibble])
  box::use(lubridate = lubridate[floor_date, ceiling_date, as_datetime])
  box::use(tidyr = tidyr[unnest])
  box::use(glue = glue[glue])

  # Filter metadata for rows where totalPages > 1
  metadata_to_paginate <- control_table %>%
    filter(page == 1 & totalPages > 1)

  # Generate new entries for pages 2:totalPages
  additional_entries <- metadata_to_paginate %>%
    rowwise() %>%
    mutate(page_seq = list(2:totalPages)) %>%
    unnest(page_seq) %>%
    mutate(
      fromDate = fromDate,
      toDate = toDate,
      page = page_seq,
      url = construct_url2(
        page = page_seq,
        sortBy = sortBy,
        sortOrder = sortOrder,
        txRx = txRx,
        LicenceDateType = licenceDateType,
        fromDate = as.character(fromDate),
        toDate = as.character(toDate),
        gridRefDefault = gridRefDefault
      ),
      uniqueKey = openssl::md5(url),
      path = glue("data/page/{uniqueKey}.json"),
      createdAt = Sys.time()
    ) %>%
    select(uniqueKey, path, url, createdAt, page, sortBy, sortOrder, txRx, licenceDateType, fromDate, toDate, gridRefDefault, fromFrequency, toFrequency, licenceStatus, totalPages, totalItems, statusCode)

  # Append the new entries to the control table
  updated_control_table <- control_table %>%
    bind_rows(additional_entries) %>%
    arrange(desc(createdAt))

  return(updated_control_table)
}
# }


