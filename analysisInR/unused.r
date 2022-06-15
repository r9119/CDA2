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







    # flat <- data.frame()
      # for (i in seq_len(nrow(flat_country_data))) {
      #   # if (year(flat_country_data[i, ]$date) == 2019) {

      #     brow <- flat_country_data[i, ] %>% mutate(
      #       "Combustible fuels percentage" = as.numeric(flat_country_data[i, "Combustible fuels"] / flat_country_data[i, "Total"]),
      #       "Nuclear fuels and other percentage" = as.numeric(flat_country_data[i, "Nuclear fuels and other fuels n.e.c."] / flat_country_data[i, "Total"]),
      #       "Hydro percentage" = as.numeric(flat_country_data[i, "Hydro"] / flat_country_data[i, "Total"]),
      #       "Geothermal percentage" = as.numeric(flat_country_data[i, "Geothermal"] / flat_country_data[i, "Total"]),
      #       "Solar thermal percentage" = as.numeric(flat_country_data[i, "Solar thermal"] / flat_country_data[i, "Total"]),
      #       "Solar photovoltaic percentage" = as.numeric(flat_country_data[i, "Solar photovoltaic"] / flat_country_data[i, "Total"]),
      #       # "Tide percentage" = as.numeric(flat_country_data[i, "Tide, wave, ocean"] / flat_country_data[i, "Total"]),
      #       # "Other fuels percentage" = as.numeric(flat_country_data[i, "Other fuels n.e.c"] / flat_country_data[i, "Total"]),
      #       "Coal percentage" = as.numeric(flat_country_data[i, "Coal and manufactured gases"] / flat_country_data[i, "Total"]),
      #       "Natural gas percentage" = as.numeric(flat_country_data[i, "Natural gas"] / flat_country_data[i, "Total"]),
      #       "Oil and petroleum percentage" = as.numeric(flat_country_data[i, "Oil and petroleum products (exluding biofuel portion)"] / flat_country_data[i, "Total"]),
      #       "Wind on shore percentage" = as.numeric(flat_country_data[i, "Wind on shore"] / flat_country_data[i, "Total"]),
      #       "Wind off shore percentage" = as.numeric(flat_country_data[i, "Wind off shore"] / flat_country_data[i, "Total"]),
      #       "Other renewables percentage" = as.numeric(flat_country_data[i, "Other tenewable energies"] / flat_country_data[i, "Total"])
      #       )
      #     flat <- rbind(flat, brow)
      #   # }
      # }