#V3.30.16.02;_2020_09_21; ;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_12.2
#Stock Synthesis (SS) is a work of the U.S. Government and is not subject to copyright protection in the United States.
#Foreign copyrights may apply. See copyright.txt for more information.
#_user_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_user_info_available_at:https://vlab.ncep.noaa.gov/group/stock-synthesis
#_data_and_control_files: BSH_IO_DAT.SS// BSH_IO_CTL.SS  
0  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
1  #_N_Growth_Patterns (Growth Patterns, Morphs, Bio Patterns, GP are terms used interchangeably in SS)
1 #_N_platoons_Within_GrowthPattern 
#_Cond 1 #_Platoon_within/between_stdev_ratio (no read if N_platoons=1)
#_Cond  1 #vector_platoon_dist_(-1_in_first_val_gives_normal_approx)
#
2 # recr_dist_method for parameters:  2=main effects for GP, Settle timing, Area; 3=each Settle entity; 4=none, only when N_GP*Nsettle*pop==1
1 # not yet implemented; Future usage: Spawner-Recruitment: 1=global; 2=by area
1 #  number of recruitment settlement assignments 
0 # unused option
#GPattern month  area  age (for each settlement assignment)
 1 1 1 0
#
#_Cond 0 # N_movement_definitions goes here if Nareas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
1 #_Nblock_Patterns
1 #_blocks_per_pattern 
# begin and end years of blocks
 1994 1994
#
# controls for all timevary parameters 
1 #_time-vary parm bound check (1=warn relative to base parm bounds; 3=no bound check); Also see env (3) and dev (5) options to constrain with base bounds
#
# AUTOGEN
1 1 1 1 1 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
# where: 0 = autogen time-varying parms of this category; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345
#
#_Available timevary codes
#_Block types: 0: P_block=P_base*exp(TVP); 1: P_block=P_base+TVP; 2: P_block=TVP; 3: P_block=P_block(-1) + TVP
#_Block_trends: -1: trend bounded by base parm min-max and parms in transformed units (beware); -2: endtrend and infl_year direct values; -3: end and infl as fraction of base range
#_EnvLinks:  1: P(y)=P_base*exp(TVP*env(y));  2: P(y)=P_base+TVP*env(y);  3: P(y)=f(TVP,env_Zscore) w/ logit to stay in min-max;  4: P(y)=2.0/(1.0+exp(-TVP1*env(y) - TVP2))
#_DevLinks:  1: P(y)*=exp(dev(y)*dev_se;  2: P(y)+=dev(y)*dev_se;  3: random walk;  4: zero-reverting random walk with rho;  5: like 4 with logit transform to stay in base min-max
#_DevLinks(more):  21-25 keep last dev for rest of years
#
#_Prior_codes:  0=none; 6=normal; 1=symmetric beta; 2=CASAL's beta; 3=lognormal; 4=lognormal with biascorr; 5=gamma
#
# setup for M, growth, wt-len, maturity, fecundity, (hermaphro), recr_distr, cohort_grow, (movement), (age error), (catch_mult), sex ratio 
#
3 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate
 #_Age_natmort_by sex x growthpattern (nest GP in sex)
 0.288	0.222	0.187	0.165	0.15	0.139	0.131	0.124	0.119	0.115	0.112	0.109	0.107	0.105	0.103	0.102	0.101	0.1	0.099	0.098	0.098	0.097	0.097	0.096	0.096	0.095	0.095	0.095	0.095	0.095	0.094
 0.277	0.212	0.179	0.158	0.144	0.134	0.126	0.121	0.116	0.113	0.11	0.107	0.105	0.104	0.102	0.101	0.1	0.1	0.099	0.098	0.098	0.097	0.097	0.097	0.097	0.096	0.096	0.096	0.096	0.096	0.096
#
2 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr; 5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
0.5 #_Age(post-settlement)_for_L1;linear growth below this
999 #_Growth_Age_for_L2 (999 to use as Linf)
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0  #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
#
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
5 #_First_Mature_Age
2 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
3 #_parameter_offset_approach for M, G, CV_G:  1- direct, no offset; 2- male=fem_parm*exp(male_parm); 3: male=female*exp(parm) then old=young*exp(parm)
#
#_growth_parms
#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn
# Sex: 1  BioPattern: 1  NatMort
# Sex: 1  BioPattern: 1  Growth
 10 120 49.8 45 10 6 -4 0 0 0 0 0.5 0 0 # L_at_Amin_Fem_GP_1
 40 410 283.2 400 10 6 -2 0 0 0 0 0.5 0 0 # L_at_Amax_Fem_GP_1
 0.1 0.25 0.129 0.15 0.8 6 -4 0 0 0 0 0.5 0 0 # VonBert_K_Fem_GP_1
 -10 10 1 1 0.8 0 -4 0 0 0 0 0.5 0 0 # Richards_Fem_GP_1
 0.01 1 0.22 0.0834877 0.8 6 -3 0 0 0 0 0.5 0 0 # CV_young_Fem_GP_1
 -3 3 -0.4 0 0.8 6 -3 0 0 0 0 0.5 0 0 # CV_old_Fem_GP_1
# Sex: 1  BioPattern: 1  WtLen
 -3 3 5.388e-06 5.388e-06 0.8 6 -3 0 0 0 0 0.5 0 0 # Wtlen_1_Fem
 -3 3.5 3.102 3.102 0.8 6 -3 0 0 0 0 0.5 0 0 # Wtlen_2_Fem
# Sex: 1  BioPattern: 1  Maturity&Fecundity
 -3 300 145 55 0.8 6 -3 0 0 0 0 0.5 0 0 # Mat50%_Fem
 -3 3 -0.138 -0.138 0.8 6 -3 0 0 0 0 0.5 0 0 # Mat_slope_Fem
 -3 46 38 37 0.8 6 -3 0 0 0 0 0.5 0 0 # Eggs_scalar_Fem
 -3 3 0 0 0.8 6 -3 0 0 0 0 0.5 0 0 # Eggs_exp_len_Fem
# Sex: 2  BioPattern: 1  NatMort
# Sex: 2  BioPattern: 1  Growth
 -3 3 0.0323 0 0.8 0 -3 0 0 0 0 0.5 0 0 # L_at_Amin_Mal_GP_1
 -3 3 -0.0214 0 0.8 0 -2 0 0 0 0 0.5 0 0 # L_at_Amax_Mal_GP_1
 -3 3 0.1306 0 0.8 0 -3 0 0 0 0 0.5 0 0 # VonBert_K_Mal_GP_1
 -3 3 0 0 0.8 6 -3 0 0 0 0 0.5 0 0 # Richards_Mal_GP_1
 -3 3 0 0 0.8 6 -3 0 0 0 0 0.5 0 0 # CV_young_Mal_GP_1
 -3 3 -0.4 0 0.8 6 -3 0 0 0 0 0.5 0 0 # CV_old_Mal_GP_1
# Sex: 2  BioPattern: 1  WtLen
 -3 3 3.293e-06 3.293e-06 0.8 6 -3 0 0 0 0 0.5 0 0 # Wtlen_1_Mal
 -3 3.5 3.225 3.225 0.8 6 -3 0 0 0 0 0.5 0 0 # Wtlen_2_Mal
# Hermaphroditism
#  Recruitment Distribution  
 -4 4 0 0 99 0 -3 0 0 0 0 0.5 0 0 # RecrDist_GP_1
 -4 4 0 0 99 0 -3 0 0 0 0 0.5 0 0 # RecrDist_Area_1
 -4 4 4 0 99 0 -3 0 0 0 0 0.5 0 0 # RecrDist_timing_1
#  Cohort growth dev base
 0.1 10 1 1 1 6 -1 0 0 0 0 0.5 0 0 # CohortGrowDev
#  Movement
#  Age Error from parameters
#  catch multiplier
#  fraction female, by GP
 0.000001 0.999999 0.5 0.5  0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_1
#
#_no timevary MG parameters
#
#_seasonal_effects_on_biology_parms
 0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
3 #_Spawner-Recruitment; Options: 1=NA; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepherd_3Parm; 9=RickerPower_3parm
0  # 0/1 to use steepness in initial equ recruitment calculation
0  #  future feature:  0/1 to make realized sigmaR a function of SR curvature
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn #  parm_name
             4            12       7.67098             7             1             6          1          0          0          0          0          0          0          0 # SR_LN(R0)
0.1 0.9 0.8 0.35 10 6 -2 0 0 0 0 0 0 0 # SR_BH_steep
0 2 0.2 0.3 0.8 6 -3 0 0 0 0 0 0 0 # SR_sigmaR
            -5             5             0             0             1             6         -1          0          0          0          0          0          1          1 # SR_regime
             0             0             0             0            99             0         -1          0          0          0          0          0          0          0 # SR_autocorr
#Next are short parm lines for timevary 
 -10 10 0.00447741 0 5 6 4 # SR_regime_BLK1add_1994
2 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1992 # first year of main recr_devs; early devs can preceed this era
2015 # last year of main recr_devs; forecast devs start in following year
2 #_recdev phase 
1 # (0/1) to read 13 advanced options
 -10 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 1 #_recdev_early_phase
 0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1979.1 #_last_yr_nobias_adj_in_MPD; begin of ramp
 2004.2 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2016 #_last_yr_fullbias_adj_in_MPD
 2020.5 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS sets bias_adj to 0.0 for fcast yrs)
 0.4257 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
 0 #_period of cycles in recruitment (N parms read below)
 -10 #min rec_dev
 10 #max rec_dev
 0 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
# read specified recr devs
#_Yr Input_value
#Fishing Mortality info 
0.2 # F ballpark value in units of annual_F
2010 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)
5 # max F or harvest rate, depends on F_Method
# no additional F input needed for Fmethod 1
# if Fmethod=2; read overall start F value; overall phase; N detailed inputs to read
# if Fmethod=3; read N iterations for tuning for Fmethod 3
4  # N iterations for tuning F in hybrid method (recommend 3 to 7)
#
#_initial_F_parms; count = 1
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
 1e-07 0.1 6.32571e-05 0.001 1 6 1 # InitF_seas_1_flt_1F1_MISC
#_Q_setup for fleets with cpue or survey data
#_1:  fleet number
#_2:  link type: (1=simple q, 1 parm; 2=mirror simple q, 1 mirrored parm; 3=q and power, 2 parm; 4=mirror with offset, 2 parm)
#_3:  extra input for link, i.e. mirror fleet# or dev index number
#_4:  0/1 to select extra sd parameter
#_5:  0/1 for biasadj or not
#_6:  0/1 to float
#_   fleet      link link_info  extra_se   biasadj     float  #  fleetname
         9         1         0         0         0         1  #  S1_JPN_EARLY
        10         1         0         0         0         1  #  S2_JPN_LATE
        11         1         0         0         0         1  #  S3_EU_POR
        12         1         0         0         0         1  #  S4_EU_ESP
        13         1         0         0         0         1  #  S5_TAI
        14         1         0         0         0         1  #  S6_IND
        15         1         0         0         0         1  #  S7_REUNION
        16         1         0         0         0         1  #  S8_ZAF
-9999 0 0 0 0 0
#
#_Q_parms(if_any);Qunits_are_ln(q)
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
           -25            25      -7.99572             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S1_JPN_EARLY(9)
           -25            25      -8.27437             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S2_JPN_LATE(10)
           -25            25      -7.74816             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S3_EU_POR(11)
           -25            25      -6.23723             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S4_EU_ESP(12)
           -25            25      -8.51087             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S5_TAI(13)
           -25            25      -8.95108             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S6_IND(14)
           -25            25      -7.14633             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S7_REUNION(15)
           -25            25      -7.14633             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_S8_ZAF(16)
#_no timevary Q parameters
#
#_Pattern Discard Male Special
 1 0 0 0 # 1 F1_MISC
 1 0 0 0 # 2 F2_GL
 24 0 4 0 # 3 F3_OTHER_LL
 24 0 3 0 # 4 F4_JPN_LL
 24 0 0 0 # 5 F5_KOR_LL
 24 0 4 0 # 6 F6_PRT_LL
 24 0 4 0 # 7 F7_TWN_LL
 24 0 0 0 # 8 F8_ESP_LL
 5 0 0 5 # 9 S1_JPN_EARLY
 5 0 0 5 # 10 S2_JPN_LATE
 5 0 0 6 # 11 S3_EU_POR
 5 0 0 8 # 12 S4_EU_ESP
 5 0 0 7 # 13 S5_TAI
 5 0 0 8 # 14 S6_IND
 5 0 0 8 # 15 S7_REUNION
 5 0 0 8 # 16 S8_ZAF
#
#_age_selex_patterns
#Pattern:_0; parm=0; selex=1.0 for ages 0 to maxage
#_Pattern Discard Male Special
 11 0 0 0 # 1 F1_MISC
 11 0 0 0 # 2 F2_GL
 11 0 0 0 # 3 F3_OTHER_LL
 11 0 0 0 # 4 F4_JPN_LL
 11 0 0 0 # 5 F5_KOR_LL
 11 0 0 0 # 6 F6_PRT_LL
 11 0 0 0 # 7 F7_TWN_LL
 11 0 0 0 # 8 F8_ESP_LL
 11 0 0 0 # 9 S1_JPN_EARLY
 11 0 0 0 # 10 S2_JPN_LATE
 11 0 0 0 # 11 S3_EU_POR
 11 0 0 0 # 12 S4_EU_ESP
 0 0 0 0 # 13 S5_TAI
 0 0 0 0 # 14 S6_IND
 0 0 0 0 # 15 S7_REUNION
 0 0 0 0 # 18 S8_ZAF
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   F1_MISC LenSelex
             1           300           200           100           0.1             6         -2          0          0          0          0        0.5          0          0  #  SizeSel_P1_F1_MISC(1)
             1           339            75           100           0.1             6         -3          0          0          0          0        0.5          0          0  #  SizeSel_P2_F1_MISC(1)
# 2   F2_GL LenSelex
             1           300           200           100           0.1             6         -2          0          0          0          0        0.5          0          0  #  SizeSel_P1_F2_GL(2)
             1           339            75           100           0.1             6         -3          0          0          0          0        0.5          0          0  #  SizeSel_P2_F2_GL(2)
# 3   F3_OTHER_LL LenSelex
           170           200       189.703           190             1             6          2          0          0          0          0        0.5          0          0  #  SizeSel_P1_F3_OTHER_LL(3)
           -10            -9      -9.57032          -9.5             0             0          2          0          0          0          0        0.5          0          0  #  SizeSel_P2_F3_OTHER_LL(3)
           -15            15       6.90381             0             0             0         -4          0          0          0          0        0.5          0          0  #  SizeSel_P3_F3_OTHER_LL(3)
           -15            15             8             0             0             0         -5          0          0          0          0        0.5          0          0  #  SizeSel_P4_F3_OTHER_LL(3)
          -999          -999          -999             0             0             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P5_F3_OTHER_LL(3)
          -999          -999          -999             0             5             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P6_F3_OTHER_LL(3)
           -20           200            10           125            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Peak_F3_OTHER_LL(3)
           -15            15             0             4            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Ascend_F3_OTHER_LL(3)
           -15            15             1             4            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Descend_F3_OTHER_LL(3)
           -15            15             0             4            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Final_F3_OTHER_LL(3)
           -15            15          0.33             4            50             0         -5          0          0          0          0          0          0          0  #  SzSel_Fem_Scale_F3_OTHER_LL(3)
# 4   F4_JPN_LL LenSelex
           145           165       160.157           150             0             0          1          0          0          0          0        0.5          0          0  #  SizeSel_P1_F4_JPN_LL(4)
           -10            -9      -9.69863          -9.5             0             0          2          0          0          0          0        0.5          0          0  #  SizeSel_P2_F4_JPN_LL(4)
           -15            15       8.42507             0             0             0         -4          0          0          0          0        0.5          0          0  #  SizeSel_P3_F4_JPN_LL(4)
           -15            15             7             0             0             0         -5          0          0          0          0        0.5          0          0  #  SizeSel_P4_F4_JPN_LL(4)
          -999          -999          -999             0             0             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P5_F4_JPN_LL(4)
          -999          -999          -999             0             5             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P6_F4_JPN_LL(4)
           -20           200           -15           125            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Male_Peak_F4_JPN_LL(4)
           -15            15             0             4            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Male_Ascend_F4_JPN_LL(4)
           -15            15             0             4            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Male_Descend_F4_JPN_LL(4)
           -15            15             0             4            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Male_Final_F4_JPN_LL(4)
           -15            15           0.5             4            50             0         -5          0          0          0          0          0          0          0  #  SzSel_Male_Scale_F4_JPN_LL(4)
# 5   F5_KOR_LL LenSelex
           140           165       149.848           150           0.5             6          1          0          0          0          0        0.5          0          0  #  SizeSel_P1_F5_KOR_LL(5)
           -15            15            -3             0             0             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P2_F5_KOR_LL(5)
           -15            15             8             0             0             0         -4          0          0          0          0        0.5          0          0  #  SizeSel_P3_F5_KOR_LL(5)
           -15            15             7             0             0             0         -5          0          0          0          0        0.5          0          0  #  SizeSel_P4_F5_KOR_LL(5)
          -999          -999          -999             0             0             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P5_F5_KOR_LL(5)
          -999          -999          -999             0             5             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P6_F5_KOR_LL(5)
# 6   F6_PRT_LL LenSelex
           155           175       170.181           165             0             0          1          0          0          0          0        0.5          0          0  #  SizeSel_P1_F6_PRT_LL(6)
            -1             1     -0.556314          -0.4             0             0          3          0          0          0          0        0.5          0          0  #  SizeSel_P2_F6_PRT_LL(6)
           -15            15           6.5             0             0             0         -5          0          0          0          0        0.5          0          0  #  SizeSel_P3_F6_PRT_LL(6)
           -15            15           6.5             0             0             0         -5          0          0          0          0        0.5          0          0  #  SizeSel_P4_F6_PRT_LL(6)
          -999          -999          -999             0             0             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P5_F6_PRT_LL(6)
          -999          -999          -999             0             5             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P6_F6_PRT_LL(6)
           -20           200            10           125            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Peak_F6_PRT_LL(6)
           -15            15             0             4            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Ascend_F6_PRT_LL(6)
           -15            15             0             4            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Descend_F6_PRT_LL(6)
           -15            15             0             4            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Final_F6_PRT_LL(6)
           -15            15           0.2             4            50             0         -5          0          0          0          0          0          0          0  #  SzSel_Fem_Scale_F6_PRT_LL(6)
# 7   F7_TWN_LL LenSelex
           195           215       208.809           209             0             0          1          0          0          0          0        0.5          0          0  #  SizeSel_P1_F7_TWN_LL(7)
           -10            -9      -9.42939          -9.5             0             0          2          0          0          0          0        0.5          0          0  #  SizeSel_P2_F7_TWN_LL(7)
           -15            15           7.5             0             0             0         -4          0          0          0          0        0.5          0          0  #  SizeSel_P3_F7_TWN_LL(7)
           -15            15          7.75             0             0             0         -5          0          0          0          0        0.5          0          0  #  SizeSel_P4_F7_TWN_LL(7)
          -999          -999          -999             0             0             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P5_F7_TWN_LL(7)
          -999          -999          -999             0             5             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P6_F7_TWN_LL(7)
           -20           200             0           125            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Peak_F7_TWN_LL(7)
           -15            15             0             4            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Ascend_F7_TWN_LL(7)
           -15            15             0             4            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Descend_F7_TWN_LL(7)
           -15            15             0             4            50             0         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Final_F7_TWN_LL(7)
           -15            15          0.75             4            50             0         -5          0          0          0          0          0          0          0  #  SzSel_Fem_Scale_F7_TWN_LL(7)
# 8   F8_ESP_LL LenSelex
           200           225       215.472           215             0             0          1          0          0          0          0        0.5          0          0  #  SizeSel_P1_F8_ESP_LL(8)
            -5             1      -3.57447            -3             1             6          2          0          0          0          0        0.5          0          0  #  SizeSel_P2_F8_ESP_LL(8)
           -15            15             8             0             0             0         -4          0          0          0          0        0.5          0          0  #  SizeSel_P3_F8_ESP_LL(8)
           -15            15             8             0             0             0         -5          0          0          0          0        0.5          0          0  #  SizeSel_P4_F8_ESP_LL(8)
          -999          -999          -999             0             0             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P5_F8_ESP_LL(8)
          -999          -999          -999             0             5             0         -2          0          0          0          0        0.5          0          0  #  SizeSel_P6_F8_ESP_LL(8)
# 9   S1_JPN_EARLY LenSelex
             1           200             1            50            99             6         -2          0          0          0          0        0.5          0          0  #  SizeSel_P1_S1_JPN_EARLY(9)
             1           239            76            50            99             6         -3          0          0          0          0        0.5          0          0  #  SizeSel_P2_S1_JPN_EARLY(9)
# 10   S2_JPN_LATE LenSelex
             1           200             1            50            99             6         -2          0          0          0          0        0.5          0          0  #  SizeSel_P1_S2_JPN_LATE(10)
             1           239            76            50            99             6         -3          0          0          0          0        0.5          0          0  #  SizeSel_P2_S2_JPN_LATE(10)
# 11   S3_EU_POR LenSelex
             1           200             1            50            99             6         -2          0          0          0          0        0.5          0          0  #  SizeSel_P1_S3_EU_POR(11)
             1           239            76            50            99             6         -3          0          0          0          0        0.5          0          0  #  SizeSel_P2_S3_EU_POR(11)
# 12   S4_EU_ESP LenSelex
             1           200             1            50            99             6         -2          0          0          0          0        0.5          0          0  #  SizeSel_P1_S4_EU_ESP(12)
             1           239            76            50            99             6         -3          0          0          0          0        0.5          0          0  #  SizeSel_P2_S4_EU_ESP(12)
# 13   S5_TAI LenSelex
             1           200             1            50            99             6         -2          0          0          0          0        0.5          0          0  #  SizeSel_P1_S5_TAI(13)
             1           239            76            50            99             6         -3          0          0          0          0        0.5          0          0  #  SizeSel_P2_S5_TAI(13)
# 14   S6_IND LenSelex
             1           200             1            50            99             6         -2          0          0          0          0        0.5          0          0  #  SizeSel_P1_S6_IND(14)
             1           239            76            50            99             6         -3          0          0          0          0        0.5          0          0  #  SizeSel_P2_S6_IND(14)
# 15   S7_REUNION LenSelex
             1           200             1            50            99             6         -2          0          0          0          0        0.5          0          0  #  SizeSel_P1_S7_REUNION(15)
             1           239            76            50            99             6         -3          0          0          0          0        0.5          0          0  #  SizeSel_P2_S7_REUNION(15)
# 16   S8_ZAF LenSelex
             1           200             1            50            99             6         -2          0          0          0          0        0.5          0          0  #  SizeSel_P1_S8_ZAF(16)
             1           239            76            50            99             6         -3          0          0          0          0        0.5          0          0  #  SizeSel_P2_S8_ZAF(16)
# 1   F1_MISC AgeSelex
             1            40             0             1            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P1_F1_MISC(1)
             1            40            30             3            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P2_F1_MISC(1)
# 2   F2_GL AgeSelex
             1            40             0             1            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P1_F2_GL(2)
             1            40            30             3            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P2_F2_GL(2)
# 3   F3_OTHER_LL AgeSelex
             1            40             0             1            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P1_F3_OTHER_LL(3)
             1            40            30             3            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P2_F3_OTHER_LL(3)
# 4   F4_JPN_LL AgeSelex
             1            40             0             1            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P1_F4_JPN_LL(4)
             1            40            30             3            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P2_F4_JPN_LL(4)
# 5   F5_KOR_LL AgeSelex
             1            40             0             1            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P1_F5_KOR_LL(5)
             1            40            30             3            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P2_F5_KOR_LL(5)
# 6   F6_PRT_LL AgeSelex
             1            40             0             1            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P1_F6_PRT_LL(6)
             1            40            30             3            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P2_F6_PRT_LL(6)
# 7   F7_TWN_LL AgeSelex
             1            40             0             1            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P1_F7_TWN_LL(7)
             1            40            30             3            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P2_F7_TWN_LL(7)
# 8   F8_ESP_LL AgeSelex
             1            40             0             1            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P1_F8_ESP_LL(8)
             1            40            30             3            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P2_F8_ESP_LL(8)
# 9   S1_JPN_EARLY AgeSelex
             1            40             0             1            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P1_S1_JPN_EARLY(9)
             1            40            30             3            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P2_S1_JPN_EARLY(9)
# 10   S2_JPN_LATE AgeSelex
             1            40             0             1            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P1_S2_JPN_LATE(10)
             1            40            30             3            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P2_S2_JPN_LATE(10)
# 11   S3_EU_POR AgeSelex
             1            40             0             1            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P1_S3_EU_POR(11)
             1            40            30             3            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P2_S3_EU_POR(11)
# 12   S4_EU_ESP AgeSelex
             1            40             0             1            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P1_S4_EU_ESP(12)
             1            40            30             3            99             6         -1          0          0          0          0        0.5          0          0  #  AgeSel_P2_S4_EU_ESP(12)
# 13   S5_TAI AgeSelex
# 14   S6_IND AgeSelex
# 15   S7_REUNION AgeSelex
#_no timevary selex parameters
#
0   #  use 2D_AR1 selectivity(0/1)
#_no 2D_AR1 selex offset used
#
# Tag loss and Tag reporting parameters go next
0  # TG_custom:  0=no read and autogen if tag data exist; 1=read
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
# no timevary parameters
#
#
# Input variance adjustments factors: 
 #_1=add_to_survey_CV
 #_2=add_to_discard_stddev
 #_3=add_to_bodywt_CV
 #_4=mult_by_lencomp_N
 #_5=mult_by_agecomp_N
 #_6=mult_by_size-at-age_N
 #_7=mult_by_generalized_sizecomp
#_Factor  Fleet  Value
      4      2   1.468
      4      3   0.483
      4      4   3.056
      4      5   2.257
      4      6   4.667
      4      7   3.178
      4      8   9.448
 -9999   1    0  # terminator
#
1 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 26 changes to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark; 18=initEQregime
#like_comp fleet  phase  value  sizefreq_method
 1 1 1 0 1
 1 2 1 0 1
 1 3 1 0 1
 1 4 1 0 1
 1 5 1 0 1
 1 6 1 0 1
 1 7 1 0 1
 1 8 1 0 1
 1 9 1 0 1 # StartCPUE_LAMBDAS
1 10 1 1 1  # 10 S2_JPN_LATE
1 11 1 1 1  # PRT_cpue
1 12 1 1 1  # ESP_cpue
1 13 1 1 1  # S5_TAI_cpue
1 14 1 0 1  # S6_IND_cpue
1 15 1 1 1  # S7_REUNION_cpue
1 16 1 1 1  # 16 S8_ZAF
 4 1 1 0 0
 4 2 1 1 0
 4 3 1 1 0
 4 4 1 1 0
 4 5 1 1 0
 4 6 1 1 0
 4 7 1 1 0
 4 8 1 1 0
 4 9 1 0 0
 4 10 1 0 0
 9 1 1 1 0
-9999  1  1  1  1  #  terminator
#
0 # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M and Dyn Bzero
 # 0 2 0 0 # Selectivity: (1) fleet, (2) 1=len/2=age/3=both, (3) year, (4) N selex bins
 # 0 0 # Growth: (1) growth pattern, (2) growth ages
 # 0 0 0 # Numbers-at-age: (1) area(-1 for all), (2) year, (3) N ages
 # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)
 # -1 # list of ages for growth std (-1 in first bin to self-generate)
 # -1 # list of ages for NatAge std (-1 in first bin to self-generate)
999

