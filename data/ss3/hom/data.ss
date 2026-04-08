#V3.30.22.1;_safe;_compile_date:_Jan 30 2024;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.1
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-ost/ss3-source-code

#_Start_time: Fri May 10 15:49:20 2024
#_echo_input_data
#C data file created using the SS_writedat function in the R package r4ss
#C file write time: 2024-04-30 10:33:28.729694
#V3.30.22.1;_safe;_compile_date:_Jan 30 2024;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.1
1982 #_StartYr
2024 #_EndYr
1 #_Nseas
 12 #_months/season
2 #_Nsubseasons (even number, minimum is 2)
1 #_spawn_month
1 #_Nsexes: 1, 2, -1  (use -1 for 1 sex setup with SSB multiplied by female_frac parameter)
15 #_Nages=accumulator age, first age is always age 0
1 #_Nareas
5 #_Nfleets (including surveys)
#_fleet_type: 1=catch fleet; 2=bycatch only fleet; 3=survey; 4=predator(M2) 
#_sample_timing: -1 for fishing fleet to use season-long catch-at-age for observations, or 1 to use observation month;  (always 1 for surveys)
#_fleet_area:  area the fleet/survey operates in 
#_units of catch:  1=bio; 2=num (ignored for surveys; their units read later)
#_catch_mult: 0=no; 1=yes
#_rows are fleets
#_fleet_type fishery_timing area catch_units need_catch_mult fleetname
 1 -1 1 1 0 Commercial  # 1
 3 1 1 2 0 IBTS  # 2
 3 1 1 2 0 MEGS  # 3
 3 1 1 1 0 CPUE  # 4
 3 1 1 1 0 Acoustics  # 5
#Bycatch_fleet_input_goes_next
#a:  fleet index
#b:  1=include dead bycatch in total dead catch for F0.1 and MSY optimizations and forecast ABC; 2=omit from total catch for these purposes (but still include the mortality)
#c:  1=Fmult scales with other fleets; 2=bycatch F constant at input value; 3=bycatch F from range of years
#d:  F or first year of range
#e:  last year of range
#f:  not used
# a   b   c   d   e   f 
#_Catch data: yr, seas, fleet, catch, catch_se
#_catch_se:  standard error of log(catch)
#_NOTE:  catch data is ignored for survey fleets
-999 1 1 82794 0.2
1982 1 1 52976 0.2
1983 1 1 89606 0.2
1984 1 1 83473 0.2
1985 1 1 98541 0.2
1986 1 1 140530 0.2
1987 1 1 165488 0.2
1988 1 1 197224 0.2
1989 1 1 270511 0.2
1990 1 1 346607 0.2
1991 1 1 279328 0.2
1992 1 1 360173 0.2
1993 1 1 405918 0.2
1994 1 1 396819 0.2
1995 1 1 525381 0.2
1996 1 1 413698 0.2
1997 1 1 472470 0.2
1998 1 1 299630 0.2
1999 1 1 262085 0.2
2000 1 1 187998 0.2
2001 1 1 204706 0.2
2002 1 1 177903 0.2
2003 1 1 177231 0.1
2004 1 1 154714 0.1
2005 1 1 176226 0.1
2006 1 1 168295 0.1
2007 1 1 131773 0.1
2008 1 1 164972 0.1
2009 1 1 214643 0.1
2010 1 1 244651 0.1
2011 1 1 201819 0.1
2012 1 1 180814 0.1
2013 1 1 169764 0.1
2014 1 1 132750 0.1
2015 1 1 98865 0.1
2016 1 1 106375 0.1
2017 1 1 87045 0.1
2018 1 1 106657 0.1
2019 1 1 128145 0.1
2020 1 1 79294 0.1
2021 1 1 86605 0.1
2022 1 1 73904 0.1
2023	1	1	12845	0.1
2024	1	1	12402	0.1

-9999	-9999	-9999	-9999	-9999

#
#_CPUE_and_surveyabundance_and_index_observations
#_Units: 0=numbers; 1=biomass; 2=F; 30=spawnbio; 31=exp(recdev); 36=recdev; 32=spawnbio*recdev; 33=recruitment; 34=depletion(&see Qsetup); 35=parm_dev(&see Qsetup)
#_Errtype:  -1=normal; 0=lognormal; 1=lognormal with bias correction; >1=df for T-dist
#_SD_Report: 0=not; 1=include survey expected value with se
#_note that link functions are specified in Q_setup section of control file
#_Fleet Units Errtype SD_Report
1 1 0 0 # Commercial
2 33 0 0 # IBTS
3 30 0 0 # MEGS
4 1 0 0 # CPUE
5 1 0 0 # Acoustics
#_yr month fleet obs stderr
2003	11.92	2	1360342.478	0.244832089
2004	11.92	2	3541585.974	0.328675533
2005	11.92	2	3316029.627	0.263921216
2006	11.92	2	1971045.854	0.222499769
2007	11.92	2	3790228.031	0.246036389
2008	11.92	2	9377675.694	0.273424479
2009	11.92	2	2450506.444	0.249290403
2010	11.92	2	1138417.486	0.264412273
2011	11.92	2	501153.2679	0.294975378
2012	11.92	2	8159425.537	0.25199771
2013	11.92	2	3374730.128	0.291481679
2014	11.92	2	6365229.875	0.231318659
2015	11.92	2	7223562.172	0.208979941
2016	11.92	2	6084771.263	0.202930313
2017	11.92	2	9293181.131	0.275929418
2018	11.92	2	5881898.952	0.215509744
2019	11.92	2	4972250.982	0.317138458
2020	11.92	2	2085038.134	0.255285349
2021	11.92	2	1647995.918	0.183389362
2022	11.92	2	7993004.481	0.233773079
2023	11.92	2	2572140.055	0.195782518
2024	11.92	2	4064142.61	0.201187138


1992 4.96 3 2.09e+12 0.139321 #_ MEGS
1995 4.96 3 1.34e+12 0.675207 #_ MEGS
1998 4.96 3 1.24e+12 0.438112 #_ MEGS
2001 4.96 3 8.64e+11 0.312233 #_ MEGS
2004 4.96 3 8.84e+11 0.312233 #_ MEGS
2007 4.96 3 1.49e+12 0.570322 #_ MEGS
2010 4.96 3 1.03e+12 0.367261 #_ MEGS
2013 4.96 3 3.66e+11 0.330745 #_ MEGS
2016 4.96 3 3.31e+11 0.34909 #_ MEGS
2019 4.96 3 1.78e+11 0.546531 #_ MEGS
2022 4.96 3 5.52e+11 0.514087 #_ MEGS
2017 7 4 416.964 0.125343 #_ CPUE
2018 7 4 494.835 0.0958623 #_ CPUE
2019 7 4 472.332 0.0886356 #_ CPUE
2020 7 4 461.286 0.11919 #_ CPUE
2021 7 4 336.525 0.123507 #_ CPUE
2022 7 4 329.228 0.134396 #_ CPUE
2011	5	5	108599	0.250229428 #Acoustics
2012	5	5	143034	0.26955786	#Acoustics
2013	5	5	169174	0.218441025	#Acoustics
2014	5	5	167623	0.209344031	#Acoustics
2015	5	5	218244	0.165133939	#Acoustics
2016	5	5	221078	0.286884995	#Acoustics
2017	5	5	303879	0.249968559	#Acoustics
2018	5	5	195930	0.246648086	#Acoustics
2019	5	5	144202	0.272739769	#Acoustics
2021	5	5	110821	0.273767355	#Acoustics
2022	5	5	106457	0.228328158	#Acoustics
2023	5	5	300010	0.246351324	#Acoustics
2024	5	5	135057	0.241130454	#Acoustics

-9999 1 1 1 1 # terminator for survey observations 
#
0 #_N_fleets_with_discard
#_discard_units (1=same_as_catchunits(bio/num); 2=fraction; 3=numbers)
#_discard_errtype:  >0 for DF of T-dist(read CV below); 0 for normal with CV; -1 for normal with se; -2 for lognormal; -3 for trunc normal with CV
# note: only enter units and errtype for fleets with discard 
# note: discard data is the total for an entire season, so input of month here must be to a month in that season
#_Fleet units errtype
# -9999 0 0 0.0 0.0 # terminator for discard data 
#
0 #_use meanbodysize_data (0/1)
#_COND_0 #_DF_for_meanbodysize_T-distribution_like
# note:  type=1 for mean length; type=2 for mean body weight 
#_yr month fleet part type obs stderr
#  -9999 0 0 0 0 0 0 # terminator for mean body size data 
#
# set up population length bin structure (note - irrelevant if not using size data and using empirical wtatage
2 # length bin method: 1=use databins; 2=generate from binwidth,min,max below; 3=read vector
1 # binwidth for population size comp 
1 # minimum size in the population (lower edge of first bin and size at age 0.00) 
51 # maximum size in the population (lower edge of last bin) 
1 # use length composition data (0/1/2) where 2 invokes new comp_control format
#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level.
#_addtocomp:  after accumulation of tails; this value added to all bins
#_combM+F: males and females treated as combined sex below this bin number 
#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation
#_Comp_Error:  0=multinomial, 1=dirichlet using Theta*n, 2=dirichlet using beta, 3=MV_Tweedie
#_ParmSelect:  consecutive index for dirichlet or MV_Tweedie
#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001
#
#_Using old format for composition controls
#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize
-1 0.001 0 0 0 0 1 #_fleet:1_Commercial
-1 0.001 0 0 0 0 1 #_fleet:2_IBTS
-1 0.001 0 0 0 0 1 #_fleet:3_MEGS
-1 0.001 0 0 0 0 1 #_fleet:4_CPUE
-1 0.001 0 0 0 0 1 #_fleet:5_Acoustics
# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution
# partition codes:  (0=combined; 1=discard; 2=retained
47 #_N_LengthBins; then enter lower edge of each length bin
 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51
#_yr month fleet sex part Nsamp datavector(female-male)
-9999 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
#
16 #_N_age_bins
 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
1 #_N_ageerror_definitions
-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001
#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level.
#_addtocomp:  after accumulation of tails; this value added to all bins
#_combM+F: males and females treated as combined sex below this bin number 
#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation
#_Comp_Error:  0=multinomial, 1=dirichlet using Theta*n, 2=dirichlet using beta, 3=MV_Tweedie
#_ParmSelect:  consecutive index for dirichlet or MV_Tweedie
#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001
#
#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize
-1 0.001 0 0 0 0 1 #_fleet:1_Commercial
-1 0.001 0 0 0 0 1 #_fleet:2_IBTS
-1 0.001 0 0 0 0 1 #_fleet:3_MEGS
-1 0.001 0 0 0 0 1 #_fleet:4_CPUE
-1 0.001 0 0 0 0 1 #_fleet:5_Acoustics
3 #_Lbin_method_for_Age_Data: 1=poplenbins; 2=datalenbins; 3=lengths
# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution
# partition codes:  (0=combined; 1=discard; 2=retained
#_yr month fleet sex part ageerr Lbin_lo Lbin_hi Nsamp datavector(female-male)
 1982 7 1 0 0 1 -1 -1 6.8 0 3713 21072 134743 11515 13197 11741 8848 1651 414 1651 6582 18483 28679 19432 8210
 1983 7 1 0 0 1 -1 -1 6.8 0 7903 2269 32900 53508 15345 44539 52673 17923 3291 5505 3386 17017 23902 38352 46482
 1984 7 1 0 0 1 -1 -1 6.8 0 0 241360 4439 36294 149798 22350 38244 34020 14756 4101 0 639 1757 5080 50895
 1985 7 1 0 0 1 -1 -1 6.8 0 1633 4901 602992 4463 41822 100376 12644 16172 6200 9224 339 850 3723 1250 34814
 1986 7 1 0 0 1 -1 -1 6.8 0 0 0 1548 676208 8727 65147 109747 25712 21179 15271 3116 1031 855 292 51531
 1987 7 1 0 0 1 -1 -1 6.8 0 99 493 0 2950 891660 2061 41564 90814 11740 9549 19363 8917 1398 200 32899
 1988 7 1 0 0 1 -1 -1 6.8 876 27369 6112 2099 4402 18968 941725 12115 39913 67869 9739 16326 17304 5179 4892 32396
 1989 7 1 0 0 1 -1 -1 6.8 0 0 0 20766 18282 5308 14500 1.27673e+06 12046 59357 83125 13905 24196 13731 8987 18132
 1990 7 1 0 0 1 -1 -1 6.8 0 20406 45036 138929 61442 33298 10549 20607 1.38485e+06 37011 70512 101945 14987 34687 18077 56598
 1991 7 1 0 0 1 -1 -1 6.8 20176 24021 56066 17977 159643 97147 49515 21713 17148 1.02842e+06 20309 12161 43665 8141 7053 25553
 1992 7 1 0 0 1 -1 -1 4.5 14888 229694 36332 80550 56280 255874 126816 48711 18992 23447 1.09978e+06 13409 23002 65250 11967 33246
 1993 7 1 0 0 1 -1 -1 7.5 46 131108 109807 16738 62342 105760 325674 141148 68418 55289 30689 1.07561e+06 11373 24018 68137 32140
 1994 7 1 0 0 1 -1 -1 6.1 3686 60759 911713 115729 53056 44520 38769 221863 106390 40988 43083 22380 918512 10143 14599 36635
 1995 7 1 0 0 1 -1 -1 4.8 2702 233030 646753 526053 269658 74592 114649 36076 228687 113304 96624 59874 63187 951901 39278 148243
 1996 7 1 0 0 1 -1 -1 6.3 10729 19774 659641 864188 189273 87562 52050 55914 53835 57361 56962 91690 67114 56012 349086 165611
 1997 7 1 0 0 1 -1 -1 7.5 4860 110451 471611 732959 408648 256563 141168 143166 143769 123044 133166 96058 176730 98196 51674 283110
 1998 7 1 0 0 1 -1 -1 6.2 744 91505 184443 488661 359590 217571 153136 119309 77494 67072 50108 58791 30535 65839 57583 141362
 1999 7 1 0 0 1 -1 -1 5.1 14822 97561 83715 176919 265820 254516 212217 187196 147271 77622 35582 22909 34440 29743 41830 122176
 2000 7 1 0 0 1 -1 -1 5.6 565 66210 130897 64801 119297 232346 202175 165745 109218 54365 14594 17509 18642 18585 10031 73174
 2001 7 1 0 0 1 -1 -1 6.4 60561 93125 204360 166641 113659 120410 141419 259974 218002 110319 38576 22749 17102 14092 18857 64868
 2002 7 1 0 0 1 -1 -1 7.2 14044 505717 122603 158114 123258 66640 68890 95052 132743 87285 46167 29692 25333 11305 12753 72682
 2003 7 1 0 0 1 -1 -1 7.1 15653 118891 412390 122429 129125 86345 45874 42212 75345 110250 51750 24892 21874 7743 3563 37962
 2004 7 1 0 0 1 -1 -1 5.4 13646 189937 117412 417137 78784 79389 41102 26407 21503 38291 55542 39785 13840 6392 2464 24166
 2005 7 1 0 0 1 -1 -1 7.1 7124 64787 105338 180392 444866 78109 61073 51372 37025 37642 30220 66902 22151 11333 5430 29358
 2006 7 1 0 0 1 -1 -1 6.9 5909 70565 48901 70056 83936 403078 95327 51277 42753 25839 21593 28696 45627 23608 11806 25046
 2007 7 1 0 0 1 -1 -1 5.3 26042 75236 107329 60895 62161 54098 237861 62858 31595 25971 16924 14046 19897 27827 11251 27546
 2008 7 1 0 0 1 -1 -1 7 24401 197612 56610 51540 83664 92172 68285 211885 57529 46956 37227 29846 26152 19206 19270 31763
 2009 7 1 0 0 1 -1 -1 7.3 45741 75845 58907 23389 37225 72283 93600 81473 279216 67478 64417 38438 21127 20038 14477 56001
 2010 7 1 0 0 1 -1 -1 6.7 53949 164238 132583 71626 32567 40421 79973 122571 127556 243023 102405 73811 51708 27384 17603 33936
 2011 7 1 0 0 1 -1 -1 6.9 99205 63325 100022 83953 51536 54722 52629 72008 83172 74547 187163 59869 40478 23632 12532 46235
 2012 7 1 0 0 1 -1 -1 7 119365 109396 46951 86915 128949 88093 48706 53443 56451 48418 72691 91342 38800 21507 17934 42799
 2013 7 1 0 0 1 -1 -1 7.8 106566 269959 24627 47386 86464 178859 96917 48689 33072 36432 40704 28466 53838 18489 12889 44497
 2014 7 1 0 0 1 -1 -1 8.1 28792 22426 96257 31727 25582 57877 105438 62729 43859 35208 48267 25480 20566 33634 13216 31524
 2015 7 1 0 0 1 -1 -1 6.8 82594 59338 26565 47713 30755 32649 47087 86432 37104 27576 34483 19038 13257 10824 22083 19934
 2016 7 1 0 0 1 -1 -1 8 75948 49902 92430 38305 35879 24402 23433 28218 56476 31523 39121 27739 23035 16228 17038 46852
 2017 7 1 0 0 1 -1 -1 7.8 126159 89377 36019 93103 43821 42745 26913 20160 32185 44712 25796 15353 10322 10474 8900 26927
 2018 7 1 0 0 1 -1 -1 7.8 32064 174851 57548 69891 200603 49638 41537 25315 15379 23532 45179 20475 15820 7164 5792 26691
 2019 7 1 0 0 1 -1 -1 7.4 12433 57051 83886 84081 74272 192866 51329 40999 21590 18947 27637 30887 15468 8362 6685 27177
 2020 7 1 0 0 1 -1 -1 6.7 20158 17995 29034 31684 19788 35153 130104 23964 21110 12697 11049 9171 14849 3219 1064 12232
 2021 7 1 0 0 1 -1 -1 7.7 2395 21887 44799 57408 74844 41276 57207 88014 17962 22663 19001 11485 6916 6232 3454 9603
 2022 7 1 0 0 1 -1 -1 7.9 22185 50526 23413 22279 36599 62291 27313 23843 68650 13186 16848 9991 5681 5584 7589 9445
2023	7	1	0	0	1	-1	-1	6.7	712	9998	2244	868	626	1617	5478	2017	4995	8935	3545	2992	1378	1074	2230	5161
2024	7	1	0	0	1	-1	-1	6.9	4013	13687	7242	1085	760	856	2642	4127	2454	2692	10059	3525	1852	1664	1323	4307

-9999  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
0 #_Use_MeanSize-at-Age_obs (0/1)
#
0 #_N_environ_variables
# -2 in yr will subtract mean for that env_var; -1 will subtract mean and divide by stddev (e.g. Z-score)
#Yr Variable Value
#
# Sizefreq data. Defined by method because a fleet can use multiple methods
0 # N sizefreq methods to read (or -1 for expanded options)
# 
0 # do tags (0/1/2); where 2 allows entry of TG_min_recap
#
0 #    morphcomp data(0/1) 
#  Nobs, Nmorphs, mincomp
#  yr, seas, type, partition, Nsamp, datavector_by_Nmorphs
#
0  #  Do dataread for selectivity priors(0/1)
# Yr, Seas, Fleet,  Age/Size,  Bin,  selex_prior,  prior_sd
# feature not yet implemented
#
999

