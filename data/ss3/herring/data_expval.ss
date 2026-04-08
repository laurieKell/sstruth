#V3.30.23.2;_safe;_compile_date:_Apr 17 2025;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:_https://groups.google.com/g/ss3-forum_and_NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:_https://nmfs-ost.github.io/ss3-website/
#_Source_code_at:_https://github.com/nmfs-ost/ss3-source-code

#_Start_time: Tue Apr  7 13:35:50 2026
#_expected_values
#C data file for Herring SD 30-31
#C file created using an r4ss function
#C file write time: 2026-04-07  12:47:36
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
-999 1 1 21926.9 0.2
1903 1 1 29091.4 0.1
1904 1 1 34661.7 0.1
1905 1 1 35934.9 0.1
1906 1 1 36179.4 0.1
1907 1 1 36632.5 0.1
1908 1 1 36665.5 0.1
1909 1 1 37581.9 0.1
1910 1 1 37394.7 0.1
1911 1 1 37643.9 0.1
1912 1 1 37954.4 0.1
1913 1 1 39369.8 0.1
1914 1 1 41126.5 0.1
1915 1 1 40904.7 0.1
1916 1 1 41011.7 0.1
1917 1 1 41714.4 0.1
1918 1 1 41287.9 0.1
1919 1 1 40764.9 0.1
1920 1 1 42044.8 0.1
1921 1 1 43269.8 0.1
1922 1 1 43607.5 0.1
1923 1 1 43136.4 0.1
1924 1 1 43992.5 0.1
1925 1 1 44789.1 0.1
1926 1 1 44703.1 0.1
1927 1 1 45438.1 0.1
1928 1 1 46989 0.1
1929 1 1 47530.8 0.1
1930 1 1 47113.3 0.1
1931 1 1 48919.7 0.1
1932 1 1 50359.4 0.1
1933 1 1 50906.7 0.1
1934 1 1 51594.1 0.1
1935 1 1 52627.1 0.1
1936 1 1 55083.4 0.1
1937 1 1 55606.8 0.1
1938 1 1 56362.1 0.1
1939 1 1 57968 0.1
1940 1 1 59377.7 0.1
1941 1 1 59917.2 0.1
1942 1 1 62524.4 0.1
1943 1 1 63949.3 0.1
1944 1 1 66039.8 0.1
1945 1 1 70247.3 0.1
1946 1 1 73371.9 0.1
1947 1 1 76139.6 0.1
1948 1 1 77983.8 0.1
1949 1 1 79952.7 0.1
1950 1 1 83510.8 0.1
1951 1 1 88941.5 0.1
1952 1 1 94222.9 0.1
1953 1 1 100757 0.1
1954 1 1 105293 0.1
1955 1 1 111327 0.1
1956 1 1 118865 0.1
1957 1 1 124492 0.1
1958 1 1 133189 0.1
1959 1 1 140129 0.1
1960 1 1 147425 0.1
1961 1 1 151951 0.1
1962 1 1 164006 0.1
1963 1 1 172537 0.1
1964 1 1 180761 0.1
1965 1 1 191926 0.1
1966 1 1 196845 0.1
1967 1 1 206536 0.1
1968 1 1 212545 0.1
1969 1 1 222925 0.1
1970 1 1 234894 0.1
1971 1 1 238786 0.1
1972 1 1 246884 0.1
1973 1 1 251943 0.1
1974 1 1 258236 0.05
1975 1 1 255940 0.05
1976 1 1 255218 0.05
1977 1 1 261240 0.05
1978 1 1 256923 0.05
1979 1 1 260295 0.05
1980 1 1 255454 0.05
1981 1 1 252962 0.05
1982 1 1 250814 0.05
1983 1 1 247176 0.05
1984 1 1 239043 0.05
1985 1 1 238681 0.05
1986 1 1 231340 0.05
1987 1 1 227085 0.05
1988 1 1 225217 0.05
1989 1 1 210962 0.05
1990 1 1 211063 0.05
1991 1 1 208218 0.05
1992 1 1 195941 0.05
1993 1 1 190836 0.05
1994 1 1 186041 0.05
1995 1 1 178451 0.05
1996 1 1 174228 0.05
1997 1 1 170266 0.05
1998 1 1 166601 0.05
1999 1 1 161909 0.05
2000 1 1 161961 0.05
2001 1 1 158457 0.05
2002 1 1 151119 0.05
2003 1 1 149891 0.05
2004 1 1 146490 0.05
2005 1 1 143670 0.05
2006 1 1 137737 0.05
2007 1 1 136770 0.05
2008 1 1 140097 0.05
2009 1 1 137694 0.05
2010 1 1 135369 0.05
2011 1 1 133658 0.05
2012 1 1 132823 0.05
2013 1 1 129447 0.05
2014 1 1 126040 0.05
2015 1 1 124389 0.05
2016 1 1 122985 0.05
2017 1 1 119906 0.05
2018 1 1 117754 0.05
2019 1 1 117140 0.05
2020 1 1 113047 0.05
2021 1 1 107306 0.05
2022 1 1 99379.9 0.05
2023 1 1 98564.1 0.05
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
2000 10 2 56522.5 0.03 #_orig_obs: 56531.1 Acoustics
2006 10 2 64575.5 0.03 #_orig_obs: 62701.3 Acoustics
2007 10 2 61762.2 0.03 #_orig_obs: 63565.8 Acoustics
2009 10 2 69022.3 0.03 #_orig_obs: 70049.2 Acoustics
2010 10 2 63685.2 0.03 #_orig_obs: 63815.3 Acoustics
2011 10 2 51812.5 0.03 #_orig_obs: 51566.4 Acoustics
2012 10 2 51359.3 0.03 #_orig_obs: 49450.9 Acoustics
2013 10 2 52736.9 0.03 #_orig_obs: 51666.3 Acoustics
2014 10 2 50426.9 0.03 #_orig_obs: 49743.8 Acoustics
2015 10 2 66297.4 0.03 #_orig_obs: 64895.6 Acoustics
2016 10 2 65599.5 0.03 #_orig_obs: 68559.2 Acoustics
2017 10 2 62318.9 0.03 #_orig_obs: 62937.5 Acoustics
2018 10 2 58618.8 0.03 #_orig_obs: 60550.1 Acoustics
2019 10 2 54944.7 0.03 #_orig_obs: 55435 Acoustics
2020 10 2 56290.7 0.03 #_orig_obs: 58355.5 Acoustics
2021 10 2 53696.1 0.03 #_orig_obs: 51370.6 Acoustics
2022 10 2 51544.2 0.03 #_orig_obs: 51324.8 Acoustics
2023 10 2 66188.7 0.03 #_orig_obs: 66126.7 Acoustics
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
1974  7 1  0 0 1 -1 -1 800  121.232 159.269 119.155 130.235 62.0126 51.2458 59.0903 97.7605
1975  7 1  0 0 1 -1 -1 800  106.061 165.301 155.987 104.35 89.6975 57.246 48.6466 72.7107
1976  7 1  0 0 1 -1 -1 800  179.185 134.854 148.271 115.285 64.9061 61.713 43.7682 52.0177
1977  7 1  0 0 1 -1 -1 800  113.203 233.96 125.972 114.635 74.4429 51.337 44.3372 42.1124
1978  7 1  0 0 1 -1 -1 800  121.015 146.822 217.367 102.256 75.5047 58.4264 38.4544 40.1547
1979  7 1  0 0 1 -1 -1 800  91.8313 157.522 150.614 176.755 73.5736 61.7141 47.0291 40.9603
1980  7 1  0 0 1 -1 -1 800  156.358 98.7592 145.116 128.294 116.679 67.3285 45.4054 42.06
1981  7 1  0 0 1 -1 -1 800  238.78 151.665 79.2088 101.605 74.9458 73.3846 42.9827 37.4283
1982  7 1  0 0 1 -1 -1 800  173.435 242.912 124.553 62.1189 62.0374 52.3847 47.3392 35.22
1983  7 1  0 0 1 -1 -1 800  138.26 186.769 218.497 92.5135 40.7542 44.2264 39.2035 39.7771
1984  7 1  0 0 1 -1 -1 800  189.886 150.134 150.951 151.447 56.9619 33.7954 32.1867 34.6381
1985  7 1  0 0 1 -1 -1 800  154.987 213.031 124.075 113.109 92.9827 49.6225 24.1 28.0933
1986  7 1  0 0 1 -1 -1 800  77.5508 210.289 201.249 104.521 76.9018 69.6318 35.2284 24.6295
1987  7 1  0 0 1 -1 -1 800  174.147 103.388 189.539 144.05 65.6193 53.4815 43.555 26.2193
1988  7 1  0 0 1 -1 -1 800  66.2499 239.839 106.624 157.459 98.9668 58.9731 38.3339 33.5555
1989  7 1  0 0 1 -1 -1 800  116.003 93.3161 230.499 99.9377 106.51 78.5751 41.5062 33.6525
1990  7 1  0 0 1 -1 -1 800  154.415 169.151 92.4781 167.862 63.2679 69.0969 50.5507 33.1781
1991  7 1  0 0 1 -1 -1 800  106.136 219.726 161.286 83.5492 100.813 53.4747 41.6197 33.3954
1992  7 1  0 0 1 -1 -1 800  147.526 156.051 208.192 117.314 49.2922 58.9478 32.7666 29.9107
1993  7 1  0 0 1 -1 -1 800  119.277 209.998 146.233 151.57 72.5262 39.777 35.6991 24.9201
1994  7 1  0 0 1 -1 -1 800  89.9089 174.139 203.305 122.143 97.878 59.736 26.7271 26.1625
1995  7 1  0 0 1 -1 -1 800  129.977 135.229 170.579 156.959 78.5409 67.867 37.9924 22.8556
1996  7 1  0 0 1 -1 -1 800  116.718 194.221 131.347 134.766 97.3706 60.1321 40.2603 25.1849
1997  7 1  0 0 1 -1 -1 800  71.1771 189.976 202.629 113.161 87.2942 69.5785 37.8963 28.2877
1998  7 1  0 0 1 -1 -1 800  126.757 117.051 194.897 159.445 72.3008 59.3571 42.5581 27.6337
1999  7 1  0 0 1 -1 -1 800  71.5676 210.422 123.887 162.039 104.521 60.0944 37.684 29.7852
2000  7 1  0 0 1 -1 -1 800  191.137 104.637 191.571 97.4335 91.1808 66.5179 32.8508 24.672
2001  7 1  0 0 1 -1 -1 800  131.272 272.114 99.561 132.088 55.1284 52.3992 35.9241 21.5137
2002  7 1  0 0 1 -1 -1 800  135.856 175.951 242.384 79.9889 75.0065 41.2775 28.4745 21.0611
2003  7 1  0 0 1 -1 -1 800  241.061 163.957 138.307 140.981 40.073 38.3696 20.6502 16.6018
2004  7 1  0 0 1 -1 -1 800  108.742 298.504 142.346 100.317 79.657 35.6498 21.1057 13.6787
2005  7 1  0 0 1 -1 -1 800  66.8755 161.256 292.044 116.771 66.4293 57.5946 23.1606 15.869
2006  7 1  0 0 1 -1 -1 800  121.645 103.414 160.385 223.988 80.3163 53.693 38.1836 18.3757
2007  7 1  0 0 1 -1 -1 800  105.069 171.424 101.373 139.84 145.734 75.5316 35.1029 25.9256
2008  7 1  0 0 1 -1 -1 800  189.489 137.782 152.794 79.9724 81.896 88.698 43.9437 25.4251
2009  7 1  0 0 1 -1 -1 800  118.393 253.693 131.115 110.869 49.6832 52.3791 53.8041 30.0627
2010  7 1  0 0 1 -1 -1 800  92.6389 162.018 244.34 108.844 73.2997 43.7863 37.0113 38.0622
2011  7 1  0 0 1 -1 -1 800  62.7727 142.869 172.111 206.325 80.6033 61.8334 35.989 37.4971
2012  7 1  0 0 1 -1 -1 800  152.152 87.2259 134.663 144.745 134.896 72.8418 41.6849 31.7906
2013  7 1  0 0 1 -1 -1 800  137.675 206.231 86.6621 107.507 91.5114 91.2471 46.7533 32.4132
2014  7 1  0 0 1 -1 -1 800  89.1926 193.416 206.198 78.1587 71.0281 65.5226 60.3014 36.1829
2015  7 1  0 0 1 -1 -1 800  258.492 105.909 153.925 126.97 41.9587 40.2437 36.9097 35.5919
2016  7 1  0 0 1 -1 -1 800  67.6545 339.885 101.319 116.991 78.5704 38.7962 27.4299 29.3538
2017  7 1  0 0 1 -1 -1 800  73.1808 100.745 337.274 93.2913 79.9454 61.6269 28.1592 25.7776
2018  7 1  0 0 1 -1 -1 800  88.8642 121.133 109.934 275.526 69.4152 62.3563 45.6362 27.1347
2019  7 1  0 0 1 -1 -1 800  58.587 135.534 125.615 123.433 193.619 84.0881 44.4944 34.6295
2020  7 1  0 0 1 -1 -1 800  136.201 94.6443 146.158 109.24 84.4403 131.558 58.9624 38.7967
2021  7 1  0 0 1 -1 -1 800  68.4626 219.412 103.474 127.092 77.9862 65.4156 90.9102 47.2476
2022  7 1  0 0 1 -1 -1 800  64.792 110.855 239.608 100.702 93.0778 68.9986 52.8675 69.0988
2023  7 1  0 0 1 -1 -1 800  217.391 91.018 100.565 167.278 62.1139 61.7862 49.1638 50.6837
2000  10 2  0 0 1 -1 -1 500  157.597 71.2618 117.807 56.7071 41.0575 29.7375 14.7415 11.09
2006  10 2  0 0 1 -1 -1 500  99.1805 71.017 100.387 138.642 38.7229 25.2712 18.0623 8.71793
2007  10 2  0 0 1 -1 -1 500  88.067 121.398 66.0268 85.9608 71.5059 36.926 17.2918 12.8242
2009  10 2  0 0 1 -1 -1 500  93.7254 170.271 81.4811 67.6366 23.5633 24.3413 24.9716 14.0099
2010  10 2  0 0 1 -1 -1 500  74.829 110.691 155.013 67.2166 35.3169 20.8887 17.7592 18.2857
2011  10 2  0 0 1 -1 -1 500  51.4496 100.206 110.802 131.999 39.97 29.8806 17.4674 18.2258
2012  10 2  0 0 1 -1 -1 500  125.54 61.7576 86.5813 89.0392 65.9272 35.3258 20.302 15.5265
2013  10 2  0 0 1 -1 -1 500  111.458 142.253 55.4705 65.7004 43.91 43.4126 22.2997 15.4955
2014  10 2  0 0 1 -1 -1 500  72.7341 134.336 132.483 48.1941 34.2959 31.459 29.0416 17.4564
2015  10 2  0 0 1 -1 -1 500  198.257 68.3605 90.6131 74.2029 19.0049 17.6553 16.2326 15.6734
2016  10 2  0 0 1 -1 -1 500  54.3715 229.147 63.9228 70.8861 37.0593 18.0642 12.8155 13.7339
2017  10 2  0 0 1 -1 -1 500  61.5202 70.023 216.052 57.643 38.882 29.7435 13.633 12.5029
2018  10 2  0 0 1 -1 -1 500  73.4871 83.6028 69.9513 174.073 34.4856 29.6891 21.7528 12.9583
2019  10 2  0 0 1 -1 -1 500  52.088 101.184 86.0759 76.8576 99.747 43.2135 22.9511 17.8825
2020  10 2  0 0 1 -1 -1 500  116.062 67.0383 94.9082 69.0796 41.5001 63.8361 28.6695 18.9058
2021  10 2  0 0 1 -1 -1 500  58.1812 156.309 67.6527 80.5313 38.4234 31.7468 44.1692 22.9862
2022  10 2  0 0 1 -1 -1 500  55.9076 79.6148 158.531 63.724 46.7989 34.4249 26.4251 34.5733
2023  10 2  0 0 1 -1 -1 500  173.033 60.6384 61.2845 101.081 29.3934 28.4679 22.6859 23.4155
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

