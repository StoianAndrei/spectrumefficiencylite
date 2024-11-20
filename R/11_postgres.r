#' @export
connection_postgres <- function(host = Sys.getenv("POSTGRES_HOST"),
                                port = Sys.getenv("POSTGRES_PORT"),
                                user = Sys.getenv("POSTGRES_USER"),
                                password = Sys.getenv("POSTGRES_PASSWORD"),
                                dbname = Sys.getenv("POSTGRES_DB"),
                                cache_dir = "../cache/") {
  box::use(glue, DBI = DBI[dbConnect], RPostgres[Postgres])
  # Connect to the default PostgreSQL database
  con_default <- dbConnect(Postgres(), host = host, port = port, user = user, password = password, dbname = "postgres")
  on.exit(DBI$dbDisconnect(con_default))

  # Check if the target database exists
  db_exists <- DBI$dbGetQuery(con_default, sprintf("SELECT 1 FROM pg_database WHERE datname = '%s'", dbname))
  if (nrow(db_exists) == 0) {
    # Create the database if it does not exist
    DBI$dbExecute(con_default, glue$glue("CREATE DATABASE {dbname}"))
  }

  # Connect to the target database
  dbConnect(Postgres(), host = host, port = port, user = user, password = password, dbname = dbname)
}


#' @export
table_exists <- function(dataname, ...) {
  box::use(DBI)
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  DBI$dbExistsTable(con, dataname)
}


#' @export
table_drop <- function(dataname, ...) {
  box::use(DBI)
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  DBI$dbRemoveTable(con, dataname)
}

#' @export
tables_list <- function(...) {
  box::use(DBI)
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  DBI$dbListTables(con)
}

#' @export
tables_row_retrieve <- function(where_cols, id, table, showNotification = FALSE, ...) {
  box::use(DBI)
  box::use(glue)
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  cmd <- glue$glue("SELECT * FROM {table} WHERE {where_cols} = '{id}'")
  out <- DBI$dbGetQuery(con, cmd)
  if (showNotification) {
    box::use(shiny)
  }
  out
}

#' @export
tables_row_remove <- function(where_cols, id, table, showNotification = FALSE, ...) {
  box::use(DBI)
  box::use(glue)
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  cmd <- glue$glue("DELETE FROM {table} WHERE {where_cols} LIKE '{id}'")
  DBI$dbExecute(con, cmd)
  if (showNotification) {
    box::use(shiny)
  }
}

#' @export
table_create_or_upsert <- function(data, where_cols = NULL, ...) {
  #
  box::use(DBI, dbx)
  box::use(glue[glue])
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  dataname <- deparse1(substitute(data))
  if (isFALSE(DBI$dbExistsTable(con, dataname))) {
    DBI$dbCreateTable(con, dataname, data)
    if (!is.null(where_cols)) {
      DBI$dbExecute(con, glue(
        "ALTER TABLE {dataname}
	     ADD CONSTRAINT {paste0(dataname,where_cols)} UNIQUE ({where_cols});"
      ))
    }
  }
  dbx$dbxUpsert(con, dataname, data, where_cols = where_cols)

  # DBI$dbAppendTable(con, dataname, data)
}


#' @export
table_append <- function(data, ...) {
  box::use(DBI, dbx)
  box::use(glue[glue])
  box::use(. / postgres[connection_postgres])

  con <- connection_postgres(...)

  on.exit(DBI$dbDisconnect(con))
  dataname <- deparse1(substitute(data))

  if (isFALSE(DBI$dbExistsTable(con, dataname))) {
    DBI$dbCreateTable(con, dataname, data)
  }
  DBI$dbAppendTable(con, dataname, data)
}


#' @export
table_get <- function(dataname, ...) {
  box::use(DBI)
  box::use(dplyr)
  box::use(dbplyr)
  box::use(. / postgres[connection_postgres])
  con <- connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  dplyr$tbl(con, dataname) |>
    dplyr$collect()
}

#' @export
instance_state <- function(ImageId = NA_character_,
                           InstanceType = NA_character_,
                           InstanceStorage = NA_integer_,
                           user_data = NA_character_,
                           GroupId = NA_character_,
                           KeyName = NA_character_,
                           InstanceId = NA_character_,
                           status = "undefined", ...) {
  box::use(DBI)
  box::use(. / postgres)


  instance_state <- data.frame(
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
  con <- postgres$connection_postgres(...)
  on.exit(DBI$dbDisconnect(con))
  postgres$table_append(instance_state)
  instance_state
}


if (FALSE) {
  box::use(. / postgres)
}
