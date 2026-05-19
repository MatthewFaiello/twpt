#--------------------------- server ------------------------------------------#
# This file contains the app logic in the same order as the UI tabs.
server <- function(input, output, session) {
    #-------------------update inputs
    observeEvent(input$LEA, {
      dat <- 
        lea_data_list[[input$LEA]] %>%
        filter(`School Year` == yr) %>%
        distinct()
      
      updateNumericInputIcon(inputId = "Mat", 
                             label = "Matriculation Rate", 
                             value = round((dat$`Matriculation Rate` * 100), 1), 
                             min = 0.0, max = 100.0, step = 0.1, icon = icon("percent"))
      
      updateNumericInputIcon(inputId = "IEP", 
                             label = "IEP Identification Rate", 
                             value = round((dat$`IEP Identification Rate` * 100), 1), 
                             min = 0.0, max = 100.0, step = 0.1, icon = icon("percent"))
      
      updateNumericInputIcon(inputId = "STsped", 
                             label = "Students per Teacher (Special Education)", 
                             value = round(dat$`Students per Teacher (SPED)`, 1), 
                             min = 0.0, max = 100.0, step = 0.1, icon = icon("user"))
      
      updateNumericInputIcon(inputId = "STgen", 
                             label = "Students per Teacher  (Non-Special Education)", 
                             value = round(dat$`Students per Teacher (Non-SPED)`, 1), 
                             min = 0.0, max = 100.0, step = 0.1, icon = icon("user"))
      
      updateNumericInputIcon(inputId = "RRsped", 
                             label = "Teacher Retention Rate  (Special Education)", 
                             value = round((dat$`Teacher Retention Rate (SPED)` * 100), 1), 
                             min = 0.0, max = 100.0, step = 0.1, icon = icon("percent"))
      
      updateNumericInputIcon(inputId = "RRgen", 
                             label = "Teacher Retention Rate (Non-Special Education)", 
                             value = round((dat$`Teacher Retention Rate (Non-SPED)` * 100), 1), 
                             min = 0.0, max = 100.0, step = 0.1, icon = icon("percent"))})
    
    
    #--------------delay inputs
    vals <- 
      reactive({req(input$Mat, input$IEP, input$STsped, input$STgen, input$RRsped, input$RRgen)
        list(Mat = input$Mat, IEP = input$IEP, STsped = input$STsped,
             STgen = input$STgen, RRsped = input$RRsped, RRgen = input$RRgen)})
    
    debouncedVals <- throttle(vals, 300)
    
    
    #----------------------------- forecasts -----------------------------------------------#
    demand_data <- 
      reactive({
        
        vals <- req(debouncedVals())
        
        dat <- lea_data_list[[req(input$LEA)]]
        
        filtered_data <- 
          dat %>%
          filter(`School Year` >= yr, `School Year` <= req(input$SchoolYear))
        
        tmp0 <- 
          cagrf(d = filtered_data,
                begin = yr,
                end_ = input$SchoolYear,
                mat_ = vals$Mat,
                iep_ = vals$IEP,
                STsped_ = vals$STsped,
                STgen_ = vals$STgen,
                RRsped_ = vals$RRsped,
                RRgen_ = vals$RRgen)
        
        tmp1 <- 
          predict_model(d = filtered_data,
                        rate = tmp0,
                        begin = yr,
                        end = input$SchoolYear)
        
        tmp2 <- demand(d = bind_rows(tmp1, dat %>% filter(`School Year` < yr)))
        
        return(tmp2)})
    
    
    #panel 1 ##################################################################
    #card 1 ##################################################################
    #---------------forecast plot
    plot1Fx <- 
      reactive({
        
        vr <- input$PLT
        
        dmnd <- demand_data()
        
        if (vr %in% c("Population (5-18 yrs)", "Enrollment", "Students with an IEP")) {
          
          tmp <-
            dmnd %>% 
            {if (vr == "Students with an IEP") rename(., `Students with an IEP` = `Students (IEP)`) else .} %>% 
            {if (vr == "Population (5-18 yrs)") mutate(., LEA = County) else .} %>% 
            mutate(LEA = str_remove(LEA, " School District"),
                   hst = if_else(`School Year` <= yr, "h", "p")) %>% 
            pivot_longer(starts_with(vr)) %>% 
            rename(!!vr := value) %>% 
            mutate(name = if_else(str_detect(name, "\\("), str_extract(name, "(?<=\\().*?(?=\\))"), name))
          
          if (vr == "Population (5-18 yrs)") {
            tmp <- tmp %>% mutate(LEA = if_else(County == "Statewide", County, paste(County, "County")))}
          
          clrs <- c("darkgreen", "purple4")
          
          ttl <- "name"} else {
            
            d <-
              dmnd %>% 
              mutate(LEA = str_remove(LEA, " School District"),
                     hst = if_else(`School Year` <= yr, "h", "p")) %>% 
              pivot_longer(starts_with(c("Teacher Demand", "Teachers Retained"))) %>% 
              filter(str_detect(name, paste0("\\", str_extract(vr, "\\(.*(?=\\))")))) %>% 
              rename(!!vr := value)
            
            mxD <-
              d %>% 
              filter(`School Year` == input$SchoolYear,
                     str_detect(name, "Teacher Demand")) %>% 
              select(all_of(vr)) %>% 
              pull()
            
            mxR <-
              d %>% 
              filter(`School Year` == input$SchoolYear,
                     str_detect(name, "Teachers Retained")) %>% 
              select(all_of(vr)) %>% 
              pull()
            
            ttl <- str_extract(d$name, "(?<=\\().*?(?=\\))") %>% unique()
            
            tmp <- 
              d %>% 
              mutate(name = str_remove(name, " \\(.*?\\)")) %>% 
              rename(!!ttl := name)
            
            clrs <- c("darkorange3", "firebrick4")}
        
        lab = ""
        rnd = 0
        
        fh = c(min(data$`School Year`), 2015, 2018, 2020, 2023, yr)
        sh = c(2029, 2031, 2034, max(data$`School Year`))
        
        sy <- max(tmp$`School Year`)
        
        p <- pltFx(d = tmp, 
                   vr = vr, 
                   ttl = ttl, 
                   sy = sy,
                   sh = sh, 
                   fh = fh, 
                   rnd = rnd, 
                   lab = lab, 
                   clrs = clrs)
        
        if (str_detect(vr, "Hiring Need")) {
          
          gap <- round(mxD - mxR)
          
          title_txt <- if (gap > 0) {
            paste0("Projected staffing gap: ",
                   gap, 
                   " ",
                   str_extract(vr, "(?<=\\().+?(?=\\))"),
                   " Teacher vacancies in SY ",
                   sy - 1, "-",
                   sy - 2000)
          } else if (gap == 0) {
            paste0("Projected staffing balance in SY ",
                   sy - 1, "-",
                   sy - 2000,
                   ": no ", 
                   str_extract(vr, "(?<=\\().+?(?=\\))"),
                   " Teacher vacancies expected")
          } else {
            paste0("Projected staffing surplus: ",
                   gap,
                   " ",
                   str_extract(vr, "(?<=\\().+?(?=\\))"),
                   " Teachers in SY ",
                   sy - 1, "-",
                   sy - 2000)}
          
          p <- p +
            annotate(geom = "line",
                     x = sy,
                     y = c(mxR, mxD),
                     linewidth = 1,
                     color = "black",
                     linetype = "dotted") +
            annotate(geom = "text",
                     x = sy + 0.25,
                     hjust = 0,
                     size = 3.5,
                     fontface = "bold",
                     y = mean(c(mxD, mxR)),
                     label = paste(gap, "Teachers")) +
            labs(color = paste0(ttl, ": "),
                 title = title_txt) +
            theme(plot.title.position = "plot",
                  plot.title = element_text(size = 19, face = "bold", hjust = 0.5))
                    
          
        } else {
          p <- p + labs(color = "")}
        
        return(p)})
    
    output$plot <- renderPlot({plot1Fx()})
    
    
    #------------------download forecast chart and assumptions
    output$plot1Export <- downloadHandler(
      filename = function() {
        req(input$LEA, input$SchoolYear)
        safe_lea <- make_safe_name(input$LEA)
        timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
        paste0("TWPT_", safe_lea, "_", input$SchoolYear, "_", timestamp, ".zip")
      },
      
      contentType = "application/zip",
      
      content = function(file) {
        req(input$LEA, input$SchoolYear, input$PLT)
        vals <- req(debouncedVals())
        
        note_id <- showNotification(
          "Preparing your download...",
          type = "message",
          duration = NULL,
          closeButton = FALSE,
          session = session
        )
        
        download_ok <- FALSE
        on.exit({
          removeNotification(note_id, session = session)
          
          if (download_ok) {
            showNotification(
              "Download ready. Check your downloads folder.",
              type = "message",
              duration = 5,
              session = session
            )
          } else {
            showNotification(
              "Download failed. Please try again or contact Matt if this keeps happening.",
              type = "error",
              duration = 8,
              session = session
            )
          }
        }, add = TRUE)
        
        year <- as.integer(input$SchoolYear)
        school_year_label <- make_school_year_label(year)
        timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
        safe_lea <- make_safe_name(input$LEA)
        
        export_dir <- tempfile("twpt_download_")
        dir.create(export_dir, recursive = TRUE, showWarnings = FALSE)
        on.exit(unlink(export_dir, recursive = TRUE, force = TRUE), add = TRUE)
        
        plot_file <- file.path(
          export_dir,
          paste0("forecast_chart_", safe_lea, "_", year, "_", timestamp, ".png")
        )
        
        inputs_file <- file.path(
          export_dir,
          paste0("planning_targets_", safe_lea, "_", year, "_", timestamp, ".csv")
        )
        
        readme_file <- file.path(
          export_dir,
          paste0("read_me_", safe_lea, "_", year, "_", timestamp, ".txt")
        )
        
        # Save the current forecast chart.
        ggplot2::ggsave(
          filename = plot_file,
          plot = plot1Fx(),
          width = 13.33,
          height = 7,
          units = "in",
          dpi = 300,
          bg = "white",
          device = "png"
        )
        
        # Save the planning targets as a simple CSV.
        planning_targets <- tibble::tibble(
          `LEA or Grouping` = input$LEA,
          `Projected School Year` = school_year_label,
          `Projected Measure` = input$PLT,
          `Matriculation Rate (%)` = vals$Mat,
          `IEP Identification Rate (%)` = vals$IEP,
          `Students per Teacher (SPED)` = vals$STsped,
          `Students per Teacher (Non-SPED)` = vals$STgen,
          `Teacher Retention Rate (SPED) (%)` = vals$RRsped,
          `Teacher Retention Rate (Non-SPED) (%)` = vals$RRgen
        )
        
        readr::write_csv(planning_targets, inputs_file, na = "")
        
        # Save a short plain-language note for the ZIP file.
        readr::write_lines(
          c(
            "Teacher Workforce Planning Tool download",
            "",
            paste0("LEA or Grouping: ", input$LEA),
            paste0("Projected School Year: ", school_year_label),
            paste0("Projected Measure: ", input$PLT),
            "",
            "Files included:",
            "- forecast_chart: PNG image of the current forecast chart",
            "- planning_targets: CSV file with the assumptions used to create the forecast",
            "",
            "Note: TWPT provides planning estimates based on historical data and selected assumptions. Results should be interpreted alongside local context, policy changes, and workforce conditions."
          ),
          readme_file
        )
        
        # Create the ZIP file returned by the download button.
        zip::zipr(
          zipfile = file,
          files = list.files(export_dir),
          root = export_dir,
          include_directories = FALSE
        )
        
        download_ok <- TRUE
      }
    )
    
    
    #card 2 ##################################################################
    #------------------metric plot
    cached_metric <- 
      reactive({
        
        #output
        vr <- input$MTRC
        
        dmnd <- demand_data()
        
        d <-
          dmnd %>% 
          mutate(across(contains("Rate"), ~ . * 100),
                 LEA = str_remove(LEA, " School District"),
                 hst = if_else(`School Year` <= yr, "h", "p")) %>% 
          pivot_longer(starts_with(vr)) %>% 
          rename(!!vr := value) %>% 
          mutate(name = if_else(str_detect(name, "\\("), str_extract(name, "(?<=\\().*?(?=\\))"), name)) %>% 
          {if (str_detect(vr, "Students per|Teacher")) mutate(., name = factor(name, levels = c("SPED", "Non-SPED"))) else .}
        
        lab = ""
        rnd = 0
        
        if (str_detect(vr, "Rate")) {lab = "%"; rnd = 1}
        if (str_detect(vr, "per")) {rnd = 1}
        
        fh = c(min(data$`School Year`), 2015, 2018, 2020, 2023, yr)
        sh = c(2029, 2031, 2034, max(data$`School Year`))
        
        sy <- max(d$`School Year`)
        
        clrs <- c("darkgreen", "purple4")
        
        pltFx(d = d, 
              vr = vr, 
              ttl = "name", 
              sy = sy,
              sh = sh, 
              fh = fh, 
              rnd = rnd, 
              lab = lab,
              clrs = clrs) +
          labs(color = "") -> p
        
        return(p)})
    
    output$metric <- renderPlot({p <- cached_metric(); return(p)})
    
    
    #card 3 ##################################################################
    #------------------data download
    output$hist <- 
      renderDT({
        
        dmnd <- demand_data()
        
        datHist <-
          dmnd %>% 
          mutate(`School Year` = paste(`School Year` - 1, 
                                       `School Year` - 2000, 
                                       sep = "-"),
                 LEA = str_remove(LEA, " School District"),
                 `LEA Type` = str_remove(`LEA Type`, "s$"),
                 across(`School Year`:`Grade Level`, ~ factor(.)),
                 across(contains("Rate"), ~ round(. * 100, 1)),
                 across(contains("per"), ~ round(., 1)),
                 across(c(`Population (5-18 yrs)`, Enrollment, `Students (IEP)`, `Students (No IEP)`,
                          contains("Demand"), contains("Hire"), contains("Retained")), ~ round(.)),
                 across(starts_with(protected), ~ ifelse(. < 15, "< 15", .)),
                 `Data Type` = if_else(str_extract(`School Year`, "^\\d+") >= yr, "Forecast", "Actual")) %>% 
          select(`Data Type`,
                 `School Year`,
                 County,
                 `LEA Type`,
                 LEA,
                 `Grade Level`,
                 
                 `Population (5-18 yrs)`,
                 `Matriculation Rate (%)` = `Matriculation Rate`,
                 Enrollment,
                 
                 `IEP Identification Rate (%)` = `IEP Identification Rate`,
                 `Students (IEP)`,
                 `Students per Teacher (SPED)`,
                 `Teacher Demand (SPED)`,
                 `Teacher Retention Rate (SPED)`,
                 `Teachers Retained (SPED)`,
                 `Teacher New Hires (SPED)`,
                 `Teacher Transfer Hires (SPED)`,
                 `Teachers Hired (SPED)`,
                 
                 `Students (No IEP)`,
                 `Students per Teacher (Non-SPED)`,
                 `Teacher Demand (Non-SPED)`,
                 `Teacher Retention Rate (Non-SPED)`,
                 `Teachers Retained (Non-SPED)`,
                 `Teacher New Hires (Non-SPED)`,
                 `Teacher Transfer Hires (Non-SPED)`,
                 `Teachers Hired (Non-SPED)`,
                 
                 `Teacher Demand (Total)`,
                 `Teachers Retained (Total)`,
                 `Teachers Hired (Total)`) %>% 
          arrange(desc(`School Year`))
        
        #output
        datatable(datHist,
                  filter = "none",
                  extensions = "Buttons",
                  rownames = FALSE,
                  class = "compact stripe hover",
                  options = list(dom = "Brti",
                                 buttons = list(list(extend = "excel", 
                                                     text = "Export Data")),
                    scrollX = TRUE,
                    autoWidth = TRUE,
                    pageLength = nrow(datHist),
                    columnDefs = list(list(className = "dt-nowrap", targets = "_all")))) -> dt
        
        return(dt)})
    
    
    #panel 2 ##################################################################
    #------------------table
    output$hires <- DT::renderDT({
      
      vr <- stringr::str_extract(input$PLT, "(?<=\\().*?(?=\\))")
      
      if (input$PLT %in% c("Population (5-18 yrs)", "Enrollment")) vr <- "Total"
      if (input$PLT == "Students with an IEP") vr <- "SPED"
      
      dmnd <- demand_data()
      
      tmp0 <-
        dmnd %>%
        dplyr::filter(`School Year` <= yr)
      
      tmp1 <-
        tmp0 %>%
        dplyr::arrange(desc(`School Year`)) %>%
        dplyr::mutate(
          `Teacher New Hires (Total)` = `Teacher New Hires (SPED)` + `Teacher New Hires (Non-SPED)`,
          `Teacher Transfer Hires (Total)` = `Teacher Transfer Hires (SPED)` + `Teacher Transfer Hires (Non-SPED)`
        ) %>%
        tidyr::pivot_longer(dplyr::contains("Hires")) %>%
        dplyr::mutate(
          grp = stringr::str_extract(name, "(?<=\\().*?(?=\\))"),
          `Staffing Pool` = stringr::str_remove(name, "Teacher "),
          `School Year` = paste0(`School Year` - 1, "-", `School Year` - 2000)
        ) %>%
        dplyr::filter(grp == vr) %>%
        tidyr::pivot_wider(
          id_cols = c(`School Year`:`Grade Level`, `Staffing Pool`),
          names_from = grp,
          values_from = value
        ) %>%
        tidyr::pivot_wider(
          names_from = `School Year`,
          values_from = dplyr::all_of(vr)
        )
      
      tmp2 <-
        tmp1 %>%
        dplyr::select(-County:-`Grade Level`) %>%
        janitor::adorn_totals(name = paste0("All Hires (", vr, ")"))
      
      names(tmp2)[1] <- "Staffing Pool"
      
      year_cols <- names(tmp2)[-1]
      
      n_rows <- nrow(tmp2)
      scroll_height <- min(max(n_rows * 38, 120), 240)
      scroll_height <- paste0(scroll_height, "px")
      
      DT::datatable(
        tmp2,
        rownames = FALSE,
        class = "compact stripe hover nowrap",
        options = list(
          dom = "t",
          paging = FALSE,
          searching = FALSE,
          ordering = FALSE,
          info = FALSE,
          autoWidth = TRUE,
          scrollX = TRUE,
          scrollY = scroll_height,
          scrollCollapse = TRUE,
          columnDefs = list(
            list(className = "dt-left", targets = 0),
            list(className = "dt-center", targets = seq_along(year_cols))
          )
        ),
        callback = DT::JS("
      table.on('init.dt', function() {
        setTimeout(function() {
          table.columns.adjust().draw(false);
        }, 100);
      });

      $(document).on('shown.bs.collapse', function() {
        $.fn.dataTable
          .tables({ visible: true, api: true })
          .columns.adjust()
          .draw(false);
      });

      $(window).on('resize', function() {
        $.fn.dataTable
          .tables({ visible: true, api: true })
          .columns.adjust()
          .draw(false);
      });
    ")
      ) %>%
        DT::formatStyle(
          "Staffing Pool",
          fontWeight = "700",
          backgroundColor = "#fcfdff"
        )
      
    }, server = FALSE)
}
