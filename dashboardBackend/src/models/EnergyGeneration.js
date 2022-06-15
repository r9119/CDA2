module.exports = mongoose => {
    const EnergyGeneration = mongoose.model(
      "EnergyGeneration",
      mongoose.Schema(
        {
          country_code: String,
          country_name: String,
          comment: String,
          data: Array
        },
        {
          collection: 'energyGeneration'
        }
      )
    );
    return EnergyGeneration;
  };
