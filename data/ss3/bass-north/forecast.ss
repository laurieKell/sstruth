#V3.30.17.00;_2021_06_11;_trans;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_12.3
#Stock Synthesis (SS) is a work of the U.S. Government and is not subject to copyright protection in the United States.
#Foreign copyrights may apply. See copyright.txt for more information.
# for all year entries except rebuilder; enter either: actual year, -999 for styr, 0 for endyr, neg number for rel. endyr
1 # Benchmarks: 0=skip; 1=calc F_spr,F_btgt,F_msy; 2=calc F_spr,F0.1,F_msy 
2 # MSY: 1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt) or F0.1; 4=set to F(endyr) 
0.35 # SPR target (e.g. 0.40)
0.4 # Biomass target (e.g. 0.40)
#C file created using an r4ss function
#C file write time: 2025-01-28  16:15:36
#
1 #_benchmarks
2 #_MSY
0.35 #_SPRtarget
0.4 #_Btarget
#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF,  beg_recr_dist, end_recr_dist, beg_SRparm, end_SRparm (enter actual year, or values of 0 or -integer to be rel. endyr)
0 0 0 0 0 0 0 0 0 0
1 #_Bmark_relF_Basis
1 #_Forecast
1 #_Nforecastyrs
1 #_F_scalar
#_Fcast_years:  beg_selex, end_selex, beg_relF, end_relF, beg_recruits, end_recruits (enter actual year, or values of 0 or -integer to be rel. endyr)
-2 0 -2 0 -999 0
0 #_Fcast_selex
1 #_ControlRuleMethod
0.4 #_BforconstantF
0.1 #_BfornoF
0.75 #_Flimitfraction
3 #_N_forecast_loops
3 #_First_forecast_loop_with_stochastic_recruitment
0 #_fcast_rec_option
1 #_fcast_rec_val
0 #_Fcast_loop_control_5
2020 #_FirstYear_for_caps_and_allocations
0 #_stddev_of_log_catch_ratio
0 #_Do_West_Coast_gfish_rebuilder_output
1999 #_Ydecl
2024 #_Yinit
1 #_fleet_relative_F
# Note that fleet allocation is used directly as average F if Do_Forecast=4 
2 #_basis_for_fcast_catch_tuning
# enter list of fleet number and max for fleets with max annual catch; terminate with fleet=-9999
-9999 -1
# enter list of area ID and max annual catch; terminate with area=-9999
-9999 -1
# enter list of fleet number and allocation group assignment, if any; terminate with fleet=-9999
-9999 -1
-1 #_InputBasis
 #_Year Seas Fleet Catch.or.F Basis
   2024    1     1        0.1    99
   2024    1     2        0.1    99
   2024    1     3        0.2    99
   2024    1     4        0.1    99
   2024    1     5        0.1    99
   2024    1     6        0.1    99
   2024    1     7        0.1    99
   2024    1     8        0.1    99
   2024    1     16        0.1    99
   2024    1    17       0.1    99
   2025    1     1        0.1    99
   2025    1     2        0.1    99
   2025    1     3        0.1    99
   2025    1     4        0.1    99
   2025    1     5        0.1    99
   2025    1     6        0.1    99
   2025    1     7        0.1    99
   2025    1     8        0.1    99
   2025    1     16       0.1    99
   2025    1    17       0.1    99
   2026    1     1        0.1    99
   2026    1     2        0.1    99
   2026    1     3        0.1    99
   2026    1     4        0.1    99
   2026    1     5        0.1    99
   2026    1     6        0.1    99
   2026    1     7        0.1    99
   2026    1     8        0.1    99
   2026    1     16        0.1    99
   2026    1    17       0.1    99
-9999 0 0 0 0
#
999 # verify end of input 

