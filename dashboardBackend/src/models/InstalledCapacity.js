module.exports = mongoose => {
    const installedCapacity = mongoose.model(
      "installedCapacity",
      mongoose.Schema(
        {
          country_code: String,
          country_name: String,
          comment: String,
          data: Array
        },
        {
          collection: 'installedCapacity'
        }
      )
    );
    return installedCapacity;
  };