% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DenseArray.R
\name{is.sparse,tiledb_dense-method}
\alias{is.sparse,tiledb_dense-method}
\title{#' Reopens a TileDB array an opened tiledb array
#'
#' Reopening an array is useful when the array got updated after it got opened
#' and the tiledb array object got created. To sync-up with the updates,
#' the user must either close the array and open again,
#' or just use tiledb_reopen(array) which can be faster because
#' only metdata regarding updates has to be loaded.
#'
#' @param object tileb array object
#' @return the reopened array object
#' @export
setGeneric("reopen", function(object, ...) standardGeneric("reopen"))}
\usage{
\S4method{is.sparse}{tiledb_dense}(object)
}
\arguments{
\item{object}{tiledb_dense}
}
\value{
FALSE
}
\description{
#' @export
setMethod("reopen", "tiledb_dense", function(object) {
libtiledb_array_reopen(object@ptr)
return(object)
})
}
\details{
#' Closes a tiledb array object
#'
#' @param conn tiledb array object
#' @return returns the closed array object
close.tiledb_dense <- function(conn, ...)  {
stopifnot(is(conn, "tiledb_dense"))
libtiledb_array_close(conn@ptr)
return(conn);
}
Returns true is if the array or array_schema is sparse
}
