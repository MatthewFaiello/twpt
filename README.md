# Teacher Workforce Planning Tool (TWPT)

TWPT is a Shiny app for exploring long-term teacher workforce projections in Delaware. It helps users examine how changes in enrollment, student need, staffing ratios, and teacher retention may affect projected teacher demand, retained teachers, and hiring need.

## Live app

https://mattfaiello.shinyapps.io/TWPT/

## Intended use

TWPT is a planning and scenario-testing tool, not a precise prediction engine. Results should be interpreted alongside local context, policy changes, and workforce conditions.

## What the app does

TWPT allows users to:

- select an LEA, county, or statewide view
- choose a projected school year
- adjust planning targets for matriculation, IEP identification, students per teacher, and teacher retention
- view projected demand, retained teachers, and hiring need
- review planning target trends and downloadable data outputs

## Data sources

The app uses preprocessed Delaware education and population data, including:

- Delaware Population Consortium population projections
- Delaware student enrollment unit count data
- Delaware educator employment snapshot data

## Project structure

- `global.R` – package imports, data loading, and forecasting/helper functions
- `ui.R` – app interface
- `server.R` – reactive logic, plots, tables, and downloads
- `preprocessed_data.rds` – preprocessed app data
- `www/` – static assets

## Run locally

Open the project in RStudio, or set your working directory to the repository root. Install the required packages, make sure `preprocessed_data.rds` is in the project root, then run:

```r
install.packages(c(
  "shiny", "shinyWidgets", "tidyverse", "knitr", "kableExtra", "DT",
  "ggthemes", "ggfun", "ggrepel", "bslib", "janitor", "shinyjs",
  "bsicons", "webshot2", "pagedown", "chromote", "curl", "magick",
  "shinycssloaders"
))

shiny::runApp()
