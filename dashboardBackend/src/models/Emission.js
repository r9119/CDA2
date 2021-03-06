module.exports = mongoose => {
    const Emission = mongoose.model(
      "Emission",
      mongoose.Schema(
        {
          country_code: String,
          country_name: String,
          comment: String,
          data: Array
        },
        {
          collection: 'emissions'
        }
      )
    );
    return Emission;
  };
