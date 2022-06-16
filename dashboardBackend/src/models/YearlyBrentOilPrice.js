module.exports = mongoose => {
    const YearlyBrentOilPrice = mongoose.model(
      "YearlyBrentOilPrice",
      mongoose.Schema(
        {
          year: Number,
          sum: Number,
          avg: Number
        },
        {
          collection: 'yearlyBrentOilPrice'
        }
      )
    );
    return YearlyBrentOilPrice;
  };