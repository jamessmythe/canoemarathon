#----------------SERVER FUNCTION ---------------------

server <- function(input, output, session) {
  
  bigtable <- reactive({
    
    data <- table_data
    if (input$season != "All") {
      data <- data[data$Season %in% input$season,]
    }
    if (input$event != "All") {
      data <- data[data$Event %in% input$event,]
    }
    if (input$div != "All") {
      data <- data[data$Race %in% input$div,]
    }
    data
    
  })
  
  # Big Database table with reactive filtering
  output$table <- DT::renderDataTable({
    
    req(bigtable())
    
    validate(need(nrow(bigtable())>0, message = "Please select items from the filters above"))
    
    DT::datatable(
    bigtable(),
    options = list(pageLength = 15), 
    rownames = FALSE)
    
  })
  
  #filtered inputs for main table
  menus_filtered1 <- reactive({
    if ("All" %in% input$season) {
      menus
    } else {
      menus %>% filter(Season %in% input$season)}
  })
  
  observe({
    updateSelectInput(session, "event", choices = c("All", menus_filtered1()$Event), selected = "All")
  })
  
  menus_filtered2 <- reactive({
    if ("All" %in% input$event) {
      menus_filtered1()
    } else {
      menus_filtered1() %>% filter(Event %in% c(input$event))}
  })
  
  observe({
    updateSelectInput(session, "div", choices = c("All",menus_filtered2()$Race), selected = "All")
  })
  
  #define outputs for individual paddler
  output$paddlername <- renderText({paste("Paddler History:",input$paddler)})
  
  output$no_races <- renderText({
    paste(nrow(main_data[main_data$Name2 == input$paddler,]),
          "races entered,")
  })
  
  output$comprate <- renderText({
    paste(round(completeCount$n[completeCount$Name2 == input$paddler]/nrow(main_data[main_data$Name2 == input$paddler,])*100, digits = 0),
          "% completion rate")
  })
  
  output$top3s <- renderText({
    paste("Number of Top 3 finishes:",
          top3s$n[top3s$Name2 == input$paddler]
    )
  })
  
  # output$medals <- renderText({
  #   paste("Number of National Championship medals:",
  #         medals$n[medals$Name2 == input$paddler]
  #   )
  # })
  
  output$faveraces <- renderTable({
    faveraces1 <- faveEvents %>% 
      filter(Name2 == input$paddler) %>% 
      rename(Entries = n) %>% 
      head(5)
    
  }, rownames = FALSE)
  
  output$races <- renderPlot({
    
    racechartdata <- main_data %>% 
      select(Season, Name2) %>% 
      filter(Name2 == input$paddler)
    
    ggplot(racechartdata, aes(Season))+
      geom_histogram(aes(fill = Season), stat = "count")+
      ylab("Number of Races Entered")
    
  })
  
  output$positions <- renderPlot({
    
    poschartdata <- main_data %>% 
      select(Season, Position, Race, Name2) %>% 
      filter(Name2 == input$paddler)
    
    ggplot(poschartdata)+
      geom_point(aes(Season, Position, color = Race), position=position_jitter(width=0.1, height=0.1), size = 5)+
      scale_y_continuous(trans = "reverse", breaks = unique(main_data$Position))
    
  })
  
  output$travels <- renderPlot({
    
    regchartdata <- main_data %>% 
      select(Season, RaceRegion, Name2) %>% 
      filter(Name2 == input$paddler)
    
    ggplot(regchartdata, aes(Season))+
      geom_histogram(aes(fill = RaceRegion), stat = "count")+
      theme(axis.title.y=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank())
    
  })
  
  output$attendance <- renderPlot({
    
    attchartdata <- main_data %>% 
      select(RaceRegion, Event, Season, Race) %>% 
      filter(RaceRegion == input$region, Race %in% input$attdiv)
    
    ggplot(attchartdata, aes(Event))+
      geom_bar(aes(fill = Race), stat = "count")+
      coord_flip()+
      facet_wrap(~Season)
    
  })
  
  output$qualification <- renderTable({
    qualdata <- qualstatus %>% 
      filter(Club == input$qualclub) %>% 
      select(Qualname, RaceCt, Event, Race) %>% 
      spread(Event, Race) %>% 
      arrange(desc(RaceCt), Qualname)
  }, rownames = FALSE)
  
  output$clubpts <- renderTable({
    clubqualdata <- clubdata %>% 
      filter(Region == input$qualreg) %>% 
      select(Club, `Race Name`, `Hasler points`, Total) %>%
      spread(`Race Name`, `Hasler points`) %>% 
      arrange(desc(Total), Club)
  }, rownames = FALSE)
  
  # Big Database table with reactive filtering
  output$promotable <- DT::renderDataTable({
    DT::datatable({
      promos #i.e. render this dataset as a table
    },
    options = list(pageLength = 15), 
    rownames = FALSE)
  }
  )
  
  observeEvent(input$go, {
    
    withBusyIndicatorServer("go", {
      
      changes <- tibble(`Old Name` = input$name_combo, 
                        `First name` = toupper(input$ch_firstname), 
                        Surname = toupper(input$ch_surname))
      
      gs_key(sheet_key) %>% gs_add_row(ws = "names", input = changes)
      
    })
  
  })
  
  
}