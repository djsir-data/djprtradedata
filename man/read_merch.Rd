% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_merch.R
\name{read_merch}
\alias{read_merch}
\title{Download merchandise exports data}
\usage{
read_merch(
  path = tempdir(),
  max_date = Sys.Date(),
  min_date = max_date - 180,
  check_local = TRUE,
  merch_lookup = create_merch_lookup()
)
}
\arguments{
\item{path}{Path to directory where XML files should be stored}

\item{max_date}{The maximum date to include in your data}

\item{min_date}{The minimum date to include in your data}

\item{check_local}{Logical. Check if a local version of the requested data is
available at the \code{path} location; if present it will be loaded.}

\item{merch_lookup}{A list of tibbles containing short and long versions
of various data entries; see \code{create_merch_lookup()}.}
}
\value{
A tibble containing merchandise export data
}
\description{
Obtains merchandise exports data from ABS.Stat
(\url{https://stat.data.abs.gov.au/index.aspx?DatasetCode=MERCH_EXP}).
}
\details{
The ABS will not supply data frames of over 1m rows using the
ABS.Stat API. For this reason, you cannot download more than 1 year at a
time worth of data using this function, as this is around the point at which
the 1m row limit is reached.
}
\examples{
read_merch()
}
