library(tidyverse) # opinionated collection of R packages designed for data science
library(lubridate) # simplifies working with dates
library(knitr) # tools to make nice outputs
library(plotly) # interactive plots
library(httr) # for http requests (to get data)
library(jsonlite) # to deal with json
library(mongolite) # to connect to mongodb
library(magrittr)
# library(cbsodataR) # Netherland Data

# --- Function to retreive data from API ---
callApi <- function(url) {
  get_data <- GET(url)
  print(status_code(get_data))
  # Getting status of HTTP Call
  if (status_code(get_data) == 200) {
    # Converting content to text
    get_data_text <- content(get_data,
      "text",
      encoding = "UTF-8"
    )
    # Parsing data in JSON
    get_data_json <- fromJSON(get_data_text,
      flatten = TRUE
    )
    return(get_data_json)
  }
}

prepEurostatData <- function(url, code, label, prec, flat = FALSE) { # ToDo: add unit to data
  api_data <- callApi(url)
  if (length(api_data$value) > 0) {
    values <- data.frame(names(api_data$value), unlist(unname(api_data$value)))
    colnames(values) <- c("index", "value")
    consolidated_data <- data.frame(names(api_data$dimension$time$category$index), unlist(unname(api_data$dimension$time$category$index)))
    colnames(consolidated_data) <- c("month", "index")
    consolidated_data <- merge(consolidated_data, values, by = "index", all = TRUE) %>%
      mutate(date = switch(prec, # dynamic col name
        "year" = month,
        "month" = ym(month),
        "semester" = month
      )) %>%
      select(-index, -month)
    consolidated_data <- drop_na(consolidated_data)
    if (flat == FALSE) {
      row <- data.frame(code = code, label = label)
      row_json <- toJSON(row)
      row$data <- list(consolidated_data)
      return(row)
    } else {
       consolidated_data$code <- code
       consolidated_data$label <- label
       return(consolidated_data)
    }
  }
}

getAndWriteEurostatData <- function(codes, labels, second_codes = NULL, second_labels = NULL, collection, url_part_one, url_part_two = NULL, since_period, precision, comment = "no comment") {
  list <- data.frame(code = codes, label = labels)
  data <- data.frame()
  if (!is.null(second_codes)) {
    second_list <- data.frame(code = second_codes, label = second_labels)
  }

  for (country_code in country_list$country_code) {
    country_data <- data.frame(matrix(nrow = 0, ncol = 3))
    colnames(country_data) <- c("code", "label", "data")
    if (collection == "energyGeneration" || collection == "shareOfRenewableEnergy" || collection == "industryPrices" || collection == "consumerPrices") {
      for (i_code in list$code) {
        url <- paste(base_url, url_part_one, i_code, "&sinceTimePeriod=", since_period, "&precision=1&geo=", country_code, "&unitLabel=label", sep = "")
          country_data <- rbind(country_data, prepEurostatData(url, i_code, list[list$code == i_code, ]$label, precision, flat = FALSE))
      }
    } else if (collection == "emissions" || collection == "installedCapacity") {
      for (i_code in list$code) {
        crf_data <- data.frame()
        for (j_code in second_list$code) {
          url <- paste(base_url, url_part_one, i_code, "&sinceTimePeriod=", since_period, "&precision=1&", url_part_two, j_code, "&geo=", country_code, "&unitLabel=label", sep = "")
          crf_data <- rbind(crf_data, prepEurostatData(url, j_code, second_list[second_list$code == j_code, ]$label, precision))
          # unit
        }
        country_row <- data.frame(i_code, label = list[list$code == i_code, ]$label)
        country_row$data <- list(crf_data)
        country_data <- rbind(country_data, country_row)
      }
    }
    row <- data.frame(country_code, country_name = country_list[country_list$country_code == country_code, ]$country, comment = comment)
    row$data <- list(country_data)
    data <- rbind(data, row)
  }
  db_collection <- mongo(collection = collection, db = "cda2")
  db_collection$insert(data)
}

getAndWriteFlatEurostatData <- function(codes, labels, second_code = NULL, second_label = NULL, collection, url_part_one, url_part_two = NULL, since_period, precision, comment = "no comment") {
  list <- data.frame(code = codes, label = labels)
  flat_data <- data.frame()
  for (country_code in country_list$country_code) {
    flat_country_data <- data.frame()
    for (i_code in list$code) {
      if (!is.null(second_code)) {
        url <- paste(base_url, url_part_one, i_code, "&sinceTimePeriod=", since_period, "&precision=1&", url_part_two, second_code, "&geo=", country_code, "&unitLabel=label", sep = "")
      } else{
        url <- paste(base_url, url_part_one, i_code, "&sinceTimePeriod=", since_period, "&precision=1&geo=", country_code, "&unitLabel=label", sep = "")
      }
      flat_country_data <- rbind(flat_country_data, prepEurostatData(url, i_code, list[list$code == i_code, ]$label, precision, flat = TRUE))
    }
    flat_row <- data.frame(country_code, country_name = country_list[country_list$country_code == country_code, ]$country, comment = comment)
    flat_country_data %<>% select(-code) %>% pivot_wider(names_from = label, values_from = value)
    flat_country_data[is.na(flat_country_data)] <- 0
    if (collection == "energyGeneration2019" | collection == "energyGeneration" | collection == "installedCapacity") {
      for (colname in colnames(flat_country_data)[2:length(colnames(flat_country_data))]) {
        temp_name <- paste(colname, "percentage")
          flat_country_data[, temp_name] <- flat_country_data[, colname] / flat_country_data[, "Total"]
      }
    }
    if (collection == "energyGeneration2019") {
      flat_country_data %<>% filter(year(date) == 2019) %>% select(-date)
      means_data <- data.frame(as.list(colMeans(flat_country_data)))
      flat_row$data <- list(means_data)
    } else{
      flat_row$data <- list(flat_country_data)
    }
    flat_data <- rbind(flat_data, flat_row)
  }
  flat_collection <- mongo(collection = collection, db = "cda2")
  flat_collection$insert(flat_data)
}

prepReeData <- function(data, new_data) {
  new_data %<>% rename(data = attributes.values, label = type, code = id)
  if (dim(data)[1] == 0) {
    for (l in new_data$label) {
      new_data[new_data$label == l, ]$data[[1]] %<>% rename(date = datetime)
    }
    return(new_data)
  } else {
    for (l in new_data$label) {
      new_data[new_data$label == l, ]$data[[1]] %<>% rename(date = datetime)
      if (dim(data[data$label == l, ])[1] != 0) {
        data[data$label == l, ]$data[[1]] <- rbind(data[data$label == l, ]$data[[1]], new_data[new_data$label == l, ]$data[[1]])
      } else {
        data <- rbind(data, new_data[new_data$label == l, ])
      }
    }
    return(data)
  }
}

collectReeData <- function(years, url, trunc, collection) {
  ree_data <- data.frame()
  for (year in years) {
    if (year != years[length(years)]) {
      call <- paste(url, "?start_date=", year, "-01-01T00:00&end_date=", year, "-12-31T23:59&time_trunc=", trunc, sep = "")
    } else {
      call <- paste(url, "?start_date=", year, "-01-01T00:00&end_date=", Sys.Date(), "T23:59&time_trunc=", trunc, sep = "")
    }
    ree_data <- prepReeData(ree_data, callApi(call)$included)
  }
  row <- data.frame(country_code = "ES", country_name = "Spain", comment = "ree data")
  row$data <- list(ree_data)
  db_collection <- mongo(collection = collection, db = "cda2")
  db_collection$insert(row)
}

# --- ree data (detailed data from Spain) ----
## --- generation ---
# collectReeData(2011:2022, "https://apidatos.ree.es/en/datos/generacion/estructura-generacion", "day", "energyGeneration") # available since 2011

# ## --- emissions ---
# collectReeData(2011:2022, "https://apidatos.ree.es/en/datos/generacion/no-renovables-detalle-emisiones-CO2", "day", "emissions") # available since 2011

# ## --- generation potential ---
# collectReeData(2015:2022, "https://apidatos.ree.es/en/datos/generacion/potencia-instalada", "month", "installedCapacity") # available since 2015

# ## --- electricity Prices ---
# collectReeData(2015:2022, "https://apidatos.ree.es/en/datos/mercados/componentes-precio", "month", "consumerPrices") # available since 2014


# --- Oil Price ---
# provided by eia.gov
oil_price_data <- callApi("https://api.eia.gov/v2/petroleum/pri/spt/data?api_key=a6BwytwjsQLCDb3KXMwJZE11WPoT64BnazpYaYEE&frequency=daily&facets[product][]=EPCBRENT&data[]=value")$response$data
oil_price_data <- oil_price_data %>% select(
  -duoarea,
  -"area-name",
  -product,
  -"product-name",
  -process,
  -"process-name",
  -series,
  -"series-description",
  -units
)
oil_price_collection <- mongo(collection = "BrentOilPrice", db = "cda2")
oil_price_collection$insert(oil_price_data)


yearly_oil_price_df <- mutate(oil_price_data, year = year(period)) %>%
  filter(year >= 1990 & year <= 2020) %>%
  group_by(year) %>%
  summarise(sum = sum(value), avg = sum / n())

yearly_oil_price_collection <- mongo(collection = "yearlyBrentOilPrice", db = "cda2")
yearly_oil_price_collection$insert(yearly_oil_price_df)

emissions_europe <- read.csv("./datasets/ghg-emissions-by-sector.csv") %>%
  filter(Entity == "European Union (27)") %>%
  select(Year, Electricity.and.heat)

emissions_europe_collection <- mongo(collection = "emissionsEurope", db = "cda2")
emissions_europe_collection$insert(emissions_europe)

co2_prices_europe <- read.csv("./datasets/EMBER_Coal2Clean_EUETSPrices.csv") %>%
  mutate(Date = ymd_hms(Date))

co2_price_europe_collection <- mongo(collection = "co2PriceEurope", db = "cda2")
co2_price_europe_collection$insert(co2_prices_europe)

lcoe <- data.frame("Gas Peaker" = 175, "Nuclear" = 155, "Solar Thermal Power" = 141, "Coal" = 109, "Gas" = 56, "Onshore Wind" = 41, "Solar Photovoltaic" = 40, "Offshore Wind" = 115)
lcoe_collection <- mongo(collection = "LCOE", db = "cda2")
lcoe_collection$insert(lcoe)

# --- data from eurostat ---
## --- global variables ---
base_url <- "http://ec.europa.eu/eurostat/wdds/rest/data/v2.1/json/en/"
country <- c(
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

country_code <- c(
  "EL",
  "DE",
  "ES",
  "FI",
  "IS",
  "AT",
  "NL",
  "PL",
  "SE",
  "TR",
  "PT"
)
country_list <- data.frame(country_code, country)

siec_codes <- c(
  "C0000",
  "CF",
  "G3000",
  "N9000",
  "O4000XBIO",
  "RA100",
  "RA200",
  "RA310",
  "RA320",
  "RA410",
  "RA420",
  "RA500",
  "RA500_5160",
  "X9900",
  "TOTAL"

)

siec_labels <- c(
  "Coal and manufactured gases",
  "Combustible fuels",
  "Natural gas",
  "Nuclear fuels and other fuels n.e.c.",
  "Oil and petroleum products (exluding biofuel portion)",
  "Hydro",
  "Geothermal",
  "Wind on shore",
  "Wind off shore",
  "Solar thermal",
  "Solar photovoltaic",
  "Tide, wave, ocean", ##
  "Other renewable energies",
  "Other fuels n.e.c.",
  "Total"
)

## --- energy generation ---
getAndWriteFlatEurostatData(
  codes = siec_codes,
  labels = siec_labels,
  collection = "energyGeneration",
  url_part_one = "nrg_cb_pem?siec=",
  since_period = "2016M01&",
  precision = "month"
)

getAndWriteFlatEurostatData(
  codes = siec_codes,
  labels = siec_labels,
  collection = "energyGeneration2019",
  url_part_one = "nrg_cb_pem?siec=",
  since_period = "2019M01&",
  precision = "month"
)

# ## --- emissions ---
getAndWriteFlatEurostatData(
  codes = c("CRF1A1A"),
  labels = c(
    "Fuel combustion in public electricity and heat production"
  ),
  second_code = "GHG",
  second_label = "Greenhouse gases (CO2, N2O in CO2 eq., CH4 in CO2 eq., HFC in CO2 eq., PFC in CO2 eq., SF6 in CO2 eq., NF3 in CO2 eq.",
  collection = "emissions",
  url_part_one = "env_air_gge?src_crf=",
  url_part_two = "&unit=THS_T&airpol=",
  since_period = "1990",
  precision = "year"
)

model_db <- data.frame()
for (code in country_code) {
  emissions_collection <- mongo(collection = "emissions", db = "cda2")
  emissions <- as_tibble(emissions_collection$find(paste('{"country_code":"', code, '"}', sep = "")))
  emissions <- emissions$data[[1]]
  colnames(emissions) <- c("date", "emissions")
  model_data <- merge(yearly_oil_price_df, emissions, by.x = "year", by.y = "date")
  lm <- lm(emissions ~ avg, data = model_data, x = TRUE, y = TRUE)
  point1 <- c("x" = 0, "y" = unname(coefficients(lm)[1]))
  point2 <- c("x" = max(model_data$avg), "y" = unname(coefficients(lm)[2]) * unname(max(model_data$avg)) + unname(coefficients(lm)[1]))
  model_row <- data.frame(country_code = code)
  model_row$data <- list(rbind(point1, point2))
  model_db <- rbind(model_db, model_row)
}

model_collection <- mongo(collection = "linearModel", db = "cda2")
model_collection$insert(model_db)

# ## --- share of energy by renewables ---
# getAndWriteFlatEurostatData(
#   codes = c("REN_ELC"), #, "REN_HEAD_CL", "REN_TRA", "REN"),
#   labels = c("Renewable energy sources in electricity"), # "Renewable energy sources", "Renewable energy sources in heating and cooling", "Renewable energy soruces in transport"),
#   collection = "ShareOfRenewableEnergy",
#   url_part_one = "nrg_ind_ren?nrg_bal=",
#   since_period = "2004",
#   precision = "year"
# ) # maybe problem

# siec_codes <- c(
#   # "C0000",
#   "CF",
#   # "CF_NR",
#   # "CR_R",
#   # "G3000",
#   "N9000",
#   # "O4000XBIO",
#   "RA100",
#   # "RA110",
#   # "RA120",
#   # "RA130",
#   "RA200",
#   "RA300",
#   # "RA310",
#   # "RA320",
#   # "RA400",
#   "RA410",
#   "RA420",
#   "RA500",
#   # "RA500_5160",
#   "X9900",
#   "TOTAL"

# )

# siec_labels <- c(
#   # "Coal and manufactured gases",
#   "Combustible fuels",
#   # "Combustible fuels - non-renewable",
#   # "Combustible fuels - renewable",
#   # "Natural gas",
#   "Nuclear fuels and other fuels n.e.c.",
#   # "Oil and petroleum products (exluding biofuel portion)",
#   "Hydro",
#   # "Pure Hydro power",
#   # "Mixed hydro power",
#   # "Pumped hydro power", ##
#   "Geothermal",
#   "Wind",
#   # "Wind on shore",
#   # "Wind off shore",
#   # "Solar",
#   "Solar thermal",
#   "Solar photovoltaic",
#   "Tide, wave, ocean", ##
#   # "Other renewable energies",
#   "Other fuels n.e.c.",
#   "Total"
# )

# ## --- installed capacity ---
# getAndWriteFlatEurostatData(
#   codes = siec_codes, # "PRR_AUTO"
#   labels = siec_labels, # "Autoproducers"
#   second_code = "PRR_MAIN",
#   second_label = "Main activity producers",
#   collection = "installedCapacity",
#   url_part_one = "nrg_inf_epc?siec=",
#   url_part_two = "&operator=",
#   since_period = "1990",
#   precision = "year"
# )



# ## --- Prices ---
# ### --- Industry ---
getAndWriteEurostatData(
  codes = c("4162050", "4162100", "4162150", "4162200", "4162250", "4162300", "4162350", "4162400", "4162450"),
  labels = c(
    "Industry - Ia (Annual consumption: 30 MWh; maximum demand: 30 kW; annual load: 1 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
    "Industry - Ib (Annual consumption: 50 MWh; maximum demand: 50 kW; annual load: 1 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
    "Industry - Ic (Annual consumption: 160 MWh; maximum demand: 100 kW; annual load: 1 600 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
    "Industry - Id (Annual consumption: 1 250 MWh; maximum demand: 500 kW; annual load: 2 500 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
    "Industry - Ie (Annual consumption: 2 000 MWh; maximum demand: 500 kW; annual load: 4 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
    "Industry - If (Annual consumption: 10 000 MWh; maximum demand: 2 500 kW; annual load: 4 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
    "Industry - Ig (Annual consumption: 24 000 MWh; maximum demand: 4 000 kW; annual load: 6 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
    "Industry - Ih (Annual consumption: 50 000 MWh; maximum demand: 10 000 kW; annual load: 5 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
    "Industry - Ii (Annual consumption: 70 000 MWh; maximum demand: 10 000 kW; annual load: 7 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)"
  ),
  collection = "industryPrices",
  url_part_one = "nrg_pc_205_h?product=6000&unit=KWH&tax=I_TAX&currency=EUR&consom=",
  since_period = "1985S1",
  precision = "semester",
  comment = "until 2007"
)

getAndWriteEurostatData(
  codes = c("4162901", "4162902", "4162903", "4162904", "4162905", "4162906", "4162907"),
  labels = c(
    "Band IA : Consumption < 20 MWh",
    "Band IB : 20 MWh < Consumption < 500 MWh",
    "Band IC : 500 MWh < Consumption < 2 000 MWh",
    "Band ID : 2 000 MWh < Consumption < 20 000 MWh",
    "Band IE : 20 000 MWh < Consumption < 70 000 MWh",
    "Band IF : 70 000 MWh < Consumption < 150 000 MWh",
    "Band IG : Consumption > 150 000 MWh"
  ),
  collection = "industryPrices",
  url_part_one = "nrg_pc_205?product=6000&tax=I_TAX&unit=KWH&currency=EUR&consom=",
  since_period = "2007S1",
  precision = "semester",
  comment = "after 2007"
)

# # ### --- Consumer ---
getAndWriteEurostatData(
  codes = c("4161050", "4161100", "4161150", "4161200", "4161250"),
  labels = c(
    "Households - Da (Annual consumption: 600 kWh)", "Households - Db (Annual consumption: 1 200 kWh)", "Households - Dc (Annual consumption: 3 500 kWh of which night 1 300)",
    "Households - Dd (Annual consumption :7 500 kWh of which night 2 500)", "Households - De (Annual consumption: 20 000 kWh of which night 15 000)"
  ),
  collection = "consumerPrices",
  url_part_one = "nrg_pc_204_h?product=6000&tax=I_TAX&currency=EUR&consom=",
  since_period = "1985S1",
  precision = "semester",
  comment = "until 2007"
)

getAndWriteEurostatData(
  codes = c("4161901", "4161902", "4161903", "4161904", "4161905"),
  labels = c(
    "Band DA : Consumption < 1 000 kWh", "Band DB : 1 000 kWh < Consumption < 2 500 kWh", "Band DC : 2 500 kWh < Consumption < 5 000 kWh",
    "Band DD : 5 000 kWh < Consumption < 15 000 kWh", "Band DE : Consumption > 15 000 kWh"
  ),
  collection = "consumerPrices",
  url_part_one = "nrg_pc_204?product=6000&tax=I_TAX&unit=KWH&currency=EUR&consom=",
  since_period = "2007S1",
  precision = "semester",
  comment = "after 2007"
)