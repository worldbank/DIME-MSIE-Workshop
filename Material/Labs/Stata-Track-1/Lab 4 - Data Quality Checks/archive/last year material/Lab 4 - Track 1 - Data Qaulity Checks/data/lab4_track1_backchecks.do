/*******************************************************************************
*		
*		Project:
*			DIME Field Coordinator Training
*			Lab 4 - Track 1
*			Exercise 3
*
********************************************************************************			
	Written by:	Laura Costica, DECIE
********************************************************************************/

	clear 
	set more off
			
	global lab4  			"C:\Users\wb503680\Downloads\MyThes-1\Lab 4 - Real-time Data Quality Checks\Lab 4 - Real-time Data Quality Checks\Track 1\"

	cd "$lab4/bcstats"

	* ENUMERATOR, TEAMS, BACK CHECKERS
	* Enumerator variable
	local enum "enum_id"
	* Enumerator Team variable
	local enumteam "hhidteam"
	* Back checker variable
	local  bcer "tl_id"

	* DATASETS: first, compare main study participants only
	* The original dataset that will be used for the comparison
	local orig_dta "$lab4/data/baseline.dta"
	* The backcheck dataset that will be used for the comparison
	local bc_dta "$lab4/data/backcheck.dta"

	* Unique ID*
	local id "serial"

	**********************************************************************
	* VARIABLE LISTS
	**********************************************************************

	* 	Type 1 variables: Check whether the surveyors are a) performing the interview and 
	*	b) with the right respondent. These are questions that should never ever change,
	*	regardless of interviewer, location or time of day. 
	*
	* 	Type 2 variables: Assess how well the surveyors are administering the survey
	*	The responses to these questions are unlikely to change, but they are questions
	*	where the team will be tempted to cut corners. These may have been difficult 
	*	for surveyors to understand or to administer due to complexity or sensitivity.
	*
	*	Type 3 variables: Check the stability of your measures on key outcomes
	*	These are questions where we want to understand the stability of the measure, where
	*	we’re concerned about whether we’re asking the question in the right way.
	*	Or we may be concerned that respondents change their answers because they don’t know. 
	*	They are likely to be key outcomes, interaction or stratification variables that are integral to 
	*	understanding the intervention. These may or may not change over time. If they change over time, 
	*	you are interested in understanding those trends. These questions aim to understand survey, 
	*	not surveyor, performance.
	*	
	*	VARIABLES:
	*	mod1female - gender
	*	mod1age - How old were you at your last birthday?
	*	mod1school_attend - Are you currently attending school?
	*	mod1school_level - attending school: what level?
	*	mod1school_class_primary - attending school at primary level: class?
	*	mod1school_class_secondary - attending school at secondary level: class?
	*	mod1ever_attend_school - Have you ever attended school?
	*	mod1highest_school_level - attended school: level
	*	mod1highest_class_primary - attended school at primary level: class?
	*	mod1highest_class_secondary - attended school at secondary level: class?
	*	mod1workforpay_1yr - Did you do any work that was paid in the past 1 year?
	*	mod2hivreduce - What can a person do to reduce their chances of getting HIV? 
	*	mod2hivexpo - Suppose someone thinks that [he/she] may have been exposed to HIV, for example through sex or through a contaminated
	*   	blade. Suppose this person immediately goes for an HIV test and it is negative. Can this person be sure that [he/she] has NOT been
	*		infected with HIV?
	*	mod2test_sleeparound - Suppose I say:  “If a young person of your age goes to get tested for HIV, it means that he/she has been 
	*		sleeping around. “Do you agree or disagree? Strongly or just [agree/disagree]?  	
	*	mod2test_sleeparound_com - If you picked 20 people of your age from your community, how many will agree that “If a young person
	*		of your age  goes to get tested for HIV, it means that he/she has been sleeping around. “?
	*	mod3agreement_bringcondom - If a woman brings a condom, will her partner think that she is not serious and lose respect for her?
	*	mod3date - Many young people have a boyfriend or girlfriend. Are you dating someone?
	*	mod2spec_drug - Have you heard about special drugs that people infected with HIV can get from a doctor or a nurse to help them 
	*		live longer? IF YES: Do you remember how they are called?
	*	mod2famsecret - If a member of your family got HIV, would you want it to remain a secret?
	*	Main text for the following 3 questions: 
	*	I will read you a list of statements, and I would like you to tell me whether you strongly agree, agree, disagree or strongly 
	*		disagree with the statement. There are no right or wrong answers, just tell me what you think.
	* 	mod7vaw_statementsman_boss - It is important for a man to show his wife or girlfriend who the boss is.  
	*	mod7vaw_fam_interv - If a man mistreats his wife or girlfriend, someone in the family should intervene.
	*	mod7vaw_friends_interv -If a man mistreats his wife or girlfriend, someone outside of the family, 
	*		like friends or neighbours, should intervene.
	
	*	Some examples are provided. Categorize the rest of the variables into Type 1, Type 2 and Type 3
	
	local t1vars "mod1female mod1school_attend"

	local t2vars "mod2test_sleeparound_com mod3date"

	local t3vars "mod2famsecret mod7vaw_statementsman_boss"


	* Variables from the backcheck that you want to see in the outputted .csv, but not compare.
	* 	reached	- 1 if tl_leader has been able to talk to the respondent 
	*	contacted - 1 if enumerator contacted the respondent
	*	interviewed - 1 if enumerator interviewed the respondent
	*	enum_approach - how was the enumerator during the interview
	
	local keepbc "reached contacted interviewed enum_approach"

	* Variables from the original survey that you want to see in the outputted .csv, but not compare.
	local keepsurvey "enum_name hhidlocation"

	**********************************************************************
	* Compare the backcheck and original data
	**********************************************************************
	* Run the comparison
	* Make sure to specify the enumerator team and the backchecker vars.
	* Select the options that you want to use, i.e. okrate, okrange, full, filename
	* This is the code that we think will be the most applicable across projects.
	* Feel free to edit and add functionality.

	* Log your results.
	
	cap log close
	log using "$lab4/bcstats/analysis_report", replace


	bcstats, surveydata(`orig_dta') bcdata(`bc_dta') id(`id') okrange(mod2test_sleeparound_com [-4, 4]) t1vars(`t1vars') enumerator(`enum') enumteam(`enumteam') backchecker(`bcer') t2vars(`t2vars') t3vars(`t3vars') keepbc(`keepbc') keepsurvey(`keepsurvey') lower nosymbol trim filename(bc_diffs.dta) replace dta 

	log close

