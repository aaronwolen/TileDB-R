
library(tiledb)

## Name of the array to create.
array_name <- "ex_2"
## Path is either current directory, or a local config value is found
uri <- file.path(getOption("TileDB_Data_Path", "."), array_name)

create_array <- function(uri) {
  ## Check if the array already exists.
  if (tiledb_object_type(uri) == "ARRAY") {
    message("Array already exists.")
    return(invisible(NULL))
  }

  ## The array will be 10x5 with dimensions "rows" and "cols", with domains [1,10] and [1,5].
  dom <- tiledb_domain(dims = c(tiledb_dim("rows", c(ISOdatetime(2010,1,1,0,0,0),
                                                     ISOdatetime(2029,12,31,23,59,59.999)),
                                           10,
                                           #type = "DATETIME_MS")))
                                           type = "FLOAT64")))

  ## The array will be dense with a single attribute "a" so each (i,j) cell can store an integer.
  schema <- tiledb_array_schema(dom, attrs = c(tiledb_attr("a", type = "INT32"),
                                               tiledb_attr("b", type = "FLOAT64"),
                                               tiledb_attr("d", type = "DATETIME_DAY"),
                                               tiledb_attr("e", type = "DATETIME_MS")),
                                sparse=TRUE)

  ## Create the (empty) array on disk.
  tiledb_array_create(uri, schema)
}

write_array <- function(uri) {
  data <- list(seq(1:10),
               as.double(seq(101,110)),
               #c(letters[1:26], "brown", "fox", LETTERS[1:22])[1:10],
               as.Date("2020-01-01") + cumsum(runif(10)*5),
               ISOdatetime(2020,1,1,6,0,0) + cumsum(rnorm(10) * 1e5))
  ## Open the array and write to it.
  A <- tiledb_sparse(uri = uri)
  coords <- ISOdatetime(2020,1,1,0,0,0) + (1:10)*60
  A[coords] <- data
}

read_array <- function(uri) {
  ## Open the array and read from it.
  A <- tiledb_sparse(uri = uri)
  data <- A[]
  show(data)

}

read_as_df <- function(uri) {
  A <- tiledb_sparse(uri = uri, as.data.frame = TRUE)
  data <- A[1577858580:1577858700]
  show(data)
  data <- A[as.POSIXct("2020-01-01 00:01:00"):as.POSIXct("2020-01-01 00:03:00")]
  show(data)
}

set.seed(42)

if (dir.exists(uri)) {
  cat("Nuking existing array\n")
  unlink(uri, recursive=TRUE)
}

if (!dir.exists(uri)) {
  create_array(uri)
}

write_array(uri)
read_array(uri)
read_as_df(uri)

cat("Done.\n")
