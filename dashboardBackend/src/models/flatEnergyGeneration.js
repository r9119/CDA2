module.exports = mongoose => {
    const flatEnergyGeneration = mongoose.model(
      "flatEnergyGeneration",
      mongoose.Schema(
        {
          country_code: String,
          country_name: String,
          comment: String,
          data: Array
        },
        {
          collection: 'flatEnergyGeneration'
        }
      )
    );
    return flatEnergyGeneration;
  };
