///
/// Process 2 Data formation SSM 2015
///

frame create ssm15
frame change ssm15
cd 
use "SSM2015_v070.dta" ,clear

///////////////////////////////////////
**# 1 Parents' stratification

//// 1.1 Parents' Education
capture drop *edu13
recode q22_a q22_b (11=10) (12=11) (13=12) (14=13), copyrest gen(fedu13 medu13) 


						
//// 1.2 Parents' Job
local alp "a b c d e"
foreach x of local alp {
	generate  fjob`x' = q21_1_`x'
}
foreach x of local alp {
	generate  mjob`x' = q21_3_`x'
}
recode fjoba (6=3)(7=6)(8=7)(9=8)(10=9)(11=10)(12 13 14 =11), copyrest
recode mjoba (6=3)(7=6)(8=7)(9=8)      (11=10)              , copyrest
gen mom15job = q21_3
 
/////////////////////////////////////////
**# 2 Respodents' background

//// 2.1 Sex, Cohort, Siblings
gen sex = q1_1
gen cohort  = 2015 - q1_2_5
gen sibs = q10_5 /*siblings*/





//////////////////////////////////////////////
**# 3. Respondents' Education (higher education)

//// 3.1 Educational Attainment

//// 3.2 First transition on post-secondary education
capture drop high*
generate high1 = q20_1_d_2

replace high1=2 if high1>= 100 & high1<2000  /*National, Public*/ 
replace high1=4 if high1>=2000 & high1<2955  /*Private*/ 
replace high1=5 if q20_1==8			/*JrCol*/
replace high1=6 if q20_1==7			/*Tech prof*/
replace high1=7 if edssmx==5 /* no transition*/

///The technical collage and institutions out of law
replace high1=8 if q20_1 ==9

///Regard those who don't answer the name of institution as National B or Private B or Jr.col.
replace high1=2 if (high1==9990 | high1==99999) & q20_1==10 & q20_1_c<=2
replace high1=4 if (high1==9990 | high1==99999) & q20_1==10 & q20_1_c==3

///generate "prestidgious institution and faculty"
gen pres = q20_1_d_2
recode pres	100 132 168 172 180 192 220 224 236 260 280 280 292 296 304	 	///
			332 336 368 384 408 1148 1149 1152 1204 1224 1236 1240 1248	=1	/// 
			2190 2193 2197 2205 2257 2259 2299 2547 2552 2614 2669 			///
			2223 2235 2249 2254 2261 									=3	///
			else =0
replace pres=1 if q20_1_d_1>=171 & q20_1_d_1<=173 & q20_1_c<=2   /*medical & phermacy*/
replace pres=3 if q20_1_d_1>=171 & q20_1_d_1<=173 & q20_1_c==3
replace high1=pres if pres==1 | pres ==3

replace high1=. if high1>=9


drop pres
/////////////////////////////////////////////////


gen syear = 2015
keep fedu13 - syear edssmx 
label data "SSM2015_edit"


save "ssm2015_edit.dta"	 ,replace
