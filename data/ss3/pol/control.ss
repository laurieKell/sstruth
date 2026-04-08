#C growth parameters are estimated
#C spawner-recruitment bias adjustment Not tuned For optimality
#C file created using an r4ss function
#C file write time: 2025-02-02  14:15:36
#
0 # 0 means do not read wtatage.ss; 1 means read and usewtatage.ss and also read and use growth parameters
1 #_N_Growth_Patterns
1 #_N_platoons_Within_GrowthPattern
4 # recr_dist_method for parameters
1 # not yet implemented; Future usage:Spawner-Recruitment; 1=global; 2=by area
1 # number of recruitment settlement assignments 
0 # unused option
# for each settlement assignment:
#_GPattern	month	area	age
1	1	1	0	#_recr_dist_pattern1
#
#_Cond 0 # N_movement_definitions goes here if N_areas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
1 #_Nblock_Patterns
 1#_blocks_per_pattern 
# begin and end years of blocks
 2014 2099 # set end at a silly value so you dont have to update each year

#_Cond 0 #_blocks_per_pattern
# begin and end years of blocks
#
# controls for all timevary parameters 
1 #_env/block/dev_adjust_method for all time-vary parms (1=warn relative to base parm bounds; 3=no bound check)
#
# AUTOGEN
1 1 1 1 1 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
# where: 0 = autogen all time-varying parms; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345
#
# setup for M, growth, maturity, fecundity, recruitment distibution, movement
#
3 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=Maunder_M;_6=Age-range_Lorenzen
#age0	age1	age2	age3	age4	age5	age6	age7	age8	age9	age10	age11	age12	age13	age14	age15	age16	age17	age18	age19	age20
0.920	0.657	0.534	0.463	0.417	0.385	0.361	0.344	0.330	0.319	0.311	0.311	0.311	0.311	0.311	0.311	0.311	0.311	0.311	0.311	0.311 # natm

1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr;5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
0.5 #_Age(post-settlement)_for_L1;linear growth below this
999 #_Growth_Age_for_L2 (999 to use as Linf)
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0 #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
3 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
#age0	age1	age2	age3	age4	age5	age6	age7	age8	age9	age10	age11	age12	age13	age14	age15	age16	age17	age18	age19	age20
0	0	0	0.9	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
2 # first mature age
1 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
#
#_growth_parms
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env_var&link	dev_link	dev_minyr	dev_maxyr	dev_PH	Block	Block_Fxn
    0	      45	   16.57	   36	 10	0	 -2	0	0	0	0	0	0	0	#_L_at_Amin_Fem_GP_1 
   40	     150	     120	   70	 10	0	 -4	0	0	0	0	0	0	0	#_L_at_Amax_Fem_GP_1 
 0.05	     0.5	    0.11	 0.15	0.8	0	 -4	0	0	0	0	0	0	0	#_VonBert_K_Fem_GP_1 
 0.05	     0.5	    0.15	0.125	0.8	0	 -3	0	0	0	0	0	0	0	#_CV_young_Fem_GP_1  
 0.05	     0.5	     0.1	 0.05	0.8	0	 -3	0	0	0	0	0	0	0	#_CV_old_Fem_GP_1    
   -3	       3	5.96e-06	1e-05	0.8	0	 -3	0	0	0	0	0	0	0	#_Wtlen_1_Fem_GP_1   
   -3	       4	   3.121	    3	0.8	0	 -3	0	0	0	0	0	0	0	#_Wtlen_2_Fem_GP_1   
    0	      10	       2	   50	0.8	0	 -3	0	0	0	0	0	0	0	#_Mat50%_Fem_GP_1 - ignored but still needed
   -3	       3	      -2	-0.25	0.8	0	 -3	0	0	0	0	0	0	0	#_Mat_slope_Fem_GP_1  - ignored but still needed
   -3	       3	       1	    1	0.8	0	 -3	0	0	0	0	0	0	0	#_Eggs_alpha_Fem_GP_1
   -3	       3	       0	    0	0.8	0	 -3	0	0	0	0	0	0	0	#_Eggs_beta_Fem_GP_1 
  0.1	      10	       1	    1	  1	0	 -1	0	0	0	0	0	0	0	#_CohortGrowDev      
1e-06	0.999999	     0.5	  0.5	0.5	0	-99	0	0	0	0	0	0	0	#_FracFemale_GP_1    
#_no timevary MG parameters
#
#_seasonal_effects_on_biology_parms
0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
3 #_Spawner-Recruitment; 2=Ricker; 3=std_B-H; 4=SCAA;5=Hockey; 6=B-H_flattop; 7=survival_3Parm;8=Shepard_3Parm
0 # 0/1 to use steepness in initial equ recruitment calculation
0 # future feature: 0/1 to make realized sigmaR a function of SR curvature
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn # parm_name
 10	20	11.6435	 12	  10	0	  1	0	0	0	0	0	0	0	#_SR_LN(R0)  
0.2	 1	   0.76	0.7	0.05	1	 -4	0	0	0	0	0	0	0	#_SR_BH_steep
  0	 2	    0.5	0.6	 0.8	0	 -4	0	0	0	0	0	0	0	#_SR_sigmaR  - sugggested by r4ss
 -5	 5	      0	  0	   1	0	 -4	0	0	0	0	0	1	2	#_SR_regime  
  0	 0	      0	  0	   0	0	-99	0	0	0	0	0	0	0	#_SR_autocorr
# timevary SR parameters
 -5 5 -0.59386  0 1 0 -4 # #_SR_regime  #estimated at 2024 benchmark, then fixed

2 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
2010 # first year of main recr_devs; early devs can preceed this era
2022 # last year of main recr_devs; forecast devs start in following year (do not estimate recruitment for the last 2 years of the assessment)
2 #_recdev phase
1 # (0/1) to read 13 advanced options
#-20 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
-10 #max increased to -20 but that causes a step change in SSB, F and recr.
4 #_recdev_early_phase
0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
999 #_lambda for Fcast_recr_like occurring before endyr+1 - This is a weird one, it does not estimate zero recdev after main phase if this value is low: "This lambda is for the log likelihood of the forecast recruitment deviations that occur before endyr + 1. Use a larger value here if solitary, noisy data at end of time series cause unruly recruitment deviation estimation."
1994.2   #_last_early_yr_nobias_adj_in_MPD 
2005.4   #_first_yr_fullbias_adj_in_MPD 
2024.3   #_last_yr_fullbias_adj_in_MP
#2025.0   #_first_recent_yr_nobias_adj_in_MPD 
2022 # do not extend after main recdev 
0.9657  #_max_bias_adj_in_MPD (1.0 to mimic pre-2009 models) 
0 #_period of cycles in recruitment (N parms read below)
-5 #min rec_dev
5 #max rec_dev
0 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
# read specified recr devs
#_Yr Input_value
#
#Fishing Mortality info
0.3 # F ballpark
-2001 # F ballpark year (neg value to disable)
4 # F_Method:  1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)
3 # max F or harvest rate, depends on F_Method
#_fleet	start_F	first_parm_phase
    1	0.3	99	#_F_4_Fleet_Parms1
    2	0.1	99	#_F_4_Fleet_Parms2
    3	0.1	99	#_F_4_Fleet_Parms3
    4	0.3	99	#_F_4_Fleet_Parms4
-9999	  0	0	#_terminator      
4 # N iterations for tuning F in hybrid method (recommend 3 to 7)
#
#_initial_F_parms; 
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE

 1e-06 0.25 0.0138359 0.1 0.1 6 1 # InitF_seas_1_flt_1Gillnets
 1e-06 0.25 0.00340467 0.01 0.1 6 1 # InitF_seas_1_flt_3Trawls
# 1e-06 0.25 0.0084092 0.1 0.1 6 1 # InitF_seas_1_flt_4Recreational

#
#_Q_setup for fleets with cpue or survey data
#_fleet	link	link_info	extra_se	biasadj	float  #  fleetname
    5	1	0	1	0	1	#_Survey    
    6	1	0	1	0	1	#_LPUE_IE   
    7	1	0	1	0	1	#_LPUE_UK   
    8	1	0	1	0	1	#_LPUE_FR   
-9999	0	0	0	0	0	#_terminator
#_Q_parms(if_any);Qunits_are_ln(q)
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn  #  parm_name
 -7	5	 0.747913	 -2	0.5	0	-1	0	0	0	0	0	0	0	#_LnQ_base_Survey(5)  
  0	1	        0	0.1	0.1	0	-3	0	0	0	0	0	0	0	#_Q_extraSD_Survey(5) 
 -7	5	 0.458642	 -2	0.5	0	-1	0	0	0	0	0	0	0	#_LnQ_base_LPUE_IE(6) 
  0	1	        0	0.1	0.1	0	-3	0	0	0	0	0	0	0	#_Q_extraSD_LPUE_IE(6)
-15	5	 -9.74317	 -2	0.5	0	-1	0	0	0	0	0	0	0	#_LnQ_base_LPUE_UK(7) 
  0	1	        0	0.1	0.1	0	-3	0	0	0	0	0	0	0	#_Q_extraSD_LPUE_UK(7)
-15	5	  -9.7637	 -2	0.5	0	-1	0	0	0	0	0	0	0	#_LnQ_base_LPUE_FR(8) 
  0	1	        0	0.1	0.1	0	-3	0	0	0	0	0	0	0	#_Q_extraSD_LPUE_FR(8)
#_no timevary Q parameters
#
#_size_selex_patterns
#_Pattern	Discard	Male	Special
 0	0	0	0	#_1 Gillnets    
 0	0	0	0	#_2 Lines       
 0	0	0	0	#_3 Trawls      
24	0	0	0	#_4 Recreational
 0	0	0	0	#_5 Survey      
 0	0	0	0	#_6 LPUE_IE     
 0	0	0	0	#_7 LPUE_UK     
 0	0	0	0	#_8 LPUE_FR     
#
#_age_selex_patterns
#_Pattern	Discard	Male	Special
20	0	0	0	#_1 Gillnets    
20	0	0	0	#_2 Lines       
12	0	0	0	#_3 Trawls      
 0	0	0	0	#_4 Recreational
15	0	0	3	#_5 Survey      
15	0	0	1	#_6 LPUE_IE - mirror gill
15	0	0	3	#_7 LPUE_UK - mirror trawl
15	0	0	3	#_8 LPUE_FR - mirror trawl
#
#_SizeSelex
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn  #  parm_name
  60	 90	79.5043	  2	99	0	 5	0	0	0	0	0	0	0	#_SizeSel_P_1_Recreational(4)
  -5	  2	     -5	1.5	99	0	-6	0	0	0	0	0	0	0	#_SizeSel_P_2_Recreational(4)
   4	 10	 6.9161	  0	99	0	 6	0	0	0	0	0	0	0	#_SizeSel_P_3_Recreational(4)
  -5	  5	      5	  0	99	0	-6	0	0	0	0	0	0	0	#_SizeSel_P_4_Recreational(4)
-999	999	   -999	  0	 0	0	-2	0	0	0	0	0	0	0	#_SizeSel_P_5_Recreational(4)
-999	999	    999	  0	 0	0	-2	0	0	0	0	0	0	0	#_SizeSel_P_6_Recreational(4)
#_AgeSelex
   1	  10	  5.6303	   2	99	0	 5	0	0	0	0	0	0	0	#_AgeSel_P_1_Gillnets(1)
  -5	   2	      -5	 1.5	99	0	-6	0	0	0	0	0	0	0	#_AgeSel_P_2_Gillnets(1)
  -5	   5	 1.24686	   0	99	0	 6	0	0	0	0	0	0	0	#_AgeSel_P_3_Gillnets(1)
  -5	   5	 1.94448	   0	99	0	 6	0	0	0	0	0	0	0	#_AgeSel_P_4_Gillnets(1)
-999	-999	    -999	-999	 0	0	-2	0	0	0	0	0	0	0	#_AgeSel_P_5_Gillnets(1)
-999	  15	    -999	   0	 0	0	-2	0	0	0	0	0	0	0	#_AgeSel_P_6_Gillnets(1)
   1	  10	 3.92977	   2	99	0	 5	0	0	0	0	0	0	0	#_AgeSel_P_1_Lines(2)   
  -5	   2	      -5	 1.5	99	0	-6	0	0	0	0	0	0	0	#_AgeSel_P_2_Lines(2)   
  -5	   5	0.496665	   0	99	0	 6	0	0	0	0	0	0	0	#_AgeSel_P_3_Lines(2)   
  -5	   5	  2.9602	   0	99	0	 6	0	0	0	0	0	0	0	#_AgeSel_P_4_Lines(2)   
-999	-999	    -999	-999	 0	0	-2	0	0	0	0	0	0	0	#_AgeSel_P_5_Lines(2)   
-999	  15	    -999	   0	 0	0	-2	0	0	0	0	0	0	0	#_AgeSel_P_6_Lines(2)   
   1	  10	 2.79595	   2	99	0	 5	0	0	0	0	0	0	0	#_AgeSel_P_1_Trawls(3)  
   0	   5	 1.09704	   2	99	0	 6	0	0	0	0	0	0	0	#_AgeSel_P_2_Trawls(3)  
#_Dirichlet and/or MV Tweedie parameters for composition error
#_multiple_fleets_can_refer_to_same_parm;_but_list_cannot_have_gaps

#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
            -5             5      0.907337             0         1.813             6          8          0          0          0          0          0          0          0  #  ln(DM_theta)_Len_P1 Recr LenComp
            -5             5      0.937651             0         1.813             6          8          0          0          0          0          0          0          0  #  ln(DM_theta)_Len_P2 Gill AgeComp
            -5             5       1.09185             0         1.813             6          8          0          0          0          0          0          0          0  #  ln(DM_theta)_Len_P3 Line AgeComp 
            -5             5       4.93553             0         1.813             6          8          0          0          0          0          0          0          0  #  ln(DM_theta)_Len_P4 Trawl AgeComp

#_no timevary selex parameters
#
0 #  use 2D_AR1 selectivity(0/1):  experimental feature
#_no 2D_AR1 selex offset used
# Tag loss and Tag reporting parameters go next
0 # TG_custom:  0=no read; 1=read if tags exist
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
# Input variance adjustments factors: 
#_factor	fleet	value
    4	1	1	#_Variance_adjustment_list1
    4	2	1	#_Variance_adjustment_list2
    4	3	1	#_Variance_adjustment_list3
    4	4	1	#_Variance_adjustment_list4
    4	5	1	#_Variance_adjustment_list5
-9999	0	0	#_terminator               
#
1 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 4 changes to default Lambdas (default value is 1.0)
#_like_comp	fleet	phase	value	sizefreq_method
    1	5	1	1	0	#_Surv_Survey_Phz1 
    1	6	1	1	0	#_Surv_LPUE_IE_Phz1
    1	7	1	1	0	#_Surv_LPUE_UK_Phz1
    1	8	1	1	0	#_Surv_LPUE_FR_Phz1
-9999	0	0	0	0	#_terminator       
#
0 # 0/1 read specs for more stddev reporting
#
999
