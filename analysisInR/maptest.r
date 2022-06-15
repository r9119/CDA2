library(shiny) # for shiny apps
library(leaflet) # renderLeaflet function
library(spData) # loads the world dataset
library(sf)
library(tidyverse)
library(dplyr)
library(lubridate)
library(shinyjs)
library(shinycssloaders)
library(mongolite) # to connect to mongodb
library(plotly)

flattenTable <- function(input_data) {
  flat_data <- data.frame()
  for (i in seq_len(nrow(input_data))) {
    label_data <- input_data[i, ]$data[[1]]
    label_data %<>% mutate(datetime = ymd_hms(date), year = year(date), date = date(date), source = input_data[i, ]$label, type = input_data[i, ]$attributes_type)
    flat_data <- rbind(flat_data, label_data)
  }
  flat_data %<>% arrange(date)
  return(flat_data)
}

# source: https://geocompr.robinlovelace.net/adv-map.html#interactive-maps

# fix for clicking stuff: https://community.rstudio.com/t/shiny-using-multiple-exclusive-reactivevalues-for-filtering-dataset/40957/6

code <- c("EL", "DE", "ES", "FI", "IS", "AT", "NL", "PL", "SE", "TR", "PT")

name <- c(
  "Greece",
  "Germany",
  "Spain",
  "Finland",
  "Iceland",
  "Austria",
  "Netherlands",
  "Poland",
  "Sweden",
  "Turkey",
  "Portugal"
)

country_list <- data.frame(code, name)

oil_price_collection <- mongo(collection = "BrentOilPrice", db = "cda2")
oil_price <- as_tibble(oil_price_collection$find(query = "{}")) %>%
  rename(c("Date" = "period", "Price" = "value")) %>%
  mutate(Date = ymd(Date), Price = as.numeric(Price), Year = year(Date)) %>%
  arrange(Date)

# ui <- fluidPage(
#   sliderInput(inputId = "life", "Life expectancy", 49, 84, value = 80),
#   leafletOutput(outputId = "map")
# )

ui <- fluidPage(
  tags$head(HTML("<title>CDA2 Dashboard </title>")),
  useShinyjs(),
  br(),
  span(style = "font-weight: 600; font-size: 25px; width: 100%;
         color: #022DB7;", "CDA2 Dashboard"),
  br(), br(),
  fluidRow(
    column(8, leafletOutput("map", height = "550px") %>% withSpinner(color = "#0dc5c1")),
    column(
      4,
      span("Please select a country from the map"),
      br(), br(),
      plotlyOutput("oil_price"),
      # tabsetPanel(
      #   uiOutput("year_panels")
      # )
      # hr(),
      # htmlOutput("od_total") %>% withSpinner(color = "#0dc5c1"),
      # hr(),
      # htmlOutput("od_total_5") %>% withSpinner(color = "#0dc5c1")
    )
  ),
  br(), br(),
  fluidRow(
    plotlyOutput("generation") %>% withSpinner(color = "#0dc5c1")
  ),
  fluidRow(
    plotlyOutput("linear_model")
  ),
  fluidRow(
    plotlyOutput("scenario")
  )
  # fluidRow(
  #   column(5, plotlyOutput("od_ton_chart", width = "100%", height = "350px") %>% withSpinner(color = "#0dc5c1")),
  #   column(4, plotlyOutput("od_ton_pie", width = "100%", height = "250px") %>% withSpinner(color = "#0dc5c1")),
  #   column(3, plotlyOutput("od_ton_pie_5", width = "100%", height = "250px") %>% withSpinner(color = "#0dc5c1"))
  # ),
  # hr(),
  # fluidRow(
  #   column(5, plotlyOutput("od_value_chart", width = "100%", height = "350px") %>% withSpinner(color = "#0dc5c1")),
  #   column(4, plotlyOutput("od_value_pie", width = "100%", height = "250px") %>% withSpinner(color = "#0dc5c1")),
  #   column(3, plotlyOutput("od_value_pie_5", width = "100%", height = "250px") %>% withSpinner(color = "#0dc5c1"))
  # )
)
server <- function(input, output, session) {
  click_count <- 0
  type <- 0
  origin <- ""
  dest <- ""
  origin_id <- 0
  dest_id <- 0

  selected_zone <- reactive({
    # p <- input$map_shape_click
    # selected_country <- country_list[country_list$code == p$id, ]
    # subset(centroid, id == p$id)
  })

  selected_od <- reactive({
    # p <- input$map_shape_click

    # selected <- p
    # od_pair <- data.frame()
    # if (type == 0) {
    #   origin <<- selected$name
    #   dest <<- ""
    #   origin_id <<- selected$id
    #   dest_id <<- 0
    # }

    # if (type == 1) {
    #   dest_id <<- selected$id
    #   dest <<- selected$name
    #   od_pair <- data.frame(origin, origin_id, dest, dest_id)
    #   colnames(od_pair) <- c("origin", "origin_id", "dest", "dest_id")
    # }
    # od_pair
  })

  output$oil_price <- renderPlotly({
    oil_price_plot <- ggplot(oil_price, aes(Date, Price)) +
      geom_line() +
      ggtitle("Brent Oil Price")
    ggplotly(oil_price_plot)
  })

  output$generation <- renderPlotly({
    # browser()
    p <- input$map_shape_click
    selected_country <- country_list[country_list$code == p$id, ]
    generation_collection <- mongo(collection = "energyGeneration", db = "cda2")
    energy_generation <- as_tibble(generation_collection$find(paste('{"country_code":', '"', selected_country$code, '"', ', "comment":"no comment"}', sep = "")))
    energy_generation_data <- energy_generation$data[[1]]

    # pivot_longer(energy_generation_data)
    plot_data <- energy_generation_data[energy_generation_data$code == "TOTAL", ]$data[[1]] %>%
      mutate(date = ymd(date))

    generation_plot <- ggplot(plot_data) +
      geom_line(aes(date, value)) +
      labs(y = "Energy Production", title = paste(selected_country$name, "\'s total Electricity production"))
    ggplotly(generation_plot)

    # selected <- p

    # if (type == 0) {
    #   origin <<- selected$name
    #   dest <<- ""
    #   origin_id <<- selected$id
    #   dest_id <<- 0
    # }

    # if (type == 1) {
    #   dest_id <<- selected$id
    #   dest <<- selected$name
    # }

    # paste(
    #   "<strong> <span style = \'font-weight: 700;\'> Displaying information for            </span> </strong>
    #     <strong> <span style = \'font-weight: 500;\'> ", selected_country$name, "</span> </strong>
    #       <br>",
    #   sep = ""
    # )
  })

  output$linear_model <- renderPlotly({
    # seit 1990
    # selected_country$code <- "EL"
    p <- input$map_shape_click
    selected_country <- country_list[country_list$code == p$id, ]
    if (selected_country$code == "ES") {
      emission_collection <- mongo(collection = "emissions", db = "cda2")
      emissions <- as_tibble(emission_collection$find('{"comment":"ree data"}'))
      emissions <- emissions[1, ]$data[[1]]

      emissions_data <- flattenTable(emissions)
      total_emissions <- filter(emissions_data, source == "Total tCO2 eq.") %>%
        select(-datetime, -source, -type, -percentage)
      correlation_data <- merge(total_emissions, oil_price, by.x = "date", by.y = "Date", all.x = TRUE) %>%
        mutate(Price = as.numeric(na_locf(ts(Price)))) %>%
        select(-Year, -date, -year)
    }
    else {
      emission_collection <- mongo(collection = "emissions", db = "cda2")
      emissions <- as_tibble(emission_collection$find(paste('{"country_code":', '"', selected_country$code, '"', ', "comment":"no comment"}', sep = "")))
      emissions <- emissions$data[[1]]
      energy_emissions <- emissions[1, ]$data[[1]]
      energy_emissions <- energy_emissions[4, ]$data[[1]]
      energy_emissions$value <- energy_emissions$value * 1000 # thousand tonnes CO2 eq.

      oil_price_yearly <- oil_price %>% group_by(Year) %>%
        summarise(Price = sum(Price))

      correlation_data <- merge(energy_emissions, oil_price_yearly, by.x = "date", by.y = "Year")
    }
    p <- ggplot(correlation_data, aes(Price, value)) +
      geom_point() +
      geom_smooth(method = "lm") +
      labs(y = "CO2 emissions in thousand tonnes", x = "Brent Oil Price (USD)", title = "Correlation between energy generation and the Brent Oil Price Years 2010+")
    ggplotly(p)
  })

  output$scenario <- renderPlotly({
    selected_country$code <- "EL"
    p <- input$map_shape_click
    selected_country <- country_list[country_list$code == p$id, ]
    consumer_price_collection <- mongo(collection = "consumerPrices", db = "cda2")
    consumer_price <- as_tibble(consumer_price_collection$find(paste('{"country_code":', '"', selected_country$code, '"', ', "comment":"after 2007"}', sep = "")))
    consumer_price <- consumer_price$data[[1]]
    flat_table <- data.frame()
    for (i in seq_len(nrow(consumer_price))) {
      label_data <- consumer_price[i, ]$data[[1]] %>%
        mutate(label = consumer_price[i, ]$label)
      flat_table <- rbind(flat_table, label_data)
    }
    flat_table %<>% arrange(date) %>%
      mutate(date = yq(date))

    p <- ggplot(flat_table, aes(date, value, fill = label)) +
      geom_area()
    ggplotly(p)
  })

  output$year_panels <- renderUI({
    # pan <- lapply(seq_len(nba_teams), function(i) {
    #   tabPanel(nba_teams[[i]]$Title, nba_teams[[i]]$Content)
    # })
    # do.call(tabBox, pan)
  })

  observe({
    p <- input$map_shape_click
    if (is.null(p)) {
      return()
    }

    # m2 <- leafletProxy("map", session = session)

    # # zone_labels <- sprintf(
    # #   "<strong>%s</strong><br/>",
    # #   paste(centroid$id, "--", centroid$name, sep = "")
    # # ) %>% lapply(htmltools::HTML)

    # selected <- selected_zone()
    # selected_zone_labels <- sprintf(
    #   "<strong>%s</strong><br/>",
    #   paste(selected$id, "--", selected$name, sep = "")
    # ) %>% lapply(htmltools::HTML)

    # type <<- click_count %% 2
    # if (type == 0) {
    #   m2 %>%
    #     clearMarkers() %>%
    #     addCircleMarkers(
    #       data = selected, radius = 6, color = "green", lng = ~x, lat = ~y, stroke = FALSE, label = selected_zone_labels,
    #       fillOpacity = 1, layerId = ~id
    #     )
    # }

    # if (type == 1) {
    #   m2 %>%
    #     addCircleMarkers(
    #       data = selected, radius = 6, color = "red", lng = ~x, lat = ~y, stroke = FALSE, label = selected_zone_labels,
    #       fillOpacity = 1, layerId = ~id
    #     )
    # }
    # click_count <<- click_count + 1
  })

  output$map <- renderLeaflet({
    leaflet(world[world$iso_a2 %in% code, ]) %>%
      addTiles() %>%
      addPolygons(layerId = ~iso_a2)
  })
}
shinyApp(ui, server)