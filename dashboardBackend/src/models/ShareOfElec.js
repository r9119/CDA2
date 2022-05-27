const EnergyGeneration = require("./EnergyGeneration");

module.exports = mongoose => {
    const ShareOfElec = mongoose.model(
      "ShareOfElec",
      mongoose.Schema(
        {
          value: Number,
          percentage: Number,
          datetime: String
        },
        {
          collection: 'ShareOfElec'
        }
      )
    );
    return ShareOfElec;
  };


// Structure that we need:
// {
//     country: String,
//     year: String,
//     values: Object
// }
// Values structure:
// {
//     source: String, The source/sector where the energy comes from
//     data: Number
// }
// Options for chart js can be added later as they are needed inside of the 'values' option
// "labels": [],
// "datasets": [
//     {
//         "label": "Brent Oil Price",
//         "fill": false,
//         "borderWidth": 2,
//         "borderColor": "rgb(75, 192, 192)",
//         "tension": 0.5,
//         "pointRadius": 0,
//         "data": [] 'values' go here
//     }
// ]