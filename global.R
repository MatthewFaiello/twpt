#--------------------------- global ------------------------------------------#
library(shiny)
library(shinyWidgets)
library(tidyverse)
library(knitr)
library(kableExtra)
library(DT)
library(ggthemes)
library(ggfun)
library(ggrepel)
library(bslib)
library(janitor)
library(shinyjs)
library(bsicons)
library(webshot2)
library(pagedown)
library(chromote)
library(curl)
library(magick)
library(shinycssloaders)


#------------------global options
options(shiny.sanitize.errors = T)


###############################################################################
#-------------------------------- load files ---------------------------------#
preprocessed <- readRDS("preprocessed_data.rds")
#preprocessed <- readRDS("twpt/preprocessed_data.rds")

data <- preprocessed$data
yr <- preprocessed$yr

lea_data_list <- preprocessed$lea_data_list
protected <- preprocessed$protected

topLevels <- preprocessed$topLevels
leaList <- preprocessed$leaList

schoolYears <- preprocessed$schoolYears

tpts <- preprocessed$tpts
outputList <- preprocessed$outputList
metricList <- preprocessed$metricList

dfltVls <- preprocessed$dfltVls

#for testing
#input <- tibble(LEA = "Appoquinimink School District", SchoolYear = 2034, Mat = 15.1, IEP = 16.9, STsped = 8.1, STgen = 16.2, RRsped = 89.9, RRgen = 90.3, PLT = "Hiring Need (Total)")
#data <- data %>% filter(LEA == input$LEA)


#--------------------growth model function------------------------------------#
cagrf <- 
  function(d,
           begin,
           end_,
           mat_,
           iep_,
           STsped_,
           STgen_,
           RRsped_,
           RRgen_) {
    
    tmp <-
      d %>% 
      filter(`School Year` %in% c(begin, end_)) %>% 
      select(`School Year`, County, `LEA Type`, LEA, `Grade Level`,
             `Matriculation Rate`, 
             `IEP Identification Rate`,
             `Students per Teacher (SPED)`,
             `Students per Teacher (Non-SPED)`,
             `Teacher Retention Rate (SPED)`,
             `Teacher Retention Rate (Non-SPED)`) %>% 
      mutate(`Matriculation Rate` = coalesce(`Matriculation Rate`, mat_ / 100), 
             `IEP Identification Rate` = coalesce(`IEP Identification Rate`, iep_ / 100),
             
             `Students per Teacher (SPED)` = coalesce(`Students per Teacher (SPED)`, STsped_),
             `Students per Teacher (Non-SPED)` = coalesce(`Students per Teacher (Non-SPED)`, STgen_),
             
             `Teacher Retention Rate (SPED)` = coalesce(`Teacher Retention Rate (SPED)`, RRsped_ / 100),
             `Teacher Retention Rate (Non-SPED)` = coalesce(`Teacher Retention Rate (Non-SPED)`, RRgen_ / 100)) %>% 
      
      pivot_longer(cols = c(`Matriculation Rate`:`Teacher Retention Rate (Non-SPED)`)) %>% 
      pivot_wider(id_cols = County:name, 
                  names_from = `School Year`,
                  values_from = value) %>% 
      mutate(start = begin,
             end = end_,
             periods = length(end_:begin) - 1,
             PI = get(as.character(end_)) / get(as.character(begin)),
             PI = case_when(is.na(PI) ~ 0,
                            is.infinite(PI) ~ 1,
                            .default = PI),
             CAGR = PI ^ (1 / periods)) %>% 
      select(County:name, 
             start, startValue = paste(begin),
             end, endValue = paste(end_), 
             periods:CAGR)
    
    #output
    return(tmp)}

#for testing
#prcntNcrs <- cagrf(d = data, begin = yr, end_ = input$SchoolYear, mat_ = input$Mat, iep_ = input$IEP, STsped_ = input$STsped, STgen_ = input$STgen, RRsped_ = input$RRsped, RRgen_ = input$RRgen)


#--------------------prediction model function--------------------------------#
predict_model <- 
  function(d, 
           rate,
           begin,
           end) {
    
    future_years <- tibble(`School Year` = (begin + 1):end)
    county <- unique(d$County)
    type <- unique(d$`LEA Type`)
    lea <- unique(d$LEA)
    grades <- unique(d$`Grade Level`)
    future_grid <- expand_grid(`School Year` = future_years$`School Year`, 
                               County = county,
                               `LEA Type` = type,
                               LEA = lea,
                               `Grade Level` = grades)
    
    base <- 
      d %>%
      filter(`School Year` == begin) %>%
      select(County, `LEA Type`, LEA, `Grade Level`, 
             `Matriculation Rate`, `IEP Identification Rate`,
             `Students per Teacher (SPED)`, `Students per Teacher (Non-SPED)`, 
             `Teacher Retention Rate (SPED)`, `Teacher Retention Rate (Non-SPED)`) %>%
      pivot_longer(-c(County, `LEA Type`, LEA, `Grade Level`), 
                   names_to = "name", values_to = "startValue")
    
    rates <- 
      rate %>%
      select(County, `LEA Type`, LEA, `Grade Level`, name, CAGR)
    
    forecast <- 
      future_grid %>%
      left_join(base, by = c("County", "LEA Type", "LEA", "Grade Level"), 
                relationship = "many-to-many") %>%
      left_join(rates, by = c("County", "LEA Type", "LEA", "Grade Level", "name")) %>%
      
      mutate(years_ahead = `School Year` - begin,
             value = startValue * (CAGR ^ years_ahead)) %>%
      
      select(`School Year`, County, `LEA Type`, LEA, `Grade Level`, name, value) %>%
      pivot_wider(names_from = name, values_from = value) %>% 
      left_join(d %>% select(`School Year`, County, `LEA Type`, LEA, `Grade Level`, 
                             `Population (5-18 yrs)`, `Teachers Hired (Total)`, 
                             `Teacher New Hires (SPED)`, `Teacher Transfer Hires (SPED)`, 
                             `Teachers Hired (SPED)`, `Teacher New Hires (Non-SPED)`, 
                             `Teacher Transfer Hires (Non-SPED)`, `Teachers Hired (Non-SPED)`),
                by = c("School Year", "County", "LEA Type", "LEA", "Grade Level"))
    
    output <- bind_rows(d %>% filter(`School Year` <= begin), forecast)
    
    #output
    return(output)}

#for testing
#predCAGR <- predict_model(d = data, rate = prcntNcrs, begin = yr, end = input$SchoolYear)


#--------------------demand model function------------------------------------#
demand <- 
  function(d) {
    
    tmp <-
      d %>% 
      mutate(Enrollment = if_else(is.na(Enrollment), 
                                  `Population (5-18 yrs)` * `Matriculation Rate`, 
                                  Enrollment),
             
             `Students (IEP)` = if_else(is.na(`Students (IEP)`), 
                                        Enrollment * `IEP Identification Rate`, 
                                        `Students (IEP)`),
             
             `Students (No IEP)` = if_else(is.na(`Students (No IEP)`), 
                                           Enrollment - `Students (IEP)`, 
                                           `Students (No IEP)`),
             
             `Teacher Demand (Non-SPED)` = if_else(is.na(`Teacher Demand (Non-SPED)`), 
                                                   `Students (No IEP)` / `Students per Teacher (Non-SPED)`, 
                                                   `Teacher Demand (Non-SPED)`),
             `Teacher Demand (Non-SPED)` = if_else(is.infinite(`Teacher Demand (Non-SPED)`), 
                                                   0, 
                                                   `Teacher Demand (Non-SPED)`),
             
             `Teacher Demand (SPED)` = if_else(is.na(`Teacher Demand (SPED)`), 
                                               `Students (IEP)` / `Students per Teacher (SPED)`, 
                                               `Teacher Demand (SPED)`),
             `Teacher Demand (SPED)` = if_else(is.infinite(`Teacher Demand (SPED)`), 
                                               0, 
                                               `Teacher Demand (SPED)`),
             
             `Teacher Demand (Total)` = if_else(is.na(`Teacher Demand (Total)`), 
                                                `Teacher Demand (Non-SPED)` + `Teacher Demand (SPED)`, 
                                                `Teacher Demand (Total)`),
             
             `Teachers Retained (Non-SPED)` = if_else(is.na(`Teachers Retained (Non-SPED)`), 
                                                      `Teacher Retention Rate (Non-SPED)` * lag(`Teacher Demand (Non-SPED)`), 
                                                      `Teachers Retained (Non-SPED)`),
             
             `Teachers Retained (SPED)` = if_else(is.na(`Teachers Retained (SPED)`), 
                                                  `Teacher Retention Rate (SPED)` * lag(`Teacher Demand (SPED)`), 
                                                  `Teachers Retained (SPED)`),
             
             `Teachers Retained (Total)` = if_else(is.na(`Teachers Retained (Total)`), 
                                                   `Teachers Retained (Non-SPED)` + `Teachers Retained (SPED)`, 
                                                   `Teachers Retained (Total)`))
    
    #output
    return(tmp)}

#for testing
#full <- demand(d = bind_rows(predCAGR, data %>% filter(`School Year` <= yr)))


#----------------------plot model function------------------------------------#
pltFx <-
  function(d, 
           vr, 
           ttl, 
           sy,
           sh, 
           fh, 
           rnd, 
           lab,
           clrs) {
    
    options(scipen = 9999)
    
    ggplot(d) +
      aes(y = .data[[vr]], x = `School Year`) +
      facet_grid(#rows = vars(`Grade Level`),
                 cols = vars(LEA)) +
      geom_line(aes(linetype = hst, color = .data[[ttl]]), show.legend = T, linewidth = 2) +
      geom_point(aes(color = .data[[ttl]]), show.legend = T, size = 4) +
      geom_label_repel(aes(label = ifelse(round(.data[[vr]], rnd) < 15 & vr %in% protected, 
                                          "< 15",
                                          ifelse(`School Year` %in% fh, 
                                                 paste0(round(.data[[vr]], rnd), lab), 
                                                 
                                                 ifelse(`School Year` %in% c(yr + 1, sh, sy), 
                                                        
                                                        ifelse((.data[[vr]] - .data[[vr]][.data$`School Year` == yr]) >= 0,
                                                               paste0("+", round(.data[[vr]] - .data[[vr]][.data$`School Year` == yr], rnd), lab),
                                                               paste0(round(.data[[vr]] - .data[[vr]][.data$`School Year` == yr], rnd), lab)), "")))), 
                       box.padding = 1.5,
                       nudge_x = 0.5,
                       label.padding = 0.35,
                       point.padding = 0, 
                       min.segment.length = 0,
                       segment.size = 1,          
                       segment.color = "black",     
                       arrow = arrow(length = unit(0.02, "npc"), type = "closed"), 
                       fill = "#194a78",        
                       color = "white",             
                       label.size = 0.25,
                       fontface = "bold",
                       size = 5,
                       show.legend = F) +
      scale_x_continuous(breaks = c(fh, sh),
                         labels = c(paste0(c(fh, sh) - 1, "-", c(fh, sh) - 2000)),
                         limits = c(min(d$`School Year`), max(d$`School Year`) + 1.5)) +
      ylim(min(d[[vr]]) * .75, max(d[[vr]]) * 1.25) +
      scale_linetype_manual(values = c("solid", "dashed"),
                            breaks = unique(d$hst)) +
      scale_color_manual(values = clrs) +
      
      geom_vline(xintercept = yr, linetype = "solid") +
      theme_hc() +
      theme(plot.title = element_blank(),
            legend.title = element_text(face = "bold", size = 17, hjust = 0.5),
            legend.title.position = "left",
            plot.caption = element_blank(),
            strip.text.x = element_text(face = "bold", size = 17, color = "white"),
            strip.text.y = element_text(face = "bold", size = 17, color = "white", angle = 270),
            legend.position = "bottom",
            axis.text.y = element_text(face = "bold", size = 12),
            axis.text.x = element_text(face = "bold", size = 11),
            panel.grid.major.x = element_line(color = "lightgrey", linewidth = 0.25, linetype = 6),
            axis.ticks = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            strip.background = element_roundrect(fill = NA, color = "#194a78", r = grid::unit(0.25, "snpc")),
            legend.key = element_rect(fill = NA, color = NA),
            strip.background.x = element_rect(fill = "#194a78", color = "#194a78"),
            strip.background.y = element_rect(fill = "#194a78", color = "#194a78"),
            legend.text = element_text(face = "bold", size = 17),
            legend.box.margin = margin(25, 25, 25, 25)) +
      guides(color = guide_legend(nrow = 1),
             linetype = "none") -> tmp
    
    return(tmp)}









