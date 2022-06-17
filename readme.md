# CDA2: Einfluss Ölpreis auf Treibhausgasausstoss
**A dashboard to cover the influence the oil price has on greenhouse gas emissions.** (currently confined to specific countries in the EU, and currently only avaliable in german)

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
The landing page of the dashboard (localhost:3000/) consitsts of a map of the covered countries. This serves as the navigation portal, clicking on one of the countries on the map takes you to the details page of that country.

Underneath the map navigation, there is a short oversight of the scope of the dashboard. Which includes a graph comparing historical data of both the Brent oil price ($) and overall EU GHG emissions (tCO2 eq.).

Data sources are mentioned under each graph.

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
