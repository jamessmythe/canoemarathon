#-------------UI SECTION ----
fluidPage(
  
  tags$head(includeHTML("GA.html")), #links to CofI client GA script
  tags$head(useShinyjs()),
  tags$head(tags$style(appCSS)),
  
  theme = shinytheme("flatly"),
  
  list(tags$head(HTML('<link rel="icon", href="kayak.png", 
                      type="image/png" />'))),
  div(style="padding: 1px 0px; width: '100%'",
      titlePanel(
        title="", windowTitle="Marathon Results Database"
      )
  ),
  
  fluidRow(column(10, tags$h1("Marathon Racing Committee Results Database")),
           column(2, tags$img(src="BritishCanoeing_LOGOCMYK.png", height = "80px", align = "left"))),
  
  tabsetPanel(
    
    tabPanel("Intro",
             
             fluidRow(column(12, tags$img(src="header.jpg", width = "100%"), tags$h6("Image copyright: Ollie Harding / Olypics"))),
             fluidRow(column(12, tags$h3("Congratulations to those winning a promotion in the last month:"))),
             fluidRow(column(12, DT::dataTableOutput("promotable")))
    ),
    
    tabPanel("Complete Database",
             fluidRow(column(12, tags$h3("Complete Database"), tags$h5("Filter all results since 2009/10 season in the table below"))),
             fluidRow(
               column(4,
                      selectizeInput("season",
                                  "Pick one or more seasons:",
                                  c("All",
                                    unique(menus$Season)),
                                  selected = "2019/20",
                                  multiple = TRUE)
               ),
               column(4,
                      selectizeInput("event",
                                  "Pick one or more events:",
                                  c("All",
                                    unique(menus$Event)),
                                  selected = "All",
                                  multiple = TRUE)
               ),
               column(4,
                      selectizeInput("div",
                                  "Pick one or more Divisions/Classes:",
                                  c("All",
                                    unique(menus$Race)),
                                  selected = "All",
                                  multiple = TRUE)
               )
             ),
             # Create a new row for the table.
             fluidRow(
               column(12, DT::dataTableOutput("table"))
             )),
    
    tabPanel("Paddler History", 
             fluidRow(
               column(7, tags$h3(textOutput("paddlername"), tags$h5("Please note, paddlers may appear as duplicates in this system if they have raced for multiple clubs or if their names were entered incorrectly at races"))),
               column(5,selectInput("paddler", "Choose Paddler: (hit backspace to clear and type in a name)", c(unique(paddlers$Name2)), selected = "LIZZIE BROUGHTON ( RIC )", multiple = FALSE))
             ),
             fluidRow(column(3, tags$h3("Races Entered"), tags$h4(textOutput("no_races")), tags$h4(textOutput("comprate"))),
                      column(9, plotOutput("races"))
             ),
             
             fluidRow(column(3, tags$h3("Positions"), tags$h4(textOutput("top3s"))), #, tags$h4(textOutput("medals")
                      column(9, plotOutput("positions"))
             ),
             
             fluidRow(column(3, tags$h3("Home & Away"), tags$h4("Top races by no. of entries"), tableOutput("faveraces")),
                      column(9, plotOutput("travels"))
             )
    ),
    
    tabPanel("Race Attendance", 
             fluidRow(
               column(6, tags$h3("Race Attendance by Region")),
               column(3,selectInput("attdiv", "Choose one or more Divisions/Classes:", c(unique(divs$Race)), selected = "Div5_5", multiple = TRUE)),
               column(3,selectInput("region", "Choose Region:", c(unique(regions$RaceRegion)), selected = "MID", multiple = FALSE))
             ),
             fluidRow(column(12, plotOutput("attendance"))
             )
    ),
    
    tabPanel("Hasler Final Qualification", 
             fluidRow(
               column(7, tags$h3("Qualifying Status by Paddler & Craft, 2019/20 Season"), tags$h5("Please note the list does not include Assessment Races which count towards Final qualification.")),
               column(5,selectInput("qualclub", "Choose Club: (hit backspace to clear and type in a club abbreviation)", c(unique(qualstatus$Club)), selected = "WOR", multiple = FALSE))
             ),
             fluidRow(column(12, tableOutput("qualification"))
             )
    ),
    
    tabPanel("Club Regional Standings", 
             fluidRow(
               column(7, tags$h3("Regional Clubs Leaderboard, 2018/19 Season"), tags$h5("Please refer to your Regional Marathon Advisor for the number of clubs qualifying for the Final from your region")),
               column(5,selectInput("qualreg", "Choose Region:", c(unique(clubdata$Region)), selected = "SO", multiple = FALSE))
             ),
             fluidRow(column(12, tableOutput("clubpts"))
             )
    ),
    
    tabPanel("Request a Name Change", 
             fluidRow(
               column(12, 
                      tags$h3("Request name change in the database"), 
                      tags$br(),
                      tags$h5("Please note: names are entered manually on or before race days and are subject to some input error."), 
                      tags$br(),
                      tags$h5("You can request that we correct instances of a name, but these requests will be checked manually before being updated"),
                      tags$h5("YOU WON'T GET A CONFIRMATION EMAIL - PLEASE WAIT A WEEK OR SO THEN CHECK THIS DATABASE"),
                      tags$br(),
                      tags$h5("You cannot request a club or class change with this form: to do so,"),
                      tags$h5("please email Race Records Officer Graham Warland at graham.warland@gmail.com"),
                      tags$br(),
                      selectInput("name_combo", "Choose name to edit. Use backspace to type and search", c(unique(names$Name2)), multiple = FALSE),
                      textInput("ch_surname", "Surname (as it should appear in database)", placeholder = "This will be converted to CAPS"),
                      textInput("ch_firstname", "First Name (as it should appear in database)", placeholder = "This will be converted to CAPS"))
             ),
             tags$hr(),
             
             withBusyIndicatorUI(
             actionButton("go", "Submit", class = "btn-success")
             )
    )
  )
  
  )