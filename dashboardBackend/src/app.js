const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const morgan = require('morgan');
const db = require('./models');
const PORT = 3030;

const app = express();
app.use(morgan('tiny'));
app.use(bodyParser.json());
app.use(cors());

require('./routes')(app);

db.sequelize.sync().then(() => {
    app.listen(PORT, () => {
        console.log(`listening at: http://localhost:${PORT}`);
    })
})
