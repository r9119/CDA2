module.exports = mongoose => {
    const IndustryPrices = mongoose.model(
      "IndustryPrices",
      mongoose.Schema(
        {
          country_code: String,
          country_name: String,
          comment: String,
          data: Array
        },
        {
          collection: 'industryPrices'
        }
      )
    );
    return IndustryPrices;
  };