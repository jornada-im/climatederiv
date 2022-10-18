############################################################################
#                EDI Fellowship : Jornada Basin LTER Project               #
#                             by: Brianda Hernandez Rosales                #
#                                                                          #
#   Derived SPEI metrics from the 15 NPP sites on the Jornada Basin using  #
#   precipitation and temperature data. Script downloaded from G. Maurer   #
#   All 15 NPP sites are included and used to calculate SPEI and min, max, #
#   and average vapor pressure deficit.                                    #
############################################################################

utils::globalVariables(c("Date","Year","Month","Ppt_mm_Tot","Air_TempC_Max",
                         "Air_TempC_Min","Air_TempC_Avg", "Relative_Humidity_Max",
                         "Relative_Humidity_Min","Relative_Humidity_Avg",
                         "VPD_Avg","tavg","tmax","sitename","everything"))

#' Create (and write) dataset 202 - climate metrics for the 15 Jornada NPP sites
#'
#' Note that there is some checking for missing values in monthly data and
#' removal of NaN/Inf values, but SPEI still gets calculated.
#'
#' @param fname Name of the file to write if dest_path != NULL
#' @param dest_path Path to write fname to. No file written if NULL (default)
#' @returns A dataframe with derived data
#' @export
derive202 <- function(fname='jrn_npp_derived.csv', dest_path=NULL){

  # Get daily data for grassland, creosote, and mesquite NPP sites at JRN
  sites <- c('C-CALI','C-GRAV','C-SAND','G-BASN','G-IBPE','G-SUMM','M-NORT','M-RABB','M-WELL','P-COLL','P-SMAL',
             'P-TOBO', 'T-EAST','T-TAYL', 'T-WEST')
  # These are the package IDs for daily data from each site on EDI
  pkgids <- c(210437046, 210437047, 210437048, 210437049, 210437050, 210437051, 210437052, 210437053, 210437054,
              210437055, 210437056, 210437057, 210437058, 210437059, 210437060 )

  # Creating a list of dataframes loaded from EDI
  df_list <- list()
  for (s in 1:length(sites)){
    df <- from_edi(pkgids[s], 0, scope='knb-lter-jrn', skip=3)
    df_list[[s]] <- df
  }

  # Assign site names to the list
  names(df_list) <- sites

  # What do the variables and data look like?
  print(names(df_list$`G-BASN`))
  #head(df_list$`G-BASN`)

  # Package used to calculate vapor pressure deficit (was used for testing)
  #library(plantecophys)

  # Calculate vapor pressure deficit (vpd) where:
  #svp is saturation vapor pressure
  #avp is actual vapor pressure
  # vpd = svp - avp

  # Calculating Vapor Pressure Deficit using the the plantecophys package
  #vpdavg <-RHtoVPD(rhavg, tavg, Pa=101)  # Average VPD
  #vpdmin <- RHtoVPD(rhmin, tmin, Pa=101) # Minimum VPD
  #vpdmax <- RHtoVPD(rhmax, tmax, Pa=101) # Maximum VPD

  # Calculate Average Vapor Pressure Deficit using a function
  get.svp <- function(temp, rh){
    svp <-0.6108*exp(17.27*temp/(temp+237.3))
    return(svp)
  }

  get.vpd <- function(temp, rh){
    svp <-get.svp(temp)      # calculate svp
    vpd <-((100-rh)/100)*svp # calculate avp
    return(vpd)
  }


  # Function to convert daily to monthly data and calculate SPEI
  # Calculate monthly temp and precip
  monthly_derived <- function(df, sitename, latitude=32.6169){

    # Get VPD for average daily temperatures and humidity.
    # Not really possible to determine max/min VPD since its a composite of
    # 2 variables at different phases
    df['VPD_Avg'] <- get.vpd(temp=df$Air_TempC_Avg, rh=df$Relative_Humidity_Avg)


    # Convert to monthly data
    dfm <- df %>% dplyr::mutate(
      Month = lubridate::month(Date)) %>%
      dplyr::group_by(Year, Month) %>%
      dplyr::summarize(ppt = sum(Ppt_mm_Tot, na.rm=T),  # note the NA remove
                       tavg = mean(Air_TempC_Avg, na.rm=T), #note the NA remove
                       tmin = min(Air_TempC_Min, na.rm=T),
                       tmax = max(Air_TempC_Max, na.rm=T),
                       rhavg= mean(Relative_Humidity_Avg, na.rm=T),
                       rhmin = min(Relative_Humidity_Min, na.rm=T),
                       rhmax = max(Relative_Humidity_Max, na.rm=T),
                       vpdavg= mean(VPD_Avg, na.rm=T),
                       vpdmin = min(VPD_Avg, na.rm=T),
                       vpdmax = max(VPD_Avg, na.rm=T)) # note the NA remove


    # Make NaN values = NA
    # At some site/month/variable combinations in a dataset, there are no non-NA
    # values. Calculating the mean with na.rm=T in these cases gives NaN, and
    # min.max give Inf values, which leads to problems later on. Change the NaNs
    # and Infs to NA.
    # *NOTE* SPEI package is continuing to calculate SPEI values for monthly temperature
    # data with NA values. It is belived that SPEI is interpolating due to 12-month
    # SPEI time scale longer than missing data. This should be revisited.
    dfm <- dfm %>% dplyr::mutate(dplyr::across(tavg:vpdmax,
                                               ~replace(., is.nan(.), NA)),
                             dplyr::across(tavg:vpdmax,
                                           ~replace(., is.infinite(.), NA)))
    dfm$ppt[is.na(dfm$tavg)] <- NA

    # SPEI can throw errors
    tryCatch({
      pet <- SPEI::thornthwaite(dfm$tavg, latitude, na.rm=T)
      # Prepare datetime index
      dateidx <- zoo::as.yearmon(paste(dfm$Month, '/', dfm$Year, sep=''), "%m/%Y")
      # Precip and PET timeseries
      prcp_xts <- xts::xts(dfm$ppt, order.by=dateidx)
      pet_xts <- xts::xts(as.numeric(pet), order.by=dateidx)
      # Climatic water differential
      cwdiff <- rclimtools::get_cwdiff(prcp_xts, pet_xts)

      # Now get 1year SPEI and extract values
      spei_12mo <- rclimtools::get_spei(cwdiff, scale=12, na.rm=T, locname=sitename)
      spei_xts <- xts::xts(as.vector(spei_12mo$fitted),  order.by=zoo::index(cwdiff))
      colnames(spei_xts) <- c('spei12mo')
      # Add PET & SPEI values
      dfm['pet_tho'] <- as.vector(pet_xts)
      dfm['spei12mo'] <- as.vector(spei_xts$spei12mo)
    },
    error=function(e){
      message('An Error Occurred')
      print(e)
    })

    # If we couldn't calculate SPEI, assign the column NA
    if (!('spei12mo' %in% names(dfm))){
      dfm['spei12mo'] <- NA
    }
    dfm['sitename'] <- sitename

    # Now return the monthly dataframe
    return(dfm)
  }

  # test
  test.s <- monthly_derived(df_list$`G-BASN`, 'BASN')

  # Now loop through all 9 sites, do conversions and SPEI calcs and then
  # bind into one big file.
  for (i in 1:length(sites)){
    print(i)
    site <- sites[i]
    print(site)
    df <- monthly_derived(df_list[[site]], substr(site, 3, 7))
    if (i==1){
      df_all <- df
    } else {
      df_all <- dplyr::bind_rows(df_all, df)
    }
  }

  # Export data to csv
  #write_csv(df_all, file = './derived_monthly_climate_spei_NPPsites.csv')

  # Import csv preciously written
  #npp.df <- read.csv('./derived_monthly_climate_spei_NPPsites.csv')

  # Package used to calculate vapor pressure deficit
  #library(plantecophys)

  # Calculate vapor pressure deficit (vpd) where:
  #svp is saturation vapor pressure
  #avp is actual vapor pressure
  # vpd = svp - avp

  # Calculating Vapor Pressure Deficit using the the plantecophys package
  #vpdavg <-RHtoVPD(rhavg, tavg, Pa=101)  # Average VPD
  #vpdmin <- RHtoVPD(rhmin, tmin, Pa=101) # Minimum VPD
  #vpdmax <- RHtoVPD(rhmax, tmax, Pa=101) # Maximum VPD


  #plot vpd against respective temperature
  plot(vpdavg~tavg, data=df_all, col="blue")
  plot(vpdmin~tmin, data=df_all, col="light blue")
  plot(vpdmax~tmax, data=df_all, col="dark blue")

  npp_out <- df_all %>% dplyr::select(year=Year, month=Month, sitename,
                                      everything())

  jrn_npp_derived <- npp_out

  # Write a csv if asked
  if(!is.null(dest_path)){
    fout = file.path(dest_path, fname)
    print(paste0('Writing ', fout))
    readr::write_csv(jrn_npp_derived, fout)
  }
  return(jrn_npp_derived)
}


#' Update the Jornada NPP DERIVED dataset
#'
#' Update the package dataset `data/jrn_NPP_derived.rda`. This is not
#' exported so use `devtools::load_all()` to access.
#'
#' @param new_derived New dataset 202 to replace `jrn_npp_derived.rda`
#' @returns A new rda file in 'data/'
dev_save_202 <- function(new_derived){
  #Get the current rda file
  jrn_npp_derived_archive <- jrn_npp_derived
  # Create the path for the archive
  lastdate <- paste(jrn_npp_derived_archive[nrow(jrn_npp_derived_archive),'year'],
                    jrn_npp_derived_archive[nrow(jrn_npp_derived_archive),'month'],
                    sep="-")
  archive_fpath <- paste0('data/jrn_npp_derived_', lastdate, '.rda')
  # Save earlier data version to archive path
  message("Archiving previous data file to '", archive_fpath, "'")
  save(jrn_npp_derived_archive, file=archive_fpath)
  # Overwrite with the new file
  message('Writing new file...')
  jrn_npp_derived <- new_derived
  save(jrn_npp_derived, file='data/jrn_npp_derived.rda')
}
