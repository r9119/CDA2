module.exports = mongoose => {
    const ConsumerPrices = mongoose.model(
      "ConsumerPrices",
      mongoose.Schema(
        {
          country_code: String,
          country_name: String,
          comment: String,
          data: Array
        },
        {
          collection: 'consumerPrices'
        }
      )
    );
    return ConsumerPrices;
  };