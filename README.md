# Teacher Workforce Planning Tool (TWPT)

TWPT is a Shiny app for exploring long-term teacher workforce projections in Delaware. It helps users examine how changes in enrollment, student need, staffing ratios, and teacher retention may affect projected teacher demand, retained teachers, and hiring need.

## Live app

Current public demo:

https://mattfaiello.shinyapps.io/TWPT/

If the app is moved to a Delaware DOE Shiny Server, update this link.

## Intended use

TWPT is a planning and scenario-testing tool, not a precise prediction engine. Results should be interpreted alongside local context, policy changes, labor-market conditions, compensation, working conditions, and other factors that may affect staffing.

The app is meant to support conversations about possible future staffing needs. It should not be used as the only source for staffing, budgeting, or policy decisions.

## What the app does

TWPT allows users to:

- select an LEA, county, LEA type, or statewide view
- choose a projected school year
- adjust planning targets for matriculation, IEP identification, students per teacher, and teacher retention
- view projected teacher demand, retained teachers, and hiring need
- review planning target trends
- review historical recruitment counts
- export the current forecast chart and selected planning targets
- review and export the underlying data table

## Main planning targets

The app uses six user-adjustable planning targets:

- `Matriculation Rate`: share of the school-age population expected to enroll in public schools
- `IEP Identification Rate`: share of enrolled students expected to have an IEP
- `Students per Teacher (SPED)`: students with an IEP per special education teacher
- `Students per Teacher (Non-SPED)`: students without an IEP per non-special education teacher
- `Teacher Retention Rate (SPED)`: share of special education teachers expected to return the following year
- `Teacher Retention Rate (Non-SPED)`: share of non-special education teachers expected to return the following year

## Basic forecasting logic

At a high level, TWPT works like this:

1. `Population (5-18 yrs) * Matriculation Rate = Enrollment`
2. `Enrollment * IEP Identification Rate = Students with an IEP`
3. `Enrollment - Students with an IEP = Students without an IEP`
4. `Students with an IEP / Students per Teacher (SPED) = Teacher Demand (SPED)`
5. `Students without an IEP / Students per Teacher (Non-SPED) = Teacher Demand (Non-SPED)`
6. `Prior-year Teacher Demand * Teacher Retention Rate = Teachers Retained`
7. `Teacher Demand - Teachers Retained = Hiring Need`

User-selected planning targets are phased in from the current year to the selected projected school year using compound annual growth logic.

## Data sources

The app uses preprocessed Delaware education and population data, including:

- Delaware Population Consortium population projections
- Delaware student enrollment unit count data
- Delaware educator employment snapshot data
- Delaware district and county lookup data

The deployed app reads from `preprocessed_data.rds`. It does not connect directly to source systems while users are using the app.

## Project structure

Core app files:

- `global.R`: package imports, app data loading, helper functions, forecasting functions, demand logic, and plot function
- `ui.R`: app layout, sidebar controls, tabs, plots, tables, and download button
- `server.R`: reactive inputs, forecast calculations, plot rendering, table rendering, and downloads
- `preprocessed_data.rds`: app-ready data object used by the Shiny app
- `www/styles.css`: app styling
- `www/Website-Header.png`: app header image

Data-prep files may include:

- `prep/scripts/gather.R`: loads raw student, staff, county, and population data
- `prep/scripts/organize.R`: cleans and organizes source data
- `prep/scripts/appData.R`: creates app-ready enrollment, student need, and staffing data
- `prep/scripts/staffRetain_rates.R`: creates retention and hiring flow rates
- `prep/scripts/staffRetain_projections.R`: creates projected hiring inputs
- `prep/scripts/prep.R`: saves the final `preprocessed_data.rds` object

## Required R packages for the Shiny app

These are the runtime packages used by the refactored Shiny app:

```r
install.packages(c(
  "shiny",
  "shinyWidgets",
  "tidyverse",
  "DT",
  "ggthemes",
  "ggfun",
  "ggrepel",
  "bslib",
  "janitor",
  "bsicons",
  "shinycssloaders",
  "zip"
))
```

The app also calls `library(grid)`. `grid` ships with R, so it usually does not need to be installed separately.

The refactored app does not require `webshot2`, `pagedown`, `chromote`, `curl`, `magick`, `knitr`, `kableExtra`, or `shinyjs` for runtime.

## Additional packages for data prep

The prep workflow may require additional packages that are not needed when simply running the deployed Shiny app, including:

```r
install.packages(c(
  "pacman",
  "openxlsx",
  "RSocrata"
))
```

Only install and use these when refreshing or rebuilding `preprocessed_data.rds`.

## Run locally

Open the project in RStudio, or set your working directory to the repository root.

Make sure these files and folders are present:

- `global.R`
- `ui.R`
- `server.R`
- `preprocessed_data.rds`
- `www/styles.css`
- `www/Website-Header.png`

Then install the app packages and run:

```r
shiny::runApp()
```

## Forecast download

The Forecasts tab includes a `Download Forecast` button.

The refactored downloader creates a ZIP file with three files:

- `forecast_chart_...png`: image of the current forecast chart
- `planning_targets_...csv`: selected LEA, year, measure, and planning targets
- `read_me_...txt`: short plain-language note describing the download

The downloader also shows simple status messages:

- `Preparing your download...`
- `Download ready. Check your downloads folder.`
- `Download failed. Please try again or contact Matt if this keeps happening.`

This download approach avoids Chrome-based image rendering and should be more stable on open-source Shiny Server.

## Deploy on open-source Shiny Server

On the Shiny Server machine, install the runtime packages:

```bash
sudo R -e 'install.packages(c(
  "shiny", "shinyWidgets", "tidyverse", "DT", "ggthemes", "ggfun",
  "ggrepel", "bslib", "janitor", "bsicons", "shinycssloaders", "zip"
), repos = "https://cloud.r-project.org")'
```

Copy the app files into the Shiny Server app directory, for example:

```bash
sudo mkdir -p /srv/shiny-server/twpt
sudo cp -R global.R ui.R server.R preprocessed_data.rds www /srv/shiny-server/twpt/
```

Make sure Shiny Server can read the files:

```bash
sudo chown -R shiny:shiny /srv/shiny-server/twpt
sudo chmod -R 755 /srv/shiny-server/twpt
```

Restart Shiny Server:

```bash
sudo systemctl restart shiny-server
```

If the app does not load or the download does not work, check the Shiny Server logs:

```bash
sudo tail -n 100 /var/log/shiny-server/*.log
```

## Data refresh notes

The Shiny app itself only needs `preprocessed_data.rds`. To refresh the data, run the prep workflow that creates that file.

Do not hard-code usernames, passwords, API tokens, or other credentials in the repository. Store credentials in `.Renviron`, server environment variables, or another secure credential management process.

After rebuilding `preprocessed_data.rds`, replace the file used by the deployed app and restart Shiny Server.

## Maintenance notes for novice maintainers

The app is intentionally organized in a simple three-file Shiny structure:

- Change packages, loaded data, and helper/model functions in `global.R`.
- Change layout, labels, notes, and visual structure in `ui.R`.
- Change reactivity, calculations, tables, plots, and downloads in `server.R`.

When making edits:

1. Make one small change at a time.
2. Run the app locally.
3. Test the selected LEA, projected year, planning target controls, forecast plot, planning target trend plot, data table, historical hires table, and download button.
4. Commit the working version before making another larger change.

## Known interpretation notes

- TWPT provides planning estimates, not exact predictions.
- Results should be interpreted with local knowledge and current policy context.
- Long-range projections become more uncertain farther into the future.
- Small-count suppression and public reporting rules should be reviewed before broader public release.
- LEA-level matriculation values should be interpreted carefully because population projections are county-based.

## Contact

For questions or suggestions, contact:

Matt Faiello  
Associate Data Scientist, DDOE Data Analytics
