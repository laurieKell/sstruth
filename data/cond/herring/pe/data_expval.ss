#V3.30.23.2;_safe;_compile_date:_Apr 17 2025;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:_https://groups.google.com/g/ss3-forum_and_NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:_https://nmfs-ost.github.io/ss3-website/
#_Source_code_at:_https://github.com/nmfs-ost/ss3-source-code

#_Start_time: Tue Apr  7 09:31:44 2026
#_expected_values
#C data file for Herring SD 30-31
#C file created using an r4ss function
#C file write time: 2026-04-07  09:30:17
#V3.30.23.2;_safe;_compile_date:_Apr 17 2025;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
1903 #_StartYr
2023 #_EndYr
1 #_Nseas
 12 #_months/season
2 #_Nsubseasons (even number, minimum is 2)
1 #_spawn_month
1 #_Nsexes: 1, 2, -1  (use -1 for 1 sex setup with SSB multiplied by female_frac parameter)
8 #_Nages=accumulator age, first age is always age 0
1 #_Nareas
2 #_Nfleets (including surveys)
#_fleet_type: 1=catch fleet; 2=bycatch only fleet; 3=survey; 4=predator(M2) 
#_sample_timing: -1 for fishing fleet to use season-long catch-at-age for observations, or 1 to use observation month;  (always 1 for surveys)
#_fleet_area:  area the fleet/survey operates in 
#_units of catch:  1=bio; 2=num (ignored for surveys; their units read later)
#_catch_mult: 0=no; 1=yes
#_rows are fleets
#_fleet_type fishery_timing area catch_units need_catch_mult fleetname
 1 -1 1 1 0 Fleet  # 1
 3 1 1 2 0 Acoustics  # 2
#Bycatch_fleet_input_goes_next
#a:  fleet index
#b:  1=include dead bycatch in total dead catch for F0.1 and MSY optimizations and forecast ABC; 2=omit from total catch for these purposes (but still include the mortality)
#c:  1=Fmult scales with other fleets; 2=bycatch F constant at input value; 3=bycatch F from range of years
#d:  F or first year of range
#e:  last year of range
#f:  not used
# a   b   c   d   e   f 
#_Catch data: year, seas, fleet, catch, catch_se
#_catch_se:  standard error of log(catch)
#_NOTE:  catch data is ignored for survey fleets
-999 1 1 26345.9 0.2
1903 1 1 26861.2 0.1
1904 1 1 23756.9 0.1
1905 1 1 31428.2 0.1
1906 1 1 39063.7 0.1
1907 1 1 52915.6 0.1
1908 1 1 58128.1 0.1
1909 1 1 50734.6 0.1
1910 1 1 45335.9 0.1
1911 1 1 39977.9 0.1
1912 1 1 37759 0.1
1913 1 1 39350.4 0.1
1914 1 1 35386.8 0.1
1915 1 1 35531.2 0.1
1916 1 1 41157.7 0.1
1917 1 1 48200.2 0.1
1918 1 1 47140.6 0.1
1919 1 1 42794.1 0.1
1920 1 1 41606.3 0.1
1921 1 1 40267.3 0.1
1922 1 1 39568.1 0.1
1923 1 1 40985.8 0.1
1924 1 1 40804 0.1
1925 1 1 39387.4 0.1
1926 1 1 39793.4 0.1
1927 1 1 41059.7 0.1
1928 1 1 44429.3 0.1
1929 1 1 46970 0.1
1930 1 1 45818.5 0.1
1931 1 1 44346.5 0.1
1932 1 1 47442.4 0.1
1933 1 1 51251.6 0.1
1934 1 1 56688.1 0.1
1935 1 1 61901.5 0.1
1936 1 1 66848.6 0.1
1937 1 1 65956.1 0.1
1938 1 1 62249.1 0.1
1939 1 1 49888 0.1
1940 1 1 45636.4 0.1
1941 1 1 55966.9 0.1
1942 1 1 66673.9 0.1
1943 1 1 71115.9 0.1
1944 1 1 62827.8 0.1
1945 1 1 61175.2 0.1
1946 1 1 48460.5 0.1
1947 1 1 40076.5 0.1
1948 1 1 43668.6 0.1
1949 1 1 58675.6 0.1
1950 1 1 64668.6 0.1
1951 1 1 57711.1 0.1
1952 1 1 58312.6 0.1
1953 1 1 79457.7 0.1
1954 1 1 96631.4 0.1
1955 1 1 164196 0.1
1956 1 1 177095 0.1
1957 1 1 160947 0.1
1958 1 1 161433 0.1
1959 1 1 166257 0.1
1960 1 1 159004 0.1
1961 1 1 161853 0.1
1962 1 1 169860 0.1
1963 1 1 192604 0.1
1964 1 1 185791 0.1
1965 1 1 191943 0.1
1966 1 1 216528 0.1
1967 1 1 268067 0.1
1968 1 1 306627 0.1
1969 1 1 282516 0.1
1970 1 1 293579 0.1
1971 1 1 304634 0.1
1972 1 1 288269 0.1
1973 1 1 344641 0.1
1974 1 1 368810 0.05
1975 1 1 345316 0.05
1976 1 1 309968 0.05
1977 1 1 301632 0.05
1978 1 1 281229 0.05
1979 1 1 272359 0.05
1980 1 1 274720 0.05
1981 1 1 285713 0.05
1982 1 1 282173 0.05
1983 1 1 297618 0.05
1984 1 1 281815 0.05
1985 1 1 271637 0.05
1986 1 1 248580 0.05
1987 1 1 255911 0.05
1988 1 1 268076 0.05
1989 1 1 267278 0.05
1990 1 1 229752 0.05
1991 1 1 204564 0.05
1992 1 1 198645 0.05
1993 1 1 211628 0.05
1994 1 1 212257 0.05
1995 1 1 186827 0.05
1996 1 1 167194 0.05
1997 1 1 163934 0.05
1998 1 1 178460 0.05
1999 1 1 160336 0.05
2000 1 1 162268 0.05
2001 1 1 138738 0.05
2002 1 1 125327 0.05
2003 1 1 111583 0.05
2004 1 1 96714.1 0.05
2005 1 1 94351.8 0.05
2006 1 1 108256 0.05
2007 1 1 116335 0.05
2008 1 1 123971 0.05
2009 1 1 130825 0.05
2010 1 1 132609 0.05
2011 1 1 119436 0.05
2012 1 1 103717 0.05
2013 1 1 105730 0.05
2014 1 1 131206 0.05
2015 1 1 169076 0.05
2016 1 1 190781 0.05
2017 1 1 205453 0.05
2018 1 1 226402 0.05
2019 1 1 200029 0.05
2020 1 1 167010 0.05
2021 1 1 124193 0.05
2022 1 1 92066.5 0.05
2023 1 1 96824 0.05
-9999 0 0 0 0
#
#_CPUE_and_surveyabundance_and_index_observations
#_units: 0=numbers; 1=biomass; 2=F; 30=spawnbio; 31=exp(recdev); 36=recdev; 32=spawnbio*recdev; 33=recruitment; 34=depletion(&see Qsetup); 35=parm_dev(&see Qsetup)
#_errtype:  -1=normal; 0=lognormal; 1=lognormal with bias correction; >1=df for T-dist
#_SD_report: 0=not; 1=include survey expected value with se
#_note that link functions are specified in Q_setup section of control file
#_dataunits = 36 and 35 should use Q_type 5 to provide offset parameter
#_fleet units errtype SD_report
1 1 0 0 # Fleet
2 0 0 0 # Acoustics
#_year month index obs err
2000 10 2 45620.1 0.1309 #_orig_obs: 44870.9 Acoustics
2006 10 2 58842.2 0.1309 #_orig_obs: 58449.9 Acoustics
2007 10 2 57332.4 0.1238 #_orig_obs: 60533.5 Acoustics
2009 10 2 64122.5 0.1141 #_orig_obs: 62750.6 Acoustics
2010 10 2 61121.7 0.089 #_orig_obs: 61062.6 Acoustics
2011 10 2 52155.6 0.1309 #_orig_obs: 51661.2 Acoustics
2012 10 2 57372 0.1377 #_orig_obs: 55432.4 Acoustics
2013 10 2 61869.1 0.1041 #_orig_obs: 61951.5 Acoustics
2014 10 2 62128.3 0.1019 #_orig_obs: 64891.5 Acoustics
2015 10 2 84881.5 0.1309 #_orig_obs: 86392.7 Acoustics
2016 10 2 77182.6 0.1727 #_orig_obs: 77711.6 Acoustics
2017 10 2 73666.2 0.121 #_orig_obs: 74052.7 Acoustics
2018 10 2 63761.3 0.147 #_orig_obs: 60486.7 Acoustics
2019 10 2 54087.7 0.1523 #_orig_obs: 56145.9 Acoustics
2020 10 2 53807.5 0.1473 #_orig_obs: 51079.4 Acoustics
2021 10 2 49506.8 0.1056 #_orig_obs: 49330.6 Acoustics
2022 10 2 50615.3 0.1482 #_orig_obs: 52148 Acoustics
2023 10 2 66179 0.1618 #_orig_obs: 63173.1 Acoustics
-9999 1 1 1 1 # terminator for survey observations 
#
0 #_N_fleets_with_discard
#_discard_units (1=same_as_catchunits(bio/num); 2=fraction; 3=numbers)
#_discard_errtype:  >0 for DF of T-dist(read CV below); 0 for normal with CV; -1 for normal with se; -2 for lognormal; -3 for trunc normal with CV
# note: only enter units and errtype for fleets with discard 
# note: discard data is the total for an entire season, so input of month here must be to a month in that season
#_fleet units errtype
# -9999 0 0 0.0 0.0 # terminator for discard data 
#
0 #_use meanbodysize_data (0/1)
#_COND_0 #_DF_for_meanbodysize_T-distribution_like
# note:  type=1 for mean length; type=2 for mean body weight 
#_year month fleet part type obs stderr
#  -9999 0 0 0 0 0 0 # terminator for mean body size data 
#
# set up population length bin structure (note - irrelevant if not using size data and using empirical wtatage
2 # length bin method: 1=use databins; 2=generate from binwidth,min,max below; 3=read vector
2 # binwidth for population size comp 
2 # minimum size in the population (lower edge of first bin and size at age 0.00) 
50 # maximum size in the population (lower edge of last bin) 
1 # use length composition data (0/1/2) where 2 invokes new comp_comtrol format
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
-1 1e-07 0 0 0 0 0.01 #_fleet:1_Fleet
-1 1e-07 0 0 0 0 0.01 #_fleet:2_Acoustics
# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sex*length distribution
# partition codes:  (0=combined; 1=discard; 2=retained
2 #_N_LengthBins
 5 50
#_year month fleet sex part Nsamp datavector(female-male)
-9999 0 0 0 0 0 0 0 
#
8 #_N_age_bins
 1 2 3 4 5 6 7 8
1 #_N_ageerror_definitions
 0.5 1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5
 0.24 0.24 0.26 0.27 0.27 0.53 0.52 0.47 0.84
#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level.
#_addtocomp:  after accumulation of tails; this value added to all bins
#_combM+F: males and females treated as combined sex below this bin number 
#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation
#_Comp_Error:  0=multinomial, 1=dirichlet using Theta*n, 2=dirichlet using beta, 3=MV_Tweedie
#_ParmSelect:  parm number for dirichlet or MV_Tweedie
#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001
#
#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize
-1 0.0001 0 0 1 1 0.01 #_fleet:1_Fleet
-1 0.0001 0 0 1 2 0.01 #_fleet:2_Acoustics
1 #_Lbin_method_for_Age_Data: 1=poplenbins; 2=datalenbins; 3=lengths
# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sex*length distribution
# partition codes:  (0=combined; 1=discard; 2=retained
#_year month fleet sex part ageerr Lbin_lo Lbin_hi Nsamp datavector(female-male)
1974  7 1  0 0 1 -1 -1 105  15.4822 20.5542 15.658 17.0067 8.3558 7.02614 8.07204 12.8449
1975  7 1  0 0 1 -1 -1 105  13.7783 21.604 20.4631 13.8378 11.7536 7.55144 6.46868 9.54307
1976  7 1  0 0 1 -1 -1 105  23.391 17.7553 19.5648 15.2414 8.62237 8.00974 5.66901 6.74634
1977  7 1  0 0 1 -1 -1 105  14.999 30.577 16.6024 15.1497 9.85506 6.75275 5.67682 5.38728
1978  7 1  0 0 1 -1 -1 105  15.9818 19.358 28.3583 13.4906 10.0175 7.69685 4.99338 5.10344
1979  7 1  0 0 1 -1 -1 105  12.1696 20.5806 19.7738 23.0912 9.77187 8.18785 6.15928 5.26584
1980  7 1  0 0 1 -1 -1 105  20.4765 12.9264 18.8764 16.8724 15.3867 8.9429 6.0252 5.49359
1981  7 1  0 0 1 -1 -1 105  31.3334 19.6958 10.3468 13.2912 9.93956 9.72165 5.72025 4.95128
1982  7 1  0 0 1 -1 -1 105  22.6811 31.7795 16.2141 8.17126 8.20354 6.9633 6.29435 4.69283
1983  7 1  0 0 1 -1 -1 105  18.1625 24.3888 28.6298 12.1111 5.3852 5.83985 5.20182 5.28099
1984  7 1  0 0 1 -1 -1 105  24.9824 19.7466 19.7442 19.8835 7.47031 4.4237 4.20552 4.54378
1985  7 1  0 0 1 -1 -1 105  20.4846 27.9565 16.3 14.8088 12.2249 6.47378 3.11806 3.63332
1986  7 1  0 0 1 -1 -1 105  10.3975 27.5813 26.3278 13.7286 10.1128 9.11913 4.56411 3.16888
1987  7 1  0 0 1 -1 -1 105  22.513 13.7755 24.8753 18.9573 8.6972 7.06674 5.71472 3.40029
1988  7 1  0 0 1 -1 -1 105  8.71793 31.0444 14.2364 20.777 13.0693 7.77576 5.02155 4.35764
1989  7 1  0 0 1 -1 -1 105  15.0947 12.4768 30.1604 13.3812 14.0023 10.2237 5.35486 4.30599
1990  7 1  0 0 1 -1 -1 105  20.422 22.3208 12.45 22.0234 8.41259 8.87924 6.35893 4.13299
1991  7 1  0 0 1 -1 -1 105  14.1527 28.8414 21.1889 11.1482 13.2617 7.02094 5.25499 4.13113
1992  7 1  0 0 1 -1 -1 105  19.2416 20.5494 27.2209 15.4752 6.64174 7.818 4.28649 3.76675
1993  7 1  0 0 1 -1 -1 105  15.4496 27.3738 19.3186 19.9806 9.62958 5.32838 4.70953 3.20985
1994  7 1  0 0 1 -1 -1 105  11.7774 22.7905 26.6827 16.1967 12.8786 7.81662 3.49734 3.36016
1995  7 1  0 0 1 -1 -1 105  17.082 17.8878 22.4521 20.665 10.3807 8.78873 4.84676 2.89695
1996  7 1  0 0 1 -1 -1 105  15.4132 25.4536 17.3577 17.7419 12.8554 7.8808 5.13345 3.16398
1997  7 1  0 0 1 -1 -1 105  9.31556 24.8579 26.4955 14.9932 11.5878 9.20641 4.94949 3.59411
1998  7 1  0 0 1 -1 -1 105  16.332 15.3684 25.6365 21.0422 9.60956 7.86145 5.59033 3.55961
1999  7 1  0 0 1 -1 -1 105  9.23535 27.5005 16.4264 21.4577 13.8227 7.87638 4.87445 3.80651
2000  7 1  0 0 1 -1 -1 105  23.8366 13.8417 25.6324 13.1834 12.24 8.82075 4.27874 3.16642
2001  7 1  0 0 1 -1 -1 105  15.4023 35.2433 13.6236 18.2891 7.69149 7.14765 4.79091 2.81154
2002  7 1  0 0 1 -1 -1 105  16.79 21.1124 32.2603 11.31 10.7769 5.9183 3.96813 2.86407
2003  7 1  0 0 1 -1 -1 105  31.456 20.4443 16.884 19.2696 5.86719 5.67955 3.03404 2.36527
2004  7 1  0 0 1 -1 -1 105  14.5876 38.1351 17.7482 12.6947 11.2836 5.24794 3.23661 2.06631
2005  7 1  0 0 1 -1 -1 105  9.01257 20.9038 37.0268 14.738 8.74112 8.38248 3.62863 2.56662
2006  7 1  0 0 1 -1 -1 105  16.007 13.3583 20.4657 28.5157 10.4179 7.28244 5.89445 3.05857
2007  7 1  0 0 1 -1 -1 105  12.6821 22.1169 13.1221 18.2208 19.2645 10.1829 5.11462 4.29608
2008  7 1  0 0 1 -1 -1 105  23.6729 16.5875 19.9942 10.6863 11.1966 12.3549 6.38936 4.11815
2009  7 1  0 0 1 -1 -1 92  13.3425 27.7478 14.0408 13.078 6.06825 6.56803 6.98093 4.17367
2010  7 1  0 0 1 -1 -1 118  13.6964 23.2202 34.4284 15.397 11.3854 6.99505 6.214 6.66361
2011  7 1  0 0 1 -1 -1 105  8.14731 18.4842 21.9503 26.1288 10.4144 8.60947 5.37453 5.89097
2012  7 1  0 0 1 -1 -1 116  21.7713 12.0183 18.954 20.5267 19.5201 10.7599 6.83325 5.61659
2013  7 1  0 0 1 -1 -1 87  14.4632 21.1879 8.86339 11.5589 10.2501 10.5723 5.69284 4.41125
2014  7 1  0 0 1 -1 -1 96  10.4586 21.7066 23.3224 9.10924 8.87265 8.62098 8.44202 5.46755
2015  7 1  0 0 1 -1 -1 109  34.9812 13.9524 19.7371 16.671 5.7341 5.91945 5.90949 6.09514
2016  7 1  0 0 1 -1 -1 117  10.3902 49.4476 14.4116 16.2899 11.1335 5.64666 4.47475 5.20572
2017  7 1  0 0 1 -1 -1 120  12.0214 16.0364 50.2756 13.4535 11.1326 8.60701 4.17826 4.2952
2018  7 1  0 0 1 -1 -1 112  13.8706 18.9452 16.2591 37.4516 8.83328 7.51147 5.52408 3.60464
2019  7 1  0 0 1 -1 -1 120  10.1854 23.6038 21.1217 18.4028 26.5254 10.9112 5.14473 4.10506
2020  7 1  0 0 1 -1 -1 185  36.5219 25.4687 38.1344 26.6013 17.6589 24.4983 10.0716 6.04499
2021  7 1  0 0 1 -1 -1 134  13.05 41.6297 19.3024 22.4037 12.7457 9.227 10.6548 4.98684
2022  7 1  0 0 1 -1 -1 109  8.89401 16.5667 35.6668 14.6067 12.9329 8.8419 5.45084 6.04011
2023  7 1  0 0 1 -1 -1 92  23.5482 10.3924 12.6617 21.1484 7.74217 7.35301 5.02669 4.12748
2000  10 2  0 0 1 -1 -1 139  43.84 17.302 32.7277 16.5532 12.2973 8.8103 4.28966 3.17986
2006  10 2  0 0 1 -1 -1 169  34.7768 20.2359 32.3915 46.373 13.8847 9.54187 7.75985 4.0364
2007  10 2  0 0 1 -1 -1 153  25.9344 31.5026 19.7523 27.2191 24.0579 12.6945 6.42333 5.41589
2009  10 2  0 0 1 -1 -1 114  22.4939 32.6543 17.5394 16.7467 6.3357 6.75504 7.171 4.30402
2010  10 2  0 0 1 -1 -1 150  23.8203 28.2124 44.4831 20.087 12.1799 7.43827 6.64501 7.13406
2011  10 2  0 0 1 -1 -1 136  14.4125 23.1856 29.0991 35.8081 11.6425 9.4401 5.91737 6.49468
2012  10 2  0 0 1 -1 -1 132  33.285 13.1151 21.515 23.3569 18.6303 10.2159 6.51414 5.36768
2013  10 2  0 0 1 -1 -1 132  29.735 30.679 13.702 17.9753 13.2609 13.6044 7.34248 5.70091
2014  10 2  0 0 1 -1 -1 136  20.4057 29.8799 34.1859 13.37 10.7871 10.4506 10.2634 6.65733
2015  10 2  0 0 1 -1 -1 132  54.1486 15.0576 22.0219 19.1473 5.33194 5.36991 5.37372 5.5491
2016  10 2  0 0 1 -1 -1 139  17.3636 57.2594 17.7509 20.2311 11.1564 5.59975 4.45224 5.18659
2017  10 2  0 0 1 -1 -1 146  20.8556 18.9576 61.7076 16.4935 11.0743 8.50473 4.14173 4.2649
2018  10 2  0 0 1 -1 -1 126  21.9474 20.2731 18.1521 42.8801 8.09981 6.60474 4.86328 3.17951
2019  10 2  0 0 1 -1 -1 145  18.4579 29.2133 27.1654 22.5326 27.0685 11.1046 5.2576 4.20015
2020  10 2  0 0 1 -1 -1 132  36.6064 17.3003 26.7516 18.8399 9.9343 13.5956 5.60123 3.37059
2021  10 2  0 0 1 -1 -1 130  18.0814 39.7034 19.255 22.6525 10.3573 7.39407 8.54929 4.00704
2022  10 2  0 0 1 -1 -1 130  15.0598 19.3531 43.8534 17.9289 13.1826 8.95541 5.53076 6.13599
2023  10 2  0 0 1 -1 -1 115  38.6677 11.7998 14.9634 25.7333 7.71579 7.1723 4.91013 4.03752
-9999  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
0 #_Use_MeanSize-at-Age_obs (0/1)
#
0 #_N_environ_variables
# -2 in year will subtract mean for that env_var; -1 will subtract mean and divide by stddev (e.g. Z-score)
#_year variable value
#
# Sizefreq data. Defined by method because a fleet can use multiple methods
0 # N sizefreq methods to read (or -1 for expanded options)
#
0 # do tags (0/1)
#
0 #    morphcomp data(0/1) 
#  Nobs, Nmorphs, mincomp
#_year, seas, type, partition, Nsamp, datavector_by_Nmorphs
#
0  #  Do dataread for selectivity priors(0/1)
#_year, seas, fleet, age/size, bin, selex_prior, prior_sd
# feature not yet implemented
#
999

