#V3.24f
#_data_and_control_files: ss3.dat // ss3.ctl
#_SS-V3.24f-safe-Win64;_08/03/2012;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_11

# FISHERY DEFINITIONS
# F1-TWN
# F2-NJP
# F3-OTH

1 #_N_Growth_Patterns
1 #_N_Morphs_Within_GrowthPattern 
#_Cond 1 #_Morph_between/within_stdev_ratio (no read if N_morphs=1)
#_Cond  1 #vector_Morphdist_(-1_in_first_val_gives_normal_approx)
#
#_Cond 1  #  N recruitment designs goes here if N_GP*nseas*area>1
#_Cond 0  #  placeholder for recruitment interaction request
#_Cond 1 1 1  # example recruitment design element for GP=1, seas=1, area=1
#
#_Cond 0 # N_movement_definitions goes here if N_areas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
1 #_Nblock_Patterns
 1 #_blocks_per_pattern 
# begin and end years of blocks
 2001 2017
#
0.5 #_fracfemale 
3 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate
  #_no additional input for selected M option; read 1P per morph
  0.448927901	0.366989621	0.322678817	0.2956845	0.278044932	0.265988458	0.257494105	0.2513812	0.246914807	0.243615204	0.241157676	0.239316199	0.237930109	0.236883227	0.236090508	0.235489098	0.235032127	0.234684539	0.234419925	0.234218335	0.234064688	0.233947534	0.233858201	0.233790037	0.233738026	0.233698366	0.233668084	0.233644965	0.233627328	0.233613856	0.233603575	0.233595731	0.233589738	0.233585183	0.233581699	0.233579019	0.233576997	0.233575438	0.233574244	0.233573343	0.233572661
  0.454798374	0.373537893	0.328479969	0.300518934	0.281953545	0.269071282	0.259858264	0.253126682	0.248130991	0.244380649	0.241540869	0.239376536	0.237718794	0.236444241	0.235461475	0.234701985	0.234114049	0.233658261	0.233304598	0.233029926	0.232816485	0.232650527	0.232521452	0.232421036	0.232342912	0.232282077	0.232234742	0.232197885	0.232169201	0.232146859	0.232129446	0.232115897	0.232105345	0.232097146	0.232090731	0.232085752	0.232081888	0.232078866	0.232076513	0.23207468	0.232073243

1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_speciific_K; 4=not implemented
1 #_Growth_Age_for_L1
40 #_Growth_Age_for_L2 (999 to use as Linf)
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
2 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=read fec and wt from wtatage.ss
#_Age_Maturity by growth pattern
# 0 0	0	0	0	0	0	0	0	0	0	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
0 #_First_Mature_Age
1 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=age-specific fxn
1 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
1 #_env/block/dev_adjust_method (1=standard; 2=logistic transform keeps in base parm bounds; 3=standard w/ no bound check)
#
#_growth_parms
#_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
 # -1 0.8 0.45 0.45 0 0.8 -1 0 0 0 0 0 0 0 # NatM_p_1_Fem_GP_1
 60 180 120 120 0 10 -1 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 150 480 243.98 250 0 10 -1 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 0.50 0.27 0.27 0 0.8 -1 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0.1 25 15 3.7 0 0.8 -1 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0.1 25 15 3.7 0 0.8 -1 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
 # -1 0.8 0.45 0.45 0 0.8 -1 0 0 0 0 0 0 0 # NatM_p_1_Mal_GP_1
 80 180 120 120 0 10 -1 0 0 0 0 0 0 0 # L_at_Amin_Mal_GP_1
 150 480 250.19 250 0 10 -1 0 0 0 0 0 0 0 # L_at_Amax_Mal_GP_1
 0 0.50 0.25 0.211 0 0.8 -1 0 0 0 0 0 0 0 # VonBert_K_Mal_GP_1
 0.1 25 15 3.7 0 0.8 -1 0 0 0 0 0 0 0 # CV_young_Mal_GP_1
 0.1 25 15 3.7 0 0.8 -1 0 0 0 0 0 0 0 # CV_old_Mal_GP_1
 -1 3 4.68e-006 4.68e-006 0 0.8 -3 0 0 0 0 0.5 0 0 # Wtlen_1_Fem
 -1 4 3.16 3.16 0 0.8 -3 0 0 0 0 0.5 0 0 # Wtlen_2_Fem
 100 200 177.04267 177.04267 0 0.8 -3 0 0 0 0 0.5 0 0 # Mat50%_Fem
 -3 3 -0.04822 -0.04822 0 0.8 -3 0 0 0 0 0.5 0 0 # Mat_slope_Fem
 -3 3 1 1 0 0.8 -3 0 0 0 0 0.5 0 0 # Eggs/kg_inter_Fem
 -3 3 0 0 0 0.8 -3 0 0 0 0 0.5 0 0 # Eggs/kg_slope_wt_Fem
 -1 3 4.68e-06 4.68e-06 0 0.8 -3 0 0 0 0 0.5 0 0 # Wtlen_1_Mal
 -1 4 3.16 3.16 0 0.8 -3 0 0 0 0 0.5 0 0 # Wtlen_2_Mal
 -4 4 0 0 -1 99 -3 0 0 0 0 0.5 0 0 # RecrDist_GP_1
 -4 4 0 0 -1 99 -3 0 0 0 0 0.5 0 0 # RecrDist_Area_1
 -4 4 4 0 -1 99 -3 0 0 0 0 0.5 0 0 # RecrDist_Seas_1
 1 1 1 1 -1 99 -3 0 0 0 0 0.5 0 0 # CohortGrowDev
#
#_Cond 0  #custom_MG-env_setup (0/1)
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-environ parameters
#
#_Cond 0  #custom_MG-block_setup (0/1)
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-block parameters
#_Cond No MG parm trends 
#
#_seasonal_effects_on_biology_parms
 0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
#_Cond -4 #_MGparm_Dev_Phase
#
#_Spawner-Recruitment
3 #_SR_function: 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm
#_LO HI INIT PRIOR PR_type SD PHASE
 5.5 7.5 6.5 6.5 -1 10 1 # SR_LN(R0)
 0.2 1 0.5 0.5 0 0.2 -4 # SR_BH_steep
 0 1 0.4 0.4 0 0.8 -1 # SR_sigmaR
 -5 5 0 0 0 1 -3 # SR_envlink
 -5 5 0 0 0 1 -1 # SR_R1_offset
 0 0 0 0 -1 99 -1 # SR_autocorr
0 #_SR_env_link
0 #_SR_env_target_0=none;1=devs;_2=R0;_3=steepness
1 #do_recdev:  0=none; 1=devvector; 2=simple deviations
1970 # first year of main recr_devs; early devs can preceed this era
2016 # last year of main recr_devs; forecast devs start in following year
1 #_recdev phase 
1 # (0/1) to read 13 advanced options
1940 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
-2 #_recdev_early_phase
0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
1 #_lambda for Fcast_recr_like occurring before endyr+1
1946 #_last_early_yr_nobias_adj_in_MPD
1970 #_first_yr_fullbias_adj_in_MPD
2016 #_last_yr_fullbias_adj_in_MPD
2017 #_first_recent_yr_nobias_adj_in_MPD
1 #_max_bias_adj_in_MPD (-1 to override ramp and set biasadj=1.0 for all estimated recdevs)
0 #_period of cycles in recruitment (N parms read below)
-5 #min rec_dev
5 #max rec_dev
0 #_read_recdevs
#_end of advanced SR options
#
#Fishing Mortality info 
0.1 # F ballpark for tuning early phases
2017 # F ballpark year (neg value to disable)
2 # F_Method:  1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)
4 # max F or harvest rate, depends on F_Method
# no additional F input needed for Fmethod 1
# if Fmethod=2; read overall start F value; overall phase; N detailed inputs to read
0.5 1 0
# if Fmethod=3; read N iterations for tuning for Fmethod 3
#4  # N iterations for tuning F in hybrid method (recommend 3 to 7)
#
#_initial_F_parms
#_LO HI INIT PRIOR PR_type SD PHASE
0	1	0.1	0.1	-1	10	1	# F1-TWN
0	1	0.1	0.1	-1	10	1	# F2-NJP
0	1	0.1	0.1	-1	10	1	# F3-OTH
#
#_Q_setup
 # Q_type options:  <0=mirror, 0=float_nobiasadj, 1=float_biasadj, 2=parm_nobiasadj, 3=parm_w_random_dev, 4=parm_w_randwalk, 5=mean_unbiased_float_assign_to_parm
#_for_env-var:_enter_index_of_the_env-var_to_be_linked
#_Den-dep  env-var  extra_se  Q_type
0	0	0	0	# F1-TWN
0	0	0	0	# F2-NJP
0	0	0	0	# F3-OTH
#
#_Cond 0 #_If q has random component, then 0=read one parm for each fleet with random q; 1=read a parm for each year of index
#_Q_parms(if_any)
#
#_size_selex_types
#discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead
#_Pattern Discard Male Special
24	0	0	0	# F1-TWN
24	0	0	0	# F2-NJP
15	0	0	1	# F3-OTH
#
#_age_selex_types
#_Pattern ___ Male Special
10	0	0	0	# F1-TWN
10	0	0	0	# F2-NJP
10	0	0	0	# F3-OTH
#_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn
#_size_sel: F1
50 310 150         150 -1 0 2 0 1 0 0 0.5 1 2 # p1 - Peak value              
-20 5 -5         0 -1 0 3 0 1 0 0 0.5 1 2 # p2 - Top logistic
-1 20 5           0 -1 0 3 0 1 0 0 0.5 1 2 # p3 - Ascending width
-1 20 5         0 -1 0 3 0 1 0 0 0.5 1 2 # p4 - Descending width
-999 1 -999           0 -1 0 -2 0 0 0 0 0.5 0 0 # p5 - Initial selectivity at first bin
-999 1 -999         0 -1 5 -2 0 0 0 0 0.5 0 0 # p6 - Final selectivity at last bin

#_size_sel: F2
50 310 150         150 -1 0 2 0 0 0 0 0.5 0 0 # p1 - Peak value              
-20 5 -5         0 -1 0 3 0 0 0 0 0.5 0 0 # p2 - Top logistic
-1 20 5           0 -1 0 3 0 0 0 0 0.5 0 0 # p3 - Ascending width
-1 20 5         0 -1 0 3 0 0 0 0 0.5 0 0 # p4 - Descending width
-999 1 -999           0 -1 0 -2 0 0 0 0 0.5 0 0 # p5 - Initial selectivity at first bin
-999 1 -999         0 -1 5 -2 0 0 0 0 0.5 0 0 # p6 - Final selectivity at last bin

## Age selectivity parameterization
##_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn

#_Cond 0 #_custom_sel-env_setup (0/1) 
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no enviro fxns
1 #_custom_sel-blk_setup (0/1) 
50	300	150	150	-1	0	2
-20	5	-5	0	-1	0	2
-1	10	5	0	-1	0	2
-1	10	5	0	-1	0	2
#_Cond No selex parm trends 
3 #_selparmdev-phase
1 #_env/block/dev_adjust_method (1=standard; 2=logistic trans to keep in base parm bounds; 3=standard w/ no bound check)
#
# Tag loss and Tag reporting parameters go next
0  # TG_custom:  0=no read; 1=read if tags exist
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
1 #_Variance_adjustments_to_input_values
#_fleet: 1 2 3 
  0 0 0  #_add_to_survey_CV
  0 0 0  #_add_to_discard_stddev
  0 0 0  #_add_to_bodywt_CV
  1 1 1  #_mult_by_lencomp_N
  0 0 0  #_mult_by_agecomp_N
  1 1 1  #_mult_by_size-at-age_N
#
3 #_maxlambdaphase
1 #_sd_offset
#
4 # number of changes to make to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 
# 9=init_equ_catch; 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin
#like_comp fleet/survey  phase  value  sizefreq_method

# Eq catch
9	1	1	0	1
9	2	1	0	1
9	3	1	0	1

# Param_prior
11	1	1	0	1
#

0 # (0/1) read specs for more stddev reporting 
 # 1 1 -1 5 1 5 1 -1 5 # selex type, len/age, year, N selex bins, Growth pattern, N growth ages, NatAge_area(-1 for all), NatAge_yr, N Natages
 # 5 15 25 35 43 # vector with selex std bin picks (-1 in first bin to self-generate)
 # 1 2 14 26 40 # vector with growth std bin picks (-1 in first bin to self-generate)
 # 1 2 14 26 40 # vector with NatAge std bin picks (-1 in first bin to self-generate)
999
		
