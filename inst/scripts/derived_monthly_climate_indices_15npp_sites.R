############################################################################
#                EDI Fellowship : Jornada Basin LTER Project               #
#                             by: Brianda Hernandez Rosales                #
#                                                                          #
#   Derived SPEI metrics from the 15 NPP sites on the Jornada Basin using  #
#   precipitation and temperature data. Script downloaded from G. Muarer   #
#   All 15 NPP sites are included and used to calculate SPEI and min, max, #
#   and average vapor pressure deficit.                                    #
############################################################################

#set directory 

getwd()
#setwd ("~/EDI_Fellow/JornadaBasinLTER")
#setwd('~/GitHub/climate-metrics/')

library(tidyverse)
library(lubridate)
library(SPEI)
#source('climate_tools/spei.r')
source('~/GitHub/climate-metrics/R/get_data.R')

library(rclimtools)
#library('SPEI')
#source('../R/derive_climate.R')

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
head(df_list$`G-BASN`)
names(df_list) <- sites
x <- df_list$`G-BASN`


# Function to convert daily to monthly data and calculate SPEI
# Calculate monthly temp and precip
monthly_derived <- function(df, sitename, latitude=32.6169){
  # Convert to monthly data
  dfm <- df %>% mutate(
    Month = month(Date)) %>%
    group_by(Year, Month) %>%
    summarize(tavg = mean(Air_TempC_Avg, na.rm=T), #note the NA remove
              ppt = sum(Ppt_mm_Tot, na.rm=T),  # note the NA remove
              rhavg= mean(Relative_Humidity_Avg, na.rm=T), 
              rhmin = mean(Relative_Humidity_Min, na.rm=T),
              rhmax = mean(Relative_Humidity_Max, na.rm=T),
              tmin= mean (Air_TempC_Min, na.rm=T),
              tmax=mean(Air_TempC_Max, na.rm=T)) # note the NA remove
  
  
  # Make NaN values = NA
  # At some site/month/variable combinations in a dataset, there are no non-NA
  # values. Calculating the mean with na.rm=T in these cases gives NaN, which
  # leads to problems later on. Change the NaNs to NA. 
  # *NOTE* SPEI package is continuing to calculate SPEI values for monthly temperature 
  # data with NA values. It is belived that SPEI is interpolating due to 12-month 
  # SPEI time scale longer than missing data. This should be revisited. 
  
  dfm <- dfm %>% mutate_at(vars(tavg,rhavg,rhmin,rhmax,tmin,tmax),
                           ~replace(., is.nan(.), NA))
   
  # SPEI can throw errors
  tryCatch({
    pet <- SPEI::thornthwaite(dfm$tavg, latitude, na.rm=T)
    # Prepare datetime index
    dateidx <- zoo::as.yearmon(paste(dfm$Month, '/', dfm$Year, sep=''), "%m/%Y")
    # Precip and PET timeseries
    prcp_xts <- xts::xts(dfm$ppt, order.by=dateidx)
    pet_xts <- xts::xts(as.numeric(pet), order.by=dateidx)
    # Climatic water differential
    cwdiff <- get_cwdiff(prcp_xts, pet_xts)
    
    # Now get 1year SPEI and extract values
    spei_12mo <- get_spei(cwdiff, scale=12, na.rm=T, locname=sitename)  
    spei_xts <- xts::xts(as.vector(spei_12mo$fitted),  order.by=zoo::index(cwdiff))
    colnames(spei_xts) <- c('spei12mo')
    # Add SPEI values
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
    df_all <- bind_rows(df_all, df)
  }
}


df_all
tail(df_all)
# Export data to csv 
write_csv(df_all, file = './derived_monthly_climate_spei_NPPsites.csv')

# Import csv preciously written 
npp.df <- read.csv('./derived_monthly_climate_spei_NPPsites.csv')

# Package used to calculate vapor pressure deficit 
#library(plantecophys)

# Create variables
tavg <- npp.df$tavg
tmin <-npp.df$tmin
tmax <-npp.df$tmax
ppt <- npp.df$ppt
rhavg <-npp.df$rhavg
rhmax <-npp.df$rhmax
rhmin <-npp.df$rhmin

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
# Get VPD for min, max and average temperatures 
vpdmin.fun <- data_frame(get.vpd(temp=tmin, rh=rhmin))
vpdmax.fun <- data_frame(get.vpd(temp=tmax, rh=rhmax))
vpdavg.fun <- data_frame(get.vpd(temp=tavg, rh=rhavg))

#plot vpd against respective temperature 
plot(vpdavg.fun$`get.vpd(temp = tavg, rh = rhavg)`~tavg, col="blue")
plot(vpdmin.fun$`get.vpd(temp = tmin, rh = rhmin)`~tmin, col="light blue")
plot(vpdmax.fun$`get.vpd(temp = tmax, rh = rhmax)`~tmax, col="dark blue")


# Bind min, max and avg VPD measured in kilopascals (kPa)
vpd.df <- cbind(vpdavg.fun, vpdmax.fun, vpdmin.fun) 


# create data set with min, max and avg VPD, site name, year, month and SPEI
vpd.comb <- cbind(npp.df, vpd.df) %>% 
  rename(vpd_avg="get.vpd(temp = tavg, rh = rhavg)", 
         vpd_min="get.vpd(temp = tmin, rh = rhmin)",
         vpd_max= "get.vpd(temp = tmax, rh = rhmax)")


colnames(vpd.comb)

npp.final <- vpd.comb[,c(1,2,11,10,12,14,13)] %>% 
  rename(year=Year, 
         month=Month)

npp.final

write_csv(npp.final, './npp_derived_spei_VPD_2013_ongoing.csv')

