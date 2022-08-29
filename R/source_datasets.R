
#' Get revisions and load latest data entity from an EDI dataset
#'
#' @param pkgid An integer defining the dataset ID to retrieve from EDI
#' @param rrev A zero (default) or negative integer indicating dataset revision
#'     relative to the most current revision (-1 is the previous)
#' @param scope = The EDI scope (string) to retrieve the dataset from
#' @param skip = The number of lines to skip on reading the
#' @returns A dataframe loaded from EDI
#' @export
from_edi <- function(pkgid, rrev=0, scope='knb-lter-jrn', skip=0){
    revs <- EDIutils::list_data_package_revisions(scope, pkgid)
    revnum <- revs[length(revs) + rrev]
    report <- EDIutils::read_data_package(paste(scope, pkgid, revnum, sep='.'))
    data_ents <- report[grepl('/data/', report)]
    if(length(data_ents) < 2){
        df <- readr::read_csv(data_ents, skip=skip,
                       na=c('.','NaN', 'NA', 'NULL'))
        return(df)
        }
    else{
        print('More than one data entity!\n')
        print(data_ents)


        }
    }


#' Update the Chihuahuan Desert USHCN dataset
#'
#' @param ushcn_path Path to a downloaded archive of the USHCN dataset
#' @param condaenv_path Path to the climatederiv conda environment on the host
#' @param dest_path Path for output csv file (default NULL, with no output csv)
#' @returns A dataframe loaded from EDI
update_chihuahuan_USHCN <- function(
    ushcn_path='/home/greg/data/rawdata/NCDC/ushcn_v2.5/ushcn.v2.5.5.20220609/',
    condaenv_path='/home/greg/data/miniconda3/bin/conda',
    dest_path=NULL){
  # Warn about reticulate
  if (!requireNamespace("reticulate", quietly = TRUE)) {
    stop(
      "Package \"pkg\", and a conda environment must be installed to use this
      function.",
      call. = FALSE
    )
  }
  # Accessing the correct python environment
  message("Loading `climatederiv` conda environment...")
  reticulate::use_condaenv('climatederiv', conda=condaenv_path)
  message("Sourcing the `get_chihuahuan_USHCN.py` script...")
  reticulate::source_python('inst/python/get_chihuahuan_USHCN.py')
  message("Running python...")
  if(is.null(dest_path)){
    ushcn_chihuahuan_data <- get_chihuahuan_USHCN(ushcn_path,
                                              dest_path=reticulate::py_none())
  }
  else{
    ushcn_chihuahuan_data <- get_chihuahuan_USHCN(ushcn_path,
                                                  dest_path=dest_path)
  }
  # For some reason reticulate converts the date column to POSIXct and we don't
  # need the time. Change back to date
  ushcn_chihuahuan_data$date <- as.Date(ushcn_chihuahuan_data$date)
  # Make an archive copy of the data file
  message("Archiving previous data file to 'data/ushcn_chihuahuan_data_archive.rda'")
  file.copy('data/ushcn_chihuahuan_data.rda',
            'data/ushcn_chihuahuan_data_archive.rda',
            overwrite=T)
  # Overwrite with the new file
  message('Writing new file...')
  save(ushcn_chihuahuan_data, file='data/ushcn_chihuahuan_data.rda')
}
