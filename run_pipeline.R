# ---------------------------------------
# Run full CoVIBA transcript pipeline
# ---------------------------------------

# Load libraries
library(stringr)
library(readr)
library(dplyr)
library(purrr)
library(chron)

# Source scripts
source("scripts/01_cleaning.R")
source("scripts/02_normalization.R")
source("scripts/03_timestamp_reconstruction.R")
source("scripts/04_save_outputs.R")

# Input directory
input_dir <- file.path("data", "raw")

# Get files
filelist <- list.files(input_dir, pattern = "\\.txt$", full.names = TRUE)

# Load data
files <- data.frame(
  Name = basename(filelist),
  Text = sapply(filelist, readr::read_file),
  stringsAsFactors = FALSE
)

# Apply pipeline
files$Text <- transcribe_1(files$Text)
files$Text <- transcribe_2(files$Text)

# Example end time (adjust if needed)
files$Text <- mapply(assign_timestamps, files$Name, files$Text, "00:00:00.000")

# Save outputs
output_dir <- file.path("outputs")
save_outputs(files, output_dir)

cat("Pipeline complete.\n")
