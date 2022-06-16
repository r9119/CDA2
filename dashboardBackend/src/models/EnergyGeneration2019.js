module.exports = mongoose => {
    const EnergyGeneration2019 = mongoose.model(
      "EnergyGeneration2019",
      mongoose.Schema(
        {
          country_code: String,
          country_name: String,
          comment: String,
          data: Array
        },
        {
          collection: 'energyGeneration2019'
        }
      )
    );
    return EnergyGeneration2019;
  };
