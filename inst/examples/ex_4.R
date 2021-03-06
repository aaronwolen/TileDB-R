library(tiledb)

## trying to mimick the simple heterogenous_domains_ex2.cpp example
## based the C++ API test

## Name of the array to create.
array_name <- "ex_4"

## Path is either current directory, or a local config value is found
uri <- file.path(getOption("TileDB_Data_Path", "."), array_name)

create_array <- function(uri) {

  dom <- tiledb_domain(dims = c(tiledb_dim("d1", c(1.0, 20.0), 5.0, type="FLOAT64"),
                                tiledb_dim("d2", c(1L, 30L), 5L, type="INT32")))

  myorder <- "COL_MAJOR"
  #cat("Using cell and tile order:", myorder, "\n")
  ## The array will be dense with a single attribute "a" so each (i,j) cell can store an integer.
  schema <- tiledb_array_schema(dom,
                                attrs = c(tiledb_attr("a", type = "INT32")),
                                cell_order = myorder, tile_order = myorder,
                                sparse=TRUE)

  ## Create the (empty) array on disk.
  tiledb_array_create(uri, schema)
}

write_array <- function(uri) {
  x <- tiledb_sparse(uri = uri)
  d1 <- c(1.1, 1.2, 1.3, 1.4)
  d2 <- c(1L, 2L, 3L, 4L)
  a <- c(11L, 21L, 31L, 41L)


  tiledb_array_open(x, "WRITE")
  qry <- tiledb:::libtiledb_query(x@ctx@ptr, x@ptr, "WRITE")
  qry <- tiledb:::libtiledb_query_set_buffer(qry, "d1", d1)
  qry <- tiledb:::libtiledb_query_set_buffer(qry, "d2", d2)
  qry <- tiledb:::libtiledb_query_set_buffer(qry, "a", a)
  qry <- tiledb:::libtiledb_query_set_layout(qry, "UNORDERED")
  qry <- tiledb:::libtiledb_query_submit(qry)
  qry <- tiledb:::libtiledb_query_finalize(qry)
  if (tiledb:::libtiledb_query_status(qry) != "COMPLETE") {
    stop("error in write query (not 'COMPLETE')", call.=FALSE)
  }
  tiledb_array_close(x)
  invisible(NULL)
}

read_array <- function(uri) {
  x <- tiledb_sparse(uri = uri)
  d1r <- vector(mode="numeric", length=4)
  d2r <- vector(mode="integer", length=4)
  ar <- vector(mode="integer", length=4)
  tiledb_array_open(x, "READ")
  qry <- tiledb:::libtiledb_query(x@ctx@ptr, x@ptr, "READ")
  qry <- tiledb:::libtiledb_query_set_buffer(qry, "d1", d1r)
  qry <- tiledb:::libtiledb_query_set_buffer(qry, "d2", d2r)
  qry <- tiledb:::libtiledb_query_set_buffer(qry, "a", ar)
  qry <- tiledb:::libtiledb_query_set_layout(qry, "UNORDERED")
  qry <- tiledb:::libtiledb_query_submit(qry)
  print(df <- data.frame(d1=d1r, d2=d2r, a=ar))
  tiledb_array_close(x)
  invisible(NULL)
}

read_array_subset <- function(uri) {
  x <- tiledb_sparse(uri = uri)
  d1r <- vector(mode="numeric", length=3)
  d2r <- vector(mode="integer", length=3)
  ar <- vector(mode="integer", length=3)
  tiledb_array_open(x, "READ")
  qry <- tiledb:::libtiledb_query(x@ctx@ptr, x@ptr, "READ")
  qry <- tiledb:::libtiledb_query_set_buffer(qry, "d1", d1r)
  qry <- tiledb:::libtiledb_query_set_buffer(qry, "d2", d2r)
  qry <- tiledb:::libtiledb_query_set_buffer(qry, "a", ar)
  qry <- tiledb:::libtiledb_query_set_layout(qry, "UNORDERED")
  qry <- tiledb:::libtiledb_query_add_range(qry, 0, 1.15, 1.35)
  qry <- tiledb:::libtiledb_query_add_range(qry, 1, 2L, 4L)
  qry <- tiledb:::libtiledb_query_submit(qry)
  ## -- next calls blows up attribute test as it gets d1
  ## nc <_ tiledb:::libtiledb_query_result_buffer_elements(qry, "a")
  print(df <- data.frame(d1=d1r, d2=d2r, a=ar))

  tiledb_array_close(x)
  invisible(NULL)
}


## Check if the array already exists.
if (tiledb_object_type(uri) == "ARRAY") {
  message("Array already exists.")
} else {
  message("Creating and writing.")
  create_array(uri)
  write_array(uri)
}

read_array(uri)
read_array_subset(uri)
cat("Done\n")
