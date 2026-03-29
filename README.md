# Webvtt-Transcript-Normalization-Using-R

## Overview

This repository contains a reproducible R-based pipeline for cleaning, normalizing, and restructuring WebVTT transcripts from sociolinguistic interviews. The project is part of an ongoing collaboration on the CoVIBA (Corpus de la Frontera) and related corpora, which document bilingual speech in the U.S.–Mexico border region.

The pipeline addresses common issues found in raw transcript data, including inconsistent formatting, metadata artifacts, and incomplete or misaligned timestamps. Through a sequence of modular processing steps, the system transforms raw transcripts into structured, corpus-ready files suitable for linguistic and computational analysis.

Key components of the pipeline include regex-based text cleaning, speaker label normalization, timestamp reconstruction, and standardized output generation. The design emphasizes reproducibility, scalability, and clarity, allowing the workflow to be applied across large collections of transcripts with varying quality.

## Features
- Cleaning WebVTT transcripts
- Removing metadata and artifacts
- Normalizing speaker labels
- Reconstructing timestamps
- Producing corpus-ready outputs

## Project Structure
## Project Structure

The repository is organized to support a clear, modular, and reproducible workflow:

### data/
Contains input and intermediate data files.

- `raw/`  
  Stores original, unmodified transcript files (e.g., WebVTT or TXT).  
  These files should not be altered directly.

- `processed/`  
  Stores intermediate versions of transcripts after cleaning and normalization steps.

---

### scripts/
Contains the core R scripts implementing each stage of the pipeline.

- `01_cleaning.R`  
  Removes metadata, NOTE blocks, and non-linguistic artifacts.

- `02_normalization.R`  
  Standardizes transcript structure, including speaker labels and formatting.

- `03_timestamp_reconstruction.R`  
  Reconstructs and repairs timestamp intervals, including interpolation of missing values.

- `04_save_outputs.R`  
  Writes the final cleaned transcripts to disk in a consistent format.

Each script is designed to be modular and can be run independently or as part of the full pipeline.

---

### notebooks/
Contains R Markdown files documenting the full pipeline.

- `pipeline.Rmd`  
  A reproducible walkthrough of the entire preprocessing workflow, combining code, explanations, and outputs.

---

### outputs/
Stores final, cleaned, and fully processed transcripts ready for analysis.

---

### Root files

- `README.md`  
  Documentation describing the project, usage, and structure.

- `.gitignore`  
  Specifies files and directories to exclude from version control (e.g., large outputs or temporary files).

## Installation
```r
install.packages(c("stringr", "dplyr", "readr", "purrr", "chron"))
```

## Usage
Step-by-step:

1. Place raw transcripts in `data/raw/`
2. Run scripts in order:
   - 01_cleaning.R
   - 02_normalization.R
   - 03_timestamp_reconstruction.R
   - 04_save_outputs.R
3. Output will be saved in `outputs/`

## Status
Ongoing project — actively being expanded for large-scale corpus processing.
