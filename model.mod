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

param drvt          {VEHC                              } symbolic;
param size          {VEHC                              } symbolic;
param dist          {VEHC                              } symbolic;
param year          {VEHC                              };
param d_max_pa      {VEHC                              };
param c_prch        {VEHC                              };   # p1
param fuel_cons     {VEHC,     FUEL                    };   # p3
param can_use       {     DRVT,FUEL                    };
param co2_rate      {          FUEL                    };   # p5
param c_fuel        {          FUEL,          YEAR     };   # p4
param c_fuel_uncr   {          FUEL,          YEAR     };   # <--- IMPLEMENT!
param co2_max       {                         YEAR     };
param demand        {               SIZE,DIST,YEAR     };
param c_insu_fctr   {                              AGES};
param c_mntn_fctr   {                              AGES};
param c_sell_fctr   {                              AGES};

# calculated params
param age      {v in VEHC,               y in YEAR     }   = if year[v]  > y then 0         else y - year[v] + 1;
param dpr_val  {v in VEHC,               y in YEAR     }   = if age[v,y] = 0 then c_prch[v] else if age[v,y] > 10 then 0 else (c_sell_fctr[age[v,y]]/100) * c_prch[v];   # p2

#===========#
# Variables #
#===========#

var C_Buy_Total     {                         YEAR     } >= 0;                                         # A
var C_Ins_Total     {                         YEAR     } >= 0;                                         # B
var C_Mnt_Total     {                         YEAR     } >= 0;                                         # C
var C_Fue_Total     {                         YEAR     } >= 0;                                         # D
var C_Sel_Total     {                         YEAR     } >= 0;                                         # E
var C_Buy           {VEHC,                    YEAR     } >= 0;                                         # G
var C_Ins           {VEHC,                    YEAR     } >= 0;                                         # I
var C_Mnt           {VEHC,                    YEAR     } >= 0;                                         # J
var C_Fue           {VEHC,                    YEAR     } >= 0;
var C_Sel           {VEHC,                    YEAR     } >= 0;
var Qty_Buy         {VEHC,                    YEAR     } >= 0   integer;                               # F
var Qty_Own         {VEHC,                    YEAR     } >= 0   integer;                               # H
var Qty_Sel         {VEHC,                    YEAR     } >= 0   integer;                               # M
var CO2_Total       {                    y in YEAR     } >= 0   <= co2_max[y];                         # N   C3
var Supply     {v in VEHC,f in FUEL,          YEAR     } >= 0   <= d_max_pa[v] * can_use[drvt[v],f];   # K
var Qty_OnFue       {VEHC,FUEL,               YEAR     } >= 0   integer;                               # L

#===========#
# Objective #
#===========#

minimize C_Total:       # ^
    sum {y in YEAR} (
          C_Buy_Total[y]
        + C_Ins_Total[y]
        + C_Mnt_Total[y]
        + C_Fue_Total[y]
        - C_Sel_Total[y]
    );

#=============#
# Constraints #
#=============#

s.t. DEF_C_Buy_Total {                      y in YEAR                        }:   C_Buy_Total[y]   = sum {v in VEHC}   C_Buy[v,y];   # A
s.t. DEF_C_Ins_Total {                      y in YEAR                        }:   C_Ins_Total[y]   = sum {v in VEHC}   C_Ins[v,y];   # B
s.t. DEF_C_Mnt_Total {                      y in YEAR                        }:   C_Mnt_Total[y]   = sum {v in VEHC}   C_Mnt[v,y];   # C
s.t. DEF_C_Fue_Total {                      y in YEAR                        }:   C_Fue_Total[y]   = sum {v in VEHC}   C_Fue[v,y];   # D
s.t. DEF_C_Sel_Total {                      y in YEAR                        }:   C_Sel_Total[y]   = sum {v in VEHC}   C_Sel[v,y];   # E

s.t. DEF_C_Buy       {v in VEHC,            y in YEAR                        }:   C_Buy[v,y]       = Qty_Buy[v,y]     * c_prch[v]                                   ;   # G
s.t. DEF_C_Ins       {v in VEHC,            y in YEAR: 0 < age[v,y] < 11     }:   C_Ins[v,y]       = Qty_Own[v,y]     * c_prch[v]     * (c_insu_fctr[age[v,y]]/100) ;   # I
s.t. DEF_C_Mnt       {v in VEHC,            y in YEAR: 0 < age[v,y] < 11     }:   C_Mnt[v,y]       = Qty_Own[v,y]     * c_prch[v]     * (c_mntn_fctr[age[v,y]]/100) ;   # J
s.t. DEF_C_Fue       {v in VEHC, f in FUEL, y in YEAR: can_use[drvt[v],f] = 1}:   C_Fue[v,y]       = Qty_OnFue[v,f,y] * Supply[v,f,y] * c_fuel[f,y] * fuel_cons[v,f];
s.t. DEF_C_Sel       {v in VEHC,            y in YEAR                        }:   C_Sel[v,y]       = Qty_Sel[v,y]     * dpr_val[v,y]                                ;
s.t. DEF_Qty_OnFue   {v in VEHC,            y in YEAR                        }:   Qty_Own[v,y]     = sum {f in FUEL: can_use[drvt[v],f] = 1} Qty_OnFue[v,f,y];

s.t. Release_Year    {v in VEHC,            y in YEAR: y != year[v]          }:                     0                     =                  Qty_Buy[v,y]                 ;   # F       C5
s.t. Sell_by_y10     {v in VEHC,            y in YEAR: age[v,y] > 10         }:                     Qty_Own[v,y]          = 0                                             ;   #         C6
s.t. DEF_Qty_Own_y1  {v in VEHC,            y in YEAR: y = first(YEAR)       }:                     Qty_Own[v,y]          =                  Qty_Buy[v,y]                 ;   # F H     C7
s.t. DEF_Qty_Own     {v in VEHC,            y in YEAR: y > first(YEAR)       }:                     Qty_Own[v,y]          = Qty_Own[v,y-1] + Qty_Buy[v,y] - Qty_Sel[v,y-1];   # F H M   C7
s.t. Sell_20pc       {                      y in YEAR                        }:   sum {v in VEHC}  (Qty_Own[v,y] * 0.2)  >= sum {v in VEHC}                 Qty_Sel[v,y]  ;   #         C8
s.t. Sell_Owned      {v in VEHC,            y in YEAR                        }:                     Qty_Own[v,y]         >=                                 Qty_Sel[v,y]  ;


s.t. Satisfy_Demand  {s in SIZE, d in DIST, y in YEAR}:   demand[s,d,y]  <= sum {v in VEHC, f in FUEL: size[v] = s and ord(d,DIST) <= ord(dist[v],DIST)}   Qty_OnFue[v,f,y] * Supply[v,f,y];                                   # C1 C2 C4
s.t. DEF_CO2_Total   {                      y in YEAR}:   CO2_Total[y]    = sum {v in VEHC, f in FUEL: can_use[drvt[v],f] =1                           }  (Qty_OnFue[v,f,y] * Supply[v,f,y] * fuel_cons[v,f] * co2_rate[f]);   # N 
