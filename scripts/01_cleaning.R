# ---------------------------------------
# Function: transcribe_1
# Description: Removes metadata artifacts from WebVTT transcripts,
# including NOTE blocks and UUID-like identifiers.
# ---------------------------------------

transcribe_1 <- function(x) {
  x %>%
    stringr::str_remove_all("\r\n\r\nNOTE .*") %>% 
    # Removes NOTE blocks and associated blank lines
    
    stringr::str_remove_all("\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}(-\\w{1})?\\r\\n")
    # Removes UUID-like identifier lines
}
