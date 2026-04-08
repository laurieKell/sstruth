#C SS3_Control_NA_SMA_2017_15.xlsx
#C file created using an r4ss function
#C file write time: 2025-06-07  08:51:51
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
1	7	1	0	#_recr_dist_pattern1
#
#_Cond 0 # N_movement_definitions goes here if N_areas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
1 #_Nblock_Patterns
1 #_blocks_per_pattern
#_begin and end years of blocks
1949 1949
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
4 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=Maunder_M;_6=Age-range_Lorenzen
#_ #_Age_natmort_by sex x growthpattern
#_Age_0	Age_1	Age_2	Age_3	Age_4	Age_5	Age_6	Age_7	Age_8	Age_9	Age_10	Age_11	Age_12	Age_13	Age_14	Age_15	Age_16	Age_17	Age_18	Age_19	Age_20	Age_21	Age_22	Age_23	Age_24	Age_25	Age_26	Age_27	Age_28	Age_29	Age_30	Age_31	Age_32	Age_33	Age_34	Age_35	Age_36	Age_37	Age_38	Age_39	Age_40	Age_41	Age_42	Age_43	Age_44	Age_45	Age_46	Age_47	Age_48	Age_49	Age_50	Age_51	Age_52	Age_53	Age_54	Age_55	Age_56	Age_57	Age_58	Age_59	Age_60	Age_61	Age_62	Age_63	Age_64	Age_65	Age_66	Age_67	Age_68	Age_69
#0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	0.0599	#_natM1
#0.1315	0.1315	0.1315	0.1315	0.1315	0.1315	0.1315	0.1304	0.1243	0.1195	0.1156	0.1124	0.1097	0.1075	0.1057	0.1041	0.1028	0.1016	0.1007	0.0998	0.0991	0.0985	 0.098	0.0975	0.0971	0.0968	0.0965	0.0962	 0.096	0.0958	0.0956	0.0955	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	0.0954	#_natM2
#	North Atlantic Life History Scenario 3																																																																																	
#	Method			
#	Peterson & Wroblewski
#   Max Age			
#   32	F																																																																													
#		29	M																																																																													
#																																																																																		
# All Ages (69)	0	1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	43	44	45	46	47	48	49	50	51	52	53	54	55	56	57	58	59	60	61	62	63	64	65	66	67	68	69	#				# ICCAT Shark Group Recomended Changes (June 9, 2025)							
# Value Female	0.273706431	0.225063424	0.194167314	0.172714033	0.156916574	0.144789528	0.1351869	0.12739875	0.120960727	0.115555748	0.110959565	0.107008908	0.103581948	0.100585853	0.097948584	0.09561335	0.093534745	0.091676012	0.090007066	0.088503031	0.087143156	0.085909985	0.084788725	0.083766753	0.082833231	0.081978798	0.081195327	0.080475725	0.079813776	0.079204006	0.078641578	0.078122202	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	0.077642057	# Female				# Include updated natural mortality at age (Ma) and steepness (h) 							
# Value Male	0.273706431	0.214887837	0.18247989	0.161962096	0.147860392	0.137630463	0.129921865	0.123948361	0.11921977	0.115413918	0.112309973	0.109751299	0.107623603	0.105841479	0.104339804	0.10306805	0.101986425	0.101063185	0.100272717	0.099594151	0.09901034	0.098507082	0.098072544	0.097696805	0.097371508	0.09708958	0.096845014	0.096632687	0.096448222	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	0.096287867	# Male 				# Updated Ma (ICCAT Shark Working Group Decision; Peterson & Wroblewski; Pers Comm Enric Cortes, Length based method similar to Lorenzen but not as steep of a decline in Ma for young ages than Lorenzen, which may be more plausible for 63-70 cm FL at birth )							
#	0	1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	43	44	45	46	47	48	49	50	51	52	53	54	55	56	57	58	59	60	61	62	63	64	65	66	67	68	69	#				# Updated h (ICCAT Shark Working Group Decision; Deterministic h value rather than stochastic h value; Pers Comm Enric Cortes, the stochastic values gave unrealisticly high values for low productivity stocks, resampling the extended age composition of adult spawners may have produced h values that were too high to be plausible )							
	0.2737	0.2251	0.1942	0.1727	0.1569	0.1448	0.1352	0.1274	0.1210	0.1156	0.1110	0.1070	0.1036	0.1006	0.0979	0.0956	0.0935	0.0917	0.0900	0.0885	0.0871	0.0859	0.0848	0.0838	0.0828	0.0820	0.0812	0.0805	0.0798	0.0792	0.0786	0.0781	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	0.0776	# Female				# Available: ICCAT Shortfin Mako Assessment NextCloud Download June 9 2025 (provided by Ai Kimoto from Enric Cortes June 9 2025) 							
#																																																																							# Male = Female				# SMA_SA\Analysis\input files\Life history inputs and demography results for shortfin mako 2025_v8.xlsx 							
	0.2737	0.2149	0.1825	0.1620	0.1479	0.1376	0.1299	0.1239	0.1192	0.1154	0.1123	0.1098	0.1076	0.1058	0.1043	0.1031	0.1020	0.1011	0.1003	0.0996	0.0990	0.0985	0.0981	0.0977	0.0974	0.0971	0.0968	0.0966	0.0964	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	0.0963	# Male											
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr;5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
0 #_Age(post-settlement)_for_L1;linear growth below this
999 #_Growth_Age_for_L2 (999 to use as Linf)
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0 #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
4 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
# Age Maturity or Age fecundity:
#_Age_0	Age_1	Age_2	Age_3	Age_4	Age_5	Age_6	Age_7	Age_8	Age_9	Age_10	Age_11	Age_12	Age_13	Age_14	Age_15	Age_16	Age_17	Age_18	Age_19	Age_20	Age_21	Age_22	Age_23	Age_24	Age_25	Age_26	Age_27	Age_28	Age_29	Age_30	Age_31	Age_32	Age_33	Age_34	Age_35	Age_36	Age_37	Age_38	Age_39	Age_40	Age_41	Age_42	Age_43	Age_44	Age_45	Age_46	Age_47	Age_48	Age_49	Age_50	Age_51	Age_52	Age_53	Age_54	Age_55	Age_56	Age_57	Age_58	Age_59	Age_60	Age_61	Age_62	Age_63	Age_64	Age_65	Age_66	Age_67	Age_68	Age_69
0	0	0	0	0	0	0.01	0.01	0.02	0.03	0.06	0.09	0.14	0.21	0.31	0.44	0.59	0.77	0.98	1.21	1.44	1.68	1.92	2.14	2.35	2.54	2.71	2.87	3.01	3.14	3.25	3.35	3.44	3.52	3.59	3.66	3.72	3.77	3.81	3.86	3.9	3.93	3.96	3.99	4.02	4.04	4.07	4.09	4.11	4.12	4.14	4.15	4.17	4.18	4.19	4.2	4.21	4.22	4.23	4.24	4.25	4.26	4.26	4.27	4.27	4.28	4.29	4.29	4.29	4.3	#_Age_Maturity1
17 #_First_Mature_Age
2 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
#
#
#_growth_parms																	
#_	LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env_var&link	dev_link	dev_minyr	dev_maxyr	dev_PH	Block	Block_Fxn			
#	Sex:	1	BioPattern:	1	NatMort												
#	Sex:	1	BioPattern:	1	Growth												
	5	100	63	63	1000	6	-3	0	0	0	0	0.5	0	0	#	L_at_Amin_Fem_GP_1	
	50	600	350.3	350.3	1000	0	2	0	0	0	0	0.5	0	0	#	L_at_Amax_Fem_GP_1	
	0.01	0.65	0.064	0.064	0.2	0	2	0	0	0	0	0.5	0	0	#	VonBert_K_Fem_GP_1	
																	
	0.01	0.3	0.0932677	0.0932677	999	6	-2	0	0	0	0	0.5	0	0	#	CV_young_Fem_GP_1	
#	0.01	0.3	0.0898002	0.0898002	0.8			0	0	0	0	0.5	0	0	#	CV_old_Fem_GP_1	
	0.01	0.3	0.15	0.15	0.8	6	6	0	0	0	0	0.5	0	0	#	CV_old_Fem_GP_1	
																	
#	Sex:	1	BioPattern:	1	WtLen												
	-3	3	5.40E-06	5.40E-06	0.8	6	-3	0	0	0	0	0.5	0	0	#	Wtlen_1_Fem_GP_1	
	-3	5	3.14	3.14	0.8	6	-3	0	0	0	0	0.5	0	0	#	Wtlen_2_Fem_GP_1	
#	Sex:	1	BioPattern:	1	Maturity&Fecundity												
	1	300	275.013	275.013	0.8	6	-3	0	0	0	0	0.5	0	0	#	Mat50%_Fem_GP_1	
	-200	3	-0.10755	-0.10755	0.8	6	-3	0	0	0	0	0.5	0	0	#	Mat_slope_Fem_GP_1	
	-3	50	6.68E-06	1.00E-05	0.8	6	-3	0	0	0	0	0.5	0	0	#	Eggs_scalar_Fem_GP_1	
	-3	3	2.34	2.34442	0.8	6	-3	0	0	0	0	0.5	0	0	#	Eggs_exp_len_Fem_GP_1	
#	Sex:	2	BioPattern:	1	NatMort												
																	
#	Sex:	2	BioPattern:	1	Growth												
	5	100	63	63	1000	6	-3	0	0	0	0	0.5	0	0	#	L_at_Amin_Mal_GP_1	
	50	600	241.8	241.8	1000	0	3	0	0	0	0	0.5	0	0	#	L_at_Amax_Mal_GP_1	
	0.01	0.65	0.136	0.136	0.2	0	3	0	0	0	0	0.5	0	0	#	VonBert_K_Mal_GP_1	
																	
	0.01	0.3	0.0973418	0.0973418	999	6	-2	0	0	0	0	0.5	0	0	#	CV_young_Mal_GP_1	
#	0.01	0.3	0.0824247	0.0824247	0.8			0	0	0	0	0.5	0	0	#	CV_old_Mal_GP_1	
	0.01	0.3	0.15	0.15	0.8	6	6	0	0	0	0	0.5	0	0	#	CV_old_Mal_GP_1	
																	
#	Sex:	2	BioPattern:	1	WtLen												
	-3	3	1.25E-05	1.25E-05	0.8	6	-3	0	0	0	0	0.5	0	0	#	Wtlen_1_Mal_GP_1	
	-3	5	2.97	2.97	0.8	6	-3	0	0	0	0	0.5	0	0	#	Wtlen_2_Mal_GP_1	

# Hermaphroditism
#  Recruitment Distribution 
# -4 4 0 1 99 0 -3 0 0 0 0 0.5 0 0 # RecrDist_GP_1
# -4 4 0 1 99 0 -3 0 0 0 0 0.5 0 0 # RecrDist_Area_1
# -4 4 0 1 99 0 -3 0 0 0 0 0.5 0 0 # RecrDist_month_1
#  Cohort growth dev base
 0.1 10 1 1 1 0 -1 0 0 0 0 0 0 0 # CohortGrowDev
#  Movement
#  Platoon StDev Ratio 
#  Age Error from parameters
#  catch multiplier
#  fraction female, by GP
 1e-06 0.999999 0.5 0.5 0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_1
#  M2 parameter for each predator fleet
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
             3            15       6.27918             5            20             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           0.2             1          0.39          0.75          0.05             0         -4          0          0          0          0          0          0          0 # SR_BH_steep
           0.2           1.9          0.42          0.28          1000             6         -4          0          0          0          0          0          0          0 # SR_sigmaR
            -5             5             0             0             1             6         -4          0          0          0          0          0          0          0 # SR_regime
            -5             5             0             0             1             6         -4          0          0          0          0          0          0          0 # SR_autocorr
#_no timevary SR parameters
1 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1990 # first year of main recr_devs; early devs can precede this era
2012 # last year of main recr_devs; forecast devs start in following year
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
#_Yr Input_value
#
#Fishing Mortality info 
0.2 # F ballpark value in units of annual_F
-2010 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope midseason rate; 2=F as parameter; 3=F as hybrid; 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
3 # max F (methods 2-4) or harvest fraction (method 1)
4  # N iterations for tuning in hybrid mode; recommend 3 (faster) to 5 (more precise if many fleets)
#
#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = 1
#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
 0.0001 1.5 0.0162907 -1.60944 0.25 3 1 # InitF_seas_1_flt_11F11_HIS
#
#
#_Q_setup for fleets with cpue or survey data
#_fleet	link	link_info	extra_se	biasadj	float  #  fleetname
   12	1	0	0	0	1	#_CPUE_EU_SPN    
   13	1	0	0	0	1	#_CPUE_EU_POR    
   14	1	0	0	0	1	#_CPUE_JPN_1     
   15	1	0	0	0	1	#_CPUE_JPN_2     
   16	1	0	0	0	1	#_CPUE_CTP       
   17	1	0	0	0	1	#_CPUE_USA       
   18	1	0	0	0	1	#_CPUE_MOR_1     
   19	1	0	0	0	1	#_CPUE_MOR_2     
   20	1	0	0	0	1	#_CPUE_USAlogbook
-9999	0	0	0	0	0	#_terminator     
#_Q_parms(if_any);Qunits_are_ln(q)
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn  #  parm_name
           -25            25      -6.63113             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_EU_SPN(12)
           -25            25      -10.0177             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_EU_POR(13)
           -25            25      -6.47043             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_JPN_1(14)
           -25            25      -6.57325             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_JPN_2(15)
           -25            25      -6.34292             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_CTP(16)
           -25            25      -6.67659             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_USA(17)
           -25            25      -9.85414             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_MOR_1(18)
           -25            25      -11.9452             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_MOR_2(19)
           -25            25      -7.09181             0          0.05             0         -1          0          0          0          0          0          0          0  #  LnQ_base_CPUE_USAlogbook(20)
#_no timevary Q parameters
#
#_size_selex_patterns
#_Pattern	Discard	Male	Special
24	0	0	0	#_1 F01_EU_SPN      
24	0	0	0	#_2 F02_EU_POR      
24	0	4	0	#_3 F03_JPN         
24	0	3	0	#_4 F04_CTP         
24	0	4	0	#_5 F05_USA         
24	0	0	0	#_6 F06_CAN         
15	0	0	2	#_7 F07_MOR         
24	0	4	0	#_8 F08_MEX         
24	0	0	0	#_9 F09_VEN         
15	0	0	1	#_10 F10_OTH        
15	0	0	1	#_11 F11_HIS        
15	0	0	1	#_12 CPUE_EU_SPN    
15	0	0	2	#_13 CPUE_EU_POR    
15	0	0	3	#_14 CPUE_JPN_1     
15	0	0	3	#_15 CPUE_JPN_2     
15	0	0	4	#_16 CPUE_CTP       
15	0	0	5	#_17 CPUE_USA       
15	0	0	7	#_18 CPUE_MOR_1     
15	0	0	7	#_19 CPUE_MOR_2     
15	0	0	5	#_20 CPUE_USAlogbook
#
#_age_selex_patterns
#_Pattern	Discard	Male	Special
11	0	0	0	#_1 F01_EU_SPN      
15	0	0	1	#_2 F02_EU_POR      
15	0	0	1	#_3 F03_JPN         
15	0	0	1	#_4 F04_CTP         
15	0	0	1	#_5 F05_USA         
15	0	0	1	#_6 F06_CAN         
15	0	0	1	#_7 F07_MOR         
15	0	0	1	#_8 F08_MEX         
15	0	0	1	#_9 F09_VEN         
15	0	0	1	#_10 F10_OTH        
15	0	0	1	#_11 F11_HIS        
15	0	0	1	#_12 CPUE_EU_SPN    
15	0	0	1	#_13 CPUE_EU_POR    
15	0	0	1	#_14 CPUE_JPN_1     
15	0	0	1	#_15 CPUE_JPN_2     
15	0	0	1	#_16 CPUE_CTP       
15	0	0	1	#_17 CPUE_USA       
15	0	0	1	#_18 CPUE_MOR_1     
15	0	0	1	#_19 CPUE_MOR_2     
15	0	0	1	#_20 CPUE_USAlogbook
#
#_SizeSelex
#_LO	HI	INIT	PRIOR	PR_SD	PR_type	PHASE	env-var	use_dev	dev_mnyr	dev_mxyr	dev_PH	Block	Blk_Fxn  #  parm_name
62.5	297.5	   127.625	135.54	0.05	1	 2	0	0	0	0	0.5	0	0	#_SizeSel_P_1_F01_EU_SPN(1)   
 -10	    4	  -9.12738	    -6	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_2_F01_EU_SPN(1)   
  -1	    9	   6.27249	   6.7	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_3_F01_EU_SPN(1)   
  -1	    9	   7.89782	  7.25	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_4_F01_EU_SPN(1)   
  -5	    9	        -5	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_5_F01_EU_SPN(1)   
  -5	    9	        -5	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_6_F01_EU_SPN(1)   
62.5	297.5	   143.683	135.54	0.05	1	 2	0	0	0	0	0.5	0	0	#_SizeSel_P_1_F02_EU_POR(2)   
 -10	    4	  -9.18118	    -6	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_2_F02_EU_POR(2)   
  -1	    9	   6.58461	   6.7	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_3_F02_EU_POR(2)   
  -1	    9	   7.19359	  7.25	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_4_F02_EU_POR(2)   
  -5	    9	        -5	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_5_F02_EU_POR(2)   
  -5	    9	        -5	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_6_F02_EU_POR(2)   
62.5	297.5	   158.547	135.54	0.05	1	 2	0	0	0	0	0.5	0	0	#_SizeSel_P_1_F03_JPN(3)      
 -10	    4	  -8.19182	    -6	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_2_F03_JPN(3)      
  -1	    9	   7.40258	   6.7	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_3_F03_JPN(3)      
  -1	    9	   8.07018	  7.25	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_4_F03_JPN(3)      
  -5	    9	        -5	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_5_F03_JPN(3)      
  -5	    9	     -4.96	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_6_F03_JPN(3)      
 -60	   60	  -7.56545	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_1_F03_JPN(3)
 -15	   15	 -0.238247	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_2_F03_JPN(3)
 -15	   15	 -0.640512	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_3_F03_JPN(3)
 -15	   15	         0	     0	0.05	1	-4	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_4_F03_JPN(3)
 0.5	  1.5	  0.797424	     1	0.05	1	 5	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_5_F03_JPN(3)
62.5	297.5	   156.975	135.54	0.05	1	 2	0	0	0	0	0.5	0	0	#_SizeSel_P_1_F04_CTP(4)      
  -6	    4	   -5.2763	    -6	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_2_F04_CTP(4)      
  -1	    9	   6.50448	   6.7	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_3_F04_CTP(4)      
  -1	    9	   7.57077	  7.25	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_4_F04_CTP(4)      
 -10	    9	        -5	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_5_F04_CTP(4)      
 -10	    9	     -4.96	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_6_F04_CTP(4)      
 -60	   60	  -12.0465	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PMalOff_1_F04_CTP(4)
 -15	   15	-0.0902655	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PMalOff_2_F04_CTP(4)
 -15	   15	  0.603408	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PMalOff_3_F04_CTP(4)
 -15	   15	         0	     0	0.05	1	-4	0	0	0	0	  0	0	0	#_SizeSel_PMalOff_4_F04_CTP(4)
 0.5	  1.5	   0.88721	     1	0.05	1	 5	0	0	0	0	  0	0	0	#_SizeSel_PMalOff_5_F04_CTP(4)
62.5	297.5	   180.207	135.54	0.05	1	 2	0	0	0	0	0.5	0	0	#_SizeSel_P_1_F05_USA(5)      
 -10	    4	  -8.25636	    -6	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_2_F05_USA(5)      
  -1	   15	   8.66723	   6.7	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_3_F05_USA(5)      
  -1	    9	   6.71835	  7.25	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_4_F05_USA(5)      
 -10	    9	  -5.57558	    -5	0.05	1	 2	0	0	0	0	0.5	0	0	#_SizeSel_P_5_F05_USA(5)      
 -10	    9	  -1.37675	    -5	0.05	1	 2	0	0	0	0	0.5	0	0	#_SizeSel_P_6_F05_USA(5)      
 -40	   40	  -23.7835	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_1_F05_USA(5)
 -15	   15	 0.0698013	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_2_F05_USA(5)
 -15	   15	  0.767565	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_3_F05_USA(5)
 -15	   15	  -3.20109	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_4_F05_USA(5)
 0.5	  1.5	  0.502963	     1	0.05	1	 5	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_5_F05_USA(5)
62.5	297.5	   137.498	135.54	0.05	1	 2	0	0	0	0	0.5	0	0	#_SizeSel_P_1_F06_CAN(6)      
 -10	    4	  -8.01335	    -6	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_2_F06_CAN(6)      
  -1	    9	   7.40037	   6.7	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_3_F06_CAN(6)      
  -1	    9	   7.66774	  7.25	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_4_F06_CAN(6)      
  -5	    9	        -5	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_5_F06_CAN(6)      
  -5	    9	        -5	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_6_F06_CAN(6)      
62.5	297.5	   189.341	135.54	0.05	1	 2	0	0	0	0	0.5	0	0	#_SizeSel_P_1_F08_MEX(8)      
  -6	   10	   -5.4754	    -6	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_2_F08_MEX(8)      
  -1	    9	   7.91438	   6.7	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_3_F08_MEX(8)      
  -1	    9	   7.20215	  7.25	0.05	1	-3	0	0	0	0	0.5	0	0	#_SizeSel_P_4_F08_MEX(8)      
  -5	    9	        -5	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_5_F08_MEX(8)      
  -5	    9	         8	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_6_F08_MEX(8)      
 -60	   60	   10.9561	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_1_F08_MEX(8)
 -15	   15	  0.391979	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_2_F08_MEX(8)
 -15	   15	 0.0748297	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_3_F08_MEX(8)
 -15	   15	  -9.60965	     0	0.05	1	 4	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_4_F08_MEX(8)
 0.5	  1.5	  0.501095	     1	0.05	1	 5	0	0	0	0	  0	0	0	#_SizeSel_PFemOff_5_F08_MEX(8)
62.5	297.5	   180.534	135.54	0.05	1	 2	0	0	0	0	0.5	0	0	#_SizeSel_P_1_F09_VEN(9)      
  -6	    4	  -5.17963	    -6	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_2_F09_VEN(9)      
  -1	    9	   7.65239	   6.7	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_3_F09_VEN(9)      
  -1	    9	    7.4919	  7.25	0.05	1	 3	0	0	0	0	0.5	0	0	#_SizeSel_P_4_F09_VEN(9)      
  -5	    9	        -5	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_5_F09_VEN(9)      
 -10	    9	     -4.96	    -5	0.05	1	-2	0	0	0	0	0.5	0	0	#_SizeSel_P_6_F09_VEN(9)      
#_AgeSelex
 0	 10	 0	0	25	0	-99	0	0	0	0	0.5	0	0	#_AgeSel_P_1_F01_EU_SPN(1)
10	100	69	0	25	0	-99	0	0	0	0	0.5	0	0	#_AgeSel_P_2_F01_EU_SPN(1)
#_no timevary selex parameters
#
0 #  use 2D_AR1 selectivity(0/1):  experimental feature
#_no 2D_AR1 selex offset used
# Tag loss and Tag reporting parameters go next
0 # TG_custom:  0=no read; 1=read if tags exist
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
#Now
#Dean Alt Values Implemented here					
#					
#_factor  fleet   Value (DC June 5, 2025 Francis+Min)								#value(s) Carmen
      1     12    0.132   																					#0.102 # 0.079  # CPUE_EU_SPN 
      1     13    0																									#0              # CPUE_EU_POR
      1     14    0.163																							#0.163 # 0.148  # CPUE_JPN_1
      1     15    0																									#0     # 0.148  # CPUE_JPN_2
      1     16    0.165																							#0.080 # 0.038  # CPUE_CTP
      1     17    0.022																							#0     #        # CPUE_USA      
      1     18    0.129																							#0.129 # 0.074  # CPUE_MOR_1
      1     19    0.010	#Not Available (used Carmen's)							#0.010 # 0.009 CPUE_MOR_2  
      1     20    0.120																							#0.120 # 0.110  # CPUE_USAlogbook ... used in 2017 assessment
#Stage_2_Weight_table Now 6/10/2025: Joel's run with Sqrt length and no Francis weight applied to CPUE
#factor fleet New_Var_adj hash Old_Var_adj New_Francis   New_MI Francis_mult Francis_lo Francis_hi  MI_mult Type
       4     1    0.401094    #           1    0.401094 1.730717     0.401094   0.286456   0.791409 1.730717  len
       4     2    0.613017    #           1    0.613017 3.331419     0.613017   0.413887   1.564787 3.331419  len
       4     3    0.968522    #           1    0.968522 4.375220     0.968522   0.688251   2.192964 4.375220  len
       4     4    0.369833    #           1    0.369833 1.721730     0.369833   0.251846  11.434558 1.721730  len
       4     5    1.124231    #           1    1.124231 5.470709     1.124231   0.756440   2.056329 5.470709  len
       4     6    0.453668    #           1    0.453668 3.581613     0.453668   0.210394   2.855612 3.581613  len
       4     7    0.553079    #           1    0.553079 0.729034     0.553079   0.335459  19.828819 0.729034  len
       4     8    2.043091    #           1    2.043091 5.463612     2.043091   1.149308   8.257688 5.463612  len
       4     9    4.434686    #           1   13.881049 4.434686    13.881049  13.881049        Inf 4.434686  len
-9999	 0	    0	#_terminator                
#
1 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 9 changes to default Lambdas (default value is 1.0)
#_like_comp	fleet	phase	value	sizefreq_method
#    1	12	1	1	1	#_Surv_CPUE_EU_SPN_Phz1    
#    1	13	1	1	1	#_Surv_CPUE_EU_POR_Phz1    
#    1	14	1	1	1	#_Surv_CPUE_JPN_1_Phz1     
#    1	15	1	1	1	#_Surv_CPUE_JPN_2_Phz1     
#    1	16	1	1	1	#_Surv_CPUE_CTP_Phz1       
#    1	17	1	1	1	#_Surv_CPUE_USA_Phz1       
#    1	18	1	1	1	#_Surv_CPUE_MOR_1_Phz1     
#    1	19	1	1	1	#_Surv_CPUE_MOR_2_Phz1     
#    1	20	1	0	1	#_Surv_CPUE_USAlogbook_Phz1
 1 12 1 1 1
 1 13 1 1 1
 1 14 1 1 1
 1 15 1 1 1
 1 16 1 1 1
 1 17 1 1 1
 1 18 1 1 1
 1 19 1 1 1
 1 20 1 0 1
 4 1 1 1 1
 4 2 1 1 1
 4 3 1 1 1
 4 4 1 1 1
 4 5 1 1 1
 4 6 1 1 1
 4 8 1 1 1
 4 9 1 1 1
 -9999	 0	0	0	0	#_terminator               
#
0 # 0/1 read specs for more stddev reporting
#
999
