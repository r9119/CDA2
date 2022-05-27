module.exports = mongoose => {
    const BrentOilPrice = mongoose.model(
      "BrentOilPrice",
      mongoose.Schema(
        {
          period: String,
          value: Number
        },
        {
          collection: 'BrentOilPrice'
        }
      )
    );
    return BrentOilPrice;
  };