% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataset202_jornada_npp.R
\name{derive202}
\alias{derive202}
\title{Create (and write) dataset 202 - climate metrics for the 15 Jornada NPP sites}
\usage{
derive202(fname = "jrn_npp_derived.csv", dest_path = NULL)
}
\arguments{
\item{fname}{Name of the file to write if dest_path != NULL}

\item{dest_path}{Path to write fname to. No file written if NULL (default)}
}
\value{
A dataframe with derived data
}
\description{
Note that there is some checking for missing values in monthly data and
removal of NaN/Inf values, but SPEI still gets calculated.
}
