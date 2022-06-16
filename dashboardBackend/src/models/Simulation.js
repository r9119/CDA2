module.exports = mongoose => {
  const Simulation = mongoose.model(
    "Simulation",
    mongoose.Schema(
      {
        country_name: String,
        country_code: String,
        consumer_price: Number,
        industry_price: Number,
        unexplained_consumer: Number,
        unexplained_industry: Number,
        data: Array
      },
      {
        collection: 'simulation'
      }
    )
  );
  return Simulation;
};