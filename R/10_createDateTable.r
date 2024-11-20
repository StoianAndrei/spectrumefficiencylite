#' 1. Create the Date Dimension Table**
#' This function generates a `dim_datetime_table` which includes dates at an
#' hourly interval.
#' This table will serve as the basis for generating `fromDate` and `toDate`
#' values for our API calls. Code to Create the
#' Date Dimension Table**
#' @param fromDate POSIXct The data time for start of date time hour. Format yyyy-mm-dd hh:00:00
#' @param toDate POSIXct The data time for end of date time hour. Format yyyy-mm-dd hh:00:00
#'
#' @return Tibble.
#'
#' @export
#'
#' @examples
#' create_date_table(fromDate = "2024-10-21 12:00:00", toDate = "2025-01-21 13:00:00")
#'
#' @importFrom box use
#' @importFrom lubridate wday,week,isoweek,year,yday,quarter,month,mday,isoyear,floor_date
#' @importFrom tibble tibble
createDateTable <- function(fromDate, toDate) {
  box::use(lubridate = lubridate[wday, week, isoweek, year, yday, quarter, month, mday, isoyear, floor_date, dst])
  box::use(tibble = tibble[tibble])
  box::use(dplyr = dplyr[mutate,select,case_when])
  # Generate a sequence of dates at hourly intervals
  Dates <- seq(
    from = as.POSIXct(fromDate, tz = "UTC"),
    to = as.POSIXct(toDate, tz = "UTC"),
    by = "hour"
  )

  # Create a data frame with the date sequence
  dateTable <- tibble$tibble(Dates)

  # Add comprehensive date attributes
  dateTable <- dateTable |>
    mutate(
      dateId = format(Dates, "%Y%m%d%H"), # Unique ID for each hour
      date = Dates,
      monthName = factor(format(Dates, "%b"), levels = month.abb),
      weekdayName = factor(lubridate$wday(Dates, label = TRUE), levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")),
      weekdayNameFull = factor(lubridate$wday(Dates, label = TRUE, abbr = FALSE), levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")),
      weekdayId = lubridate$wday(Dates),
      dayOfWeek = as.integer(lubridate$wday(Dates)),
      hourOfDay = as.integer(format(Dates, "%H")),
      year = lubridate$year(Dates),
      fiscalYear = year + ifelse(test = lubridate$month(Dates) > 6, yes = 1, no = 0), # Assuming fiscal year ends in June
      fiscalQuarter = paste0("Q", ifelse(lubridate$month(Dates) <= 6, lubridate$quarter(Dates), lubridate$quarter(Dates) - 2 + 1)),
      fiscalWeek = ceiling((lubridate$yday(Dates) - 1) / 7),
      monthId = lubridate$month(Dates),
      monthDay = lubridate$mday(Dates),
      isoYear = lubridate$isoyear(Dates),
      week = lubridate$week(Dates),
      isoWeek = lubridate$isoweek(Dates),
      isoWeekYear = paste(lubridate$isoyear(Dates), lubridate$isoweek(Dates), sep = "-"),
      quarter = paste0("Q", lubridate$quarter(Dates)),
      quarterDay = lubridate$yday(Dates) - lubridate$yday(floor_date(Dates, "quarter")) + 1,
      yearDay = lubridate$yday(Dates),
      weekend = lubridate$wday(Dates) %in% c(1, 7),
      season = factor(case_when(
        lubridate$month(Dates) %in% c(12, 1, 2) ~ "Winter",
        lubridate$month(Dates) %in% c(3, 4, 5) ~ "Spring",
        lubridate$month(Dates) %in% c(6, 7, 8) ~ "Summer",
        TRUE ~ "Fall"
      )),
      isDST = lubridate$dst(Dates),
      isMonthStart = lubridate$mday(Dates) == 1,
      isMonthEnd = lubridate$mday(Dates) == lubridate$days_in_month(Dates),
      isQuarterStart = lubridate$month(Dates) %% 3 == 1 & mday(Dates) == 1,
      isQuarterEnd = lubridate$month(Dates) %% 3 == 0 & mday(Dates) == lubridate$days_in_month(Dates),
      isYearStart = lubridate$month(Dates) == 1 & mday(Dates) == 1,
      isYearEnd = lubridate$month(Dates) == 12 & mday(Dates) == 31,
      isBusinessDay = !weekend
    ) |>
    select(
      dateId, date, monthName, weekdayName, weekdayNameFull, weekdayId, dayOfWeek, hourOfDay,
      year, fiscalYear, fiscalQuarter, fiscalWeek, monthId, monthDay, isoYear, week,
      isoWeek, isoWeekYear, quarter, quarterDay, yearDay, season, weekend, isDST,
      isMonthStart, isMonthEnd, isQuarterStart, isQuarterEnd, isYearStart, isYearEnd,
      isBusinessDay
    )

  return(dateTable)
}
