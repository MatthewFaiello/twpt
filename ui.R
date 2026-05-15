#--------------------------- ui ----------------------------------------------#

ui <- page_sidebar(
  window_title = "Teacher Workforce Planning Tool",
  fillable = TRUE,
  fillable_mobile = TRUE,
  
  useShinyjs(),
  
  tags$script(HTML("
    $(document).on('click', '#plot1Export', function () {
      Shiny.setInputValue('download_clicked', Math.random());
    });
  ")),
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
  sidebar = sidebar(
    width = 375,
    gap = "1rem",
    open = "always",
    
    title = div(
      class = "brand-wrap",
      img(src = "Website-Header.png", class = "brand-logo"),
      div(class = "brand-caption", "Teacher Workforce Planning Tool"),
      div(class = "brand-subcaption", "Delaware teacher workforce forecasting")
    ),
    
    div(
      class = "sidebar-section",
      div(class = "section-kicker", "Steps 1–2"),
      div(class = "section-title", "Select Scope and Forecast Year"),
      
      div(
        class = "info-callout",
        HTML("<strong>Use with care.</strong> TWPT provides planning estimates based on historical data and selected assumptions. Results should be interpreted alongside local context, policy changes, and workforce conditions.")
      ),
      
      div(
        class = "control-block",
        title = "Select an LEA, county, or statewide view for the forecast.",
        pickerInput(
          inputId = "LEA",
          label = "LEA or Grouping",
          choices = leaList,
          selected = "All LEAs",
          multiple = FALSE,
          options = pickerOptions(
            `actions-box` = FALSE,
            liveSearch = TRUE,
            size = 10
          )
        )
      ),
      
      div(
        class = "control-block",
        title = "Select the school year to which the forecast will extend.",
        pickerInput(
          inputId = "SchoolYear",
          label = "Projected School Year",
          choices = schoolYears,
          selected = paste0(yr - 1, "-", yr - 2000),
          multiple = FALSE,
          options = pickerOptions(
            `actions-box` = FALSE,
            size = 8
          )
        )
      )
    ),
    
    div(
      class = "sidebar-section",
      div(class = "section-kicker", "Steps 3–5"),
      div(class = "section-title", "Set Planning Targets"),
      
      accordion(
        open = FALSE,
        
        accordion_panel(
          title = "Enrollment & Student Need",
          value = "enrollment_student_need",
          
          div(
            class = "target-group",
            div(class = "subsection-title", "Enrollment and service need assumptions"),
            
            div(
              class = "control-block",
              title = "What percentage of the school-age population (ages 5–18) is expected to enroll in public schools?",
              numericInputIcon(
                inputId = "Mat",
                label = "Matriculation Rate",
                value = dfltVls$`Matriculation Rate`,
                min = 0.0,
                max = 100.0,
                step = 0.1,
                icon = icon("percent")
              ),
              p(
                class = "control-note",
                "Share of the school-age population expected to enroll in public schools."
              )
            ),
            
            div(
              class = "control-block",
              title = "What percentage of enrolled students is expected to receive special education services?",
              numericInputIcon(
                inputId = "IEP",
                label = "IEP Identification Rate",
                value = dfltVls$`IEP Identification Rate`,
                min = 0.0,
                max = 100.0,
                step = 0.1,
                icon = icon("percent")
              ),
              p(
                class = "control-note",
                "Share of enrolled students expected to receive special education services."
              )
            )
          )
        ),
        
        accordion_panel(
          title = "Teacher Demand",
          value = "teacher_demand",
          
          div(
            class = "target-group",
            div(class = "subsection-title", "Staffing intensity assumptions"),
            
            div(
              class = "control-block",
              title = "Average number of students with an IEP per full-time special education teacher.",
              numericInputIcon(
                inputId = "STsped",
                label = "Students per Teacher (Special Education)",
                value = dfltVls$`Students per Teacher (SPED)`,
                min = 0.0,
                max = 100.0,
                step = 0.1,
                icon = icon("users")
              ),
              p(
                class = "control-note",
                "Used to estimate special education teacher demand."
              )
            ),
            
            div(
              class = "control-block",
              title = "Average number of students without an IEP per full-time non-special education teacher.",
              numericInputIcon(
                inputId = "STgen",
                label = "Students per Teacher (Non-Special Education)",
                value = dfltVls$`Students per Teacher (Non-SPED)`,
                min = 0.0,
                max = 100.0,
                step = 0.1,
                icon = icon("users")
              ),
              p(
                class = "control-note",
                "Used to estimate non-special education teacher demand."
              )
            )
          )
        ),
        
        accordion_panel(
          title = "Teacher Retention",
          value = "teacher_retention",
          
          div(
            class = "target-group",
            div(class = "subsection-title", "Workforce stability assumptions"),
            
            div(
              class = "control-block",
              title = "What percentage of special education teachers typically return the following year?",
              numericInputIcon(
                inputId = "RRsped",
                label = "Teacher Retention Rate (Special Education)",
                value = dfltVls$`Teacher Retention Rate (SPED)`,
                min = 0.0,
                max = 100.0,
                step = 0.1,
                icon = icon("rotate-left")
              ),
              p(
                class = "control-note",
                "Applied to prior-year demand to estimate retained special education teachers."
              )
            ),
            
            div(
              class = "control-block",
              title = "What percentage of non-special education teachers typically return the following year?",
              numericInputIcon(
                inputId = "RRgen",
                label = "Teacher Retention Rate (Non-Special Education)",
                value = dfltVls$`Teacher Retention Rate (Non-SPED)`,
                min = 0.0,
                max = 100.0,
                step = 0.1,
                icon = icon("rotate-left")
              ),
              p(
                class = "control-note",
                "Applied to prior-year demand to estimate retained non-special education teachers."
              )
            )
          )
        )
      )
    ),
    
    div(
      class = "sidebar-footer",
      tags$a(
        href = "mailto:Matthew.Faiello@doe.k12.de.us?subject=TWPT%20Feedback&body=Your%20feedback%20goes%20directly%20to%20Matt%20Faiello%20%28he%2Fhim%29%2C%20Associate%20Data%20Scientist%20%40%20DDOE%20Data%20Analytics.",
        class = "feedback-link",
        actionButton(
          inputId = "email1",
          label = "Have a Question or Suggestion?",
          icon = icon("envelope", lib = "font-awesome")
        )
      )
    )
  ),
  
  div(
    class = "main-stack",
    
    navset_card_underline(
      full_screen = TRUE,
      
      nav_panel(
        title = strong("Forecasts"),
        icon = icon("chart-line"),
        
        div(
          class = "panel-shell",
          
          div(
            class = "panel-card",
            
            div(
              class = "panel-card-header",
              div(
                class = "panel-header",
                div(
                  class = "panel-header-text",
                  div(class = "panel-title", "Projected Teacher Workforce"),
                  p(
                    class = "panel-subtitle",
                    "Compare projected teacher demand, retained teachers, and hiring need based on the selected planning targets."
                  )
                ),
                div(
                  class = "panel-header-controls",
                  div(
                    class = "control-inline",
                    title = "Choose the workforce measure you would like to visualize.",
                    pickerInput(
                      inputId = "PLT",
                      label = "Projected Measure",
                      choices = outputList,
                      selected = "Hiring Need (Total)",
                      multiple = FALSE,
                      options = pickerOptions(
                        `actions-box` = FALSE,
                        size = 10
                      )
                    )
                  ),
                  div(
                    class = "control-action",
                    title = "Download the current forecast chart and the planning target values used to produce it as a ZIP file.",
                    downloadButton(
                      outputId = "plot1Export",
                      label = "Download Forecast",
                      icon = icon("chart-line")
                    )
                  )
                )
              )
            ),
            
            div(
              class = "panel-card-body",
              
              div(
                class = "recruitment-wrap",
                accordion(
                  open = FALSE,
                  accordion_panel(
                    title = "Past Recruitment Numbers",
                    value = "past_recruitment_numbers",
                    icon = bs_icon("people", size = "1.1em"),
                    p(
                      class = "recruitment-note",
                      "Historical recruitment counts for the selected scope, including new hires, transfer hires, and total hires."
                    ),
                    div(
                      class = "hires-shell",
                      DTOutput("hires"),
                      p(
                        class = "recruitment-note",
                        "New hires are teachers not employed in a Delaware public school in the prior year. Transfer hires are teachers who moved between LEAs or between special education and non-special education roles."
                      )
                    )
                  )
                )
              ),
              
              div(
                class = "plot-shell",
                withSpinner(
                  plotOutput("plot", width = "100%", height = "100%"),
                  size = getOption("spinner.size", default = 3),
                  color = getOption("spinner.color", default = "#194a78")
                ),
                p(
                  class = "plot-caption",
                  "Forecasts reflect the selected scope and planning targets and should be interpreted as planning estimates rather than exact predictions."
                )
              )
            )
          )
        )
      ),
      
      nav_panel(
        title = strong("Planning Target Trends"),
        icon = icon("crosshairs"),
        
        div(
          class = "panel-shell",
          div(
            class = "panel-card",
            div(
              class = "panel-card-header",
              div(
                class = "panel-header",
                div(
                  class = "panel-header-text",
                  div(class = "panel-title", "Planning Target Trends"),
                  p(
                    class = "panel-subtitle",
                    "View historical and projected trends in key planning targets to help set future assumptions."
                  )
                ),
                div(
                  class = "panel-header-controls",
                  div(
                    class = "control-inline",
                    title = "Choose the planning target you would like to explore.",
                    pickerInput(
                      inputId = "MTRC",
                      label = "Planning Target",
                      choices = metricList,
                      selected = "Matriculation Rate",
                      multiple = FALSE,
                      options = pickerOptions(
                        `actions-box` = FALSE,
                        size = 10
                      )
                    )
                  )
                )
              )
            ),
            div(
              class = "panel-card-body",
              div(
                class = "plot-shell",
                withSpinner(
                  plotOutput("metric", width = "100%", height = "100%"),
                  size = getOption("spinner.size", default = 2),
                  color = getOption("spinner.color", default = "#194a78")
                ),
                p(
                  class = "plot-caption",
                  "Trend views provide historical context and projected values for the planning targets used in forecasting."
                )
              )
            )
          )
        )
      ),
      
      nav_panel(
        title = strong("Data Download"),
        icon = icon("table"),
        
        div(
          class = "panel-shell",
          div(
            class = "panel-card",
            div(
              class = "panel-card-header",
              div(
                class = "panel-header",
                div(
                  class = "panel-header-text",
                  div(class = "panel-title", "Underlying Data"),
                  p(
                    class = "panel-subtitle",
                    "Review and export the historical and forecasted values underlying the planning views and workforce forecasts."
                  )
                )
              )
            ),
            div(
              class = "panel-card-body",
              div(
                class = "data-download-shell",
                div(
                  class = "table-shell",
                  DTOutput("hist")
                )
              )
            )
          )
        )
      )
    )
  )
)
