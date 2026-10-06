///
/// Process 1 Data formation SSM 2015
///

frame create ssm05
frame change ssm05

cd 
use "SSM2005.dta", clear


///////////////////////////////////////
**# 1 Parents' stratification

//// 1.1 Parents' Education
capture drop *edu13
clonevar fedu13 = q21_1
clonevar medu13 = q21_2



//// 1.2 Parents' Job
local alp "a b c d e"
foreach x of local alp {
	generate  fjob`x' = q23_1`x'
}
foreach x of local alp {
	generate  mjob`x' = q23_3`x'
}
recode mjoba 9=10 10=11, copyrest
clonevar mom15job = q23_3

/////////////////////////////////////////
**# 2 Respodents' background

//// 2.1 Sex, Cohort, Siblings
clonevar sex = q01_1
generate cohort  = q01_2yw +1900
clonevar sibs = q09f /*siblings*/
	{
	for num  1/9  : recode q10_0X (1=1)(2=0) ,gen( propertyX) 
	for num 10/19 : recode q10_X (1=1)(2=0) ,gen( propertyX) 
	}

//////////////////////////////////////////////
**# 3. Respondents' Education (higher education)

//// 3.1 Educational Attainment
capture drop edssmx q19_*d

forvalues x = 1/3 {
	gen q19_`x'd = q19_`x' 
	replace q19_`x'd =0 if q19_`x'd ==.
}
gen ed3_fs = q19_1d *100 + q19_2d *10 + q19_3d

clonevar edssmx	=ed_ssm
recode   edssmx 1=4 2=5 3=9 4=8 5=10 6=11 8 9=.

/////*Regard as JihgSchl who enter Tech after JrHiSchl */
replace edssmx = 5 if (ed_ssm == 1 &    ///
                       ed3_fs == 700 & ///
					   q19b_wa1 == 18) 
/////*Regard as Tech who enter Tech after dropping out HighSchl*/
replace edssmx = 7 if ed_ssm == 2  &  ///
					 (ed3_fs == 700 | ed3_fs ==770 | ed3_fs ==780 | ed3_fs==787)

//// 3.2 First transition on post-secondary education
capture drop high*
clonevar high1 = q19d2_1

replace high1=2 if high1>= 1   & high1< 100  /*National, Public*/ 
replace high1=4 if high1>= 101 & high1<=441  /*Private*/ 
replace high1=5 if q19_1==4         /*JrCol*/
replace high1=6 if q19_1==7			/*Tech prof*/
replace high1=7 if edssmx==5
replace high1=. if edssmx==4


replace high1=7 if (q17_2==1) & /// no transition
	q17_3==2 & q17_4==2 & q17_5==2 & q17_6==2 & q17_7==2

///Regard those who don't answer the name of institution as National B or Private B or Jr.col.
replace high1=2 if high1==999 & q19_1==5 & (q19c_1==1 |q19c_1==2)
replace high1=4 if high1==999 & q19_1==5 &  q19c_1==3

///The technical collage and institutions out of law
replace high1=8 if high1==998 & q19_1 ==3
replace high1=. if high1>=9

///generate "prestidgious institution and faculty"
gen pres = q19d2_1
recode pres 1 7 13 18 20 24 28 32 38 44 46 47 49 54 55 63 66	=1	/// 
			201 205 209 218 233 245 254 261 264 339 342 362 363 =3	///
			else =0
replace pres=1 if q19d1_1>=171 & q19d1_1<=173 & q19c_1<=2   /*medical & phermacy*/
replace pres=3 if q19d1_1>=171 & q19d1_1<=173 & q19c_1==3
replace high1=pres if pres==1 | pres ==3

drop pres

drop q19_*d ed3_fs
/////////////////////////////////////////////////

gen syear = 2005

keep fedu13 - high1 syear
label data "ssm2005_edit"

save "ssm2005_edit.dta"	 ,replace
