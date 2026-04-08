#V3.30.23.00;_safe;_compile_date:_Nov  4 2024;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-ost/ss3-source-code

#_data_and_control_files: BassIVVII.dat // BassIVVII.ctl
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
 1 1 1 0
#
#_Cond 0 # N_movement_definitions goes here if Nareas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
1 #_Nblock_Patterns
 5 #_blocks_per_pattern 
# begin and end years of blocks
 2015 2015 2016 2016 2017 2017 2018 2018 2019 2023
#
# controls for all timevary parameters 
1 #_time-vary parm bound check (1=warn relative to base parm bounds; 3=no bound check); Also see env (3) and dev (5) options to constrain with base bounds
#
# AUTOGEN
 1 1 1 1 0 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
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
3 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=BETA:_Maunder_link_to_maturity;_6=Lorenzen_range
0.840918 0.463849 0.365109 0.306347 0.267492 0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24	0.24 # natM
#
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr; 5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
2 #_Age(post-settlement) for L1 (aka Amin); first growth parameter is size at this age; linear growth below this
28 #_Age(post-settlement) for L2 (aka Amax); 999 to treat as Linf
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0  #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
3 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
#
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
4 #_First_Mature_Age
1 #_fecundity_at_length option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach for M, G, CV_G:  1- direct, no offset**; 2- male=fem_parm*exp(male_parm); 3: male=female*exp(parm) then old=young*exp(parm)
#_** in option 1, any male parameter with value = 0.0 and phase <0 is set equal to female parameter
#
#_growth_parms
#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn
# Sex: 1  BioPattern: 1  NatMort
# 0.01 0.5 0.2 0.24 0.1 0 -3 0 0 0 0 0 0 0 # 
# Sex: 1  BioPattern: 1  Growth
 -1 30 19.8495 19.67 0.5 0 3 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 60 100 80.26 80.26 15 0 -4 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0.01 0.2 0.108258 0.09699 0.05 0 3 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 2 6 2.99493 3.9 0.8 0 6 0 0 0 0 0 0 0 # SD_young_Fem_GP_1
 4 10 9.47124 6.9 0.8 0 6 0 0 0 0 0 0 0 # SD_old_Fem_GP_1
# Sex: 1  BioPattern: 1  WtLen
 -1 1 1.296e-05 1.296e-05 0.05 0 -3 0 0 0 0 0 0 0 # Wtlen_1_Fem_GP_1
 2 4 2.969 2.969 0.05 0 -3 0 0 0 0 0 0 0 # Wtlen_2_Fem_GP_1
# Sex: 1  BioPattern: 1  Maturity&Fecundity
 30 50 40.649 40.649 5 0 -3 0 0 0 0 0 0 0 # Mat50%_Fem_GP_1
 -5 1 -0.33349 -0.33349 0.03764 0 -3 0 0 0 0 0 0 0 # Mat_slope_Fem_GP_1
 -3 3 1 1 0.8 0 -3 0 0 0 0 0 0 0 # Eggs/kg_inter_Fem_GP_1
 -3 3 0 0 0.8 0 -3 0 0 0 0 0 0 0 # Eggs/kg_slope_wt_Fem_GP_1
# Hermaphroditism
#  Recruitment Distribution 
# 0 0 0 0 0 0 -3 0 0 0 0 0 0 0 # RecrDist_GP_1
# 0 0 0 0 0 0 -3 0 0 0 0 0 0 0 # RecrDist_Area_1
# 0 0 0 0 0 0 -4 0 0 0 0 0 0 0 # RecrDist_month_1
#  Cohort growth dev base
 0.1 10 1 1 1 6 -1 0 0 0 0 0 0 0 # CohortGrowDev
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
3 #_Spawner-Recruitment; Options: 1=NA; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepherd_3Parm; 9=RickerPower_3parm
0  # 0/1 to use steepness in initial equ recruitment calculation
0  #  future feature:  0/1 to make realized sigmaR a function of SR curvature
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn #  parm_name
             1            16        9.8729             5             1             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           0.2         0.999         0.876         0.876           0.2             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           0.1             2           0.9           0.9           0.2             0         -5          0          0          0          0          0          0          0 # SR_sigmaR
            -5             5             0          -0.7             2             0         -2          0          0          0          0          0          0          0 # SR_regime
             0             0             0             0             0             0        -99          0          0          0          0          0          0          0 # SR_autocorr
#_no timevary SR parameters
2 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1986 # first year of main recr_devs; early devs can precede this era
2022 # last year of main recr_devs; forecast devs start in following year
3 #_recdev phase 
1 # (0/1) to read 13 advanced options
 -10 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 4 #_recdev_early_phase
 0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
1979.7   #_last_early_yr_nobias_adj_in_MPD 
1988.2   #_first_yr_fullbias_adj_in_MPD 
2022.9   #_last_yr_fullbias_adj_in_MPD 
2023.6   #_first_recent_yr_nobias_adj_in_MPD 
0.9421  #_max_bias_adj_in_MPD (1.0 to mimic pre-2009 models) 
 0 #_period of cycles in recruitment (N parms read below)
 -5 #min rec_dev
 5 #max rec_dev
 0 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
# read specified recr devs
#_year Input_value
#
# all recruitment deviations
#  1981E 1982E 1983E 1984E 1985R 1986R 1987R 1988R 1989R 1990R 1991R 1992R 1993R 1994R 1995R 1996R 1997R 1998R 1999R 2000R 2001R 2002R 2003R 2004R 2005R 2006R 2007R 2008R 2009R 2010R 2011R 2012R 2013R 2014R 2015R 2016R 2017R 2018R 2019R 2020R 2021R 2022R 2023R 2024F
#  0 0 0 0 -1.64916 -1.23905 0.0147132 1.30327 1.30587 -0.598477 -0.361054 0.379621 0.0265051 0.518211 0.626661 -0.932322 0.814006 0.435235 1.18065 -0.134014 0.676368 0.61075 0.939504 1.03338 0.341927 0.529199 -0.0801089 0.453445 0.230636 -0.524641 -0.33423 -0.809726 -0.185551 0.712243 -0.0851231 0.879281 0.321143 0.44458 0.568798 0.419203 0.412406 0.297052 -0.246407 0
#
#Fishing Mortality info 
0.2 # F ballpark value in units of annual_F
-2001 # F ballpark year (neg value to disable)
4 # F_Method:  1=Pope midseason rate; 2=F as parameter; 3=F as hybrid; 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
2.9 # max F (methods 2-4) or harvest fraction (method 1)
# Read list of fleets that do F as parameter; unlisted fleets stay hybrid, bycatch fleets must be included with start_PH=1, high F fleets should switch early
# (A) fleet;
# (B) F_starting_value (ignored if start_PH=1 or reading from ss3.par);
# (C) start_PH for fleet's Fparms (99 to stay in hybrid, <0 to stay at starting value)
# Terminate list with -9999 for fleet (use -9998 to read fleet-time specific F values after reading N hybrid tune loops)
# (A) (B) (C)
 1 0.01 99 # OTHERS_BSS4BC7AD-H
 2 0.01 99 # GNS_BSS4BC7AD-H
 3 0.01 99 # LHM_BSS4BC7AD-H
 4 0.01 99 # LLS_BSS4BC7AD-H
 5 0.01 99 # OTB_BSS4BC7AD-H
 6 0.01 99 # PTM_BSS4BC7AD-H
 7 0.01 99 # SEINE_BSS4BC7AD-H
 8 0.01 1 # RECFISH
 16 0.01 99 # OTB_DISC
 17 0.01 99 # SEINE_DISC
-9999 1 1 # end of list
#F_detail template: fleet year seas F_value catch_se phase
5 #_number of loops for hybrid tuning; 4 precise; 3 faster; 2 enough if switching to parms is enabled
#
#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = 10
#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
 0 3 0.00107428 0 99 0 -1 # InitF_seas_1_flt_1OTHERS_BSS4BC7AD-H
 0 3 0.00189337 0 99 0 -1 # InitF_seas_1_flt_2GNS_BSS4BC7AD-H
 0 3 0.000797355 0 99 0 -1 # InitF_seas_1_flt_3LHM_BSS4BC7AD-H
 0 3 0.000799069 0 99 0 -1 # InitF_seas_1_flt_4LLS_BSS4BC7AD-H
 0 3 0.0200005 0 99 0 1 # InitF_seas_1_flt_5OTB_BSS4BC7AD-H
 0 3 0.013131 0 99 0 1 # InitF_seas_1_flt_6PTM_BSS4BC7AD-H
 #0 3 0 0 99 0 -1 # InitF_seas_1_flt_7SEINE_BSS4BC7AD-H
 0 3 0.105529 0 99 0 1 # InitF_seas_1_flt_8RECFISH
 #0 3 0 0 99 0 -1 # InitF_seas_1_flt_16OTB_DISC
 #0 3 0 0 99 0 -1 # InitF_seas_1_flt_17SEINE_DISC
#
# F rates by fleet x season
#_year:  1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# OTHERS_BSS4BC7AD-H 0.00107658 0.00109317 0.00125717 0.00155474 0.00278405 0.00243695 0.00175403 0.00243441 0.00303756 0.0047232 0.00911383 0.00498197 0.00567688 0.00743652 0.00982693 0.00836693 0.00877583 0.0107654 0.0104756 0.00937138 0.00908052 0.0106543 0.0129477 0.0150824 0.0117289 0.0140887 0.0179198 0.0185272 0.0190963 0.0284762 0.0294319 0.0272355 0.0197404 0.00920792 0.00943758 0.00917109 0.00722442 0.005174 0.00539987 0.00470397
# GNS_BSS4BC7AD-H 0.00189718 0.00424214 0.00401279 0.00695868 0.00913035 0.00963746 0.0103484 0.00582583 0.00331985 0.00698568 0.00804314 0.00696759 0.00959467 0.00772247 0.0074801 0.00752644 0.00894591 0.0124685 0.00854626 0.0109074 0.0108438 0.0129434 0.0146218 0.0165772 0.0161383 0.0167273 0.018101 0.0253467 0.0290858 0.0535652 0.0361667 0.0313313 0.0177796 0.022503 0.0195165 0.018443 0.0171779 0.0169601 0.0165814 0.0114578
# LHM_BSS4BC7AD-H 0.000799161 0.000905229 0.00119036 0.00315626 0.00184821 0.00160377 0.00357423 0.00213629 0.00252881 0.00470825 0.00531579 0.00433028 0.00448459 0.00412823 0.0035036 0.00956332 0.0108464 0.0113391 0.0133256 0.0103704 0.0112879 0.0161648 0.018463 0.0161573 0.0136973 0.0156503 0.0161983 0.0179369 0.0200383 0.0247401 0.024619 0.0275069 0.0324993 0.0425816 0.0372299 0.0399082 0.0354323 0.0285834 0.0221383 0.0210982
# LLS_BSS4BC7AD-H 0.00080086 0.000484829 0.00231075 0.00223705 0.00271097 0.00212369 0.00218668 0.00218181 0.00194029 0.0018616 0.00190163 0.00172884 0.00269684 0.000536943 0.00263173 0.00384049 0.00626483 0.00543026 0.00578726 0.00671529 0.00775763 0.0101624 0.00941954 0.00680935 0.0046013 0.00498961 0.00517374 0.00443981 0.00460557 0.00664043 0.00451 0.00350248 0.00467362 0.00362481 0.00329856 0.00390899 0.00322508 0.00264768 0.00190535 0.00193623
# OTB_BSS4BC7AD-H 0.0206642 0.0245246 0.0105656 0.0174441 0.0275659 0.0325075 0.0337991 0.0260462 0.0263236 0.0225931 0.0275273 0.0404375 0.0380773 0.0399851 0.0461677 0.0465814 0.0468046 0.0565538 0.0668182 0.0659749 0.0661477 0.0657897 0.067914 0.0649734 0.0609316 0.0475488 0.0498527 0.0599401 0.0532306 0.0517343 0.0724263 0.0390356 0.0314007 0.0132817 0.0132609 0.0183442 0.0168855 0.0178054 0.0259908 0.011924
# PTM_BSS4BC7AD-H 0.0131532 0.0199054 0.0522865 0.0177963 0.00814095 0.00776104 0.0167911 0.019537 0.0102321 0.00356052 0.00879993 0.0474473 0.0418605 0.0410909 0.0462958 0.0312121 0.0368081 0.0248877 0.0378869 0.0379624 0.0571406 0.0622402 0.0398307 0.0456492 0.0436528 0.0729172 0.0550673 0.0569478 0.0875351 0.0163205 0.00347564 0.00150585 0.00145669 8.33916e-05 3.63693e-05 0.000140668 0.000140977 5.06194e-05 0.000102923 6.09277e-05
# SEINE_BSS4BC7AD-H 9.5087e-06 2.87855e-05 3.27268e-06 6.67601e-06 1.03161e-05 3.76906e-06 4.23579e-06 0 0 0 3.65892e-05 0 0 0 0 3.8245e-05 0.000145626 0.000118199 0.000184919 0.000245914 0.000722205 0.00110858 0.00215739 0.00436026 0.00369093 0.00596382 0.00456435 0.00962942 0.00875822 0.0128809 0.0166038 0.00817707 0.00782849 0.00213046 0.0025446 0.00372896 0.00388216 0.00444682 0.00783789 0.00289942
# RECFISH 0.110475 0.110569 0.110774 0.111004 0.110984 0.11097 0.11086 0.11068 0.110578 0.110459 0.110165 0.109778 0.109549 0.109668 0.110229 0.110265 0.109328 0.109193 0.110096 0.11105 0.111209 0.111355 0.111004 0.109754 0.110069 0.1108 0.117714 0.134518 0.151279 0.185287 0.20587 0.0671439 0.0681193 0.0468715 0.077059 0.10577 0.102061 0.100257 0.0889581 0.0612569
# OTB_DISC 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.000148983 0.0029098 6.77886e-05 0.000466886 0.00187809 0.00057837 0.00156643 0.00334337 0.000506658 0.00812637 0.00668886 0.00151179 0.00446345 0.0218655 0.0424623 0.0659172 0.0507215 0.0368247 0.042908 0.034472 0.040995 0.0266061
# SEINE_DISC 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00659434 0.00561128 0.00201673 0.00168258 0.00183579 0.00325641 0.00292244 0.000474011 0.00131418
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
         8         1         0         1         0         1  #  RECFISH
         9         1         0         1         0         1  #  AutBass
        10         1         0         1         0         1  #  CGFS1
        11         1         0         1         0         1  #  CGFS2
        12         1         0         1         0         1  #  FR_LPUE
        13         1         0         1         0         1  #  Nourdem_DZ
        14         1         0         1         0         1  #  LaSeine
        15         1         0         1         0         1  #  FALHEL
-9999 0 0 0 0 0
#
#_Q_parameters
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
           -25            25        2.2035             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_RECFISH(8)
             0             1   0           0.1            99             0          -3          0          0          0          0          0          0          0  #  Q_extraSD_RECFISH(8)
           -25            25      -4.83859             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_AutBass(9)
             0             1      0.465015           0.1            99             0          3          0          0          0          0          0          0          0  #  Q_extraSD_AutBass(9)
           -25            25       4.38352             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CGFS1(10)
             0             1      0.500698           0.1            99             0          3          0          0          0          0          0          0          0  #  Q_extraSD_CGFS1(10)
           -25            25       4.89753             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CGFS2(11)
             0             1      0.318555           0.1            99             0          3          0          0          0          0          0          0          0  #  Q_extraSD_CGFS2(11)
           -25            25      -21.4934             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_FR_LPUE(12)
             0             1   0           0.1            99             0          -3          0          0          0          0          0          0          0  #  Q_extraSD_FR_LPUE(12)
           -25            25      0.549866             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_Nourdem_DZ(13)
             0             1     0.0311386           0.1            99             0          3          0          0          0          0          0          0          0  #  Q_extraSD_Nourdem_DZ(13)
           -25            25       3.11315             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_LaSeine(14)
             0             1      0.253043           0.1            99             0          3          0          0          0          0          0          0          0  #  Q_extraSD_LaSeine(14)
           -25            25      -9.31972             0             1             0         -1          0          0          0          0          0          0          0  #  LnQ_base_FALHEL(15)
             0             1      0.923941           0.1            99             0          3          0          0          0          0          0          0          0  #  Q_extraSD_FALHEL(15)
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
 24 0 0 0 # 1 OTHERS_BSS4BC7AD-H
 24 0 0 0 # 2 GNS_BSS4BC7AD-H
 1 0 0 0 # 3 LHM_BSS4BC7AD-H
 1 0 0 0 # 4 LLS_BSS4BC7AD-H
 24 0 0 0 # 5 OTB_BSS4BC7AD-H
 1 0 0 0 # 6 PTM_BSS4BC7AD-H
 24 0 0 0 # 7 SEINE_BSS4BC7AD-H
 24 0 0 0 # 8 RECFISH
 24 0 0 0 # 9 AutBass
 24 0 0 0 # 10 CGFS1
 24 0 0 0 # 11 CGFS2
 15 0 0 5 # 12 FR_LPUE
 24 0 0 0 # 13 Nourdem_DZ
 24 0 0 0 # 14 LaSeine
 24 0 0 0 # 15 FALHEL
 24 0 0 0 # 16 OTB_DISC
 15 0 0 16 # 17 SEINE_DISC
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
 10 0 0 0 # 1 OTHERS_BSS4BC7AD-H
 10 0 0 0 # 2 GNS_BSS4BC7AD-H
 10 0 0 0 # 3 LHM_BSS4BC7AD-H
 10 0 0 0 # 4 LLS_BSS4BC7AD-H
 10 0 0 0 # 5 OTB_BSS4BC7AD-H
 10 0 0 0 # 6 PTM_BSS4BC7AD-H
 10 0 0 0 # 7 SEINE_BSS4BC7AD-H
 10 0 0 0 # 8 RECFISH
 0 0 0 0 # 9 AutBass
 10 0 0 0 # 10 CGFS1
 10 0 0 0 # 11 CGFS2
 15 0 0 5 # 12 FR_LPUE
 0 0 0 0 # 13 Nourdem_DZ
 0 0 0 0 # 14 LaSeine
 0 0 0 0 # 15 FALHEL
 10 0 0 0 # 16 OTB_DISC
 15 0 0 5 # 17 SEINE_DISC
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   OTHERS_BSS4BC7AD-H LenSelex
            20            93       39.0719            45          0.05             0          2          0          3       2015       2023          3          0          0  #  Size_DblN_peak_OTHERS_BSS4BC7AD-H(1)
           -15             4           -15           -15          0.05             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_OTHERS_BSS4BC7AD-H(1)
           -15            20       1.96471           3.3          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_OTHERS_BSS4BC7AD-H(1)
           -15            20       7.26065           4.4          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_OTHERS_BSS4BC7AD-H(1)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_OTHERS_BSS4BC7AD-H(1)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_OTHERS_BSS4BC7AD-H(1)
# 2   GNS_BSS4BC7AD-H LenSelex
            20            93        37.727            45          0.05             0          2          0          3       2015       2023          3          0          0  #  Size_DblN_peak_GNS_BSS4BC7AD-H(2)
           -15             4           -15           -15          0.05             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_GNS_BSS4BC7AD-H(2)
           -20             9       1.52167           3.3          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_GNS_BSS4BC7AD-H(2)
            -5             9       6.26771           4.4          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_GNS_BSS4BC7AD-H(2)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_GNS_BSS4BC7AD-H(2)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_GNS_BSS4BC7AD-H(2)
# 3   LHM_BSS4BC7AD-H LenSelex
            20            91       39.1747            30          0.05             0          2          0          3       2015       2023          3          0          0  #  Size_inflection_LHM_BSS4BC7AD-H(3)
          0.01            30       2.99503             5          0.05             0          3          0          0          0          0          0          0          0  #  Size_95%width_LHM_BSS4BC7AD-H(3)
# 4   LLS_BSS4BC7AD-H LenSelex
            20            91       38.2222            30          0.05             0          2          0          3       2015       2023          3          0          0  #  Size_inflection_LLS_BSS4BC7AD-H(4)
          0.01            30       2.78461             5          0.05             0          3          0          0          0          0          0          0          0  #  Size_95%width_LLS_BSS4BC7AD-H(4)
# 5   OTB_BSS4BC7AD-H LenSelex
            20            93        38.696            45          0.05             0          2          0          3       2015       2023          3          0          0  #  Size_DblN_peak_OTB_BSS4BC7AD-H(5)
           -15             4           -15           -15          0.05             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_OTB_BSS4BC7AD-H(5)
           -20             9        2.3588           3.3          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_OTB_BSS4BC7AD-H(5)
            -1             9       6.36626           4.4          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_OTB_BSS4BC7AD-H(5)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_OTB_BSS4BC7AD-H(5)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_OTB_BSS4BC7AD-H(5)
# 6   PTM_BSS4BC7AD-H LenSelex
            20            91       41.0454            30          0.05             0          2          0          0          0          0          0          0          0  #  Size_inflection_PTM_BSS4BC7AD-H(6)
          0.01            50       4.83329             5          0.05             0          3          0          0          0          0          0          0          0  #  Size_95%width_PTM_BSS4BC7AD-H(6)
# 7   SEINE_BSS4BC7AD-H LenSelex
            20            93       42.9225            45          0.05             0          2          0          3       2015       2023          3          0          0  #  Size_DblN_peak_SEINE_BSS4BC7AD-H(7)
           -15             4           -15           -15          0.05             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_SEINE_BSS4BC7AD-H(7)
           -20            20       2.82032           3.3          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_SEINE_BSS4BC7AD-H(7)
           -10            20       16.9009           4.4          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_SEINE_BSS4BC7AD-H(7)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_SEINE_BSS4BC7AD-H(7)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_SEINE_BSS4BC7AD-H(7)
# 8   RECFISH LenSelex
            20            93       50.6849            45          0.05             0          2          0          3       2015       2023          3          0          0  #  Size_DblN_peak_RECFISH(8)
           -15            15       1.81526           -15          0.05             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_RECFISH(8)
           -20            25        5.2126             5          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_RECFISH(8)
           -20            25       3.57032           4.4          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_RECFISH(8)
          -999            99      -3.13372          -999          0.05             0         -4          0          0          0          0          0          0          0  #  Size_DblN_start_logit_RECFISH(8)
          -999            99       9.03311          -999          0.05             0         -4          0          0          0          0          0          0          0  #  Size_DblN_end_logit_RECFISH(8)
# 9   AutBass LenSelex
            5            50       24.0544            32          0.05             0          2          0          0          0          0          0          0          0  #  Size_DblN_peak_AutBass(7)
           -15             4           -15            -6          0.05             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_AutBass(7)
            -1             9      -0.26125           3.3          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_AutBass(7)
            -1             9     -0.239813           4.4          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_AutBass(7)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_AutBass(7)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_AutBass(7)
# 10   CGFS1 LenSelex
            20            93       31.4768            32          0.05             0          2          0          0          0          0          0          0          0  #  Size_DblN_peak_CGFS1(10)
           -15             4           -15           -15          0.05             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_CGFS1(10)
            -1            15       3.00599           3.3          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_CGFS1(10)
            -5            15       6.14944           4.4          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_CGFS1(10)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_CGFS1(10)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_CGFS1(10)
# 11   CGFS2 LenSelex
            20            93        34.923            32          0.05             0          2          0          0          0          0          0          0          0  #  Size_DblN_peak_CGFS2(11)
           -15             4           -15           -15          0.05             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_CGFS2(11)
            -1            15       3.37334           3.3          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_CGFS2(11)
            -5            15       7.67251           4.4          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_CGFS2(11)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_CGFS2(11)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_CGFS2(11)
# 12   FR_LPUE LenSelex
# 13   Nourdem_DZ LenSelex
            19            93       21.0454            32          0.05             0          2          0          0          0          0          0          0          0  #  Size_DblN_peak_Nourdem_DZ(13)
           -15             4           -15            -6          0.05             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_Nourdem_DZ(13)
            -1             9       1.55677           3.3          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_Nourdem_DZ(13)
            -1             9       6.35177           4.4          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_Nourdem_DZ(13)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_Nourdem_DZ(13)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_Nourdem_DZ(13)
# 14   LaSeine LenSelex
             3            93       7.14823            32          0.05             0          2          0          0          0          0          0          0          0  #  Size_DblN_peak_LaSeine(14)
           -15             4           -15            -6          0.05             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_LaSeine(14)
            -1             9     -0.628646           3.3          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_LaSeine(14)
            -1             9        6.3691           4.4          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_LaSeine(14)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_LaSeine(14)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_LaSeine(14)
# 15   FALHEL LenSelex
             3            93       7.14823            32          0.05             0          2          0          0          0          0          0          0          0  #  Size_DblN_peak_LaSeine(14)
           -15             4           -15            -6          0.05             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_LaSeine(14)
            -1             9     -0.628646           3.3          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_LaSeine(14)
            -1             9        6.3691           4.4          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_LaSeine(14)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_LaSeine(14)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_LaSeine(14)
# 16   OTB_DISC LenSelex
            0            93       41.2784            45          0.05             0          2          0         3       2015       2023          3          0          0  #  Size_DblN_peak_UKOTB_Nets(1)
           -15             4           -15           -15          0.05             0         3          0        3       2015       2023          3             0          0  #  Size_DblN_top_logit_UKOTB_Nets(1)
            -20             25       4.59137           3.3          0.05             0          3          0        3       2015       2023          3          0          0  #  Size_DblN_ascend_se_UKOTB_Nets(1)
            -20             20       6.59951           4.4          0.05             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_UKOTB_Nets(1)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_start_logit_UKOTB_Nets(1)
          -999             9          -999          -999          0.05             0         -2          0          0          0          0          0          0          0  #  Size_DblN_end_logit_UKOTB_Nets(1)
# 17   SEINE_DISC LenSelex
# 1   OTHERS_BSS4BC7AD-H AgeSelex
# 2   GNS_BSS4BC7AD-H AgeSelex
# 3   LHM_BSS4BC7AD-H AgeSelex
# 4   LLS_BSS4BC7AD-H AgeSelex
# 5   OTB_BSS4BC7AD-H AgeSelex
# 6   PTM_BSS4BC7AD-H AgeSelex
# 7   SEINE_BSS4BC7AD-H AgeSelex
# 8   RECFISH AgeSelex
# 9   AutBass AgeSelex
#             2             2             2             2            99             0        -3          0          0          0          0          0          0          0  #  minage@sel=1_AutBass(9)
#             4             4             4             4            99             0        -3          0          0          0          0          0          0          0  #  maxage@sel=1_AutBass(9)
# 10   CGFS1 AgeSelex
# 11   CGFS2 AgeSelex
# 12   FR_LPUE AgeSelex
# 13   Nourdem_DZ AgeSelex
# 14   LaSeine AgeSelex
# 15   FALHEL AgeSelex
#             0             0             0             0            99             0        -3          0          0          0          0          0          0          0  #  minage@sel=1_FALHEL(15)
#             1             1             1             1            99             0        -3         0          0          0          0          0          0          0  #  maxage@sel=1_FALHEL(15)
# 16   OTB_DISC AgeSelex
# 17   SEINE_DISC AgeSelex
#_No_Dirichlet parameters
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name

# info on dev vectors created for selex parms are reported with other devs after tag parameter section 
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
# deviation vectors for timevary parameters
#  base   base first block   block  env  env   dev   dev   dev   dev   dev
#  type  index  parm trend pattern link  var  vectr link _mnyr  mxyr phase  dev_vector
#      5     1     1     0     0     0     0     1     3  2015  2023     3 2.31751 2.18426 1.88148 1.70791 1.53943 1.41624 0.581965 -0.621507 -0.497455
#      5     7     3     0     0     0     0     2     3  2015  2023     3 4.47875 4.55001 1.62896 0.743476 0.600579 -0.620258 0.131466 1.08846 0.36431
#      5    13     5     0     0     0     0     3     3  2015  2023     3 2.57647 1.51562 1.01468 1.43269 -0.190784 -0.291674 0.14063 0.560581 0.0762438
#      5    15     7     0     0     0     0     4     3  2015  2023     3 -0.356374 1.41279 1.21581 1.39898 0.366497 1.64074 1.33011 -0.708192 -0.354286
#      5    17     9     0     0     0     0     5     3  2015  2023     3 3.45785 3.62314 2.7936 2.41665 0.826312 0.182293 0.138502 -0.163591 0.421216
#      5    25    11     0     0     0     0     6     3  2015  2023     3 1.40876 1.30634 1.03994 1.03183 1.03131 0.619376 0.10205 0.025068 -0.0661053
#      5    31    13     0     0     0     0     7     3  2015  2023     3 1.12007 1.10457 1.15619 1.07171 1.24775 0.957592 0.912258 0.569004 0.237171
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
4     1         0.3375470 # 23   23   2.36336  78.32850       50.4783       17.04260            NA          0        NA multinomial   NA   NA
4     2         0.2040650 # 23   23  26.62640 217.75800      401.0870       82.78680            NA          0        NA multinomial   NA   NA
4     3         0.2810740 # 24   24  39.06620 251.54200      401.5830      112.86600            NA          0        NA multinomial   NA   NA
4     4         0.4444500 # 24   24   5.87678 106.23400       99.0833       44.79160            NA          0        NA multinomial   NA   NA
4     5         0.2166850 # 24   24   4.57376 315.80700      567.2920      123.55500            NA          0        NA multinomial   NA   NA
4     6         0.3211230 # 16   16   1.61405 127.51000      150.2500       48.50220            NA          0        NA multinomial   NA   NA
4     7         0.3101240 # 13   13   1.24575  19.62060       37.5385       11.69090            NA          0        NA multinomial   NA   NA
4     8         1.7126600 # 11   11  30.70420 194.46000       53.3636       91.02720            NA          0        NA multinomial   NA   NA
4    10         0.3159370 # 27   27   2.53026  37.95400       75.5926       23.90870            NA          0        NA multinomial   NA   NA
4    11         0.4054260 #  9    9  24.64730  39.43570       76.4444       31.40250            NA          0        NA multinomial   NA   NA
4    13         0.0532417 #  4    4   6.10690   9.13425      157.0000        8.19472            NA          0        NA multinomial   NA   NA
4    14         0.0995071 #  7    7  22.09890  22.09890      199.0000       22.09890            NA          0        NA multinomial   NA   NA
4    16         0.1065210 # 20   20   1.00000  27.18430       56.5500        6.08086            NA          0        NA multinomial   NA   NA
5     5         0.0186129 #       719  696   1.00000   1.39973      39.63510        1.00180            NA          0        NA multinomial
5     9         0.0522172 #        34   34   2.08305   4.87740      87.20590        4.43060            NA          0        NA multinomial
5    10         0.3105380 #        93   93   1.00000   4.67509       4.16129        1.52278            NA          0        NA multinomial
5    11         0.2461580 #       160  160   1.00000   5.14305       7.86250        2.11907            NA          0        NA multinomial
5    13         0.2315150 #        26   26   1.00000   3.25598       6.69231        1.71742            NA          0        NA multinomial
5    14         0.3402200 #       112  112   1.00000  13.34320       8.33929        3.00696            NA          0        NA multinomial
5    15         0.0879278 #        18   18  27.00000  27.00000
 -9999   1    0  # terminator
#
3 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 14 changes to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark; 18=initEQregime
#like_comp fleet  phase  value  sizefreq_method
 4 1 1 1 1
 4 2 1 1 1
 4 3 1 1 1
 4 4 1 1 1
 4 5 1 1 1
 4 6 1 1 1
 4 7 1 1 1
 5 1 1 1 1
 5 2 1 1 1
 5 3 1 1 1
 5 4 1 1 1
 5 5 1 1 1
 5 6 1 1 1
 5 7 1 1 1
-9999  1  1  1  1  #  terminator
#
# lambdas (for info only; columns are phases)
#  0 0 0 #_CPUE/survey:_1
#  0 0 0 #_CPUE/survey:_2
#  0 0 0 #_CPUE/survey:_3
#  0 0 0 #_CPUE/survey:_4
#  0 0 0 #_CPUE/survey:_5
#  0 0 0 #_CPUE/survey:_6
#  0 0 0 #_CPUE/survey:_7
#  1 1 1 #_CPUE/survey:_8
#  1 1 1 #_CPUE/survey:_9
#  1 1 1 #_CPUE/survey:_10
#  1 1 1 #_CPUE/survey:_11
#  1 1 1 #_CPUE/survey:_12
#  1 1 1 #_CPUE/survey:_13
#  1 1 1 #_CPUE/survey:_14
#  1 1 1 #_CPUE/survey:_15
#  0 0 0 #_CPUE/survey:_16
#  0 0 0 #_CPUE/survey:_17
#  1 1 1 #_lencomp:_1
#  1 1 1 #_lencomp:_2
#  1 1 1 #_lencomp:_3
#  1 1 1 #_lencomp:_4
#  1 1 1 #_lencomp:_5
#  1 1 1 #_lencomp:_6
#  1 1 1 #_lencomp:_7
#  1 1 1 #_lencomp:_8
#  0 0 0 #_lencomp:_9
#  1 1 1 #_lencomp:_10
#  1 1 1 #_lencomp:_11
#  0 0 0 #_lencomp:_12
#  1 1 1 #_lencomp:_13
#  1 1 1 #_lencomp:_14
#  0 0 0 #_lencomp:_15
#  1 1 1 #_lencomp:_16
#  0 0 0 #_lencomp:_17
#  1 1 1 #_agecomp:_1
#  1 1 1 #_agecomp:_2
#  1 1 1 #_agecomp:_3
#  1 1 1 #_agecomp:_4
#  1 1 1 #_agecomp:_5
#  1 1 1 #_agecomp:_6
#  1 1 1 #_agecomp:_7
#  0 0 0 #_agecomp:_8
#  1 1 1 #_agecomp:_9
#  1 1 1 #_agecomp:_10
#  1 1 1 #_agecomp:_11
#  0 0 0 #_agecomp:_12
#  1 1 1 #_agecomp:_13
#  1 1 1 #_agecomp:_14
#  1 1 1 #_agecomp:_15
#  1 1 1 #_agecomp:_16
#  0 0 0 #_agecomp:_17
#  1 1 1 #_init_equ_catch1
#  1 1 1 #_init_equ_catch2
#  1 1 1 #_init_equ_catch3
#  1 1 1 #_init_equ_catch4
#  1 1 1 #_init_equ_catch5
#  1 1 1 #_init_equ_catch6
#  1 1 1 #_init_equ_catch7
#  1 1 1 #_init_equ_catch8
#  1 1 1 #_init_equ_catch9
#  1 1 1 #_init_equ_catch10
#  1 1 1 #_init_equ_catch11
#  1 1 1 #_init_equ_catch12
#  1 1 1 #_init_equ_catch13
#  1 1 1 #_init_equ_catch14
#  1 1 1 #_init_equ_catch15
#  1 1 1 #_init_equ_catch16
#  1 1 1 #_init_equ_catch17
#  1 1 1 #_recruitments
#  1 1 1 #_parameter-priors
#  1 1 1 #_parameter-dev-vectors
#  1 1 1 #_crashPenLambda
#  0 0 0 # F_ballpark_lambda
0 # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M,Dyn. Bzero, SmryBio
 # 0 2 0 0 # Selectivity: (1) fleet, (2) 1=len/2=age/3=both, (3) year, (4) N selex bins
 # 0 0 # Growth: (1) growth pattern, (2) growth ages
 # 0 0 0 # Numbers-at-age: (1) area(-1 for all), (2) year, (3) N ages
 # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)
 # -1 # list of ages for growth std (-1 in first bin to self-generate)
 # -1 # list of ages for NatAge std (-1 in first bin to self-generate)
999

