<<<<<<< HEAD
///
/// Process 3 Combine two dataset 
///

frame create combined
frame change combined

clear 
append using "ssm2005_edit.dta" "ssm2015_edit.dta"

gen id = _n ,before(fedu13)
	label var id "ID"

/************* label variables	*************/
label var syear "dataset"
label var cohort "本人出生年"	
label variable high1 "Postsecondary Transition 7 categories+ "

label variable fedu13 "education patris"
label variable medu13 "education matris"

label define highcate ///
				1"NationalA" 2"NationalB" 3"PrivateA" 4"PrivateB" ///
				5"Jrcol" 6"Tech" 7"Leave" 8"Spcial Tech"
	label values high1 highcate

label define parentsedu ///
				 1 "old elementary" 	2 "old posterementary" 	3 "old JrHigh" 4 "old Vocational"	///
				 5 "old normal"	6 "old high"			7 "old univ."	///
				 8 "JrHigh"		9 "High"			10 "TechJrcol"				///
				 11 "Univ."		12 "graduate schl"		13 "other"		99 "DKNA"
	label values fedu13 medu13 parentsedu

label data "SSM2005 and 2015 combined"
note: job classifications are to be assigned

numlabel, add


//////////////////////////////////////////////////////
**#      create EGP 8 class on parents' jobs	//////
//////////////////////////////////////////////////////
/// ref Takenoshita et al. (2008) in Shizuoka Univ.

capture label drop egp
label def egp 10"I" 20"II" 31"IIIa" 32"IIIb" 41"IVa" 42"IVb" 50"V" 60"VI" 71"VIIa" 72"IVc+VIIb" ///
				.d"NoJob" .a"Absent" .b"Unknown"

capture drop *jc*				
local fm "f m"
foreach x of local fm {
	generate `x'jc01=`x'jobd
	recode  `x'jc01   ///
	  (501/504 507/510 517/519 524 525/535 536 545/553 610	=10) ///
	  (505/506 511/516 520/523 537/544 608/609 615			=20) /// 
	  (554/565 586 590 593/598 611 616/619					=31) ///
	  (566/577 584 587 589 591								=32) ///
	  (684													=50) ///
	  (581 579 606 623 628 631 633 635/642 644 647 651 		 	 ///
	   654/656 658 660/666 670/671 673/675 677/681 668		=60) ///
	  (578 580 582/583 585 588 592 607 612/614 620/622 			 ///
	  624/627 629/630 632 634 643 645/646 648/650 652/653 		 ///
	  657 659 667 669 672 676 682/683 685/688				=71) ///
	  (599/605												=72) ///
	  (689/691												=.b) ///
		///
	  (701=32)(702=60)(703=20)(704=71)(705=.b)(706=71)			 ///  
	  (801=32)(802=71)(805=71)(806=71) //* 2005 2015 new code*//

	generate `x'jc02 = `x'jc01
		replace `x'jc02=10 if (`x'joba==1 | `x'joba==6) & `x'jobc>=5 & `x'jobc<=10
		replace `x'jc02=41 if (`x'joba==1 | `x'joba==6) & `x'jobc>=2 & `x'jobc<=4 &((`x'jc02>=31 & `x'jc02<=71) | `x'jobd==707)
		replace `x'jc02=42 if (`x'joba==1 | `x'joba==6) & `x'jobc==1 &             ((`x'jc02>=31 & `x'jc02<=71) | `x'jobd==707)
		replace `x'jc02=20 if  `x'jobd>=548 & `x'jobd<=553 & `x'joba>=2 & `x'joba<=5 & `x'jobc>=2 & `x'jobc<=4
		replace `x'jc02=10 if  `x'jc02>=31 & `x'jc02<=71 & `x'jobe>=4 & `x'jobe<=6 & `x'jobc>=5 & `x'jobc<=10 & `x'joba>=2 & `x'joba<=5
		replace `x'jc02=20 if  `x'jc02>=31 & `x'jc02<=71 & `x'jobe>=4 & `x'jobe<=6 & `x'jobc>=2 & `x'jobc<=4  & `x'joba>=2 & `x'joba<=5
		replace `x'jc02=20 if  `x'jc02>=31 & `x'jc02<=32 & `x'jobe>=2 & `x'jobe<=3
		replace `x'jc02=50 if  `x'jc02>=60 & `x'jc02<=71 & `x'jobe>=2 & `x'jobe<=3
		replace `x'jc02=71 if  `x'jobd>=596 & `x'jobd<=597 & `x'jobc~=10

	replace `x'jc02 = .d if `x'joba==10	/*Nojob*/
	replace `x'jc02 = .a if `x'joba==11	/*Absent*/	
	replace `x'jc02 = .b if `x'jc02>=701 & `x'jc02<=9999	/*Unknown*/ 
}
drop *jc01 

label values *jc02 egp

label variable fjc02  "EGP patris" 
label variable mjc02 "EGP matris"


//////////////////////////////////////
**# 	Education Parents
//////////////////////////////////////

captur drop fedu3 medu3
recode fedu13 medu13	(1 2 8 			= 1 "compulsory") 	///
						(3 4 5 9		= 2 "secondary") 	///
						(6 7 10 11 12 	= 3 "postsecondary") ///
						(88				=.a "DK(Absent)")	/// 
						(99 999			=.b "Unknown") 		///
						(13				=.c "others") ,		///
						gen(fedu3 medu3) label(educat3)

replace fedu3 = .a if fjc02 ==.a & fedu3 > 3
replace medu3 = .a if mjc02 ==.a & medu3 > 3

capture label drop edu3
label variable fedu3 "edu3 patris" 
label variable medu3 "edu3 matris"


/********************************
	COHORT decade
*********************************/
gen coh_dp = floor((cohort - 1900)/10)

capture drop pcoh*
recode cohort (1935/1950=4 "35-50")(1951/1960=5 "51-60")	///
			  (1961/1970=6 "61-70")(1971/1980=7 "71-80")	///
			  (1981/1995=8 "81-95")	, gen(pcoh5) lab(pcohlab)



capture drop edssm4
recode edssmx (4=1 "Jrhigh")(5=2 "High") ///
			  (7 8 9=3 "Jrcol/Tech")	 ///
			  (10 11=4 "Higher") (else=.) , gen(edssm4) lab(edlab4)
			  
			  
save  "ssm0515_combined.dta" , replace
=======
///
/// Process 3 Combine two dataset 
///

frame create combined
frame change combined

clear 
append using "ssm2005_edit.dta" "ssm2015_edit.dta"

gen id = _n ,before(fedu13)
	label var id "ID"

/************* label variables	*************/
label var syear "dataset"
label var cohort "本人出生年"	
label variable high1 "Postsecondary Transition 7 categories+ "

label variable fedu13 "education patris"
label variable medu13 "education matris"

label define highcate ///
				1"NationalA" 2"NationalB" 3"PrivateA" 4"PrivateB" ///
				5"Jrcol" 6"Tech" 7"Leave" 8"Spcial Tech"
	label values high1 highcate

label define parentsedu ///
				 1 "old elementary" 	2 "old posterementary" 	3 "old JrHigh" 4 "old Vocational"	///
				 5 "old normal"	6 "old high"			7 "old univ."	///
				 8 "JrHigh"		9 "High"			10 "TechJrcol"				///
				 11 "Univ."		12 "graduate schl"		13 "other"		99 "DKNA"
	label values fedu13 medu13 parentsedu

label data "SSM2005 and 2015 combined"
note: job classifications are to be assigned

numlabel, add


//////////////////////////////////////////////////////
**#      create EGP 8 class on parents' jobs	//////
//////////////////////////////////////////////////////
/// ref Takenoshita et al. (2008) in Shizuoka Univ.

capture label drop egp
label def egp 10"I" 20"II" 31"IIIa" 32"IIIb" 41"IVa" 42"IVb" 50"V" 60"VI" 71"VIIa" 72"IVc+VIIb" ///
				.d"NoJob" .a"Absent" .b"Unknown"

capture drop *jc*				
local fm "f m"
foreach x of local fm {
	generate `x'jc01=`x'jobd
	recode  `x'jc01   ///
	  (501/504 507/510 517/519 524 525/535 536 545/553 610	=10) ///
	  (505/506 511/516 520/523 537/544 608/609 615			=20) /// 
	  (554/565 586 590 593/598 611 616/619					=31) ///
	  (566/577 584 587 589 591								=32) ///
	  (684													=50) ///
	  (581 579 606 623 628 631 633 635/642 644 647 651 		 	 ///
	   654/656 658 660/666 670/671 673/675 677/681 668		=60) ///
	  (578 580 582/583 585 588 592 607 612/614 620/622 			 ///
	  624/627 629/630 632 634 643 645/646 648/650 652/653 		 ///
	  657 659 667 669 672 676 682/683 685/688				=71) ///
	  (599/605												=72) ///
	  (689/691												=.b) ///
		///
	  (701=32)(702=60)(703=20)(704=71)(705=.b)(706=71)			 ///  
	  (801=32)(802=71)(805=71)(806=71) //* 2005 2015 new code*//

	generate `x'jc02 = `x'jc01
		replace `x'jc02=10 if (`x'joba==1 | `x'joba==6) & `x'jobc>=5 & `x'jobc<=10
		replace `x'jc02=41 if (`x'joba==1 | `x'joba==6) & `x'jobc>=2 & `x'jobc<=4 &((`x'jc02>=31 & `x'jc02<=71) | `x'jobd==707)
		replace `x'jc02=42 if (`x'joba==1 | `x'joba==6) & `x'jobc==1 &             ((`x'jc02>=31 & `x'jc02<=71) | `x'jobd==707)
		replace `x'jc02=20 if  `x'jobd>=548 & `x'jobd<=553 & `x'joba>=2 & `x'joba<=5 & `x'jobc>=2 & `x'jobc<=4
		replace `x'jc02=10 if  `x'jc02>=31 & `x'jc02<=71 & `x'jobe>=4 & `x'jobe<=6 & `x'jobc>=5 & `x'jobc<=10 & `x'joba>=2 & `x'joba<=5
		replace `x'jc02=20 if  `x'jc02>=31 & `x'jc02<=71 & `x'jobe>=4 & `x'jobe<=6 & `x'jobc>=2 & `x'jobc<=4  & `x'joba>=2 & `x'joba<=5
		replace `x'jc02=20 if  `x'jc02>=31 & `x'jc02<=32 & `x'jobe>=2 & `x'jobe<=3
		replace `x'jc02=50 if  `x'jc02>=60 & `x'jc02<=71 & `x'jobe>=2 & `x'jobe<=3
		replace `x'jc02=71 if  `x'jobd>=596 & `x'jobd<=597 & `x'jobc~=10

	replace `x'jc02 = .d if `x'joba==10	/*Nojob*/
	replace `x'jc02 = .a if `x'joba==11	/*Absent*/	
	replace `x'jc02 = .b if `x'jc02>=701 & `x'jc02<=9999	/*Unknown*/ 
}
drop *jc01 

label values *jc02 egp

label variable fjc02  "EGP patris" 
label variable mjc02 "EGP matris"


//////////////////////////////////////
**# 	Education Parents
//////////////////////////////////////

captur drop fedu3 medu3
recode fedu13 medu13	(1 2 8 			= 1 "compulsory") 	///
						(3 4 5 9		= 2 "secondary") 	///
						(6 7 10 11 12 	= 3 "postsecondary") ///
						(88				=.a "DK(Absent)")	/// 
						(99 999			=.b "Unknown") 		///
						(13				=.c "others") ,		///
						gen(fedu3 medu3) label(educat3)

replace fedu3 = .a if fjc02 ==.a & fedu3 > 3
replace medu3 = .a if mjc02 ==.a & medu3 > 3

capture label drop edu3
label variable fedu3 "edu3 patris" 
label variable medu3 "edu3 matris"


/********************************
	COHORT decade
*********************************/
gen coh_dp = floor((cohort - 1900)/10)

capture drop pcoh*
recode cohort (1935/1950=4 "35-50")(1951/1960=5 "51-60")	///
			  (1961/1970=6 "61-70")(1971/1980=7 "71-80")	///
			  (1981/1995=8 "81-95")	, gen(pcoh5) lab(pcohlab)



capture drop edssm4
recode edssmx (4=1 "Jrhigh")(5=2 "High") ///
			  (7 8 9=3 "Jrcol/Tech")	 ///
			  (10 11=4 "Higher") (else=.) , gen(edssm4) lab(edlab4)
			  
			  
save  "ssm0515_combined.dta" , replace
>>>>>>> ebd6294484188b0357d6c141452cab949bda669b
