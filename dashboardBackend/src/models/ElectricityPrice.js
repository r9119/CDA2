module.exports = mongoose => {
    const ElecPrice = mongoose.model(
      "ElecPrice",
      mongoose.Schema(
        {
          value: Number,
          percentage: Number,
          datetime: String
        },
        {
          collection: 'ElecPrice'
        }
      )
    );
    return ElecPrice;
  };


// Structure that we need:
//   {
//       country: String,
//       values: Array,
//       labels/dates: String
//   }
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