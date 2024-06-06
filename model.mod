# SETS

set YEARS;
set AGE;

set VEHICL;
set V_SIZE;
set V_TYPE;
set V_DRNG;

set FUELS;

# params

param vehicle_type               {VEHICL}                    symbolic;
param vehicle_size               {VEHICL}                    symbolic;
param model_year                 {VEHICL};
param purch_cost                 {VEHICL};
param yearly_range               {VEHICL};
param daily_range                {VEHICL}                    symbolic;
param fuel_emissions             {       FUELS          };

param resale_value               {                  AGE };
param insurance_cost             {                  AGE };
param maintenance_cost           {                  AGE };

param carbon_emissions           {             YEARS    };

param vehicle_fuel_consumption   {VEHICL,FUELS          };
param fuel_cost                  {       FUELS,YEARS    };
param fuel_cost_uncertainty      {       FUELS,YEARS    };

param demand                     {             YEARS,V_SIZE,V_DRNG};