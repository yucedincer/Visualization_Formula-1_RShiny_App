library(plotly)
library(dplyr)
library(shiny)
library(shinydashboard)
library(DT)
library(shinyWidgets)
library(RSQLite)
library(shinyLP)



conn = dbConnect(drv = SQLite(), dbname = "./database.sqlite")

dbListTables(conn)

##########################################################################
# standings = dbGetQuery(conn, "SELECT * FROM standings")
# races = dbGetQuery(conn, "SELECT * FROM races")
# circuits = dbGetQuery(conn, "SELECT * FROM circuits")
# for_map = dbGetQuery(conn, "SELECT * FROM races LEFT JOIN circuits ON circuits.Circuit_id = races.circuit_id" )
# constructors = dbGetQuery(conn, "SELECT * FROM constructors")
# constructor_standings = dbGetQuery(conn, "SELECT * FROM constructor_standings")
# constructors_new = dbGetQuery(conn, "SELECT * FROM constructor_standings LEFT JOIN constructors ON constructor_standings.constructor_id = constructors.constructor_id")
# results = dbGetQuery(conn, "SELECT * FROM results")
# status = dbGetQuery(conn, "SELECT * FROM status")
# results_new = dbGetQuery(conn, "SELECT * FROM results LEFT JOIN status on results.status_id = status.status_id")
# pit_stops = dbGetQuery(conn, "SELECT * FROM pit_stops")
##########################################################################

# map projection
for_map2 = for_map %>% group_by(year) %>% mutate(EndLat = lead(lat), EndLong=lead(lng))

# for standings page
# drivers = dbGetQuery(conn, "SELECT * FROM driver")
# standings_v1 = dbGetQuery(conn, "SELECT * FROM results LEFT JOIN driver ON results.driver_id = driver.driver_id")
# dbWriteTable(conn, name = "standings_v1", value = standings_v1)
# standings = dbGetQuery(conn, "SELECT * FROM standings_v1 LEFT JOIN constructors ON standings_v1.constructor_id = constructors.constructor_id")
# dbWriteTable(conn, name = "standings", value = standings)
# standings = dbGetQuery(conn, "SELECT * FROM standings LEFT JOIN races ON standings.race_id = races.race_id")
# standings
# colnames(standings)
# standings <- standings[, -c(1,2,3,4,5,8,9,11,12,13,14,18,19,20,21,22,25,27,28,30,31,33,34,36)]
# standings$driver_name <- paste(standings$name, standings$last_name, sep = " ")
# standings <- standings[, -c(7,8)]
# standings <- standings[, -c(4)]
# dbWriteTable(conn, name = "standings", value = standings, overwrite = TRUE)


standings = dbGetQuery(conn, "SELECT * FROM standings")
standings

####### DO NOT LOAD THESE #################
# race_stats = dbGetQuery(conn, "SELECT * FROM results LEFT JOIN driver ON results.driver_id = driver.driver_id") #delete when done
# dbWriteTable(conn, name = "race_stats", value = race_stats)
# race_stats1 = dbGetQuery(conn, "SELECT * FROM race_stats LEFT JOIN constructors ON race_stats.constructor_id = constructors.constructor_id")
# dbWriteTable(conn, name = "race_stats1", value = race_stats1)
# race_stats2 = dbGetQuery(conn, "SELECT * FROM race_stats1 LEFT JOIN races ON race_stats1.race_id = races.race_id")
# dbWriteTable(conn, name = "race_stats2", value = race_stats2)
# race_stats3 = dbGetQuery(conn, "SELECT * FROM race_stats2 LEFT JOIN status ON race_stats2.status_id = status.status_id")
# dbWriteTable(conn, name = "race_stats3", value = race_stats3)
# race_stats_final = dbGetQuery(conn, "SELECT * FROM race_stats3 LEFT JOIN pit_stops ON race_stats3.race_id = pit_stops.race_id") #THIS IS THE FINAL NEEDED
# 
# write.csv(race_stats_final, file = "race_stats_final_adj.csv")


setwd("~/Desktop/Data Science/NYCDA/f1_project/backup_f1/f1db_csv")
race_stats_final = read.csv(file = "race_stats_final.csv", header = TRUE)


year_vector = sort(unique(race_stats_final$year))
gp_vector = sort(unique(race_stats_final$gp_name))

year_vector_animation = sort(unique(race_and_laps$year))

# sum(race_stats_final$fastest_lap_time)

# ms(race_stats_final$fastest_lap)

race_stats_final$speed = as.numeric(race_stats_final$speed)

#race_stats_final$fastest_lap_time = as.numeric(race_stats_final$fastest_lap_time)

race_stats_final$driver_name <- paste(race_stats_final$name, race_stats_final$last_name, sep=" ")
race_and_laps$driver_name <- paste(race_and_laps$name, race_and_laps$last_name, sep = " ")

# merge driver name & last name

race_stats_final$driver_name <- paste(race_stats_final$name, race_stats_final$last_name, sep=" ")


# t = "02:30.5"

time_calc <- function(t) {
  t = as.character(t)
  minutes = as.integer(substr(t, 1, 2))
  seconds = as.integer(substr(t, 4, 5))
  milliseconds = as.integer(substr(t, 7, 7))
  new_fastest_time = minutes * 60000 + seconds * 1000 + milliseconds * 1
  return(new_fastest_time)
}

time_calc_to <- function(new_time) {
  minutes = as.integer(new_time %/% 60000)
  seconds = (new_time-minutes*60000)%/%1000
  milliseconds = (new_time-minutes*60000)-seconds*1000
  
  minutes = ifelse(minutes<10, paste0("0", as.character(minutes)), paste0(as.character(minutes)))
  seconds = ifelse(seconds<10, paste0("0", as.character(seconds)), paste0(as.character(seconds)))
  
  paste0(minutes,":",seconds,".",milliseconds)
  
}

test = race_stats_final %>% mutate(millisec = time_calc(fastest_lap_time)) 


####################### FOR DRIVERS TAB

drivers = read.csv("drivers_wiki.csv", header = TRUE)
drivers

champions = read.csv("champions.csv", header = TRUE)
champions


champ_counts = plot_ly(data = champions,
                       x = reorder(champions$name, champions$championships),
                       y = ~championships,
                       type = "bar",
                       color = champions$name,
                       showlegend = FALSE) %>%
  layout(title = "World Champions",
         xaxis = list(title = ""),
         yaxis = list(title = ""))


####################################################

cntr = drivers %>% group_by(country) %>% summarise(sum(wins))
cntr

country_wins = plot_ly(data = cntr,
                       x = reorder(cntr$country,-cntr$`sum(wins)`),
                       y = cntr$`sum(wins)`,
                       type = "bar",
                       color = cntr$country,
                       showlegend = FALSE) %>%
  layout(title = "Most Successful Countries in Producing Winners",
         xaxis = list(title = ""),
         yaxis = list(title = ""))

country_wins

##################################################

drivers_table = datatable(drivers, class = "display")
drivers_table
