module.exports = mongoose => {
    const ShareOfRenewables = mongoose.model(
      "ShareOfRenewables",
      mongoose.Schema(
        {
          country_code: String,
          country_name: String,
          comment: String,
          data: Array
        },
        {
          collection: 'shareOfRenewableEnergy'
        }
      )
    );
    return ShareOfRenewables;
  };