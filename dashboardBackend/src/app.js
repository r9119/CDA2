const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const morgan = require('morgan');
const PORT = 8080;

const app = express();
app.use(morgan('tiny'));
app.use(bodyParser.json());
app.use(cors({
    origin: "localhost:8080"
}));

const db = require("./models");
db.mongoose
  .connect(db.url, {
    useNewUrlParser: true,
    useUnifiedTopology: true
  })
  .then(() => {
    console.log("Connected to the database!");
  })
  .catch(err => {
    console.log("Cannot connect to the database!", err);
    process.exit();
  });

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  next();
});

require('./routes')(app);

app.listen(PORT, () => {
    console.log(`listening at: http://localhost:${PORT}`);
})
