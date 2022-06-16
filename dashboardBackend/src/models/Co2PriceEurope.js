module.exports = mongoose => {
    const Co2OilPriceEurope = mongoose.model(
      "Co2OilPriceEurope",
      mongoose.Schema(
        {
          Date: String,
          Price: Number
        },
        {
          collection: 'co2OilPriceEurope'
        }
      )
    );
    return Co2OilPriceEurope;
  };
