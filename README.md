# climatderiv

Climate metrics derived from published Jornada and regional datasets.

## Derived datasets

The following datasets contain derived climate metrics for locations in the northern Chihuahuan Desert, including the Jornada Basin. These metrics are calculated using public data from NOAA or EDI. The datasets are available by name in the package namespace, and this R package provides functions for creating, updating, and viewing them.

### Dataset 103 - derived metrics for Chihuahuan desert USHCN sites

This dataset contains meteorology and derived climate metrics (drought indices, PET) for the 9 USHCN weather stations located in the Chihuahuan Desert.

Name: `ushcn_chihuahuan_derived`

Published version: EDI [knb-lter-jrn.103.n](https://portal.edirepository.org/nis/mapbrowse?scope=knb-lter-jrn&identifier=103)

Build function: `derive103()`. This build function updates the dataset in the namespace (`data/ushcn_chihuahuan_derived.rda`) and returns the dataframe. Add `path = <path>` to output a csv, and `fname = <file name>` to give it a more descriptive name.

Plotting: You can plot a few things with `plot_103()`.

## Dataset 104 - derived metrics for Jornada Basin NPP sites

This dataset contains meteorology and derived climate metrics (drought indices, PET, VPD) for the 15 weather stations associated with the Jornada LTER NPP study sites.

Name: `jrn_npp_derived`

Published version: EDI [knb-lter-jrn.104.n](https://portal.edirepository.org/nis/mapbrowse?scope=knb-lter-jrn&identifier=104)

Build function: `derive104()`. This build function updates the dataset in the namespace (`data/jrn_npp_derived.rda`) and returns the dataframe. Add `path = <path>` to output a csv, and `fname = <file name>` to give it a more descriptive name.

## Source datasets

The following source datasets are available in the package namespace:

1. `ushcn_chihuahuan_data` - USHCN station data from 9 Chihuahuan desert locations

    - This is taken from the  most recent USHCN dataset processed and should be updated regularly. See details on updating below.

2. `ushcn_chihuahuan_stations` - USHCN station descriptive summary data of the 9 Chihuahuan USHCN stations.

### Updating `ushcn_chihuahuan_data`

This will require the `reticulate` R package and a Conda environment with pandas and the [`climtools`](https://github.com/gremau/climtools) python package installed and available in a conda environment. The best way to do this is to use yaml file provided in this package (`inst/python/climatederiv.yml`) that will create this environment. If you have `conda` installed already you can use these commands:

    wget https://github.com/jornada-im/climatederiv/blob/main/inst/python/climatederiv.yml
    conda env create -f climatederiv.yml

To update the station dataset run the `update_chihuahuan_USHCN()` function. A csv file can be output in the process if desired.

## Requirements

See the `DESCRIPTION` file for details. A variety of packages are used.

## Installation

Install the GitHub version with `devtools`.

    devtools::install_github("jornada-im/climatederiv")

The requirements in the `DESCRIPTION` file should be pulled in at install time if you don't already have them, but there are some that require special handling.
