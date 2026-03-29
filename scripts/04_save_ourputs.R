# ---------------------------------------
# Function: save_outputs
# Description: Creates an output directory (if needed) and
# writes each cleaned transcript to disk.
# ---------------------------------------

save_outputs <- function(files, output_dir) {

  # Create directory if it does not exist
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

  # Write each cleaned transcript
  for (i in seq_len(nrow(files))) {
    readr::write_file(
      files$Text[i],
      file.path(output_dir, files$Name[i])
    )
  }

  cat("Cleanup script complete!\n")
}
