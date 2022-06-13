library(tidyverse) # opinionated collection of R packages designed for data science
library(lubridate) # simplifies working with dates
library(knitr) # tools to make nice outputs
library(plotly) # interactive plots
library(httr) # for http requests (to get data)
library(jsonlite) # to deal with json
library(mongolite) # to connect to mongodb
library(magrittr)
# library(cbsodataR) # Netherland Dat

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

prepEurostatData <- function(url, code, label, prec) { # ToDo: add unit to data
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
    row <- data.frame(code = code, label = label)
    row_json <- toJSON(row)
    row$data <- list(consolidated_data)
    return(row)
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
        country_data <- rbind(country_data, prepEurostatData(url, i_code, list[list$code == i_code, ]$label, precision))
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

# # --- get Data from polish API ---
# get_data_pl <- function(label_url, url, data_type) {
#   labels <- call_api(label_url)$results
#   api_data <- call_api(url)$results
#   labels <- arrange(labels, id)
#   api_data <- api_data %>%
#     mutate(type = labels[labels$id == id, ]$n1, measureUnit = labels[labels$id == id, ]$measureUnitName) %>%
#     select(-measureUnitId)
#   for (id in api_data$id) {
#     data_per_label <- api_data[api_data$id == id, ]$values[[1]]
#     collection <- mongo(collection = paste(data_type, api_data[api_data$id == id, ]$type, sep = "-"), db = "Poland")
#     collection$insert(data_per_label)
#   }
# }

# # --- Netherland data ---
# ## --- generation ---
# generation_data_nl <- cbs_get_data("84575ENG") # Energy Production: https://www.cbs.nl/en-gb/figures/detail/84575ENG?q=electricity
# generation_data_nl <- cbs_add_label_columns(generation_data_nl) %>% select(-Periods)
# energy_collection_nl <- mongo(collection = "energyGeneration", db = "Netherlands")
# energy_collection_nl$insert(energy_data_nL)

# ## --- emissions ---
# emission_data_nl <- cbs_get_data("37221eng") # Emission Data: https://www.cbs.nl/en-gb/figures/detail/37221eng?q=electricity%20emission Source 346700 = Energy supply
# emission_data_nl <- emission_data_nl %>% filter(Sources == "346700   ") # Filter for emissions by energy production
# emission_data_nl <- cbs_add_label_columns(emission_data_nl) %>% select(-Periods, -Sources, -Sources_label)
# emissions_collection_nl <- mongo(collection = "emissions", db = "Netherlands")
# emissions_collection_nl$insert(emission_data_nl)

# ## --- generation potential ---
# generation_potential_nl <- cbs_get_data("82610ENG")
# generation_potential_nl <- cbs_add_label_columns(generation_potential_nl) %>% select(-EnergySourcesTechniques, -Periods)
# potential_collecton_nl <- mongo(collection = "generationPotential", db = "Netherlands")
# potential_collecton_nl$insert(generation_potential_nl)

# ## --- electricity Prices (average energy prices for consumers) ---
# electricity_prices_nl <- cbs_get_data("84672ENG") # https://www.cbs.nl/en-gb/figures/detail/84672ENG?q=%22average%20energy%20prices%22
# electricity_prices_nl <- cbs_add_label_columns(electricity_prices_nl) %>% select(-VAT, -Period)
# prices_collection_nl <- mongo(collection = "electricityPrices", db = "Netherlands")
# prices_collection_nl$insert(electricity_prices_nl)

# --- Poland data ---
# provided by state api

# ## --- generation ---
# label_url <- "https://bdl.stat.gov.pl/api/v1/Variables?subject-id=P1674&lang=en"
# url <- "https://bdl.stat.gov.pl/api/v1/data/by-unit/000000000000?format=json&lang=en&year=1995&year=1996&year=1997&year=1998&year=1999
#   &year=2000&year=2001&year=2002&year=2003&year=2004&year=2005&year=2006&year=2007&year=2008
#   &year=2009&year=2010&year=2011&year=2012&year=2013&year=2014&year=2015&year=2016&year=2017
#   &year=2018&year=2019&year=2020&year=2021&year=2022&var-id=7883&var-id=76361&var-id=7884
#   &var-id=79238&var-id=7885&var-id=7936&var-id=194886&var-id=288086&var-id=454054"

# # get_data_pl(labelUrl, url, "energyGeneration")
# labels <- call_api(label_url)$results
# api_data <- call_api(url)$results
# labels <- arrange(labels, id)
# api_data <- api_data %>%
#   mutate(type = labels[labels$id == id, ]$n1, measureUnit = labels[labels$id == id, ]$measureUnitName) %>%
#   select(-measureUnitId)
# for (id in api_data$id) {
#   data_per_label <- api_data[api_data$id == id, ]$values[[1]]
#   collection <- mongo(collection = paste("energyGeneration", api_data[api_data$id == id, ]$type, sep = "-"), db = "Poland")
#   collection$insert(data_per_label)
# }

# ## --- emissions ---


# ## --- generation potential ---
# label_url <- "https://bdl.stat.gov.pl/api/v1/Variables?subject-id=P1672&lang=en"
# url <- "https://bdl.stat.gov.pl/api/v1/data/by-unit/000000000000?format=json&lang=en&year=1995&year=1996&year=1997&year=1998&year=1999
#   &year=2000&year=2001&year=2002&year=2003&year=2004&year=2005&year=2006&year=2007&year=2008
#   &year=2009&year=2010&year=2011&year=2012&year=2013&year=2014&year=2015&year=2016&year=2017
#   &year=2018&year=2019&year=2020&year=2021&year=2022&var-id=4834&var-id=79240&var-id=79242
#   &var-id=4835&var-id=4836&var-id=4837&var-id=4838&var-id=4839&var-id=4840&var-id=76364"

# # get_data_pl(labelUrl, url, "generationPotential")
# labels <- call_api(label_url)$results
# api_data <- call_api(url)$results
# labels <- arrange(labels, id)
# api_data <- api_data %>%
#   mutate(type = labels[labels$id == id, ]$n2, measureUnit = labels[labels$id == id, ]$measureUnitName) %>%
#   select(-measureUnitId)
# for (id in api_data$id) {
#   data_per_label <- api_data[api_data$id == id, ]$values[[1]]
#   collection <- mongo(collection = paste("generationPotential", api_data[api_data$id == id, ]$type, sep = "-"), db = "Poland")
#   collection$insert(data_per_label)
# }

# --- ree data (detailed data from Spain) ----
## --- generation ---
collectReeData(2015:2022, "https://apidatos.ree.es/en/datos/generacion/estructura-generacion", "day", "energyGeneration") # available since 2011

## --- emissions ---
collectReeData(2015:2022, "https://apidatos.ree.es/en/datos/generacion/no-renovables-detalle-emisiones-CO2", "day", "emissions") # available since 2011

## --- generation potential ---
collectReeData(2015:2022, "https://apidatos.ree.es/en/datos/generacion/potencia-instalada", "month", "installedCapacity") # available since 2015

## --- electricity Prices ---
collectReeData(2015:2022, "https://apidatos.ree.es/en/datos/mercados/componentes-precio", "month", "consumerPrices") # available since 2014


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
  "CF_NR",
  "CR_R",
  "G3000",
  "N9000",
  "O4000XBIO",
  "RA100",
  "RA110",
  "RA120",
  "RA130",
  "RA200",
  "RA300",
  "RA310",
  "RA320",
  "RA400",
  "RA410",
  "RA420",
  "RA500",
  "RA500_5160",
  "TOTAL",
  "X9900"
)

siec_labels <- c(
  "Coal and manufactured gases",
  "Combustible fuels",
  "Combustible fuels - non-renewable",
  "Combustible fuels - renewable",
  "Natural gas",
  "Nuclear fuels and other",
  "Oil and petroleum products (exluding biofuel portion)",
  "Hydro",
  "Pure Hydro power",
  "Mixed hydro power",
  "Pumped hydro power", ##
  "Geothermal",
  "Wind",
  "Wind on shore",
  "Wind off shore",
  "Solar",
  "Solar thermal",
  "Solar photovoltaic",
  "Tide, wave, ocean", ##
  "Other renewable energies",
  "Total",
  "Other fuels n.e.c."
)

## --- energy generation ---
getAndWriteEurostatData(
  codes = siec_codes,
  labels = siec_labels,
  collection = "energyGeneration",
  url_part_one = "nrg_cb_pem?siec=",
  since_period = "2016M01&",
  precision = "month"
)


## --- emissions ---
getAndWriteEurostatData(
  codes = c("CRF1", "CRF1A1", "CRF1A1A", "CRF1A1B", "CRF1A1C", "CRF1B2"),
  labels = c(
    "Energy", "Fuel combustion in energy industries", "Fuel combustion in public electricity and heat production",
    "Fuel combustion in petroleum refining", "Fuel combustion in manufacture of solid fuels and other energy industries", "Oil, natural gas and other energy production - fugitive emissions"
  ),
  second_codes = c("CH4", "CH4_CO2E", "CO2", "GHG", "HFC_CO2E", "HFC_PFC_NSP_CO2E", "N2O", "N2O_CO2E", "NF3_CO2E", "PFC_CO2E", "SF6_CO2E"),
  second_labels = c(
    "Methane", "Methane (CO2 eq.)", "Carbon dioxide", "Greenhouse gases (CO2, N2O in CO2 eq., CH4 in CO2 eq., HFC in CO2 eq., PFC in CO2 eq., SF6 in CO2 eq., NF3 in CO2 eq.",
    "Hydrofluorocarbones (CO2 eq.)", "Hydrofluorocarbones and perfluorocarbones - nor specified mix (CO2 eq.)", "Nitrous oxide", "Nitrous oxide (CO2 eq.)", "Nitrogen trifluoride (CO2 eq.)",
    "Perfluorocarbones (CO2 eq.)", "Sulphur hexafluoride (CO2 eq.)"
  ),
  collection = "emissions",
  url_part_one = "env_air_gge?src_crf=",
  url_part_two = "&unit=MIO_T&airpol=",
  since_period = "1985",
  precision = "year"
)


## --- share of energy by renewables --- -> maybe not enough data
getAndWriteEurostatData(
  codes = c("REN", "REN_ELC", "REN_HEAD_CL", "REN_TRA"),
  labels = c("Renewable energy sources", "Renewable energy sources in electricity", "Renewable energy sources in heating and cooling", "Renewable energy soruces in transport"),
  collection = "shareOfRenewableEnergy",
  url_part_one = "nrg_ind_ren?nrg_bal=",
  since_period = "2004",
  precision = "year"
) # maybe problem


## --- installed capacity ---
getAndWriteEurostatData(
  codes = c("PRR_AUTO", "PRR_MAIN"),
  labels = c("Autoproducers", "Main activity producers"),
  second_codes = siec_codes,
  second_labels = siec_labels,
  collection = "installedCapacity",
  url_part_one = "nrg_inf_epc?operator=",
  url_part_two = "&siec=",
  since_period = "1990",
  precision = "year"
)

## --- Prices ---
### --- Industry ---
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

### --- Consumer ---
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