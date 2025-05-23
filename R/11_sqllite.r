### 1. Establishing a Connection to SQLite


#' @export
connection_sqlite <-  function(dbname = "spectrumefficiencylite.sqlite", cache_dir = "../cache/") {
  box::use(DBI = DBI[dbConnect], RSQLite = RSQLite[SQLite])

  # Ensure the cache directory exists
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }

  # Construct the full path to the SQLite database file
  db_path <-  file.path(cache_dir, dbname)

  # Connect to the SQLite database (creates the file if it doesn't exist)
  dbConnect(SQLite(), dbname = db_path)
}

con <- connection_sqlite(dbname = "spectrumefficiencylite.sqlite")

## Explanation:##

## -  Uses the `RSQLite` package to connect to an SQLite database.
## -  The database file is stored in the specified `cache_dir`.
## -  If the directory doesn't exist, it's created.
## -  SQLite creates the database file if it doesn't already exist.



### 2. Checking if a Table Exists


#' @export
table_exists <-  function(dataname, ...) {
  box::use(DBI)
  box::use(. / sqlite[connection_sqlite])

  con <-  connection_sqlite(...)
  on.exit(DBI$dbDisconnect(con))

  DBI::dbExistsTable(con, dataname)
}




### 3. Dropping a Table


#' @export
table_drop <-  function(dataname, ...) {
  box::use(DBI)
  box::use(. / sqlite[connection_sqlite])

  con <-  connection_sqlite(...)
  on.exit(DBI$dbDisconnect(con))

  DBI::dbRemoveTable(con, dataname)
}




### 4. Listing All Tables


#' @export
tables_list <-  function(...) {
  box::use(DBI)
  box::use(. / sqlite[connection_sqlite])

  con <-  connection_sqlite(...)
  on.exit(DBI$dbDisconnect(con))

  DBI::dbListTables(con)
}




### 5. Retrieving Rows from a Table


#' @export
tables_row_retrieve <-  function(where_cols, id, table, showNotification = FALSE, ...) {
  box::use(DBI)
  box::use(glue)
  box::use(. / sqlite[connection_sqlite])

  con <-  connection_sqlite(...)
  on.exit(DBI$dbDisconnect(con))

  statement <-  glue::glue("SELECT * FROM {table} WHERE {where_cols} = '{id}'")
  out <-  DBI::dbGetQuery(con, statement = statement)

  if (showNotification) {
    box::use(shiny)
    # Implement notification logic here if needed
  }

  out
}




### 6. Removing Rows from a Table


#' @export
tables_row_remove <-  function(where_cols, id, table, showNotification = FALSE, ...) {
  box::use(DBI)
  box::use(glue)
  box::use(. / sqlite[connection_sqlite])

  con <-  connection_sqlite(...)
  on.exit(DBI$dbDisconnect(con))

  statement <-  glue::glue("DELETE FROM {table} WHERE {where_cols} LIKE '{id}'")
  DBI::dbExecute(con, statement)

  if (showNotification) {
    box::use(shiny)
    # Implement notification logic here if needed
  }
}




### 7. Creating or Upserting Data into a Table


#' @export
table_create_or_upsert <-  function(data, where_cols = NULL, ...) {
  box::use(DBI, dbx)
  box::use(glue[glue])

  con <-  connection_sqlite(...)
  on.exit(DBI$dbDisconnect(con))

  dataname <-  deparse1(substitute(data))

  if (!DBI::dbExistsTable(con, dataname)) {
    # Create the table
    DBI::dbCreateTable(con, dataname, data)

    if (!is.null(where_cols)) {
      # Create a unique index for the specified columns
      index_name <-  paste0("idx_unique_", dataname, "_", where_cols)
      cmd <-  glue::glue("CREATE UNIQUE INDEX {index_name} ON {dataname} ({where_cols});")
      DBI::dbExecute(con, cmd)
    }
  }

  # Upsert data using dbx package
  dbx::dbxUpsert(con, dataname, data, where_cols = where_cols)
}


## Explanation:##

## -  SQLite allows creating unique indexes to enforce uniqueness.
## -  The `dbxUpsert` function from the `dbx` package supports SQLite and performs the upsert operation.
## -  If the table doesn't exist, it's created, and a unique index is added if `where_cols` is specified.



### 8. Appending Data to a Table


#' @export
table_append <-  function(data, tablename = NULL, con = NULL, ...) {
  box::use(DBI)
  box::use(. / sqlite[connection_sqlite])

  if (is.null(con)) {
    con <-  connection_sqlite(...)
    on.exit(DBI$dbDisconnect(con))
  }

  if (is.null(tablename)) {
    tablename <-  deparse1(substitute(data))
  }

  if (!DBI::dbExistsTable(con, tablename)) {
    DBI::dbCreateTable(con, tablename, data)
  }

  DBI::dbAppendTable(con, tablename, data)
}


## Explanation:##

## -  Allows specifying a `tablename` and reusing a database connection `con`.
## -  Creates the table if it doesn't exist and appends the data.



### 9. Retrieving an Entire Table


#' @export
table_get <-  function(dataname, ...) {
  box::use(DBI)
  box::use(dplyr)
  box::use(dbplyr)
  box::use(. / sqlite[connection_sqlite])

  con <-  connection_sqlite(...)
  on.exit(DBI$dbDisconnect(con))

  dplyr::tbl(con, dataname) %>%
    dplyr::collect()
}




### 10. Recording Instance State Information


#' @export
instance_state <-  function(ImageId = NA_character_,
                           InstanceType = NA_character_,
                           InstanceStorage = NA_integer_,
                           user_data = NA_character_,
                           GroupId = NA_character_,
                           KeyName = NA_character_,
                           InstanceId = NA_character_,
                           status = "undefined", ...) {
  box::use(DBI)
  box::use(. / sqlite[connection_sqlite, table_append])

  data_to_append <-  data.frame(
    ImageId = ImageId,
    InstanceType = InstanceType,
    InstanceStorage = InstanceStorage,
    user_data = user_data,
    GroupId = GroupId,
    KeyName = KeyName,
    InstanceId = InstanceId,
    status = status,
    time = Sys.time()
  )

  con <-  connection_sqlite(...)
  on.exit(DBI$dbDisconnect(con))

  table_append(data = data_to_append, tablename = "instance_state", con = con)

  data_to_append
}

