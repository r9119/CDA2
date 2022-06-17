# CDA2: Einfluss Ölpreis auf Treibhausgasausstoss
**A dashboard to cover the influence the oil price has on greenhouse gas emissions.** (currently confined to a handful countries in the EU, and currently only avaliable in german)

### Project Requirements:

* [Node.js](https://nodejs.org/en/) (14.15.5 or newer)
* [R](https://www.r-project.org/) (Or [RStudio](https://www.rstudio.com/products/rstudio/))
* [Docker](https://www.docker.com/) (To run a local mongoDB instance)

### Project Stack:

* [Vue 3](https://vuejs.org/) (Frontend)
* [Express.js](https://expressjs.com/) (Backend)
* [Mongoose](https://mongoosejs.com/) (Backend database connection)
* [MongoDB](https://www.mongodb.com/) (Database)

## Dashboard/Frontend
#### Frontend Setup
##### Initialisation
```
cd dashboard
npm install
```

##### Compiles and hot-reloads for development/Local hosting:
```
npm run dev
```

##### Compile for production:
```
npm run build
```

#### Navigating and using the dashboard:
Die Startseite des Dashboards (localhost:3000/) besteht aus einer  Weltkarte der erfassten Länder. Diese dient als Navigationsportal. Wenn Sie auf eines der Länder auf der Karte klicken, kommen Sie auf die Detailseite des jeweiligen Landes.

Unterhalb der Kartennavigation befindet sich ein kurzer Überblick über den Umfang des Dashboards. Dazu gehört ein Diagramm, in dem historische Daten zum Brent Ölpreis (Ii Dollar) und zu den gesamten Treibhausgasemissionen der EU (tCO2 eq.) verglichen werden.

The landing page of the dashboard (localhost:3000/) consitsts of a map of the covered countries. This serves as the navigation portal, clicking on one of the countries on the map takes you to the details page of that country.

Underneath the map navigation, there is a short oversight of the scope of the dashboard. Which includes a graph comparing historical data of both the Brent oil price (in dollars) and overall EU GHG emissions (tCO2 eq.).

## Backend:
#### Backend Setup
##### Initialisation
```
cd dashboardBackend
npm install
```

##### Compiles and hot-reloads for development/Local hosting:
```
npm start
```

## MongoDB Setup:
[MongoDB Docker and Database Setup](https://github.com/r9119/CDA2/blob/main/analysisInR/readme.md)

# Datenbeschaffung

Zu Beginn der Challenge haben wir uns zunächst mit der Beschaffung der benötigten Daten beschäftigt. Dazu haben wir definiert, dass wir die folgenden Informationen pro Land sammeln möchten:
- Co2 / GHG Emissionen der Energieindustrie
- Produzierte Energie
- Anteil pro Energiequelle
- Brent-Ölpreis
- Co2 Preis Europa
- Installierte Kapazität pro Energiequelle
- Strompreise
- LCOE pro Energiequelle

Wir haben die folgenden Datenquellen identifiziert:
- [Our World In Data](https://ourworldindata.org/energy-key-charts)
- [Eurostat](https://ec.europa.eu/eurostat/online-help/public/en/API_01_Introduction_en/)
- [U.S. Energy Information Administration (EIA)](https://www.eia.gov/opendata/documentation.php)
- [Red Electrica (ree)](https://www.ree.es/en/apidatos)
- Staatliche APIs der Statistikdepartements:
- [Polen](https://api.stat.gov.pl/Home/BdlApi)
- [Niederlande](https://www.cbs.nl/en-gb/our-services/open-data/statline-as-open-data/quick-start-guide)
- [Schweden](https://www.scb.se/en/services/open-data-api/api-for-the-statistical-database/)
- [Finnland](https://www.stat.fi/static/media/uploads/org_en/avoindata/px-web_api-help.pdf)
- [Portugal](https://www.ine.pt/xportal/xmain?xpid=INE&xpgid=ine_api&INST=322751522&ine_smenu.boui=357197120&ine_smenu.selected=357197822&xlang=en)
- [Österreich](https://www.statistik.at/)
- [Griechenland](https://www.statistics.gr/en/statistics/-/publication/SIN09/-)
- [Island](http://px.hagstofa.is/pxen/pxweb/en/Umhverfi/?rxid=4ef4a14f-4e53-4199-8c70-32a9fa03e022)
- [Türkei](https://biruni.tuik.gov.tr/medas/?kn=147&locale=en)
- [Ember](https://ember-climate.org/data/data-tools/carbon-price-viewer/)

Dabei haben wir herausgefunden, dass die Daten von Spanien (REE) sehr detailliert zur Verfügung gestellt werden, weshalb wir uns dafür entschieden haben, Spanien als Grundlage für unsere Analyse zu machen. 

## Hypothese
Ein Teil der Challenge behandelt die Hypothese "Hoher Ölpreis - tiefe Emissionen". Um dies zu überprüfen haben wir uns zunächst einen Überblick über die Daten verschaffen und anschliessend eine lineare Regression mit den Emissionen der Energieproduktion in Spanien und dem Ölpreis erstellt. Das haben wir mit R gelöst und Notizen dazu im Notebook `Analysis-notebook.Rmd` festgehalten. Wir haben bemerkt, dass sich die Daten innerhalb von einem Jahr ansammeln, sodass sich die Jahre auf dem Scatterplot klar abzeichnen. Wir haben uns deshalb entschieden, eine Regression pro Jahr zu erstellen, um die Hypothese genauer zu überprüfen. Wir konnten mit diesen Regressionen keinen klaren Zusammenhang identifizieren. Ein Jahr zeigt eine starke aber sehr zerstreute positive Korrelation und das nächste Jahr genau umgekehrt.

## Daten für das Dashboard
Für das Dashboard wollten wir jeweils die höchste Auflösung der Daten zur Verfügung stellen, um ein möglichst genaues Bild liefern zu können. Wir haben dann aber bemerkt, dass die Daten von REE eine Ausnahme darstellen, denn von sämtlichen anderen Quellen konnten wir höchstens Monatliche Daten extrahieren. Um den Zeitrahmen einhalten zu können, haben wir uns deshalb dafür enschieden, die Daten für das Dashboard von Eurostat zu beziehen, weil wir dort für jedes ausgewählte Land die Daten im selben Format abrufen können. Wir haben im Script `loadDB.r` Code geschrieben, welcher die benötigten Daten liest, aufbereitet und in eine Datenbank (MongoDB) schreibt. Diese Daten werden dann vom Backend des Dashboards abgerufen. 

## Szenariorechnung
Eine Szenariorechnung zu erstellen war ein weiterer Teil der Challenge. Wir haben überlegt Price Forward Curves und Merit Order Modelle zu erstellen, was jedoch unser Wissen und Zeitbudget übersteigt. Mit den Levelized Costs of Energy von [Our World In Data](https://ourworldindata.org/cheap-renewables-growth) haben wir einen guten Anhaltspunkt für die Berechnung des Strompreises gefunden. Zusammen mit dem Anteil pro Energiequelle konnten wir die folgende Szenariorechnung erstellen:
- Wir selektieren die Strompreise für [Haushalte](https://ec.europa.eu/eurostat/databrowser/view/nrg_pc_204/default/table?lang=en&category=env.env_air.env_air_ai) und [Industrie](https://ec.europa.eu/eurostat/databrowser/view/nrg_pc_205/default/table?lang=en&category=env.env_air.env_air_ai) von dem Jahr 2019
- Der Preis wird mit höherem Verbrauch teurer. Um die Rechnung Übersichtlich zu halten, haben wir jeweils den Durchschnitt der gesamten Bänder berechnet. 
- Wir berechnen dann, wie viel % der Energieproduktion durch die Energiequellen, für welche wir die LCOEs kennen, erzeugt wurde. Nur dieser Anteil vom Preis wird also durch die Produktion der berücksichtigten Quellen beeinflusst, weshalb wir diesen isolieren. 
- Wir berechnen dann, welcher Anteil von diesem Isolierten Preis durch die LCOEs erklärt werden (Anteil pro Energiequelle * LCOE)
- Wenn dann auf dem Dashboard der Slider bewegt wird, wird der Preis ausgerechnet, indem die neuen Anteile mit den LCOEs verrechnet und mit dem nicht erklärten Teil vom gesamten Strompreis summiert werden. 

Uns ist bewusst, dass dies nur eine grobe Schätzung ist, aber wir haben diese Schätzung als die Beste für den vorgegebenen Rahmen identifiziert. 
