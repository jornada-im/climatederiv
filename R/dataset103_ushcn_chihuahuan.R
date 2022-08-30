############################################################################
#                EDI Fellowship : Jornada Basin LTER Project               #
#                             by: Bri Hernandez                            #
#                                                                          #
#   Derive SPEI and scpdsi metrics from the USHCN data of the Chihuahuan   #
#   Desert. Drought indices will be compared. Focus on the JER, SOCORRO,   #
#   EL PASO, LOS LUNAS, GAGE, STATE UNIV, ELEPHANT BUTTE DAM, TULAROSA,    #
#   OROGRANDE                                                              #
#                                                                          #
#                                                                          #
############################################################################

utils::globalVariables(c("data","ushcn_chihuahuan_data","stationid","variable",
                         "station_name","ushcn_chihuahuan_derived","sc_pdsi",
                         "spei12mo","station_name"))

#' Create (and write) dataset 103 - climate metrics for 9 Chihuahuan desert
#' USHCN sites
#'
#' @param fname Name of the file to write if dest_path != NULL
#' @param dest_path Path to write fname to. No file written if NULL (default)
#' @returns A dataframe with derived data
#' @export
derive103 <- function(fname='ushcn_chihuahuan_derived.csv', dest_path=NULL){

  # Get the dataset
  raw <- ushcn_chihuahuan_data
  #fname <- './data-raw/ChihuahuanDesert_9_USHCN_dataset.csv'   # data set has all 9 sites
  #raw <- readr::read_csv(fname, na=c('', 'NaN', 'NA'))
  #head(raw)
  #tail(raw)

  stn <- unique(raw$stationid)
  stn

  # Check start date for stations
  raw %>% dplyr::group_by(stationid) %>%
    dplyr::summarize(start = min(date))

  # Loop through each station and calculate PET, SPEI and PDSI
  for (i in 1:length(stn)) {

    ## Subset the main dataset and calculate PET
    stndf <- subset(raw, stationid==stn[i] & date > '1910-12-31') # For cross-raw, limit to 1999 forward
    tavg <- subset(stndf, variable=='tavg')
    prcp <- subset(stndf, variable=='prcp')
    pet <- SPEI::thornthwaite(tavg$value, unique(tavg$lat))
    # Prepare datetime index
    tavg$month <- lubridate::month(tavg$date)
    dateidx <- zoo::as.yearmon(paste(tavg$month, '/', tavg$year, sep=''), "%m/%Y")
    # Precip and PET timeseries
    prcp_xts <- xts::xts(prcp$value, order.by=dateidx)
    pet_xts <- xts::xts(as.numeric(pet), order.by=dateidx)

    # Get spei tools, if not already installed use:
    # devtools::install_github("gremau/rclimtools")
    ## Climatic water differential
    cwdiff <- rclimtools::get_cwdiff(prcp_xts, pet_xts)

    ## Now get 1year SPEI and extract values
    spei_12mo <- rclimtools::get_spei(cwdiff, scale=12,
                                      locname=unique(stndf$station_name))
    spei_xts <- xts::xts(as.vector(spei_12mo$fitted),
                         order.by=zoo::index(cwdiff))
    colnames(spei_xts) <- c('spei12mo')

    # Create a new dataframe (from tavg) and add SPEI values
    spei_raw <- tidyr::pivot_wider(stndf, names_from='variable')
    spei_raw['pet_tho'] <- as.vector(pet_xts)
    spei_raw['spei12mo'] <- as.vector(spei_xts$spei12mo)
    # Good for verification but not needed in final dat afile
    #spei_raw['spei_date'] <- zoo::index(spei_xts)

    #### Calculating scPDSI ####

    # Package needed to calculate sc-PDSI is in the CRAN archive:
    # https://cran.r-project.org/src/contrib/Archive/scPDSI/
    # scPDSI package information:
    # https://cran.microsoft.com/snapshot/2020-04-20/web/packages/scPDSI/index.html
    # Download version 1.3, unzip, and install with:
    # install.packages('path/to/scPDSI', repos=NULL, type="source")

    #library(scPDSI)
    pdsi <- scPDSI::pdsi(spei_raw$prcp, spei_raw$pet_tho, start = 1911,
                          sc = TRUE )
    summary(pdsi)

    # Add to raw spei file
    spei_raw['sc_pdsi'] <- as.vector(pdsi$X)

    # Concatenate spei_raw dataframes into 1
    if (i==1) {
      spei_out <- spei_raw
    } else {
      spei_out <- rbind(spei_out, spei_raw)
    }
  }
  # Arrange according to station name
  spei_out <- dplyr::arrange(spei_out, station_name)

  ushcn_chihuahuan_derived <- spei_out

  # Write a csv if asked
  if(!is.null(dest_path)){
    fout = file.path(dest_path, fname)
    print(paste0('Writing ', fout))
    readr::write_csv(ushcn_chihuahuan_derived, fout)
  }
  return(ushcn_chihuahuan_derived)
}


#' Make some plots of the 9-site Chihuahuan Desert USHCN dataset
#'
#' @param df The dataset to plot - ushcn_chihuahuan_derived is default
#' @returns Some plots of ushcn_chihuahuan_derived data
#' @export
plot_103 <- function(df=ushcn_chihuahuan_derived){

  #plot SPEI and PDSI
  colors = c('scPDSI' = "tomato", 'spei12mo' = 'blue')
  g1 <- ggplot2::ggplot(df, ggplot2::aes(x=date))+
    ggplot2::geom_line(ggplot2::aes(y = sc_pdsi, color = "scPDSI")) +
    ggplot2::geom_line(ggplot2::aes(y = spei12mo, color = 'spei12mo')) +
    ggplot2::scale_color_manual(values = colors) +
    ggplot2::labs(x = "Year", y = "Drought index value", color = "Legend") +
    ggplot2::facet_wrap(~station_name)
  print(g1)

  #plot spei and pdsi separately
  spei.plot <-ggplot2::ggplot(df, ggplot2::aes(x=date))+
    ggplot2::geom_line(ggplot2::aes(y= spei12mo, color=station_name), xlab="")+
    ggplot2::theme_classic() + ggplot2::guides(color='none')
  spei.plot

  pdsi.plot <- ggplot2::ggplot(df, ggplot2::aes(x=date))+
    ggplot2::geom_line(ggplot2::aes(y= sc_pdsi, color = station_name)) +
    ggplot2::theme_classic() + ggplot2::guides(color='none')
  pdsi.plot


  doublepanel <- cowplot::plot_grid(spei.plot, pdsi.plot,
                                    labels = c('A', 'B'), label_size = 12)
  print(doublepanel)

  return(list(plot1=g1, plot2=doublepanel))

}


#' Update the Chihuahuan Desert USHCN DERIVED dataset
#'
#' Update the package dataset `data/ushcn_chihuahuan_derived.rda`. This is not
#' exported so use `devtools::load_all()` to access.
#'
#' @param new_derived New dataset 103 to replace `ushcn_chihuahuan_derived.rda`
#' @returns A new rda file in data/
dev_save_103 <- function(new_derived){
  #Get the current rda file
  ushcn_chihuahuan_derived_archive <- ushcn_chihuahuan_derived
  # Create the path for the archive
  lastdate <- as.Date(max(ushcn_chihuahuan_derived_archive$date))
  archive_fpath <- paste0('data/ushcn_chihuahuan_derived_', lastdate, '.rda')
  # Save earlier data version to archive path
  message("Archiving previous data file to '", archive_fpath, "'")
  save(ushcn_chihuahuan_derived_archive, file=archive_fpath)
  # Overwrite with the new file
  message('Writing new file...')
  ushcn_chihuahuan_derived <- new_derived
  save(ushcn_chihuahuan_derived, file='data/ushcn_chihuahuan_derived.rda')
}




