# ---------------------------------------
# Function: assign_timestamps
# Description: Reconstructs transcript timestamp intervals by
# extracting start times, assigning end times, interpolating
# missing values, and rebuilding a valid WebVTT structure.
# ---------------------------------------

assign_timestamps <- function(name, txt, end_time) {

  cat("Assigning new timestamps to ", name, "...\n", sep = "")

  # 1. Extract start times as character
  starts_raw <- stringr::str_extract_all(
    txt,
    "(\\d{1,2}:\\d{2}:\\d{2}\\.\\d{3}) -->",
    simplify = TRUE
  )
  starts_raw <- starts_raw[starts_raw != ""]
  ts <- data.frame(
    start = stringr::str_replace_all(starts_raw, " -->", ""),
    stringsAsFactors = FALSE
  )

  if (nrow(ts) == 0) {
    cat("ERROR! No timestamps found in transcript:", name, "\n")
    return(txt)
  }

  # 1.1 Pre-allocate end column
  ts$end <- NA_character_

  # 1.2 End time = next start time; last end = provided end time
  if (nrow(ts) > 1) ts$end[1:(nrow(ts) - 1)] <- ts$start[2:nrow(ts)]
  ts$end[nrow(ts)] <- end_time

  # 2. Attach dialogue text segments
  split <- t(stringr::str_split(
    txt,
    "(\\d{1,2}:\\d{2}:\\d{2}\\.\\d{3}) --> (\\d{1,2}:\\d{2}:\\d{2}\\.\\d{3})",
    simplify = TRUE
  ))
  split <- split[-1, ]

  if (nrow(ts) == length(split)) {
    ts$text <- split
  } else {
    cat("ERROR! There is likely a major formatting issue in the following transcript:", name, "\n")
    ts$text <- split
  }

  # 3. Remove milliseconds temporarily and convert to chron
  ts$start <- stringr::str_replace_all(ts$start, "(\\d{1,2}:\\d{2}:\\d{2})\\.\\d{3}", "\\1")
  ts$end   <- stringr::str_replace_all(ts$end,   "(\\d{1,2}:\\d{2}:\\d{2})\\.\\d{3}", "\\1")

  ts$start <- chron::chron(times = ts$start)
  ts$end   <- chron::chron(times = ts$end)

  # 4. Interpolate missing (00:00:00) end times
  zero_t <- chron::chron(times = "00:00:00")

  for (i in seq_len(nrow(ts))) {
    non_zero <- which(ts$end != zero_t)

    cond1 <- (ts$end[i] == zero_t && ts$start[i] != zero_t)
    cond2 <- (ts$end[i] == zero_t && ts$start[i] == zero_t && i == 1)

    if (cond1 || cond2) {
      next_candidates <- non_zero[non_zero > i]
      if (length(next_candidates) == 0) next

      next_r <- next_candidates[1]
      next_t <- ts$end[next_r]

      diff <- next_r - i
      increment <- (next_t - ts$start[i]) / (diff + 1)

      # 4.1 Debug column without changing outcomes
      ts[i, 4] <- paste(next_r, diff, increment)

      for (j in seq_len(diff)) {
        if (j == 1) ts$end[i] <- ts$start[i] + (increment * j)
        ts$start[i + j] <- ts$start[i] + (increment * j)
        ts$end[i + j]   <- ts$start[i] + (increment * (j + 1))
      }
    }
  }

  # 5. Re-add .000 milliseconds
  ts$new_start <- paste0(ts$start, ".000")
  ts$new_end   <- paste0(ts$end, ".000")

  # 6. Avoid zero-length intervals
  for (i in seq_len(nrow(ts))) {
    if (ts$start[i] == ts$end[i]) {
      ts$new_end[i] <- paste0(ts$end[i], ".250")
      if (i + 1 <= nrow(ts)) ts$new_start[i + 1] <- paste0(ts$start[i + 1], ".750")
    }
  }

  # 7. Rebuild transcript
  ts$new_text <- paste0(ts$new_start, " --> ", ts$new_end, ts$text)
  new_file <- paste(ts$new_text, collapse = "")
  paste0("WEBVTT\r\n\r\n", new_file)
}
