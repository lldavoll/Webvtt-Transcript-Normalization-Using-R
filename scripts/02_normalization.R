# ---------------------------------------
# Function: transcribe_2
# Description: Normalizes transcript structure by standardizing
# speaker labels, timestamps, line breaks, and spacing.
# ---------------------------------------

transcribe_2 <- function(x) {

  # Regex fragments
  TS  <- "(\\d{1,2}:\\d{2}:\\d{2}\\.\\d{3})"
  TSP <- paste0(TS, " --> ", TS)
  SPK <- "(INV|PAR|INT)"  # Speaker labels

  x %>%
    # 1) Normalize speaker tags / IDs
    stringr::str_replace_all("<\\.?\\s*(INV|PAR|INV)>", "<v \\1>") %>% 
    stringr::str_replace_all(
      paste0("(", "<v (INV|PAR|INV)>", ")\\s?(", TSP, ")\\r\\n(.*)"),
      "\\3\r\n\\1 \\4"
    ) %>% 
    stringr::str_replace_all(paste0("(", SPK, "):"), "<v \\1>") %>% 
    stringr::str_replace_all(paste0("/\\s+<v ", SPK, ">"), "/") %>% 

    # 2) Timestamp normalization
    stringr::str_replace_all("—->", "-->") %>%
    stringr::str_replace_all("-—>", "-->") %>%
    stringr::str_replace_all(paste0("(\\d{1,2}:\\d{2}:\\d{2}\\.)(\\d{2,3})"), "\\1000") %>%
    stringr::str_replace_all("0{3,}:", "00:") %>%

    # 3) Line break / spacing fixes around timestamps
    stringr::str_replace_all(paste0("\\n\\n", TS), "\r\n\r\n\\1") %>%
    stringr::str_replace_all(paste0("\\s{1,}(", TS, ") -->"), "\r\n\r\n\\1 -->") %>%
    stringr::str_replace_all("(\\r\\n\\r\\n)\\s{1}(\\d{1,2})", "\\1\\2") %>%
    stringr::str_replace_all("(\\d{3}\\r\\n)\\s{1}", "\\1") %>%
    stringr::str_replace_all(".000\\s*\\n<v (INV|PAR|INT)>", ".000\r\n<v \\1>") %>%

    # 4) Collapse timestamps that appear inside a speaker turn
    stringr::str_replace_all(
      paste0("\\r\\n\\r\\n\\r?\\n?(", TS, ") --> (", TS, ")\\r?\\n(?!<)"),
      " "
    ) %>%

    # 5) Remove unnecessary line breaks within dialogue
    stringr::str_replace_all("([:alnum:]|[:punct:])\\s?\\r\\n([:alnum:]|[:punct:])", "\\1 \\2") %>%
    stringr::str_replace_all("(\\r\\n\\s{3,}|\\r\\n\\t|\\s{2}\\r\\n\\s{2})", " ") %>%

    # 6) Double-space cleanup
    stringr::str_replace_all(" {2,}", " ") %>%

    # 7) Inject empty timestamps if speaker tags appear without timing
    stringr::str_replace_all(
      paste0("(?<!\\r\\n)<v ", SPK, ">"),
      "\r\n\r\n00:00:00.000 --> 00:00:00.000\r\n<v \\1>"
    ) %>%
    stringr::str_replace_all(
      paste0("(?<!000\\r\\n)<v ", SPK, ">"),
      "\r\n00:00:00.000 --> 00:00:00.000\r\n<v \\1>"
    ) %>%

    # 8) Collapse repeated timestamps with consecutive speaker codes
    stringr::str_replace_all(
      paste0("(?<=<v PAR>)(.*)\\r\\n\\r\\n\\r?\\n?(", TS, ") --> (", TS, ")\\r\\n<v PAR>"),
      "\\1 "
    ) %>%
    stringr::str_replace_all(
      paste0("(?<=<v (INT|INV)>)(.*)\\r\\n\\r\\n\\r?\\n?(", TS, ") --> (", TS, ")\\r\\n<v (INT|INV)>"),
      "\\2 "
    ) %>%

    # 9) Final cleanup
    stringr::str_replace_all("\\r\\n\\r\\n\\r\\n", "\r\n\r\n")
}
