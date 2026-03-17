#--------------------------- ui ----------------------------------------------#
ui <- 
  page_sidebar(window_title = "Teacher Workforce Planning Tool",
               fillable = T,
               fillable_mobile = T,
               useShinyjs(),
               tags$script(HTML("$(document).on('click', '#plot1Export', function () {Shiny.setInputValue('download_clicked', Math.random());});")),
               
               tags$style(type = "text/css", ".shiny-output-error { visibility: hidden; }", ".shiny-output-error:before { visibility: hidden; content: '...forecasting Teacher staffing in The First State :)'; }"),
               
               sidebar = sidebar(width = 350,
                                 gap = "10%",
                                 open = "always",
                                 
                                 title = img(src = "edExcel.png", width = 275),
                                 br(),
                                 
                                 accordion(open = T,
                                           
                                           accordion_panel(title = HTML('<b><font size = "5">Scope</font></b>'),
                                                           
                                                           tags$div(title = "Select a LEA, county, or statewide view to begin forecasting for that area.",
                                                                    pickerInput(inputId = "LEA", 
                                                                                label = "Local Education Agency", 
                                                                                choices = leaList, 
                                                                                selected = "All LEAs",
                                                                                multiple = F, 
                                                                                options = pickerOptions(`actions-box` = T, liveSearch = T))),
                                                           
                                                           tags$div(title = "What year would you like to forecast to?",
                                                                    pickerInput(inputId = "SchoolYear", 
                                                                                label = "Projected School Year", 
                                                                                choices = schoolYears, 
                                                                                selected = paste0(yr - 1, "-", yr - 2000),
                                                                                multiple = F))),
                                           
                                           accordion_panel(title = HTML('<b><font size = "5">Planning Targets</font></b>'),
                                                           
                                                           accordion_panel(title = HTML("<b>Matriculation</b>"),
                                                                           tags$div(title = "What percentage of the school-age population (5-18) enroll in public schools? Adjust to reflect local trends.",
                                                                                    numericInputIcon(inputId = "Mat", 
                                                                                                     label = "Matriculation Rate", 
                                                                                                     value = dfltVls$`Matriculation Rate`, 
                                                                                                     min = 0.0,
                                                                                                     max = 100.0,
                                                                                                     step = 0.1,
                                                                                                     icon = icon("percent")))),
                                                           
                                                           accordion_panel(title = HTML("<b>Special Education</b>"),
                                                                           tags$div(title = "What percentage of Students will require special education services based on IEP rates? Adjust to reflect local trends.",
                                                                                    numericInputIcon(inputId = "IEP", 
                                                                                                     label = "IEP Identification Rate", 
                                                                                                     value = dfltVls$`IEP Identification Rate`, 
                                                                                                     min = 0.0,
                                                                                                     max = 100.0,
                                                                                                     step = 0.1,
                                                                                                     icon = icon("percent"))),
                                                                           
                                                                           tags$div(title = "What's the average number of Students with an IEP per full-time SPED Teacher? Adjust for class size expectations.",
                                                                                    numericInputIcon(inputId = "STsped", 
                                                                                                     label = "Students per Teacher (SPED)", 
                                                                                                     value = dfltVls$`Students per Teacher (SPED)`, 
                                                                                                     min = 0.0,
                                                                                                     max = 100.0,
                                                                                                     step = 0.1,
                                                                                                     icon = icon("user"))),
                                                                           
                                                                           tags$div(title = "What percentage of SPED Teachers typically return each year? Adjust for turnover expectations.",
                                                                                    numericInputIcon(inputId = "RRsped", 
                                                                                                     label = "Teacher Retention Rate (SPED)", 
                                                                                                     value = dfltVls$`Teacher Retention Rate (SPED)`, 
                                                                                                     min = 0.0,
                                                                                                     max = 100.0,
                                                                                                     step = 0.1,
                                                                                                     icon = icon("user")))),
                                                           
                                                           accordion_panel(title = HTML("<b>Non-Special Education</b>"),
                                                                           tags$div(title = "What's the average number of Students without an IEP per full-time non-SPED Teacher? Adjust for class size expectations.",
                                                                                    numericInputIcon(inputId = "STgen", 
                                                                                                     label = "Students per Teacher (Non-SPED)", 
                                                                                                     value = dfltVls$`Students per Teacher (Non-SPED)`, 
                                                                                                     min = 0.0,
                                                                                                     max = 100.0,
                                                                                                     step = 0.1,
                                                                                                     icon = icon("user"))),
                                                                           
                                                                           tags$div(title = "What percentage of non-SPED Teachers typically return each year? Adjust for turnover expectations.",
                                                                                    numericInputIcon(inputId = "RRgen", 
                                                                                                     label = "Teacher Retention Rate (Non-SPED)", 
                                                                                                     value = dfltVls$`Teacher Retention Rate (Non-SPED)`, 
                                                                                                     min = 0.0,
                                                                                                     max = 100.0,
                                                                                                     step = 0.1,
                                                                                                     icon = icon("user")))))),
                                 
                                 a(actionButton(inputId = "email1", label = "Have a Question or Suggestion?", 
                                                icon = icon("envelope", lib = "font-awesome")),
                                   href = "mailto:Matthew.Faiello@doe.k12.de.us?subject=TWPT%20Feedback&body=Your%20feedback%20goes%20directly%20to%20Matt%20Faiello%20%28he%2Fhim%29%2C%20Associate%20Data%20Scientist%20%40%20DDOE%20Data%20Analytics.")),
               
               navset_card_underline(title = HTML('<b><font size = "5">Teacher Workforce Planning Tool</font></b>'),
                                     full_screen = T,
                                     
                                     nav_spacer(),
                                     
                                     nav_panel(title = HTML("<b>Forecasts</b>"), 
                                               icon = icon("chart-line"),
                                               
                                               fluidRow(column(width = 6, align = "left", 
                                                               tags$div(title = "Choose the forecast you’d like to visualize.",
                                                                        pickerInput(inputId = "PLT", 
                                                                                    label = "Output", 
                                                                                    choices = outputList, 
                                                                                    selected = "Hiring Need (Total)",
                                                                                    multiple = F, 
                                                                                    options = pickerOptions(`actions-box` = T)))),
                                                        
                                                        column(width = 6, align = "right",
                                                               tags$div(title = "Download your current forecast visual and planning targets as a ZIP file.",
                                                                        downloadButton("plot1Export", "Download Forecast", icon = icon("chart-line"))))),
                                               
                                               withSpinner(plotOutput("plot", width = "100%", height = "60vh"),
                                                           size = getOption("spinner.size", default = 3),
                                                           color = getOption("spinner.color", default = "#104e8b"))),
                                     
                                     nav_panel(title = HTML('<b>Planning Targets</b>'), 
                                               icon = icon("crosshairs"),
                                               
                                               tags$div(title = "Chose the planning target you would like to explore.",
                                                        pickerInput(inputId = "MTRC", 
                                                                    label = "Output", 
                                                                    choices = metricList, 
                                                                    selected = "Matriculation Rate",
                                                                    multiple = F, 
                                                                    options = pickerOptions(`actions-box` = T))),
                                               
                                               withSpinner(plotOutput("metric", width = "100%", height = "60vh"),
                                                           size = getOption("spinner.size", default = 2),
                                                           color = getOption("spinner.color", default = "#104e8b"))),
                                     
                                     nav_panel(title = HTML("<b>Data Download</b>"), 
                                               icon = icon("table"),
                                               
                                               DTOutput("hist"))),
               
               accordion(open = F,
                         
                         accordion_panel(title = HTML('<b><font size = "5">Past Recruitment Numbers</font></b>'), 
                                         icon = bs_icon("people", size = "2em"),
                                         
                                         htmlOutput("hires"))))






