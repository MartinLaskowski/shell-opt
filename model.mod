#======#
# SETS #
#======#

set DRVT;
set VEHC;
set FUEL;           # s4
set SIZE ordered;
set DIST ordered;
set AGES ordered;
set YEAR ordered;

#========#
# params #
#========#

param drvt             {     VEHC                                                                  } symbolic                                        ;
param size             {     VEHC                                                                  } symbolic                                        ;
param dist             {     VEHC                                                                  } symbolic                                        ;
param year             {     VEHC                                                                  }                                                 ;
param d_max_pa         {     VEHC                                                                  }                                                 ;
param c_prch           {     VEHC                                                                  }                                                 ;   # p1
param can_use          {                DRVT,      FUEL                                            }                                                 ;
param fuel_cons        {v in VEHC,            f in FUEL: can_use[drvt[v],f] = 1                    }                                                 ;   # p3
param co2_rate         {                           FUEL                                            }                                                 ;   # p5
param c_fuel           {                           FUEL,                            YEAR           }                                                 ;   # p4
param c_fuel_uncr      {                           FUEL,                            YEAR           }                                                 ;   # <--- IMPLEMENT!
param co2_max          {                                                            YEAR           }                                                 ;
param demand           {                                      SIZE,      DIST,      YEAR           }                                                 ;
param c_insu_fctr      {                                                                       AGES}                                                 ;
param c_mntn_fctr      {                                                                       AGES}                                                 ;
param c_sell_fctr      {                                                                       AGES}                                                 ;
param age              {v in VEHC,                                             y in YEAR           }   = if year[v]  > y then 0 else y - year[v] + 1 ;
param dpr_val          {v in VEHC,                                             y in YEAR           }   = if age[v,y] = 0 then c_prch[v]
                                                                                                    else if age[v,y] > 10 then 0
                                                                                                    else (c_sell_fctr[age[v,y]]/100) * c_prch[v]     ;   # p2
#===========#
# Variables #
#===========#

var Qty_Buy            {     VEHC,                                                  YEAR                                                             } integer >= 0   <= 500        ;   # F
var Qty_Own            {     VEHC,                                                  YEAR                                                             } integer >= 0   <= 500        ;   # H
var Qty_Sel            {     VEHC,                                                  YEAR                                                             } integer >= 0   <= 500        ;   # M
var Qty_Use            {v in VEHC,            f in FUEL,            d in DIST,      YEAR: can_use[drvt[v],f] = 1 and ord(d,DIST) <= ord(dist[v],DIST)} integer >= 0   <= 500        ;   # L 
var Supply             {v in VEHC,            f in FUEL,            d in DIST,      YEAR: can_use[drvt[v],f] = 1 and ord(d,DIST) <= ord(dist[v],DIST)}         >= 0   <= d_max_pa[v] ;   # K

#===========#
# Objective #
#===========#

minimize C_Total:   # ^
    sum {y in YEAR} (
          sum {v in VEHC                                                                                   }   (Qty_Buy[v,y]    * c_prch[v]                                 )  # A G
        + sum {v in VEHC:                       0 < age[v,y] < 11                                          }   (Qty_Own[v,y]    * c_prch[v]   * (c_insu_fctr[age[v,y]]/100) )  # B I
        + sum {v in VEHC:                       0 < age[v,y] < 11                                          }   (Qty_Own[v,y]    * c_prch[v]   * (c_mntn_fctr[age[v,y]]/100) )  # C J
        + sum {v in VEHC, f in FUEL, d in DIST: can_use[drvt[v],f] = 1 and ord(d,DIST) <= ord(dist[v],DIST)}   (Supply[v,f,d,y] * c_fuel[f,y] * fuel_cons[v,f]              )  # D
        - sum {v in VEHC                                                                                   }   (Qty_Sel[v,y]    * dpr_val[v,y]                              )  # E
    );

#=============#
# Constraints #
#=============#

s.t. DEF_Qty_Own_y1    {v in VEHC,                                             y in YEAR: y = first(YEAR)}:                   Qty_Buy[v,y]                                      =                    Qty_Own[v,y] ;   # F H     C7
s.t. DEF_Qty_Own       {v in VEHC,                                             y in YEAR: y > first(YEAR)}:                   Qty_Buy[v,y] + Qty_Own[v,y-1] - Qty_Sel[v,y-1]    =                    Qty_Own[v,y] ;   # F H M   C7
s.t. Sell_by_y10       {v in VEHC,                                             y in YEAR: age[v,y] > 10  }:                   0                                                 =                    Qty_Own[v,y] ;   #         C6
s.t. Buy_in_Model_Year {v in VEHC,                                             y in YEAR: y != year[v]   }:                   0                                                 =                    Qty_Buy[v,y] ;   # F       C5
s.t. Sell_Owned        {v in VEHC,                                             y in YEAR                 }:                   Qty_Own[v,y]                                     >=                    Qty_Sel[v,y] ;
s.t. Sell_Max_20pc     {                                                       y in YEAR                 }:   sum {v in VEHC} Qty_Own[v,y]  * 0.2                              >=  sum {v in VEHC}   Qty_Sel[v,y] ;   #     C8

s.t. DEF_Qty_Use       {v in VEHC,                                             y in YEAR                 }:                   Qty_Own[v,y]                                      =  sum {f in FUEL, d in DIST:            can_use[drvt[v],f] = 1                 and ord(d,DIST) <= ord(dist[v],DIST)}   Qty_Use[v,f,d,y]                                                   ;
s.t. Max_CO2           {                                                       y in YEAR                 }:                   co2_max[y]                                       >=  sum {v in VEHC, f in FUEL, d in DIST: can_use[drvt[v],f] = 1                 and ord(d,DIST) <= ord(dist[v],DIST)}  (Qty_Use[v,f,d,y] * Supply[v,f,d,y] * co2_rate[f] * fuel_cons[v,f]) ;   # N   C3
s.t. Satisfy_Demand    {                                 s in SIZE, d in DIST, y in YEAR                 }:                   demand[s,d,y] + 2                                <=  sum {v in VEHC, f in FUEL:            can_use[drvt[v],f] = 1 and size[v] = s and ord(d,DIST) <= ord(dist[v],DIST)}  (Qty_Use[v,f,d,y] * Supply[v,f,d,y])                                ;   #     C1 C2 C4

