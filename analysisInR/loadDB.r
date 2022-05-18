library(tidyverse)    #opinionated collection of R packages designed for data science
library(lubridate)    #simplifies working with dates
library(knitr)        #tools to make nice outputs
library(plotly)       #interactive plots
library(httr)         #for http requests (to get data)
library(jsonlite)     #to deal with json
library(mongolite)    #to connect to mongodb

# --- Function to retreive data from API ---
call_api <- function(url) {
  getData <- GET(url)
  print(status_code(getData))
  # Getting status of HTTP Call
  if (status_code(getData) == 200) {
      # Converting content to text
      getDataText <- content(getData,
                             "text", encoding = "UTF-8")
      # Parsing data in JSON
      getDataJson <- fromJSON(getDataText,
                              flatten = TRUE)
      return(getDataJson)
    }
}

prep_eurostat_data <- function(url, code, label, prec) { #ToDo: add unit to data
  apiData <- call_api(url)
  if (length(apiData$value) > 0) {
    values <- data.frame(names(apiData$value), unlist(unname(apiData$value)))
    colnames(values) <- c("Index", "Value")
    consolidatedData <- data.frame(names(apiData$dimension$time$category$index), unlist(unname(apiData$dimension$time$category$index)))
    colnames(consolidatedData) <- c("Month", "Index")
    consolidatedData <- merge(consolidatedData, values, by = "Index", all = TRUE) %>% mutate(Date = switch(prec, "year" = Month, "month" = ym(Month), "semester" = Month)) %>% select(-Index, -Month)
    consolidatedData <- drop_na(consolidatedData)
    row <- data.frame(code = code, label = label)
    row$data <- list(consolidatedData)
    return(row)
  }
}

# --- get all data from every country and fill into mongodb ---
# --- Oil Price ---
provided by eia.gov
oilPriceData <- call_api('https://api.eia.gov/v2/petroleum/pri/spt/data?api_key=a6BwytwjsQLCDb3KXMwJZE11WPoT64BnazpYaYEE&frequency=daily&facets[product][]=EPCBRENT&data[]=value')$response$data
oilPriceData <- oilPriceData %>% select(
  -duoarea,
  -'area-name',
  -product,
  -'product-name',
  -process,
  -'process-name',
  -series,
  -'series-description',
  -units)
oilPriceCollection <- mongo(collection = 'BrentOilPrice', db = 'General')
oilPriceCollection$insert(oilPriceData)

# --- data from eurostat ---
baseUrl <- "http://ec.europa.eu/eurostat/wdds/rest/data/v2.1/json/en/"
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
  "Portugal")
countryCode <- c(
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
  "PT")
countryList <- data.frame(countryCode, country)

## --- energy generation ---
siecCode <- c(
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
  "X9900")
siecLabel <- c(
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
  "Other fuels n.e.c.")
siecList <- data.frame(siecCode, siecLabel)

for (countryCode in countryList$countryCode) {
  generationData <- data.frame(matrix(nrow = 0, ncol = 3))
  colnames(generationData) <- c("siecCode", "siecLabel", "crfData")

  for (siecCode in siecList$siecCode) {
    url <- paste(baseUrl, "nrg_cb_pem?siec=", siecCode, "&sinceTimePeriod=2016M01&precision=1&geo=", countryCode, "&unitLabel=label", sep = "")
    generationData <- rbind(generationData, prep_eurostat_data(url, siecCode, siecList[siecList$siecCode == siecCode,]$siecLabel, "month"))
  }
  generationCollection <- mongo(collection = "energyGeneration", db = countryCode)
  generationCollection$insert(generationData)
}

## --- emissions ---
airpolCode <- c("CH4", "CH4_CO2E", "CO2", "GHG", "HFC_CO2E", "HFC_PFC_NSP_CO2E", "N2O", "N2O_CO2E", "NF3_CO2E", "PFC_CO2E", "SF6_CO2E")
airpolLabel <- c("Methane", "Methane (CO2 eq.)", "Carbon dioxide", "Greenhouse gases (CO2, N2O in CO2 eq., CH4 in CO2 eq., HFC in CO2 eq., PFC in CO2 eq., SF6 in CO2 eq., NF3 in CO2 eq.", "Hydrofluorocarbones (CO2 eq.)", "Hydrofluorocarbones and perfluorocarbones - nor specified mix (CO2 eq.)", "Nitrous oxide", "Nitrous oxide (CO2 eq.)", "Nitrogen trifluoride (CO2 eq.)", "Perfluorocarbones (CO2 eq.)", "Sulphur hexafluoride (CO2 eq.)")
airpolList <- data.frame(airpolCode, airpolLabel)

crfCode <- c("CRF1", "CRF1A1", "CRF1A1A", "CRF1A1B", "CRF1A1C", "CRF1B2")
crfLabel <- c("Energy", "Fuel combustion in energy industries", "Fuel combustion in public electricity and heat production", "Fuel combustion in petroleum refining", "Fuel combustion in manufacture of solid fuels and other energy industries", "Oil, natural gas and other energy production - fugitive emissions")
crfList <- data.frame(crfCode, crfLabel)

for (countryCode in countryList$countryCode) {
  emissionData <- data.frame(matrix(nrow = 0, ncol = 3))
  colnames(emissionData) <- c("crfCode", "crfLabel", "crfData")
  for (crfCode in crfList$crfCode) {
    crfData <- data.frame()
    for (airpolCode in airpolList$airpolCode) {
      url <- paste(baseUrl, "env_air_gge?airpol=", airpolCode, "&sinceTimePeriod=1985&precision=1&src_crf=", crfCode, "&geo=", countryCode, "&unit=MIO_T&unitLabel=label", sep = "")
      crfData <- rbind(crfData, prep_eurostat_data(url, airpolCode, airpolList[airpolList$airpolCode == airpolCode, ]$airpolLabel, "year"))
    }
    emissionRow <- data.frame(crfCode, crfLabel = crfList[crfList$crfCode == crfCode, ]$crfLabel)
    emissionRow$data <- list(crfData)
    emissionData <- rbind(emissionData, emissionRow)
  }
  emissionCollection <- mongo(collection = "emissions", db = countryCode)
  emissionCollection$insert(emissionData)
}

## --- share of energy by renewables --- -> maybe not enough data
energyCode <- c("REN", "REN_ELC", "REN_HEAD_CL", "REN_TRA")
energyLabel <- c("Renewable energy sources", "Renewable energy sources in electricity", "Renewable energy sources in heating and cooling", "Renewable energy soruces in transport")
energyList <- data.frame(energyCode, energyLabel)

for (countryCode in countryList$countryCode) {
  shareData <- data.frame()
  for (energyCode in energyList$energyCode) {
    url <- paste(baseUrl, "nrg_ind_ren?sinceTimePeriod=2004&precision=1&geo=", countryCode, "&unitLabel=label&nrg_bal=", energyCode, sep = "")
    shareData <- rbind(shareData, prep_eurostat_data(url, energyCode, energyList[energyList$energyCode == energyCode, ]$energyLabel, "year"))
  }
  shareCollection <- mongo(collection = "shareOfRenewableEnergy", db = countryCode)
  shareCollection$insert(shareData)
}

## --- installed capacity ---
operatorCode <- c("PRR_AUTO", "PRR_MAIN")
operatorLabel <- c("Autoproducers", "Main activity producers")
operatorList <- data.frame(operatorCode, operatorLabel)

for (countryCode in countryList$countryCode) {
  capacityData <- data.frame()
  for (operatorCode in operatorList$operatorCode) {
    siecData <- data.frame()
    for (siecCode in siecList$siecCode) {
      url <- paste(baseUrl, "nrg_inf_epc?siec=", siecCode, "&sinceTimePeriod=1990&precision=1&operator=", operatorCode, "&geo=", countryCode, sep = "")
      siecData <- rbind(siecData, prep_eurostat_data(url, siecCode, siecList[siecList$siecCode == siecCode, ]$siecLabel, "year"))
    }
    capacityRow <- data.frame(code = operatorCode, label = operatorList[operatorList$operatorCode == operatorCode, ]$operatorLabel)
    capacityRow$data <- list(siecData)
    capacityData <- rbind(capacityData, capacityRow)
  }
  capacityCollection <- mongo(collection = "installedCapacity", db = countryCode)
  capacityCollection$insert(capacityData)
}

## --- Prices ---
### --- Industry ---
consomCode <- c("4162050", "4162100", "4162150", "4162200", "4162250", "4162300", "4162350", "4162400", "4162450")
consomLabel <- c("Industry - Ia (Annual consumption: 30 MWh; maximum demand: 30 kW; annual load: 1 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
  "Industry - Ib (Annual consumption: 50 MWh; maximum demand: 50 kW; annual load: 1 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
  "Industry - Ic (Annual consumption: 160 MWh; maximum demand: 100 kW; annual load: 1 600 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
  "Industry - Id (Annual consumption: 1 250 MWh; maximum demand: 500 kW; annual load: 2 500 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
  "Industry - Ie (Annual consumption: 2 000 MWh; maximum demand: 500 kW; annual load: 4 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
  "Industry - If (Annual consumption: 10 000 MWh; maximum demand: 2 500 kW; annual load: 4 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
  "Industry - Ig (Annual consumption: 24 000 MWh; maximum demand: 4 000 kW; annual load: 6 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
  "Industry - Ih (Annual consumption: 50 000 MWh; maximum demand: 10 000 kW; annual load: 5 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)",
  "Industry - Ii (Annual consumption: 70 000 MWh; maximum demand: 10 000 kW; annual load: 7 000 hours) (for Luxembourg: 50% power reduction during hours of heavy loading)")
consomList <- data.frame(consomCode, consomLabel)

consomCodePost2007 <- c("4162901", "4162902", "4162903", "4162904", "4162905", "4162906", "4162907")
consomLabelPost2007 <- c("Band IA : Consumption < 20 MWh",
"Band IB : 20 MWh < Consumption < 500 MWh",
"Band IC : 500 MWh < Consumption < 2 000 MWh",
"Band ID : 2 000 MWh < Consumption < 20 000 MWh",
"Band IE : 20 000 MWh < Consumption < 70 000 MWh",
"Band IF : 70 000 MWh < Consumption < 150 000 MWh",
"Band IG : Consumption > 150 000 MWh")
consomListPost2007 <- data.frame(consomCodePost2007, consomLabelPost2007)
  
for (countryCode in countryList$countryCode) {
  priceData <- data.frame()
  for (consomCode in consomList$consomCode) {
    url <- paste(baseUrl, "nrg_pc_205_h?product=6000&sinceTimePeriod=1985S1&precision=1&tax=I_TAX&consom=", consomCode, "&geo=", countryCode, "&unitLabel=label&currency=EUR", sep = "")
    priceData <- rbind(priceData, prep_eurostat_data(url, consomCode, consomList[consomList$consomCode == consomCode, ]$consomLabel, "semester"))
  }
  priceCollection <- mongo(collection = "industryPrices", db = countryCode)
  priceCollection$insert(priceData)

  priceData <- data.frame()
  for (consomCodePost2007 in consomListPost2007$consomCodePost2007) {
    url <- paste(baseUrl, "nrg_pc_205?product=6000&sinceTimePeriod=2007S1&precision=1&tax=I_TAX&consom=", consomCodePost2007, "&geo=", countryCode, "&unit=KWH&currency=EUR", sep = "")
    priceData <- rbind(priceData, prep_eurostat_data(url, consomCodePost2007, consomListPost2007[consomListPost2007$consomCodePost2007 == consomCodePost2007, ]$consomLabelPost2007, "semester"))
  }
  priceCollection$insert(priceData)
}

### --- Consumer ---
consomCode <- c("4161050", "4161100", "4161150", "4161200", "4161250")
consomLabel <- c("Households - Da (Annual consumption: 600 kWh)", "Households - Db (Annual consumption: 1 200 kWh)", "Households - Dc (Annual consumption: 3 500 kWh of which night 1 300)", "Households - Dd (Annual consumption :7 500 kWh of which night 2 500)", "Households - De (Annual consumption: 20 000 kWh of which night 15 000)")
consomList <- data.frame(consomCode, consomLabel)

consomCodePost2007 <- c("4161901", "4161902", "4161903", "4161904", "4161905")
consomLabelPost2007 <- c("Band DA : Consumption < 1 000 kWh", "Band DB : 1 000 kWh < Consumption < 2 500 kWh", "Band DC : 2 500 kWh < Consumption < 5 000 kWh", "Band DD : 5 000 kWh < Consumption < 15 000 kWh", "Band DE : Consumption > 15 000 kWh")
consomListPost2007 <- data.frame(consomCodePost2007, consomLabelPost2007)

for (countryCode in countryList$countryCode) {
    priceData <- data.frame()
    for (consomCode in consomList$consomCode) {
      url <- paste(baseUrl, "nrg_pc_204_h?product=6000&sinceTimePeriod=1985S1&precision=1&tax=I_TAX&consom=", consomCode, "&geo=", countryCode, "&unitLabel=label&currency=EUR", sep = "")
      priceData <- rbind(priceData, prep_eurostat_data(url, consomCode, consomList[consomList$consomCode == consomCode, ]$consomLabel, "semester"))
    }
    priceCollection <- mongo(collection = "consumerPrices", db = countryCode)
    priceCollection$insert(priceData)

    priceData <- data.frame()
    for (consomCodePost2007 in consomListPost2007$consomCodePost2007) {
      url <- paste(baseUrl, "nrg_pc_204?product=6000&sinceTimePeriod=2007S1&precision=1&tax=I_TAX&consom=", consomCodePost2007, "&geo=", countryCode, "&unit=KWH&currency=EUR", sep = "")
      priceData <- rbind(priceData, prep_eurostat_data(url, consomCodePost2007, consomListPost2007[consomListPost2007$consomCodePost2007 == consomCodePost2007, ]$consomLabelPost2007, "semester"))
    }
    priceCollection$insert(priceData)
}