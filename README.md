# Teacher Workforce Planning Tool (TWPT)

The Teacher Workforce Planning Tool is a Shiny app for exploring long-term teacher workforce projections in Delaware. It helps users examine how changes in enrollment, student need, staffing ratios, and retention may affect projected teacher demand, retained teachers, and hiring need.

## Live app

https://mattfaiello.shinyapps.io/TWPT/

## What the app does

TWPT allows users to:

- select an LEA, county, or statewide view
- choose a projected school year
- adjust planning targets for:
  - matriculation rate
  - IEP identification rate
  - students per teacher (special education and non-special education)
  - teacher retention rate (special education and non-special education)
- view projected teacher demand, retained teachers, and hiring need
- review historical planning target trends
- download forecast outputs and supporting data

## Data sources

The app uses preprocessed Delaware education and population data, including:

- Delaware Population Consortium population projections
- Delaware student enrollment unit count data
- Delaware educator employment snapshot data

## Project structure

- `global.R` – packages, data loading, and forecasting/helper functions
- `ui.R` – app layout and controls
- `server.R` – reactive logic, plots, tables, and downloads
- `preprocessed_data.rds` – preprocessed data used by the app
- `www/` – static assets

## Run locally

1. Clone this repository.
2. Open the project in RStudio.
3. Install required packages.
4. Make sure `preprocessed_data.rds` is in the project root.
5. Run the app.

Example:

```r
install.packages(c(
  "shiny", "shinyWidgets", "tidyverse", "knitr", "kableExtra", "DT",
  "ggthemes", "ggfun", "ggrepel", "bslib", "janitor", "shinyjs",
  "bsicons", "webshot2", "pagedown", "chromote", "curl", "magick",
  "shinycssloaders"
))

shiny::runApp()
