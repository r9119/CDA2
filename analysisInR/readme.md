# Instructions / Notes
In this folder, the data is read, saved and analyzed.  

`Analysis-notebook.Rmd` is to be considered as a Notebook. We documented our analysis and preparation for the dashboard in it. 

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
When the Docker Container is running, the file `loadDB.r` can be executed to provide the DB with data. Please note, that it isn't designed to be executed multiple times. Dump the Database `cda2` before running the script again to ensure a clean database.