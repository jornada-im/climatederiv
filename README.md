# climatderiv

Generate climate metrics derived from published Jornada datasets.

## Derived datasets


## Internal datasets

### Chihuahuan desert USHCN sites

Access this file `data("ushcn_data_9chihuahuan")`

#### Updating the 9-station Chihuahuan USHCN dataset

This will require the `reticulate` R package and a Conda environment with pandas and the [`climtools`](https://github.com/gremau/climtools) python package installed and available in a conda environment. The best way to do this is to use yaml file provided in the package (`inst/python/climatederiv.yml`) that will create this environment. If you have `conda` installed already you can use this command:
    conda env create -f https://github.com/gremau/climatederiv/inst/python/climatederiv.yml

Then, run the `update_chihuahuan_USHCN()` function to update the files. A csv file can be output in the process if desired.
