
shinyUI(
  dashboardPage(skin = "red",
  dashboardHeader(title = "FIA Formula 1"),
    
  dashboardSidebar(width = 200,
    sidebarUserPanel("Rifat DINCER", 
                     image = "https://images-na.ssl-images-amazon.com/images/I/61Ysu6NeEFL._SY355_.jpg"),
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("book")),
      menuItem("Drivers", tabName = "drivers", icon = icon("graduation-cap")),
      menuItem("Standings", tabName = "standings", icon = icon("line-chart")),
      menuItem("Races", tabName = "races", icon = icon("line-chart")),
      menuItem("Let's Race", tabName = "race_animation", icon = icon("line-chart")),
      menuItem("Source Code", icon = icon("file-code-o"),
               href = "https://github.com/yucedincer/")
      )),
    
  dashboardBody(
    tags$head(
      tags$style(HTML("
                      .content-wrapper {
                      background-color: white !important;
                      }
                      .main-sidebar {
                      background-color: black !important;
                      }
                      "))
      ),
    tabItems(
      tabItem(tabName = "about",
              iframe(width="1120", height="630", url_link = "https://www.youtube.com/embed/k4Pegt-HcI8")),
      
      
      tabItem(tabName = "drivers",
              fluidPage(
                h3("Driver Info"),
                fluidRow(column(width = 6,plotlyOutput("champ_counts")),
                         column(width = 6, plotlyOutput("country_wins"))),
                fluidRow(DT::dataTableOutput("drivers_table"))
  
              )),
      
      
      tabItem(tabName = "race_animation", 
              fluidPage(
                h4("Please Select a F1 Season & Grand Prix Name"),
                fluidRow(column(width = 4, selectizeInput('year_animation', label = "F1 Season", choices = year_vector_animation)),
                         column(width = 4, uiOutput("gp_name_animation"))),
                h5("Even if you see an error, please be patient, animation is loading!"),
                plotlyOutput("race_animation")
                
              )),
      
      
      tabItem(tabName = "standings", 
              fluidPage(
                h1("Grand Prix Standings", align = "center"),
                br(),
                h6("Please Select a Season & Grand Prix", align = "center"),
                br(),
                fluidRow(column(width = 4, selectizeInput('year_table1', label = "F1 Season", choices = year_vector)),
                         column(width = 4, uiOutput("dynamic_widget"))),
                br(),
                fluidRow(
                column(4,
                  uiOutput("max_speed")
                ),
                
                column(4,
                  uiOutput("gps_held")
                ),
                
                column(4, 
                       uiOutput("fastest_lap_time")
                )),

                
                fluidRow(DT::dataTableOutput("race_standings_table"))
                
              )),
      
      
      
      tabItem(tabName = "races",
              h2('Formula 1 Races Schedule Throughout the History'),
              fluidRow(column(width = 1),
                column(width = 2, title = "Select a Formula 1 Season", solidHeader = TRUE, status = "primary",
                    selectInput(inputId = "year_races", label = '', choices = sort(unique(for_map2$year)),
                                selected = NULL, multiple = FALSE),
                DT::dataTableOutput("mini_table")),
                column(width = 9, plotlyOutput("race_map", height = 700), solidHeader = TRUE, status = "primary")
                )
                      )
                
            )       
                )
  ))