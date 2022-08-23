# climatderiv

Generate climate metrics derived from published Jornada datasets.

## Derived datasets

### Dataset 103 - derived metrics for Chihuahuan desert USHCN sites

### Dataset 104 - derived metrics for Jornada Basin NPP sites

## Source datasets

### Chihuahuan desert USHCN sites

Access this file `data("ushcn_chihuahuan_data")`

#### Updating the 9-station Chihuahuan USHCN dataset

This will require the `reticulate` R package and a Conda environment with pandas and the [`climtools`](https://github.com/gremau/climtools) python package installed and available in a conda environment. The best way to do this is to use yaml file provided in this package (`inst/python/climatederiv.yml`) that will create this environment. If you have `conda` installed already you can use these commands:

    wget https://github.com/jornada-im/climatederiv/blob/main/inst/python/climatederiv.yml
    conda env create -f climatederiv.yml

To update the station dataset run the `update_chihuahuan_USHCN()` function. A csv file can be output in the process if desired.
