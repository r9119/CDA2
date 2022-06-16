module.exports = mongoose => {
    const EmissionsEurope = mongoose.model(
      "EmissionsEurope",
      mongoose.Schema(
        {
          Year: Number,
          Electricity_and_heat: Number
        },
        {
          collection: 'emissionsEurope'
        }
      )
    );
    return EmissionsEurope;
  };
