module.exports = mongoose => {
    const LinearModel = mongoose.model(
      "LinearModel",
      mongoose.Schema(
        {
          country_code: String,
          country_name: String,
          data: Array
        },
        {
          collection: 'linearModel'
        }
      )
    );
    return LinearModel;
  };
