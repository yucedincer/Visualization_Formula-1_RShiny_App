
shinyServer(function(input, output) {
  
##### WORLD MAP  
  output$race_map <- renderPlotly({
    for_map2 <- for_map2 %>%
      dplyr::filter(., year == input$year_races)
    
    geo <- list(
      showframe = FALSE,
      showland = TRUE,
      showcoastlines = TRUE,
      projection = list(type = 'orthographic'
                        ),
      resolution = '10000',
      showcountries = TRUE,
      countrycolor = '#ededed',
      showocean = TRUE,
      oceancolor = '#0077be',
      showlakes = TRUE,
      lakecolor = '#0077be'

    )
    
    plot_geo(locationmode = 'country names', color = I("red")) %>%
      add_markers(
      data = for_map2, x = for_map2$lng, y = for_map2$lat,
      hovertext = "text", alpha = 1
      ) %>%
      add_segments(
        data = for_map2,
        x = for_map2$lng, xend = for_map2$EndLong,
        y = for_map2$lat, yend = for_map2$EndLat,
        alpha = 0.5, size = I(4), text = paste(for_map2$name, ", Race #", seq(1, length(for_map2$race_id), by = 1))
      ) %>%
      layout(
        geo = geo, showlegend = FALSE, height=700, hovermode = 'closest'
  
      )
  })
  
  output$mini_table = DT::renderDataTable({datatable((
    unique(race_stats_final %>% filter(., year == input$year_races) %>% select('gp_name'))),
           options = list(searching = FALSE))
    
  })
  ##### RACE STANDINGS TABLE
  output$race_standings_table = DT::renderDataTable({datatable(
    race_stats_final %>% filter(year == input$year_table1, gp_name == input$gp_name_table1) %>% select('grid', 'position', 'points', 'laps',
               'fastest_lap_time', 'speed', 'name',
               'last_name', 'nationality', 'constructor_name', 'status'),
    options = list(searching = FALSE))

  })
  output$max_speed <- renderUI({
    infoBox(paste("Max Speed"), 
            max((race_stats_final %>% filter(., year == input$year_table1, gp_name == input$gp_name_table1) %>% pull(., 'speed')), 
            na.rm=TRUE), 
            icon = icon("angle-double-up"), color = 'black', width = 8)
  })
  
  
  output$fastest_lap_time <- renderUI({
    fast_lap = race_stats_final %>% filter(., year == input$year_table1, gp_name == input$gp_name_table1) %>%
      mutate(millisec = time_calc(fastest_lap_time)) %>% top_n(-1, millisec)
  
    infoBox(paste("Fastest Lap"), fast_lap$fastest_lap_time[1],
            icon = icon("angle-double-up"), color = 'black', width = 8)

  })

  output$gps_held <- renderUI({
    infoBox(paste("GPs Held"),
            count(unique(race_stats_final %>% filter(gp_name == input$gp_name_table1) %>% select("race_id"))), # IF 2018 - count < 0, output 0, else count
            icon = icon("angle-double-up"), color = 'blue', width = 8)

  })


  output$dynamic_widget = renderUI({
    selectizeInput('gp_name_table1', label = "Grand Prix Name", choices = gp_name_table1_choices())
  })
  
  gp_name_table1_choices = reactive({
    sort(unique(filter(race_stats_final, year == input$year_table1)$gp_name))
  })

  ##########################
  ##########################
  output$gp_name_animation = renderUI({
    selectizeInput('gp_name_animation', label = "Grand Prix Name", choices = gp_name_animation_choices())
  })
  
  gp_name_animation_choices = reactive({
    sort(unique(filter(race_and_laps, year == input$year_animation)$gp_name))
  })
  
  output$race_animation <- renderPlotly({
    gg <- ggplot(animation_data(), aes(x = lap, y = position, color = driver_name)) +
      geom_point(aes(frame = lap))
    ggplotly(gg, height = 600, width=1000, tooltip = "driver_name")
  })

  animation_data = reactive({
    race_and_laps %>% filter(gp_name == input$gp_name_animation, year == input$year_animation)
  })
  
  # Drivers page, data table
  output$drivers_table = DT::renderDataTable({drivers_table
  })
  
  # Championships chart
  output$champ_counts = renderPlotly(champ_counts
  )
  # Country wins chart
  output$country_wins = renderPlotly(country_wins
  )
    
})


