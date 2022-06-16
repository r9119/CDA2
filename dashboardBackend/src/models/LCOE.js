module.exports = mongoose => {
    const LCOE = mongoose.model(
      "LCOE",
      mongoose.Schema(
        {
          Gas_Peaker: Number,
          Nuclear: Number,
          Solar_Thermal_Power: Number,
          Coal: Number,
          Gas: Number,
          Onshore_Wind: Number,
          Solar_Photovoltaic: Number,
          Offshore_Wind: Number,
        },
        {
          collection: 'LCOE'
        }
      )
    );
    return LCOE;
  };
