#V3.30.23.2;_safe;_compile_date:_Apr 17 2025;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:_https://groups.google.com/g/ss3-forum_and_NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:_https://nmfs-ost.github.io/ss3-website/
#_Source_code_at:_https://github.com/nmfs-ost/ss3-source-code

#C SS3_Control_NA_SMA_2017_15.xlsx
#C file created using an r4ss function
#C file write time: 2025-06-07  11:44:30
#_data_and_control_files: data.ss // control.ss
0  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
1  #_N_Growth_Patterns (Growth Patterns, Morphs, Bio Patterns, GP are terms used interchangeably in SS3)
1 #_N_platoons_Within_GrowthPattern 
#_Cond 1 #_Platoon_within/between_stdev_ratio (no read if N_platoons=1)
#_Cond sd_ratio_rd < 0: platoon_sd_ratio parameter required after movement params.
#_Cond  1 #vector_platoon_dist_(-1_in_first_val_gives_normal_approx)
#
4 # recr_dist_method for parameters:  2=main effects for GP, Area, Settle timing; 3=each Settle entity; 4=none (only when N_GP*Nsettle*pop==1)
1 # not yet implemented; Future usage: Spawner-Recruitment: 1=global; 2=by area
1 #  number of recruitment settlement assignments 
0 # unused option
#GPattern month  area  age (for each settlement assignment)
 1 7 1 0
#
#_Cond 0 # N_movement_definitions goes here if Nareas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
1 #_Nblock_Patterns
 1 #_blocks_per_pattern 
# begin and end years of blocks
 1949 1949
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
#_NATMORT
4 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=BETA:_Maunder_link_to_maturity;_6=Lorenzen_range
 #_Age_natmort_by sex x growthpattern (nest GP in sex)
 0.274 0.196 0.159 0.137 0.123 0.112 0.105 0.099 0.095 0.091 0.088 0.086 0.084 0.082 0.08 0.079 0.078 0.077 0.077 0.076 0.075 0.075 0.075 0.075 0.075 0.075 0.075 0.075 0.075 0.075 0.075 0.075 0.075 0.075 0.075 0.075
 0.265 0.194 0.161 0.143 0.131 0.122 0.116 0.112 0.109 0.106 0.104 0.102 0.101 0.1 0.099 0.099 0.098 0.098 0.097 0.097 0.097 0.097 0.097 0.097 0.097 0.097 0.097 0.097 0.097 0.097 0.097 0.097 0.097 0.097 0.097 0.097
#
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr; 5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
0 #_Age(post-settlement) for L1 (aka Amin); first growth parameter is size at this age; linear growth below this
999 #_Age(post-settlement) for L2 (aka Amax); 999 to treat as Linf
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0  #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
#
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
10 #_First_Mature_Age
2 #_fecundity_at_length option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach for M, G, CV_G:  1- direct, no offset**; 2- male=fem_parm*exp(male_parm); 3: male=female*exp(parm) then old=young*exp(parm)
#_** in option 1, any male parameter with value = 0.0 and phase <0 is set equal to female parameter
#
#_growth_parms
#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn
# Sex: 1  BioPattern: 1  NatMort
# Sex: 1  BioPattern: 1  Growth
 5 100 63 63 1000 6 -3 0 0 0 0 0.5 0 0 # L_at_Amin_Fem_GP_1
 50 600 350 350 1000 6 -4 0 0 0 0 0.5 0 0 # L_at_Amax_Fem_GP_1
 0.01 0.65 0.124 0.124 0.2 6 -5 0 0 0 0 0.5 0 0 # VonBert_K_Fem_GP_1
 0.01 0.3 0.0932677 0.0932677 999 6 -2 0 0 0 0 0.5 0 0 # CV_young_Fem_GP_1
 0.01 0.3 0.08 0.15 0.8 6 -3 0 0 0 0 0.5 0 0 # CV_old_Fem_GP_1
# Sex: 1  BioPattern: 1  WtLen
 -3 3 5.4e-06 5.4e-06 0.8 6 -3 0 0 0 0 0.5 0 0 # Wtlen_1_Fem_GP_1
 -3 5 3.14 3.14 0.8 6 -3 0 0 0 0 0.5 0 0 # Wtlen_2_Fem_GP_1
# Sex: 1  BioPattern: 1  Maturity&Fecundity
 1 300 274 274 0.8 6 -3 0 0 0 0 0.5 0 0 # Mat50%_Fem_GP_1
 -200 3 -0.046 -0.046 0.8 6 -3 0 0 0 0 0.5 0 0 # Mat_slope_Fem_GP_1
 -3 50 4.4 11 0.8 6 -3 0 0 0 0 0.5 0 0 # Eggs_scalar_Fem_GP_1    Here this is 11/2.5
 -3 3 0 0 0.8 6 -3 0 0 0 0 0.5 0 0 # Eggs_exp_len_Fem_GP_1
# Sex: 2  BioPattern: 1  NatMort
# Sex: 2  BioPattern: 1  Growth
 5 100 63 63 1000 6 -3 0 0 0 0 0.5 0 0 # L_at_Amin_Mal_GP_1
 50 600 247.81 247.81 1000 6 -4 0 0 0 0 0.5 0 0 # L_at_Amax_Mal_GP_1
 0.01 0.65 0.196 0.196 0.2 6 -5 0 0 0 0 0.5 0 0 # VonBert_K_Mal_GP_1
 0.01 0.3 0.0973418 0.0973418 999 6 -2 0 0 0 0 0.5 0 0 # CV_young_Mal_GP_1
 0.01 0.3 0.15 0.15 0.8 6 -3 0 0 0 0 0.5 0 0 # CV_old_Mal_GP_1
# Sex: 2  BioPattern: 1  WtLen
 -3 3 1.25e-05 1.25e-05 0.8 6 -3 0 0 0 0 0.5 0 0 # Wtlen_1_Mal_GP_1
 -3 5 2.97 2.97 0.8 6 -3 0 0 0 0 0.5 0 0 # Wtlen_2_Mal_GP_1
# Hermaphroditism
#  Recruitment Distribution 
#  Cohort growth dev base
 0.1 10 1 1 1 0 -1 0 0 0 0 0 0 0 # CohortGrowDev
#  Movement
#  Platoon StDev Ratio 
#  Age Error from parameters
#  catch multiplier
#  fraction female, by GP
 1e-06 0.999999 0.5 0.5 0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_1
#  M2 parameter for each predator fleet
#
#_no timevary MG parameters
#
#_seasonal_effects_on_biology_parms
 0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
7 #_Spawner-Recruitment; Options: 1=NA; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepherd_3Parm; 9=RickerPower_3parm
0  # 0/1 to use steepness in initial equ recruitment calculation
0  #  future feature:  0/1 to make realized sigmaR a function of SR curvature
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn #  parm_name
             3            15       5.52606          7.04            20             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
          0.01             1         0.406           0.5           0.2             6         -4          0          0          0          0          0          0          0 # SR_surv_zfrac
          0.01            10             3             1           0.2             6         -4          0          0          0          0          0          0          0 # SR_surv_Beta
           0.2           1.9      0.283103          0.28          1000             6         -4          0          0          0          0          0          0          0 # SR_sigmaR
            -5             5             0             0             1             6         -4          0          0          0          0          0          0          0 # SR_regime
            -5             5             0             0             1             6         -4          0          0          0          0          0          0          0 # SR_autocorr
#_no timevary SR parameters
1 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1990 # first year of main recr_devs; early devs can precede this era
2020 # last year of main recr_devs; forecast devs start in following year
3 #_recdev phase 
1 # (0/1) to read 13 advanced options
 -15 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 4 #_recdev_early_phase
 0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1977.9 #_last_yr_nobias_adj_in_MPD; begin of ramp
 2000 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2016.3 #_last_yr_fullbias_adj_in_MPD
 2023.4 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
 0.5929 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
 0 #_period of cycles in recruitment (N parms read below)
 -10 #min rec_dev
 10 #max rec_dev
 0 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
# read specified recr devs
#_year Input_value
#
# all recruitment deviations
#  1975E 1976E 1977E 1978E 1979E 1980E 1981E 1982E 1983E 1984E 1985E 1986E 1987E 1988E 1989E 1990R 1991R 1992R 1993R 1994R 1995R 1996R 1997R 1998R 1999R 2000R 2001R 2002R 2003R 2004R 2005R 2006R 2007R 2008R 2009R 2010R 2011R 2012R 2013R 2014R 2015R 2016R 2017R 2018R 2019R 2020R 2021F 2022F 2023F 2024F
#  -0.180383 -0.200799 -0.22171 -0.241011 -0.253158 -0.262134 -0.2682 -0.266158 -0.261045 -0.257656 -0.253943 -0.238649 -0.193482 -0.0969276 0.0189033 -0.117135 0.0979822 -0.0196951 0.000901747 -0.0380215 0.0150778 -0.377024 -0.348505 -0.0784873 -0.00165794 0.0668629 0.216065 0.0984674 0.229484 0.394347 0.42257 0.0727427 0.0675625 0.185567 -0.20863 0.0421417 -0.0476493 -0.101483 0.0973989 0.120275 -0.169098 -0.0637786 -0.0319828 -0.0663759 -0.229552 -0.228372 0.098398 0.118221 0.00286464 0
#
#Fishing Mortality info 
0.2 # F ballpark value in units of annual_F
-2010 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope midseason rate; 2=F as parameter; 3=F as hybrid; 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
4 # max F (methods 2-4) or harvest fraction (method 1)
5  # N iterations for tuning in hybrid mode; recommend 3 (faster) to 5 (more precise if many fleets)
#
#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = 1
#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
 0.0001 1.5 0.0410891 -1.60944 0.25 3 1 # InitF_seas_1_flt_11F11_HIS
#
# F rates by fleet x season
#_year:  1950 1951 1952 1953 1954 1955 1956 1957 1958 1959 1960 1961 1962 1963 1964 1965 1966 1967 1968 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# F01_EU_SPN 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.0500561 0.200573 0.231658 0.173438 0.0941374 0.120829 0.098481 0.144505 0.128279 0.140583 0.147054 0.23214 0.174022 0.170372 0.165645 0.120314 0.118718 0.132722 0.124939 0.121942 0.0973299 0.0974643 0.0858317 0.0914734 0.11313 0.112461 0.0971397 0.140559 0.0949765 0.0944296 0.0838687 0.093257 0.10798 0.0715693 0.0521772 0.0513892 0.0406091 0.0407446 0.0637821 0.153516
# F02_EU_POR 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.0145664 0.0212265 0.0139444 0.0491698 0.0396389 0.0410051 0.0458397 0.0240359 0.0217034 0.0246282 0.0233707 0.0254831 0.0256744 0.0719134 0.0260296 0.0586152 0.0462984 0.0688128 0.0457335 0.0547569 0.0712739 0.055823 0.0579603 0.0480108 0.0129661 0.0124445 0.0143004 0.0150533 0.0152295 0.0158959 0.0194426 0.0118699 0.0118352 0.00699428 0.0168344
# F03_JPN 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00728595 0.00645468 0.0120252 0.00617645 0.0107584 0.0105265 0.00678316 0.0127973 0.0165832 0.00822321 0.0230291 0.0323679 0.0108676 0.0386385 0.0054411 0.00621687 0.0044457 0.0172085 0.00983096 0.0200767 0.0140836 0.0112022 0.00238138 0.00366151 0.00282494 0.00351512 0.00170543 0.00189355 0.00114946 0.00248137 0.00160213 0.00255144 0.00304622 0.00069404 0.00112957 0.00108588 0.000609485 0.000384342 0.000469629 0.00113034
# F04_CTP 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00455421 0.00524387 0.00151774 0.00027362 0.00013002 0.000534649 0.00208239 0.00079404 0.000428047 0.00135361 0.00150645 0.00222907 0.00212947 0.00246338 0.00412862 0.00306643 0.00243456 0.00255934 0.00166462 0.00300066 0.00278173 0.00152045 0.00020935 0.000790651 0.000385282 0.000510207 0.000481118 0.000625059 0.000335706 0.0001763 0.000628225 0.000314814 5.67227e-05 0.0010416 0.000229965 0.000541483 5.92004e-05 7.34455e-05 0.000338109 0.000813789
# F05_USA 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00341008 0.00440308 0.00652543 0.00775429 0.00880603 0.00635462 0.00706192 0.010273 0.0090578 0.00962267 0.00935603 0.00622675 0.00703997 0.00582859 0.00514754 0.00533329 0.00525033 0.0044871 0.00360778 0.00460051 0.00433561 0.002801 0.00459741 0.00397385 0.00457824 0.00470421 0.00467811 0.00464321 0.00444058 0.00499868 0.00319835 0.00342 0.00351544 0.00128707 0.00121904 0.00106898 0.0011989 0.00108732 0.00117846 0.00283641
# F06_CAN 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00505168 0.00320077 0.00582986 0.00337824 0.00347758 0.0036678 0.00344339 0.00325035 0.00315554 0.00331488 0.00335019 0.00269424 0.0024923 0.00152487 0.00205517 0.00167074 0.00172132 0.00134311 0.0017509 0.00271548 0.00419911 0.00398771 0.00532235 0.00305726 0.00320287 0.00199177 0.00191965 0.00239145 0.000783988 0.00188697
# F07_MOR 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00848887 0.00928776 0.0113503 0.0107201 0.00676467 0.0125234 0.0222849 0.0316814 0.0208408 0.0215392 0.0361799 0.0345932 0.0470928 0.0557258 0.0178557 0.0240341 0.0200208 0.0208891 0.0162723 0.000481973 0.000696512 0.00167643
# F08_MEX 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5.9878e-05 0 0 0 0 6.02208e-05 9.52735e-05 0 5.56937e-05 3.72991e-05 5.33323e-05 2.95326e-05 4.45105e-05 3.2744e-05 3.86654e-05 4.31306e-05 3.8745e-05 4.14609e-05 1.98468e-05 1.86348e-05 1.8457e-05 1.7765e-05 2.46474e-05 1.27994e-05 1.10136e-05 1.20626e-05 1.20717e-05 1.65614e-05 1.10457e-05 2.65857e-05
# F09_VEN 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.000124128 8.09714e-05 0.000121248 0.000374438 6.34459e-05 8.49341e-05 2.45426e-05 2.04242e-05 0.000118841 0.000143134 0.000410488 0.000121939 2.77925e-05 7.36381e-05 8.33967e-05 0.000758227 0.000570342 0.000738598 0.0018494 0.000595701 0.000180115 0.000295492 4.4973e-05 0.000854993 0.000544224 0.000465073 0.000659157 0.000166289 0.000220296 0.000222668 0.000195533 0.00025858 0.000215046 0.000233881 0.000212431 7.95821e-05 1.50721e-05 8.74078e-06 2.10381e-05
# F10_OTH 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.271786 0.124038 0.0445479 0.0745159 0.059877 0.0221414 0.0154652 0.0174827 0.043758 0.0217161 0.0964426 0.0182355 0.0133998 0.0140263 0.00886103 0.0249497 0.016661 0.0182299 0.00123108 0.0208226 0.0172307 0.0139303 0.014921 0.0116228 0.0157356 0.0137603 0.0194278 0.0271678 0.027607 0.0574037 0.0401282 0.0147231 0.0258806 0.0243667 0.0145727 0.00282014 0.00230769 0.00243001 0.000679817 0.00163624
# F11_HIS 0.040934 0.0270773 0.0258209 0.0305637 0.00744164 0.0146585 0.00869766 0.0230374 0.0191115 0.0252325 0.0165362 0.0402827 0.0561564 0.024905 0.0468817 0.037902 0.077498 0.0720042 0.0981055 0.101292 0.0943832 0.155401 0.153011 0.150709 0.165253 0.128966 0.141731 0.159305 0.175433 0.180717 0.147293 0.197266 0.226941 0.203885 0.255232 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
#_Q_setup for fleets with cpue or survey or deviation data
#_1:  fleet number
#_2:  link type: 1=simple q; 2=mirror; 3=power (+1 parm); 4=mirror with scale (+1p); 5=offset (+1p); 6=offset & power (+2p)
#_     where power is applied as y = q * x ^ (1 + power); so a power value of 0 has null effect
#_     and with the offset included it is y = q * (x + offset) ^ (1 + power)
#_3:  extra input for link, i.e. mirror fleet# or dev index number
#_4:  0/1 to select extra sd parameter
#_5:  0/1 for biasadj or not
#_6:  0/1 to float
#_   fleet      link link_info  extra_se   biasadj     float  #  fleetname
        12         1         0         0         0         1  #  CPUE_EU_SPN
        13         1         0         0         0         1  #  CPUE_EU_POR
        14         1         0         0         0         1  #  CPUE_JPN_1
        15         1         0         0         0         1  #  CPUE_JPN_2
        16         1         0         0         0         1  #  CPUE_CTP
        17         1         0         0         0         1  #  CPUE_USA
        18         1         0         0         0         1  #  CPUE_MOR_1
        19         1         0         0         0         1  #  CPUE_MOR_2
        20         1         0         0         0         1  #  CPUE_USAlogbook
-9999 0 0 0 0 0
#
#_Q_parameters
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
           -25            25      -6.27471             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_EU_SPN(12)
           -25            25      -9.79825             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_EU_POR(13)
           -25            25      -6.39419             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_JPN_1(14)
           -25            25      -6.48455             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_JPN_2(15)
           -25            25      -6.36979             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_CTP(16)
           -25            25      -6.54337             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_USA(17)
           -25            25      -9.62355             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_MOR_1(18)
           -25            25       -11.562             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_MOR_2(19)
           -25            25      -6.84799             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_USAlogbook(20)
#_no timevary Q parameters
#
#_size_selex_patterns
#Pattern:_0;  parm=0; selex=1.0 for all sizes
#Pattern:_1;  parm=2; logistic; with 95% width specification
#Pattern:_5;  parm=2; mirror another size selex; PARMS pick the min-max bin to mirror
#Pattern:_11; parm=2; selex=1.0  for specified min-max population length bin range
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_6;  parm=2+special; non-parm len selex
#Pattern:_43; parm=2+special+2;  like 6, with 2 additional param for scaling (mean over bin range)
#Pattern:_8;  parm=8; double_logistic with smooth transitions and constant above Linf option
#Pattern:_9;  parm=6; simple 4-parm double logistic with starting length; parm 5 is first length; parm 6=1 does desc as offset
#Pattern:_21; parm=2*special; non-parm len selex, read as N break points, then N selex parameters
#Pattern:_22; parm=4; double_normal as in CASAL
#Pattern:_23; parm=6; double_normal where final value is directly equal to sp(6) so can be >1.0
#Pattern:_24; parm=6; double_normal with sel(minL) and sel(maxL), using joiners
#Pattern:_2;  parm=6; double_normal with sel(minL) and sel(maxL), using joiners, back compatibile version of 24 with 3.30.18 and older
#Pattern:_25; parm=3; exponential-logistic in length
#Pattern:_27; parm=special+3; cubic spline in length; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=special+3+2; cubic spline; like 27, with 2 additional param for scaling (mean over bin range)
#_discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead;_4=define_dome-shaped_retention
#_Pattern Discard Male Special
 24 0 0 0 # 1 F01_EU_SPN
 24 0 0 0 # 2 F02_EU_POR
 24 0 4 0 # 3 F03_JPN
 24 0 3 0 # 4 F04_CTP
 24 0 4 0 # 5 F05_USA
 24 0 0 0 # 6 F06_CAN
 15 0 0 2 # 7 F07_MOR
 24 0 4 0 # 8 F08_MEX
 24 0 0 0 # 9 F09_VEN
 15 0 0 1 # 10 F10_OTH
 15 0 0 1 # 11 F11_HIS
 15 0 0 1 # 12 CPUE_EU_SPN
 15 0 0 2 # 13 CPUE_EU_POR
 15 0 0 3 # 14 CPUE_JPN_1
 15 0 0 3 # 15 CPUE_JPN_2
 15 0 0 4 # 16 CPUE_CTP
 15 0 0 5 # 17 CPUE_USA
 15 0 0 7 # 18 CPUE_MOR_1
 15 0 0 7 # 19 CPUE_MOR_2
 15 0 0 5 # 20 CPUE_USAlogbook
#
#_age_selex_patterns
#Pattern:_0; parm=0; selex=1.0 for ages 0 to maxage
#Pattern:_10; parm=0; selex=1.0 for ages 1 to maxage
#Pattern:_11; parm=2; selex=1.0  for specified min-max age
#Pattern:_12; parm=2; age logistic
#Pattern:_13; parm=8; age double logistic. Recommend using pattern 18 instead.
#Pattern:_14; parm=nages+1; age empirical
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_16; parm=2; Coleraine - Gaussian
#Pattern:_17; parm=nages+1; empirical as random walk  N parameters to read can be overridden by setting special to non-zero
#Pattern:_41; parm=2+nages+1; // like 17, with 2 additional param for scaling (mean over bin range)
#Pattern:_18; parm=8; double logistic - smooth transition
#Pattern:_19; parm=6; simple 4-parm double logistic with starting age
#Pattern:_20; parm=6; double_normal,using joiners
#Pattern:_26; parm=3; exponential-logistic in age
#Pattern:_27; parm=3+special; cubic spline in age; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=2+special+3; // cubic spline; with 2 additional param for scaling (mean over bin range)
#Age patterns entered with value >100 create Min_selage from first digit and pattern from remainder
#_Pattern Discard Male Special
 11 0 0 0 # 1 F01_EU_SPN
 15 0 0 1 # 2 F02_EU_POR
 15 0 0 1 # 3 F03_JPN
 15 0 0 1 # 4 F04_CTP
 15 0 0 1 # 5 F05_USA
 15 0 0 1 # 6 F06_CAN
 15 0 0 1 # 7 F07_MOR
 15 0 0 1 # 8 F08_MEX
 15 0 0 1 # 9 F09_VEN
 15 0 0 1 # 10 F10_OTH
 15 0 0 1 # 11 F11_HIS
 15 0 0 1 # 12 CPUE_EU_SPN
 15 0 0 1 # 13 CPUE_EU_POR
 15 0 0 1 # 14 CPUE_JPN_1
 15 0 0 1 # 15 CPUE_JPN_2
 15 0 0 1 # 16 CPUE_CTP
 15 0 0 1 # 17 CPUE_USA
 15 0 0 1 # 18 CPUE_MOR_1
 15 0 0 1 # 19 CPUE_MOR_2
 15 0 0 1 # 20 CPUE_USAlogbook
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   F01_EU_SPN LenSelex
          62.5         297.5       125.837        135.54          0.05             1          2          0          0          0          0        0.5          0          0  #  Size_DblN_peak_F01_EU_SPN(1)
           -10             4      -7.75496            -6          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_top_logit_F01_EU_SPN(1)
            -1             9       6.09026           6.7          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_ascend_se_F01_EU_SPN(1)
            -1             9       7.70018          7.25          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_descend_se_F01_EU_SPN(1)
            -5             9            -5            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_start_logit_F01_EU_SPN(1)
            -5             9            -5            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_end_logit_F01_EU_SPN(1)
# 2   F02_EU_POR LenSelex
          62.5         297.5       142.088        135.54          0.05             1          2          0          0          0          0        0.5          0          0  #  Size_DblN_peak_F02_EU_POR(2)
           -10             4      -7.81045            -6          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_top_logit_F02_EU_POR(2)
            -1             9       6.67779           6.7          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_ascend_se_F02_EU_POR(2)
            -1             9       7.25094          7.25          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_descend_se_F02_EU_POR(2)
            -5             9            -5            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_start_logit_F02_EU_POR(2)
            -5             9            -5            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_end_logit_F02_EU_POR(2)
# 3   F03_JPN LenSelex
          62.5         297.5       152.117        135.54          0.05             1          2          0          0          0          0        0.5          0          0  #  Size_DblN_peak_F03_JPN(3)
           -10             4      -7.26388            -6          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_top_logit_F03_JPN(3)
            -1             9       7.29192           6.7          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_ascend_se_F03_JPN(3)
            -1             9       7.86215          7.25          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_descend_se_F03_JPN(3)
            -5             9            -5            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_start_logit_F03_JPN(3)
            -5             9         -4.96            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_end_logit_F03_JPN(3)
           -60            60      -1.51294             0          0.05             1          4          0          0          0          0          0          0          0  #  SzSel_Fem_Peak_F03_JPN(3)
           -15            15    -0.0632176             0          0.05             1          4          0          0          0          0          0          0          0  #  SzSel_Fem_Ascend_F03_JPN(3)
           -15            15     -0.527682             0          0.05             1          4          0          0          0          0          0          0          0  #  SzSel_Fem_Descend_F03_JPN(3)
           -15            15             0             0          0.05             1         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Final_F03_JPN(3)
           0.5           1.5        1.3641             1          0.05             1          5          0          0          0          0          0          0          0  #  SzSel_Fem_Scale_F03_JPN(3)
# 4   F04_CTP LenSelex
          62.5         297.5       126.119        135.54          0.05             1          2          0          0          0          0        0.5          0          0  #  Size_DblN_peak_F04_CTP(4)
            -6             4      -2.04644            -6          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_top_logit_F04_CTP(4)
            -1             9       3.57865           6.7          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_ascend_se_F04_CTP(4)
            -1             9        7.7942          7.25          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_descend_se_F04_CTP(4)
           -10             9            -5            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_start_logit_F04_CTP(4)
           -10             9         -4.96            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_end_logit_F04_CTP(4)
           -60            60       1.27701             0          0.05             1          4          0          0          0          0          0          0          0  #  SzSel_Male_Peak_F04_CTP(4)
           -15            15       1.29739             0          0.05             1          4          0          0          0          0          0          0          0  #  SzSel_Male_Ascend_F04_CTP(4)
           -15            15     -0.363521             0          0.05             1          4          0          0          0          0          0          0          0  #  SzSel_Male_Descend_F04_CTP(4)
           -15            15             0             0          0.05             1         -4          0          0          0          0          0          0          0  #  SzSel_Male_Final_F04_CTP(4)
           0.5           1.5      0.775731             1          0.05             1          5          0          0          0          0          0          0          0  #  SzSel_Male_Scale_F04_CTP(4)
# 5   F05_USA LenSelex
          62.5         297.5       169.477        135.54          0.05             1          2          0          0          0          0        0.5          0          0  #  Size_DblN_peak_F05_USA(5)
           -10             4      -7.19835            -6          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_top_logit_F05_USA(5)
            -1            15       8.86311           6.7          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_ascend_se_F05_USA(5)
            -1             9       7.36404          7.25          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_descend_se_F05_USA(5)
           -10             9      -6.28472            -5          0.05             1          2          0          0          0          0        0.5          0          0  #  Size_DblN_start_logit_F05_USA(5)
           -10             9      -2.45963            -5          0.05             1          2          0          0          0          0        0.5          0          0  #  Size_DblN_end_logit_F05_USA(5)
           -40            40      -15.6153             0          0.05             1          4          0          0          0          0          0          0          0  #  SzSel_Fem_Peak_F05_USA(5)
           -15            15       0.10704             0          0.05             1          4          0          0          0          0          0          0          0  #  SzSel_Fem_Ascend_F05_USA(5)
           -15            15      0.257303             0          0.05             1          4          0          0          0          0          0          0          0  #  SzSel_Fem_Descend_F05_USA(5)
           -15            15      -2.43635             0          0.05             1          4          0          0          0          0          0          0          0  #  SzSel_Fem_Final_F05_USA(5)
           0.5           1.5      0.916761             1          0.05             1          5          0          0          0          0          0          0          0  #  SzSel_Fem_Scale_F05_USA(5)
# 6   F06_CAN LenSelex
          62.5         297.5       134.681        135.54          0.05             1          2          0          0          0          0        0.5          0          0  #  Size_DblN_peak_F06_CAN(6)
           -10             4      -6.46178            -6          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_top_logit_F06_CAN(6)
            -1             9       7.21262           6.7          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_ascend_se_F06_CAN(6)
            -1             9       7.71585          7.25          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_descend_se_F06_CAN(6)
            -5             9            -5            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_start_logit_F06_CAN(6)
            -5             9            -5            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_end_logit_F06_CAN(6)
# 7   F07_MOR LenSelex
# 8   F08_MEX LenSelex
          62.5         297.5       165.359        135.54          0.05             1          2          0          0          0          0        0.5          0          0  #  Size_DblN_peak_F08_MEX(8)
            -6            10      -1.34871            -6          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_top_logit_F08_MEX(8)
            -1             9       7.78974           6.7          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_ascend_se_F08_MEX(8)
            -1             9       7.20215          7.25          0.05             1         -3          0          0          0          0        0.5          0          0  #  Size_DblN_descend_se_F08_MEX(8)
            -5             9            -5            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_start_logit_F08_MEX(8)
            -5             9             8            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_end_logit_F08_MEX(8)
           -60            60       14.2058             0          0.05             1          4          0          0          0          0          0          0          0  #  SzSel_Fem_Peak_F08_MEX(8)
           -15            15       0.45672             0          0.05             1          4          0          0          0          0          0          0          0  #  SzSel_Fem_Ascend_F08_MEX(8)
           -15            15             0             0          0.05             1         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Descend_F08_MEX(8)
           -15            15             0             0          0.05             1         -4          0          0          0          0          0          0          0  #  SzSel_Fem_Final_F08_MEX(8)
           0.5           1.5             1             1          0.05             1         -5          0          0          0          0          0          0          0  #  SzSel_Fem_Scale_F08_MEX(8)
# 9   F09_VEN LenSelex
          62.5         297.5       178.763        135.54          0.05             1          2          0          0          0          0        0.5          0          0  #  Size_DblN_peak_F09_VEN(9)
            -6             4        -5.591            -6          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_top_logit_F09_VEN(9)
            -1             9       7.67043           6.7          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_ascend_se_F09_VEN(9)
            -1             9       7.38799          7.25          0.05             1          3          0          0          0          0        0.5          0          0  #  Size_DblN_descend_se_F09_VEN(9)
            -5             9            -5            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_start_logit_F09_VEN(9)
           -10             9         -4.96            -5          0.05             1         -2          0          0          0          0        0.5          0          0  #  Size_DblN_end_logit_F09_VEN(9)
# 10   F10_OTH LenSelex
# 11   F11_HIS LenSelex
# 12   CPUE_EU_SPN LenSelex
# 13   CPUE_EU_POR LenSelex
# 14   CPUE_JPN_1 LenSelex
# 15   CPUE_JPN_2 LenSelex
# 16   CPUE_CTP LenSelex
# 17   CPUE_USA LenSelex
# 18   CPUE_MOR_1 LenSelex
# 19   CPUE_MOR_2 LenSelex
# 20   CPUE_USAlogbook LenSelex
# 1   F01_EU_SPN AgeSelex
             0            10             0             0            25             0        -99          0          0          0          0        0.5          0          0  #  minage@sel=1_F01_EU_SPN(1)
            10           100            35             0            25             0        -99          0          0          0          0        0.5          0          0  #  maxage@sel=1_F01_EU_SPN(1)
# 2   F02_EU_POR AgeSelex
# 3   F03_JPN AgeSelex
# 4   F04_CTP AgeSelex
# 5   F05_USA AgeSelex
# 6   F06_CAN AgeSelex
# 7   F07_MOR AgeSelex
# 8   F08_MEX AgeSelex
# 9   F09_VEN AgeSelex
# 10   F10_OTH AgeSelex
# 11   F11_HIS AgeSelex
# 12   CPUE_EU_SPN AgeSelex
# 13   CPUE_EU_POR AgeSelex
# 14   CPUE_JPN_1 AgeSelex
# 15   CPUE_JPN_2 AgeSelex
# 16   CPUE_CTP AgeSelex
# 17   CPUE_USA AgeSelex
# 18   CPUE_MOR_1 AgeSelex
# 19   CPUE_MOR_2 AgeSelex
# 20   CPUE_USAlogbook AgeSelex
#_No_Dirichlet parameters
#_no timevary selex parameters
#
0   #  use 2D_AR1 selectivity? (0/1)
#_no 2D_AR1 selex offset used
#_specs:  fleet, ymin, ymax, amin, amax, sigma_amax, use_rho, len1/age2, devphase, before_range, after_range
#_sigma_amax>amin means create sigma parm for each bin from min to sigma_amax; sigma_amax<0 means just one sigma parm is read and used for all bins
#_needed parameters follow each fleet's specifications
# -9999  0 0 0 0 0 0 0 0 0 0 # terminator
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
#_factor  fleet  value
      1     12     0.132
      1     13         0
      1     14     0.163
      1     15         0
      1     16     0.165
      1     17     0.022
      1     18     0.129
      1     19      0.01
      1     20      0.12
      # 4      1     0.454
      # 4      2     0.659
      # 4      3      1.08
      # 4      4     0.359
      # 4      5     1.541
      # 4      6     0.456
      # 4      7     0.747
      # 4      8     2.802
      # 4      9    11.623
 -9999   1    0  # terminator
#
1 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 9 changes to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark; 18=initEQregime
#like_comp fleet  phase  value  sizefreq_method
 1 12 1 1 1
 1 13 1 1 1
 1 14 1 1 1
 1 15 1 1 1
 1 16 1 1 1
 1 17 1 1 1
 1 18 1 1 1
 1 19 1 1 1
 1 20 1 0 1
-9999  1  1  1  1  #  terminator
#
# lambdas (for info only; columns are phases)
#  0 #_CPUE/survey:_1
#  0 #_CPUE/survey:_2
#  0 #_CPUE/survey:_3
#  0 #_CPUE/survey:_4
#  0 #_CPUE/survey:_5
#  0 #_CPUE/survey:_6
#  0 #_CPUE/survey:_7
#  0 #_CPUE/survey:_8
#  0 #_CPUE/survey:_9
#  0 #_CPUE/survey:_10
#  0 #_CPUE/survey:_11
#  1 #_CPUE/survey:_12
#  1 #_CPUE/survey:_13
#  1 #_CPUE/survey:_14
#  1 #_CPUE/survey:_15
#  1 #_CPUE/survey:_16
#  1 #_CPUE/survey:_17
#  1 #_CPUE/survey:_18
#  1 #_CPUE/survey:_19
#  0 #_CPUE/survey:_20
#  1 #_lencomp:_1
#  1 #_lencomp:_2
#  1 #_lencomp:_3
#  1 #_lencomp:_4
#  1 #_lencomp:_5
#  1 #_lencomp:_6
#  1 #_lencomp:_7
#  1 #_lencomp:_8
#  1 #_lencomp:_9
#  0 #_lencomp:_10
#  0 #_lencomp:_11
#  0 #_lencomp:_12
#  0 #_lencomp:_13
#  0 #_lencomp:_14
#  0 #_lencomp:_15
#  0 #_lencomp:_16
#  0 #_lencomp:_17
#  0 #_lencomp:_18
#  0 #_lencomp:_19
#  0 #_lencomp:_20
#  1 #_init_equ_catch1
#  1 #_init_equ_catch2
#  1 #_init_equ_catch3
#  1 #_init_equ_catch4
#  1 #_init_equ_catch5
#  1 #_init_equ_catch6
#  1 #_init_equ_catch7
#  1 #_init_equ_catch8
#  1 #_init_equ_catch9
#  1 #_init_equ_catch10
#  1 #_init_equ_catch11
#  1 #_init_equ_catch12
#  1 #_init_equ_catch13
#  1 #_init_equ_catch14
#  1 #_init_equ_catch15
#  1 #_init_equ_catch16
#  1 #_init_equ_catch17
#  1 #_init_equ_catch18
#  1 #_init_equ_catch19
#  1 #_init_equ_catch20
#  1 #_recruitments
#  1 #_parameter-priors
#  1 #_parameter-dev-vectors
#  1 #_crashPenLambda
#  0 # F_ballpark_lambda
0 # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M,Dyn. Bzero, SmryBio
 # 0 2 0 0 # Selectivity: (1) fleet, (2) 1=len/2=age/3=both, (3) year, (4) N selex bins
 # 0 0 # Growth: (1) growth pattern, (2) growth ages
 # 0 0 0 # Numbers-at-age: (1) area(-1 for all), (2) year, (3) N ages
 # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)
 # -1 # list of ages for growth std (-1 in first bin to self-generate)
 # -1 # list of ages for NatAge std (-1 in first bin to self-generate)
999

