///
/// Process 4 Analysis
///

clear
frame reset

use "ssm0515_combined.dta", clear
label data "SSM2005 and 2015 combined"
note: job classifications are to be assigned
numlabel, add

recode fjc02 mjc02 ///
			 (10 20 		= 1 "I+II") 	///
			 (31 32 		= 2 "IIIab") 	///
			 (41 42 		= 3 "IVab")		///
			 (50 60 71 72	= 4 "V+VI+VIIab+IVc") ///
			 (.a .d 		= 5 "Nojob+Abs"), ///
			 gen(fegp4 megp4 ) lab(egp4lab)
			 

******* Missing values and Descriptives
mvdecode sibs ,mv(99)
capture drop trans1

capture drop miss*
misstable sum sibs fedu3  pcoh5 fegp4 sex edssm4, gen(miss) 
gen miss1 = misssibs + missfedu3 + missfegp4 + missedssm4

recode edssm4 (1=0)(2 3 4 =1) ,gen(trans1)
table (edssm4) (trans1) (sex) ,m
table (edssm4) (trans1) (sex) if miss1 ==0

***replace father's EGP by Mother's one when Missing on Father's EGP
gen mutate_egp = fegp4 if fegp4 <=4
	replace mutate_egp = megp4 if mutate_egp>4
gen mutate_edu = fedu3 if fedu3 <=3
	replace mutate_edu = medu3 if mutate_edu>3
	replace fegp4 = mutate_egp if fegp4 ==.b
	
capture drop miss*
misstable sum sibs mutate_edu  pcoh5 mutate_egp edssm4, gen(miss) 
gen miss2 = misssibs + missmutate_edu + missmutate_egp + missedssm4
table (edssm4) (trans1) (sex)  if miss2==0  


///////////////  Main Analysis ///////////
******* MALE ******
*** First transition (binomial)
quietly logit  trans1 sibs i.mutate_edu  i.pcoh5 c.pcoh5##ib4.fegp4 if sex==1
	est store logi_m1 			
	matrix MT1 = r(table)'
	matrix MT1 = MT1[1...,1..4]
	scalar MN1 = e(N)
	scalar MLL1 = e(ll)

*** Second Transition (Multinomial)	
quietly mlogit edssm4 sibs i.mutate_edu  i.pcoh5 c.pcoh5##ib4.fegp4 if sex==1 & trans1==1
	est store logi_m2
	matrix MT2 = r(table)'
	matrix MT2 = MT2[rowsof(MT2) / e(k_out)+1...,1..4]
	/// drop 0 column
	scalar MN2 = e(N)
	scalar MLL2 = e(ll)

	matrix Mtable = (MT1 \ MT2)

*** EXPORT
cd 
	putexcel set "marebuis_vol2_m",  modify 
	putexcel A1 ="MALE"
	putexcel B2 = "N="
	putexcel C2 = MN1
	putexcel D2 = MN2
	putexcel B3 = "N="
	putexcel C3 = MLL1
	putexcel D3 = MLL2
	
	putexcel A4 = matrix(Mtable),names

	
**** FEMALE ****
*** First transition (binomial)
logit  trans1 sibs i.mutate_edu  i.pcoh5 c.pcoh5##ib4.fegp4 if sex==2
	est store logi_f1 			
	matrix FT1 = r(table)'
	matrix FT1 = FT1[1...,1..4]
	scalar FN1 = e(N)
	scalar FLL1 = e(ll)
	
*** Second Transition (Multinomial)
mlogit edssm4 sibs i.mutate_edu  i.pcoh5 c.pcoh5##ib4.fegp4 if sex==2 & trans1==1
	est store logi_f2
	matrix FT2 = r(table)'
	matrix FT2 = FT2[rowsof(FT2) / e(k_out)+1...,1..4]
	/// 基準カテゴリの0を行列から除く
	scalar FN2 = e(N)
	scalar FLL2 = e(ll)

	matrix Ftable = (FT1 \ FT2)

*** EXPORT
	putexcel set "marebuis_vol2_f",  modify 
	putexcel A1 ="FEMALE"
	putexcel B2 = "N="
	putexcel C2 = FN1
	putexcel D2 = FN2
	putexcel B3 = "N="
	putexcel C3 = FLL1
	putexcel D3 = FLL2
	
	putexcel A4 = matrix(Ftable),names


