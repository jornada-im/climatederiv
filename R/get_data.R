#' Get revisions and load latest data entity
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
