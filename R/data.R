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
#'   \item{month}{Month of observation, integer}
#'   \item{day}{Day of observation, integer}
#'   \item{tavg}{Observed temperature (monthly average), numeric}
#'   \item{ppt}{Observed precipitation (monthly sum), numeric}
#'   \item{lat}{Latitude of station, decimal degrees}
#'   \item{lon}{Longitude of station, decimal degrees}
#'   \item{elev}{Elevation of station, meters}
#'   \item{state}{State station is in, US state code string}
#'   \item{station_name}{Unique name of station, string}
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
#'   \item{elev}{Elevation of station, meters}
#'   \item{state}{State station is in, US state code string}
#'   \item{station_name}{Unique name of station, string}
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
#'   \item{month}{Month of observation, integer}
#'   \item{day}{Day of observation, integer}
#'   \item{lat}{Latitude of station, decimal degrees}
#'   \item{lon}{Longitude of station, decimal degrees}
#'   \item{elev}{Elevation of station, meters}
#'   \item{state}{State station is in, US state code string}
#'   \item{station_name}{Unique name of station, string}
#'   \item{tavg}{Average monthly air temperature, Celsius}
#'   \item{prcp}{Monthly precipitation sum, millimeters}
#'   \item{pet_tho}{Average monthly Thornthwaite potential evapotranspiration, millimeters}
#'   \item{spei12mo}{12-month SPEI value, std deviation units}
#'   \item{sc_pdsi}{Self-calibrating PDSI value, units?}
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
#' \item{year}{Year of observation, integer}
#' \item{month}{Month of observation, integer}
#' \item{sitename}{NPP site identifier code, 4-letter string}
#' \item{ppt}{Monthly precipitation sum, millimeters}
#' \item{tavg}{Average monthly air temperature, Celsius}
#' \item{tmin}{Maximum monthly air temperature, Celsius}
#' \item{tmax}{Minimum monthly air temperature, Celsius}
#' \item{rhavg}{Average monthly relative humidity, percent}
#' \item{rhmin}{Maximum monthly relative humidity, percent}
#' \item{rhmax}{Minimum monthly relative humidity, percent}
#' \item{vpdavg}{Average monthly vapor pressure deficit, kilopascals}
#' \item{vpdmin}{Maximum monthly vapor pressure deficit, kilopascals}
#' \item{vpdmax}{Minimum monthly vapor pressure deficit, kilopascals}
#' \item{pet_tho}{Average monthly Thornthwaite potential evapotranspiration, millimeters}
#' \item{spei12mo}{12-month SPEI value, std deviation units}
#' }
#' @source \describe{Derived from published EDI datasets and the
#' derive104_jornada_npp.R file}
"jrn_npp_derived"
