#!/usr/bin/env python
# coding: utf-8

# ## Chihuahuan desert USHCN station data
# 
# There are 9 USHCN network sites in the Chihuahuan Desert, all in New Mexico or Texas.

# Importing part of our climate tools module
# If you don't have it see here: https://github.com/gremau/climtools
import climtools.get_ushcn as ushcn

# Import standard python modules for data and file handling
import pandas as pd
import os
import sys

# Path to our USHCN data store we downloaded should be argv[1]
# argv[2] is where we want to put the combined file
# Later versions of the data have had issues...
# ushcn_path = '/home/greg/data/rawdata/NCDC/ushcn_v2.5/ushcn.v2.5.5.20220609'
def get_chihuahuan_USHCN(ushcn_path,
                         sites_path='inst/extdata/USHCN_CDSites.txt',
                         cutoff_year=2022,
                         dest_path=None):

    # Get the inventory file for USHCN stations (not needed for now)
    # inventory = ushcn.get_stationsfile(os.path.dirname(ushcn_path))
    # inventory.head()

    # Get the dataframe of 9 Chihuahuan desert sites
    # Note that this table is derived, essentially, from the station inventory
    # file for USHCN - ushcn-v2.5-stations.txt
    chides_sites = pd.read_table(os.path.join(sites_path))

    print('The table of USHCN stations in the Chihuahuan Desert')
    print(chides_sites)

    # ushcn.get_monthly_var will take a list of site ids (from the Chihuahuan
    # Desert sites dataframe) and return data from all
    studystn = chides_sites.stationid.tolist()

    # See function definition, this will fetch precip and avg T, subset to site,
    # drop flags, and convert to correct units
    tavg = ushcn.get_monthly_var('tavg', stationids=studystn, dpath=ushcn_path)
    prcp = ushcn.get_monthly_var('prcp', stationids=studystn, dpath=ushcn_path)
    # Then subset to years before cutoff_year
    print("Subsetting to <2022")
    tavg = tavg.loc[tavg.year < cutoff_year,:]
    prcp = prcp.loc[prcp.year < cutoff_year,:]
    
    # Put together the T and PRCP dataframes into one
    print('Shape of incoming tavg and prcp datasets')
    print(tavg.shape, prcp.shape)
    out = pd.concat([tavg, prcp])
    # Pivot to wider form
    out2 = out.pivot_table(columns='variable', values='value',
                           index=['stationid','date','year', 'month','day'
                                  ]).reset_index()
    print('Shape of output datasets')
    print(out2.shape)
    print(out2.head())

    # Merge in other info about the sites
    print("Merge columns and variables...")
    out2 = out2.merge(chides_sites, on='stationid', how='left')
    
    if dest_path is not None:
        # Write data out to a file
        print("Write " + dest_path + "ChihuahuanDesert_9_USHCN_dataset.csv")
        out2.to_csv(os.path.join(dest_path,
            'ChihuahuanDesert_9_USHCN_dataset.csv'),
            index=False)
        
    return(out2)
