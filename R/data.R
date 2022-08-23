#' Long-term met data from 9 Chihuahuan desert USHCN weather stations
#'
#' A dataset containing stationids, names, location information, and time series
#' of temperature and precipitation data from the 9 USHCN stations located in
#' the northern Chihuahuan Desert (U.S.A. portion).
#'
#' @format A data frame with 28776 rows and 12 variables:
#' \describe{
#'   \item{stationid}{USHCN station identifier, unique alphanumeric}
#'   \item{date}{Date of observation, POSIXct}
#'   \item{year}{Year of observation, integer}
#'   ...
#' }
#' @source \url{https://www.ncei.noaa.gov/products/land-based-station/us-historical-climatology-network}
"ushcn_chihuahuan_data"


#' Station descriptors for 9 Chihuahuan desert USHCN weather stations
#'
#' Table of station id, names, and location information for the 9 USHCN stations
#' located in the northern Chihuahuan Desert (U.S.A. portion).
#'
#' @format A data frame with 9 rows and 6 variables:
#' \describe{
#'   \item{stationid}{USHCN station identifier, unique alphanumeric}
#'   \item{lat}{Latitude of station, decimal degrees}
#'   \item{lon}{Longitude of station, decimal degrees}
#'   ...
#' }
#' @source \url{https://www.ncei.noaa.gov/products/land-based-station/us-historical-climatology-network}
"ushcn_chihuahuan_stations"


#' Dataset 103 - Monthly derived climate metrics from 9 Chihuahuan desert USHCN
#' weather stations.
#'
#' A dataset containing stationids, names, location information, and time series
#' of met and derived climate indices (SPEI, scPDSI) for the 9 USHCN stations
#' located in the northern Chihuahuan Desert (U.S.A. portion).  Published to
#' EDI as Jornada dataset 103.
#'
#' @format A data frame with 11988 rows and 15 variables:
#' \describe{
#'   \item{stationid}{USHCN station identifier, unique alphanumeric}
#'   \item{date}{Date of observation, POSIXct}
#'   \item{year}{Year of observation, integer}
#'   ...
#' }
#' @source \describe{Derived from the ushcn_chihuahuan_data dataset and
#' derive103_ushcn_chihuahuan.R file}
"ushcn_chihuahuan_derived"


#' Dataset 104 - Monthly derived climate metrics from the 15 Jornada LTER NPP
#' weather stations.
#'
#' A dataset containing stationids, names, location information, and time series
#' of met and derived climate indices (SPEI, scPDSI) for the 15 weather
#' stations in the Jornada Basin (southern New Mexico, U.S.A.) that are
#' associated with the long-term NPP study. Published to EDI as Jornada dataset
#'104.
#'
#' @format A data frame with 1513 rows and 15 variables:
#' \describe{
#'   \item{year}{Year of observation, integer}
#'   \item{month}{Month of observation, integer}
#'   \item{sitename}{NPP site identifier code, 4-letter string}
#'   ...
#' }
#' @source \describe{Derived from published EDI datasets and the
#' derive104_jornada_npp.R file}
"jrn_npp_derived"
