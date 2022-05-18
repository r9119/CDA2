# Instructions / Notes
In this folder, the data is read, saved and analyzed.  

`Analysis-notebook.Rmd` is a work in progress. Currently it pulls data from energy departements of Spain, Netherlands and Poland and saves it to mongoDB although only Spain's data is more detailed than the data provided by eurostat. The analysis part doesn't work at the moment.  

`loadDB.r` reads data from eurostat for every country, prepares it and saves it to mongodb.  

Both files need a local instance of MongoDB to work, which can easily be created with Docker:  
```r
docker run --name mongodb -d -p 27017:27017 mongo
```
Once it has been run, a container is created and this can be listed with
```r
docker ps -l
```
To shut down the Container type
```
docker stop 'id'
```
To start it again type
```
docker start 'id'
```

# ToDos
- Change analysis Notebook to read from MongoDB
- analyse and understand the data thoroughly
- read and save more detailed data where possible and needed
- test, if DB structure works for the Frontend