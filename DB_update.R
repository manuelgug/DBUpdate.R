###############################
# Script Name: DB_update.R
# Author: Manuel García Ulloa Gamiz
# Date: May 11, 2023
# Description: This script is designed to add library and/or sequencing data and/or update the GenMoz Lab database based on tube barcodes
# Tested on: R version 4.1.2 (2021-11-01) -- "Bird Hippie"
###############################


######################
#  LOAD DEPENDENCIES #
######################

if (!require(readxl)) {
  install.packages("readxl")
  library(readxl)
}

if (!require(openxlsx)) {
  install.packages("openxlsx")
  library(openxlsx)
}

if (!require(optparse)) {
  install.packages("optparse")
  library(optparse)
}

suppressWarnings({
  rm(lib)
  rm(sequencing)
  rm(scan_)
  rm(db)
})

#################
#  USER INPUTS  #
#################

option_list <- list(
  make_option(c("-l", "--lib"), type="character", default=NA, help="Path to the library file"),
  make_option(c("-s", "--seq"), type="character", default=NA, help="Path to the sequencing file"),
  make_option(c("-c", "--scan"), type="character", default=NA, help="Path to the scan file"),
  make_option(c("-d", "--db"), type="character", default=NA, help="Path to the database file"),
  make_option(c("-o", "--out"), type="character", default=paste0("GenMoz_LAB_DB_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".xlsx"), help="Path to the output file")
)

opt_parser <- OptionParser(option_list=option_list)

args <- parse_args(opt_parser)

LIB_FILE <- ifelse(!is.na(args$lib), args$lib, NA)
SEQ_FILE <- ifelse(!is.na(args$seq), args$seq, NA)
SCAN_FILE <- ifelse(!is.na(args$scan), args$scan, NA)
DB_FILE <- ifelse(!is.na(args$db), args$db, NA)
OUT_FILE <- ifelse(!is.na(args$out), args$out, NA)

if (is.na(DB_FILE)) {
  stop("\n\nThere is no database to be modified. Introduce DB_FILE in xlsx format.\n\n")
}

if (is.na(LIB_FILE) && is.na(SEQ_FILE) && is.na(SCAN_FILE)) {
  stop("\n\nThere are no changes to be done. Introduce a LIB_FILE and/or SEQ_FILE and/or SCAN_FILE in xlsx format.\n\n")
}


#############
#  IMPORTS  #
#############

#Set relevant file names
library_filename <- LIB_FILE
sequencing_filename <- SEQ_FILE

#Import files
db <- read_excel(DB_FILE)

tryCatch({
  lib <- suppressMessages(read_excel(library_filename, sheet = "Wilmut Scan Output"))
}, error = function(e) {
  # Handle the error however you like
  print("----------------")
})

tryCatch({
  sequencing <- suppressMessages(read_excel(sequencing_filename, sheet = "Balancing"))
}, error = function(e) {
  # Handle the error however you like
  print("----------------")
})

tryCatch({
  scan_ <- suppressMessages(read_excel(SCAN_FILE))
}, error = function(e) {
  # Handle the error however you like
  print("----------------")
})

sequencing_filename <- try(basename(sequencing_filename), silent = TRUE)


################
#  FORMATTING  #
################

clean_data <- function(df) {
  df[] <- lapply(df, function(x) gsub(",", ".", x))
  df[] <- lapply(df, function(x) gsub(" ", "_", x))
  return(df)
}

db <- clean_data(db)

lib <- try(clean_data(lib), silent = TRUE)
sequencing <- try(clean_data(sequencing), silent = TRUE)


#################
#  ADDING DATA  #
#################

if(class(lib)[1] != "try-error"){
  
  # join db and lib data frames
  db <- merge(db, lib, by.x = "TubeBarcode", by.y = "Barcode", all.x = TRUE)
  
  # define function to check if a specific position already has data
  has_data <- function(x) {
    !is.na(x) & !is.null(x) & x != ""
  }
  
  # loop through positions and update lib columns accordingly
  for (i in 1:nrow(db)) {
    if (has_data(db[i, "LIBRARY1"])) {
      if (has_data(db[i, "LIBRARY2"])) {
        if (has_data(db[i, "LIBRARY3"])) {
          if (has_data(db[i, "LIBRARY4"])) {
            if (has_data(db[i, "LIBRARY5"])) {
            } else {
              db[i, "LIBRARY5"] <- db[i, "Library"]
            }
          } else {
            db[i, "LIBRARY4"] <- db[i, "Library"]
          }
        } else {
          db[i, "LIBRARY3"] <- db[i, "Library"]
        }
      } else {
        db[i, "LIBRARY2"] <- db[i, "Library"]
      }
    } else {
      db[i, "LIBRARY1"] <- db[i, "Library"]
    }
  }
  print("Added library data.")
}
 

# add run name if sequencing object is not NA or null or empty
if (class(sequencing)[1] != "try-error") {
  
  # define function to check if a specific position already has data
  has_data <- function(x) {
    !is.na(x) & !is.null(x) & x != ""
  }
  
  matching_idx <- match(db$TubeBarcode, sequencing$Barcode, nomatch = 0)
  matching_rows <- which(matching_idx > 0)
  
  for (i in matching_rows) {
    if (has_data(db[i, "RUN"])) {
      if (has_data(db[i, "RUN2"])) {
        if (has_data(db[i, "RUN3"])) {
          if (has_data(db[i, "RUN4"])) {
            if (has_data(db[i, "RUN5"])) {
            } else {
              db[i, "RUN5"] <- sequencing_filename
            }
          } else {
            db[i, "RUN4"] <- sequencing_filename
          }
        } else {
          db[i, "RUN3"] <- sequencing_filename
        }
      } else {
        db[i, "RUN2"] <- sequencing_filename
      }
    } else {
      db[i, "RUN"] <- sequencing_filename
    }
  }
  print("Added run data.")
}

# reorder rows by NUM
db <- db[order(as.numeric(db$NUM)),]
rownames(db) <- NULL

# clean table
db<-as.data.frame(db)
db <- db[, 1:which(names(db) == "NOTES")]
colnames(db)[which(colnames(db) == "Position.x")] <- "Position"
run_cols <- grep("RUN", colnames(db), value = TRUE)
for (col in run_cols) {
  db[, col] <- gsub(".xlsx", "", db[, col])
}


###################
#  UPDATING DATA  #
###################
if (exists("scan_")) {
  
  # join db and scan_ data frames
  db <- merge(db, scan_, by = "TubeBarcode", all.x = TRUE)
  
  # update Position and RackBarcode columns in db
  db$Position.x[!is.na(db$Position.y)] <- db$Position.y[!is.na(db$Position.y)]
  db$RackBarcode.x[!is.na(db$RackBarcode.y)] <- db$RackBarcode.y[!is.na(db$RackBarcode.y)]
  
  print("Updated database.")
}


####################
#  FINAL CLEANING  #
####################

db <- db[, 1:which(names(db) == "NOTES")]
colnames(db)[which(colnames(db) == "Position.x")] <- "Position"
colnames(db)[which(colnames(db) == "RackBarcode.x")] <- "RackBarcode"
db <- db[order(as.numeric(db$NUM)),]
rownames(db) <- NULL

#reorder columns as example db provided by Carla
db <- db[, c("NUM", "STUDY", "SAMPLE.ID", "EXTRACTION", "VOL", "TubeBarcode", "CT", "PARASITEMIA", "GROUP", "LIBRARY1", "LIBRARY2", "LIBRARY3", "LIBRARY4", "LIBRARY5", "RackBarcode", "Position", "FREEZER", "RUN", "RUN2", "RUN3", "RUN4", "RUN5", "NOTES")]


###################
#  OUTPUT NEW DB  #
###################
write.xlsx(db, OUT_FILE, rowNames = FALSE)

print("SUCCESS!")
