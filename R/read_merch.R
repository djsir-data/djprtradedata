#' Download merchandise exports data
#'
#' Obtains merchandise exports data from ABS.Stat
#' (\url{https://stat.data.abs.gov.au/index.aspx?DatasetCode=MERCH_EXP}).
#'
#' @details The ABS will not supply data frames of over 1m rows using the
#' ABS.Stat API. For this reason, you cannot download more than 1 year at a
#' time worth of data using this function, as this is around the point at which
#' the 1m row limit is reached.
#' @param path Path to directory where XML files should be stored
#' @param min_date The minimum date to include in your data
#' @param max_date The maximum date to include in your data
#' @param check_local Check if a local version of the requested data is
#' available at the `path` location; if present it will be loaded.
#' @param merch_lookup A list of tibbles containing short and long versions
#' of various data entries; see `create_merch_lookup()`.
#' @examples
#' \dontrun{
#' read_merch()
#' }
#' @export
#' @return A tibble containing merchandise export data


read_merch <- function(path = tempdir(),
                       min_date = max_date - 180,
                       max_date = Sys.Date(),
                       check_local = TRUE,
                       merch_lookup = create_merch_lookup()) {
  if (max_date - min_date > 365) {
    stop("Cannot download more than 12 months worth of data at a time due to ABS limits.")
  }

  min_month <- format(min_date, "%Y-%m")
  max_month <- format(max_date, "%Y-%m")

  url <- paste0(
    "https://stat.data.abs.gov.au/restsdmx/sdmx.ashx/GetData/MERCH_EXP/-+2/all?startTime=",
    min_month,
    "&endTime=",
    max_month
  )

  file <- file.path(
    path,
    paste0("abs_merch_", min_month, "_", max_month, ".xml")
  )

  if (isFALSE(check_local) || !file.exists(file)) {
    message(
      "Downloading merchandise trade data from ", min_month, " to ",
      max_month
    )
    utils::download.file(
      url,
      file
    )
  } else {
    message("Loading merchandise trade from local file:\n", file)
  }

  safely_read_sdmx <- purrr::safely(readsdmx::read_sdmx)

  merch <- safely_read_sdmx(file)

  if (is.null(merch$error)) {
    merch <- merch$result %>%
      dplyr::as_tibble()
  } else {
    # If file did not load, try again by loading straight from URL
    merch <- readsdmx::read_sdmx(url)
  }

  names(merch) <- tolower(names(merch))

  merch <- merch %>%
    dplyr::select(.data$country,
      .data$industry,
      .data$sitc_rev3,
      .data$time,
      .data$region,
      value = .data$obsvalue
    )

  if (nrow(merch) == 1000000) {
    warning(
      "The ABS has supplied a dataframe with exactly 1,000,000 rows, which suggests your request is too big and has been truncated."
    )
  }

  merch <- merch %>%
    dplyr::mutate(
      value = as.numeric(.data$value),
      unit = "000s"
    )

  merch <- suppressMessages(
    purrr::reduce(
      .x = c(list(merch), merch_lookup),
      .f = dplyr::left_join
    )
  )

  merch <- merch %>%
    dplyr::mutate(date = lubridate::ymd(paste0(.data$time, "-01"))) %>%
    dplyr::select(.data$date,
      country_dest = .data$country_desc,
      industry = .data$industry_desc,
      sitc_rev3 = .data$sitc_rev3_desc,
      sitc_rev3_code = .data$sitc_rev3,
      origin = .data$region_desc,
      .data$unit
    )

  merch
}